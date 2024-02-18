%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICEEGBandRecord
% This function takes as a parameter the IP string to which NIC is
% listening to. It creates a socket to NIC and expects to recieve band
% info from the running EEG protocol.
% If isAscii is true, info must be a string of data
% separeted by tabs, where each sample has 7 bands of n_channels columns.
% Else if isAscii is false, info must be a matrix 7*8 of doubles + 1 double
% for timestamp each sample.
% Band power sampling rate is 10samp/s, which results from NIC class
% BandPowerExtraction. Nic has a shared instance of this class which is
% used by tcpserver, scalp and feature widgets.
%
% Input: 
% period            : number of seconds to read from the stream
% n_channels        : number of channels to read from the host
% parse_timestamps  : boolean to indicate whether timestamps will be received
% isAscii           : boolean to indicate whether the format will be in ascii or not
% host              : host to be connected to, notice that the ip can be local or
%                     remote depending on the boolean 'asServer'
% port              : port to be used. NIC2 uses port 1236 by default to run the
%                     server that provided power in band values.
% asServer          : boolean to indicate if the function works like server
%                     so waiting for a incoming connection or as client, so
%                     generating a outcoming connection to NIC2.
%
% Output: [band] A set of string cells. 
% A set contains [n_channels x bands x n_samples]
% for each band, and bands are in the following order:
% 'alpha','beta','gamma','theta','delta','custom1', 'not_used'
% 'custom1' band can be configured in NIC2 TCP settings.
%
% Author: Sergi Aregall (sergi.aregall@neuroelectrics.com)
% Update: Miguel Angel Blanco (miguelangel.blanco@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 20 Jul 2017
% Updated: 10 Aug 2017
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [band] = MatNICEEGBandRecord(period, n_channel, parse_timestamps, isAscii, host, port, asServer)
% Number of bands are always 7
n_bands = 7;

rawbytes = (n_bands*n_channel);
import java.io.*
import java.nio.*
if asServer
    sock = java.net.ServerSocket( port);
    sock = sock.accept();
    sock.setKeepAlive(true);
else
    sock = java.net.Socket(host,port);
end
ch = channels.Channels.newChannel(sock.getInputStream);

disp('Please wait...')
totalsamples = 10*period; % 1s / 100s/ms  *  period
procesedsamples = 0;
band = [];

while 1
    if isAscii
        buffsize = 6;
        
        bytes = ByteBuffer.allocate(buffsize);
        bytes.order(ByteOrder.LITTLE_ENDIAN);
        n_bytes = 0;
        while n_bytes < 6
            n_bytes = n_bytes + ch.read(bytes);
            buffsize = char(bytes.array()');
        end
        buffsize = strsplit(buffsize,'\t');
        
        bytes = ByteBuffer.allocate(str2double(buffsize(1)));
        bytes.order(ByteOrder.LITTLE_ENDIAN);
        n_bytes = 0;
        while n_bytes < str2double(buffsize(1))
            n_bytes = n_bytes + ch.read(bytes);
        end
       
        text = char(bytes.array())';
        
        bp = strsplit(text,'\t');
        data = reshape(bp(1:end-1),[n_channel,n_bands]);
        timestamp  = bp(end);
        mattimes = cell(1,n_bands);
        mattimes(:) = timestamp;
        data = vertcat(data, mattimes);
        if ~parse_timestamps
            data(end,:,:) = [];
        end
    else
        bytes = ByteBuffer.allocate(rawbytes*8);
        bytes.order(ByteOrder.LITTLE_ENDIAN);
        n_bytes = 0;
        while n_bytes < rawbytes
            n_bytes = n_bytes + ch.read(bytes);
        end
        n_bytes
        text = typecast(int8(bytes.array()), 'double' )';
        data = reshape(text, [n_channel, n_bands]);
        
        data = num2cell(data);
        if parse_timestamps
            bytes = ByteBuffer.allocate(8);
            bytes.order(ByteOrder.LITTLE_ENDIAN);
            n_bytes = 0;
            while n_bytes < 8
                n_bytes = n_bytes + ch.read(bytes);
            end
            timestamp = typecast(int8(bytes.array()), 'int64' )';

            mattimes = cell(1, n_bands);
            mattimes(:) = num2cell(timestamp);
            data = vertcat(data, mattimes);
        end
    end
    
    procesedsamples = procesedsamples + 1;
    if procesedsamples == totalsamples
        break;
    end
    
    band = cat(3,band,data);
end
sock.close;

end
%
%
