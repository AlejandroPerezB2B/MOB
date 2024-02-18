%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICAbortStimulation
%
% This function aborts the stimulation script that might be running.
%
% Input:
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: NIC is not running a Protocol.
%       -3: Error communicating with the server.
%       -5: Error writing command to the server.
%
% Author: Javier Acedo (javier.acedo@starlab.es)
%         Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICAbortProtocol (socket)
    
    ret = 0;
    
    % Prevent unadequate status
    [ret, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_RUNNING'
        otherwise
            disp('NIC is not running a Protocol.')
            ret = -2;
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
        commandID = protocolSet('CODE_COMMAND_ABORT_PROTOCOL');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    isAbortedDone = false;
    max_retries = 20; 
    retries = 0;
    
    while (isAbortedDone == false)
        [ret, status] = MatNICQueryStatus(socket);   
        if (ret < 0 || retries == max_retries)
            ret = -3;
            disp('No response from server');
            return
        end
        
        
        switch status
            case 'CODE_STATUS_PROTOCOL_RUNNING'
                disp('Protocol is still running');
                
            case 'CODE_STATUS_PROTOCOL_ERROR'
                disp('Protocol has stopped due to an error');
                isAbortedDone = true;
                
            case 'CODE_STATUS_PROTOCOL_ABORTING'
                disp('Protocol is being aborted')
                
            case 'CODE_STATUS_PROTOCOL_ABORTED'
                disp('Protocol is aborted')
                isAbortedDone = true;
        end
        
        pause(1)
    end  
end