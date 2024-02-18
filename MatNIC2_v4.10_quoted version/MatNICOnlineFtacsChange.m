%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICFtacsChange
%
% This function sends a request to NIC to
% change the amplitude of a given channel.
%
% Input:
% frequencyArray : Array of frequencies for every channel indicated in channel
% n_channels     : number of Channels current device
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: New Frequency is set to 0
%       -3: Error in parameters
%       -5: Error writing command to the server.
%       -6 : NIC is not doing stimulation.
%       -7 : Frequency array length does not match channel array.
%       -8 : Selected channel is not appropriate. Channel [1-32].
%       -9 : Selected amplitude is not appropriate. Frequency [0 150] Hz.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 24 Oct 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICOnlineFtacsChange (frequencyArray, n_channels, socket)

    ret = 0;
    channelArray = [ 1 : n_channels] ;
    
    % Prevent changes when not in full stimulation
    [retValue, status] = MatNICQueryStatusProtocol (socket);
    switch status
        case 'CODE_STATUS_STIMULATION_FULL'     
        otherwise
            disp('NIC is not doing stimulation.')
            ret = -6;
            return;   
    end
    
    % Validate parameters
    if( length(frequencyArray) ~= length(channelArray) )
        disp('ERROR: frequency array length does not match channel array')
        ret = -7;
        return
    end
    for i = 1:length(channelArray)
        if( (channelArray(i) < 1) || (channelArray(i) > 32) )
            disp('ERROR: Selected channel is not appropriate. Channel [1-32]')
            ret = -8;
            return
        end
        if ((frequencyArray(i) < 0) || (frequencyArray(i) > 150))
            disp('ERROR: Selected frequency is not appropriate. Frequency [0 150] Hz')
            ret = -9;
            return
        end
        
    end
    

    % Recover information for every channel
    frequencyChannelArray = zeros(1, length(channelArray) ); % Frequency for every channel
    for i = 1:length(channelArray)
        frequencyChannelArray(channelArray(i)) = frequencyArray(i); 
    end
  

    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end   
    
    % Send command ID
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        [protocolSet] = MatNICProtocolSet();
        commandId = protocolSet('CODE_COMMAND_ONLINE_FTACS_CHANGE');
        dOutputStream.writeByte( commandId );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    
    % Send parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    frequencyStr = '';
    for i = 1:length(channelArray) 
        frequencyStr = strcat(frequencyStr, num2str( frequencyChannelArray(i) ),';' );
    end
    frequencyStr = frequencyStr(1:end-1); 
    
    
    % Send frequency target
    try
        dOutputStream.writeBytes(frequencyStr);
        % The name of the template shall be ended with one of the following
        % characters:
        % '\0', '\n', '\r' so the server can know when the template name
        % finishes.
        dOutputStream.writeByte(0); % string terminator character for the NIC
                                    % to start processing the template name
        dOutputStream.flush;
    catch
        ret = -2;
        return
    end
    
end