%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICEEGRecord
%
% This function connects to the COREGUI Remote Stimulation Server and
% reads the EEG signal for t number of seconds. The server
% is running on the machine where the COREGUI application runs on the port
% 1234.
%
% Input:
% period            : number of seconds to read from the stream
% n_channels        : number of channels to read from the host
% parse_triggers    : boolean to indicate whether triggers will be received
% parse_timestamps  : boolean to indicate whether timestamps will be received
% isAscii           : boolean to indicate whether the format will be in ascii or not
% host              : host to be connected to, notice that the ip can be local or
%                     remote depending on the boolean 'asServer'
% port              : port to be used
% asServer          : boolean to indicate if works like server or client
%
% Output:
% eeg: [n_channel x samples] matrix reading the EEG signal
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Update: Sergi Aregall (sergi.aregall@neuroelectrics.com)
% Update: Miguel Angel Blanco (miguelangel.blanco@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Updated: 04 Aug 2017
% Updated: 10 Aug 2017
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eeg] = MatNICEEGRecord(period, n_channel, parse_triggers, parse_timestamps, isAscii, host, port, asServer)

import java.io.*
import java.nio.*
try
    if asServer
        sock = java.net.ServerSocket( port );
        sock = sock.accept();
        sock.setKeepAlive(true);
    else
        sock = java.net.Socket(host,port);
    end
catch
    disp('Error creating socket');
    return
end

ch = channels.Channels.newChannel(sock.getInputStream);


disp('Please wait...')
totalsamples = 500*period; % 1s / 0.5s/ms  *  period
procesedsamples = 0;
eeg = [];
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
        extracols = 2;
        data = reshape(bp(1:end),[n_channel+extracols,1])';
        eeg = [eeg;data];
        procesedsamples = procesedsamples + 1
        
        if procesedsamples == totalsamples
            if ~parse_triggers
                eeg(:,end-1) = [];
            end
            if ~parse_timestamps
                eeg(:,end) = [];
            end
            break;
        end
    else
        bytes = ByteBuffer.allocate(n_channel*4);
        bytes.order(ByteOrder.LITTLE_ENDIAN);
        n_bytes = 0;
        while n_bytes < n_channel*4
            n_bytes = n_bytes + ch.read(bytes);
        end
        text = typecast(int8(bytes.array())', 'int32' );
        data = reshape(text, [n_channel, 1])';
        
        data = num2cell(data);
        if parse_triggers
            bytes = ByteBuffer.allocate(1*4);
            bytes.order(ByteOrder.LITTLE_ENDIAN);
            n_bytes = 0;
            while n_bytes < 4
                n_bytes = n_bytes + ch.read(bytes);
            end
            trigger = typecast(int8(bytes.array())', 'int32' );
            data = horzcat(data, num2cell(trigger));
        end
        if parse_timestamps
            bytes = ByteBuffer.allocate(1*8);
            bytes.order(ByteOrder.LITTLE_ENDIAN);
            n_bytes = 0;
            while n_bytes < 8
                n_bytes = n_bytes + ch.read(bytes);
            end
            timestamp = typecast(int8(bytes.array())', 'int64' );
            data = horzcat(data, num2cell(timestamp));
        end
        eeg = [eeg;data];
        procesedsamples = procesedsamples + 1
        if procesedsamples == totalsamples
            break;
        end
    end
end

sock.close;

end