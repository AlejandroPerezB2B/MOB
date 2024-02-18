%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICPtacsChange
%
% This function sends a request to NIC to
% change the phase of a given channel.
%
% Input:
% phaseArray : Array of frequencies for every channel indicated in channel
% n_channels     : number of Channels current device
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1 : No connection with the host.
%       -3 : Error in parameters
%       -5 : Error writing command to the server.
%       -6 : NIC is not doing stimulation.
%       -7 : Phase array length does not match channel array.
%       -8 : Selected channel is not appropriate. Channel [1-32].
%       -9 : Selected phase is not appropriate. Phase [0-359] º.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 24 Oct 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICOnlinePtacsChange (phaseArray, n_channels, socket)

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
    if( length(phaseArray) ~= length(channelArray) )
        disp('ERROR: phase array length does not match channel array')
        ret = -7;
        return
    end
    for i = 1:length(channelArray)
        if( (channelArray(i) < 1) || (channelArray(i) > 32) )
            disp('ERROR: Selected channel is not appropriate. Channel [1-32]')
            ret = -8;
            return
        end
        if( (phaseArray(i) < 0) || (phaseArray(i) > 359) )
            disp('ERROR: Selected phase is not appropriate. Phase [0-359]')
            ret = -9;
            return
        end
    end


    % Recover information for every channel
    phaseChannelArray = zeros(1, length(channelArray)); % Phase for every channel
    for i = 1:length(channelArray)
        phaseChannelArray(channelArray(i)) = phaseArray(i); 
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
        commandId = protocolSet('CODE_COMMAND_ONLINE_PTACS_CHANGE');
        dOutputStream.writeByte( commandId );
        %dOutputStream.writeByte(244);
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Send parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseStr = '';
    for i = 1:length(channelArray)
        phaseStr = strcat(phaseStr, num2str( phaseChannelArray(i) ),';' );
    end
    phaseStr = phaseStr(1:end-1); 
    
    % Send frequency target
    try
        dOutputStream.writeBytes(phaseStr);
        % The name of the template shall be ended with one of the following
        % characters:
        % '\0', '\n', '\r' so the server can know when the template name
        % finishes.
        dOutputStream.writeByte(0); % string terminator character for the COREGUI
                                    % to start processing the template name
        dOutputStream.flush;
    catch
        ret = -2;
        return
    end
    
end