%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICGetImpedance
%
% This function sends a query to get the latest impedance value
%
% Input:
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -3: Error reading from server.
%       -5: Error writing command to the server.
% impedance_set: array of 'n' elements containing the values of the impedance
%
% Author:  Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 28 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, impedance_set] = MatNICGetImpedance(socket)
    
    ret = 0;
    impedance_set = [];

    % Prevent unadequate status
    [retValue, status] = MatNICQueryStatusProtocol (socket);
    switch status
        case 'CODE_STATUS_STIMULATION_FULL'     
        otherwise
            disp('NIC is not doing stimulation.')
            ret = -1;
            return;   
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
        commandID = protocolSet('CODE_COMMAND_GET_IMPEDANCE');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    % Read status from server
    try       
        in = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream));
    catch        
        ret = -1;
        return
    end
    try
        reply = char(in.readLine());
    catch
        ret = -3;
        return;
    end
   
    % Parse the impedance set
    impedance_set = str2num(reply);    
end