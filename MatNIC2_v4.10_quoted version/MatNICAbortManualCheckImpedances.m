%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICAbortManualCheckImpedances
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
%       -2: NIC is not running a Check Impedance
%       -3: Error communicating with the server.
%       -5: Error writing command to the server.
%
% Author: Axel Barroso (axel.barroso@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICAbortManualCheckImpedances (socket)
    
    ret = 0;
    
    % Prevent unadequate status
    [ret, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_CHECK_IMPEDANCE'
        otherwise
            disp('NIC is not running a Check Impedance.')
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
        commandID = protocolSet('CODE_COMMAND_CHECK_IMPEDANCE_ABORT');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Leave some time for the system to RampDown and Finish Stimulation
    isAbortedDone = false;
    max_retries = 20; 
    retries = 0;
    
    while (isAbortedDone == false)        
        pause(1)
        [ret, status] = MatNICQueryStatus(socket);
        if (ret < 0 || retries == max_retries)
            disp('No response from server');
            ret = -3;
            return
        end
        
        switch status
           case 'CODE_STATUS_CHECK_IMPEDANCE_ABORTING'
                disp(' Aborting current manual check Impedances'); 
            case 'CODE_STATUS_CHECK_IMPEDANCE_ABORTED'
                disp(' Aborted current manual check Impedances');
                isAbortedDone = true;
            case 'CODE_STATUS_CHECK_IMPEDANCE_FISNISHED'
                disp(' Finished current manual check Impedances');
                isAbortedDone = true;
        end                
    end
end