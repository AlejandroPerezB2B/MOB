%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICOnlineAtrnsChange
%
% This function sends a request to NIC to
% change the amplitude of a given channel.
%
% Input:
% socket: The socket variable for connecting to the NIC
% amplitudeArray : new amplitude expected
% n_channels     : number of Channels current device
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1 : No connection with the host.
%       -2 : Error on sending parameters
%       -3 : Error in parameters
%       -5 : Error writing command to the server.
%       -6 : NIC is not doing stimulation.
%       -7 : Amplitude array length does not match channel array.
%       -8 : Selected channel is not appropriate. Channel [1-32].
%       -9 : Selected amplitude is not appropriate. Amplitude [0-640] uA.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 29 Jan 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICOnlineAtrnsChange(amplitudeArray, n_channels, socket)
    
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
    
    
    % Validate the parameters
    if( length(amplitudeArray) ~= length(channelArray) )
        disp('ERROR: amplitude array length does not match channel array')
        ret = -7;
        return
    end
    for i = 1:length(channelArray)
        if( (channelArray(i) < 1) || (channelArray(i) > 32) )
            disp('ERROR: Selected channel is not appropriate. Channel [1-32]')
            ret = -8;
            return
        end
        if ((amplitudeArray(i) < -640) || (amplitudeArray(i) > 640))
            disp('ERROR: Selected amplitude is not appropriate. Amplitude [0-640] uA')
            ret = -9;
            return
        end
    end
    
    % Recover information for every channel
    amplitudeChannelArray = zeros(1, length(channelArray)); 
    for i = 1:length(channelArray)
        amplitudeChannelArray(channelArray(i)) = amplitudeArray(i); 
    end    
    
    % Get Input/Output stream        
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
        commandId = protocolSet('CODE_COMMAND_ONLINE_ATRNS_CHANGE');
        dOutputStream.writeByte( commandId );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Send parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    amplitudeStr = '';
    for i = 1:length(channelArray) 
        amplitudeStr = strcat(amplitudeStr, num2str( amplitudeChannelArray(i) ),';' );
    end
    amplitudeStr = amplitudeStr(1:end-1);    

    % Send frequency target
    try
        dOutputStream.writeBytes(amplitudeStr);
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