%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICPauseProtocol
%
% This function pauses the protocol script that might be running.
%
% Input:
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
%
% Author: Javier Acedo (javier.acedo@starlab.es)
%         Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICPauseProtocol (socket)
    
    ret = 0;
    
    % Prevent unadequate status
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_RUNNING'
        otherwise
            disp('NIC is not running a Protocol.')
            ret = -6;
            return;
    end
    
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end

    % Send commandId
    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_PAUSE_PROTOCOL');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    isPausedDone = false;
    max_retries = 20; retries = 0;
    
    disp('Protocol is being paused')
    while (isPausedDone == false)
        [ret, status] = MatNICQueryStatus(socket);   
        if (ret < 0 || retries == max_retries)
            disp('No response from server');
            return
        end
        
        switch status
            case 'CODE_STATUS_PROTOCOL_RUNNING'
                disp('Protocol is still running');
                
            case 'CODE_STATUS_PROTOCOL_ERROR'
                disp('Protocol has stopped due to an error');
                isPausedDone = true;              
                
            case 'CODE_STATUS_PROTOCOL_PAUSED'
                disp('Protocol is paused')
                isPausedDone = true;
        end
        
        pause(1)
    end  
end