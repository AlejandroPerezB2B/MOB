%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICStartProtocol
%
% This function requests NIC to start the protocol. 
%
% Input:
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1 : No connection with the host.
%       -3 : Error reading from server.
%       -5 : Error writing command to the server.
%       -6 : NIC has not a Protocol loaded.
%       -7 : NIC is running a Manual Check Impedance.
%       -8 : NIC has problem with the Protocol loaded.
%       -9 : NIC has not a Protocol loaded.
%       -10: NIC is running a Protocol.
%
% Author: Javier Acedo (javier.acedo@starlab.es)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICStartProtocol (socket)
    
    ret = 0;

    % Prevent unadequate status
    [ret, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_NOT_LOADED'
            disp('NIC has not a Protocol loaded.')
            ret = -6;
            return;
        case 'CODE_STATUS_CHECK_IMPEDANCE'
            disp('NIC is running a Manual Check Impedance.')
            ret = -7;
            return;
        case 'CODE_STATUS_PROTOCOL_RUNNING'
            disp('NIC is running a Protocol.')
            ret = -10;
            return;
        otherwise
    end
    
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end

    % Send command Id
    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_START_PROTOCOL');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return
    end
    
    [ret, status] = MatNICQueryStatus (socket);
    retries = 0;
    max_retries = 20;
    while ~strcmp(status,'CODE_STATUS_PROTOCOL_RUNNING')
        pause(1)
        [ret, status] = MatNICQueryStatus (socket);        
        if( ret < 0 || retries == max_retries)
            disp('No response from server. Aborting');
            return;
        end
        if(strcmp(status,'CODE_STATUS_PROTOCOL_ERROR'))
           disp('NIC has problem with the Protocol loaded.')
           ret = -8;
           return
        end
        
        if strcmp(status,'CODE_STATUS_PROTOCOL_NOT_LOADED')
            ret = -9;
            disp('NIC has not a Protocol loaded.')
            return;
        end
                       
        retries = retries+1;        
    end    
end