%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICUnloadProtocol
%
% This function sends a request to NIC to unload the current protocol. 
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
%       -8 : NIC is running a Protocol.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 20 May 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICUnloadProtocol (socket)
    
    ret = 0;
    
    % Prevent unadequate status
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_NOT_LOADED'
            disp('NIC has not a Protocol loaded.')
            ret = -6;
            return;
        case 'CODE_STATUS_CHECK_IMPEDANCE'
            disp('NIC is doing Impedance Check. Please call MatNICAbortManualCheckImpedances')
            ret = -7;
            return;
        case 'CODE_STATUS_PROTOCOL_RUNNING'
            disp('NIC is running a Protocol. Please call MatNICAbortProtocol')
            ret = -8;
            return;
        otherwise
    end
    
       
    % Get Input/Output stream
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
        commandID = protocolSet('CODE_COMMAND_UNLOAD_PROTOCOL');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    while ~strcmp(status,'CODE_STATUS_PROTOCOL_NOT_LOADED')
        pause(1)
        [ret, status] = MatNICQueryStatus (socket);
    end
    
end