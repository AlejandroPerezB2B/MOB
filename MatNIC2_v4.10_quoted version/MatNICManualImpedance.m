%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICManualImpedance
%
% This function sends a command to start the manual impedance check. It
% waits until the impedance check is finished to recieve the values.
%
% Input:
% impedanceType: String stores the impedance stimulation type.
% Possible values: DC or AC.
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: Error in input parameter.
%       -3: Error reading from server.
%       -4: Error sending parameters to the server
%       -5: Error writing command to the server.
%       -6: NIC has not a Protocol loaded.
%       -7: NIC is running a Protocol.
%       -8: NIC is already loading a Protocol.
%       -9: NIC has aborted check impedance operation.
%       -10: NIC has not a Protocol loaded.
%
% impedance_set: array of 'n' elements containing the values of the impedance
%
% Author:  Axel Barroso (axel.barroso@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 7 April 2016
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, impedance_set] = MatNICManualImpedance(impedanceType, socket)
    
    ret = 0;
    impedance_set = [];
    
    % Check if protocolName is empty
    if isempty(impedanceType) 
       ret = -6;
       disp(['Empty impedance type'])
       return;
    end
    
    if(~(strcmp(impedanceType, 'DC') || strcmp(impedanceType, 'AC')))
        ret = -2;
        disp(['No valid value for impedance type'])
        return;
    end

    % Prevent unadequate status
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_NOT_LOADED'
            disp('NIC has not a Protocol loaded.')
            ret = -6;
            return;
        case 'CODE_STATUS_PROTOCOL_RUNNING'
            disp('NIC is running a Protocol.')
            ret = -7;
            return;
        otherwise
    end
    
    disp('Manual Check Impedances is about to start, please wait ...');
   
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
        commandID = protocolSet('CODE_COMMAND_CHECK_IMPEDANCE');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
        pause(1);
    catch
        ret = -5;
        return;
    end
    
   
    % Send impedance type
    try
        dOutputStream.writeBytes(impedanceType);
        % The name of the impedance type shall be ended with one of the following
        % characters:
        % '\0', '\n', '\r' so the server can know when the template name
        % finishes.
        dOutputStream.writeByte(0); % string terminator character for the NIC
                                    % to start processing the template name
        dOutputStream.flush;
    catch
        ret = -4;
        return
    end
    
    [ret, status] = MatNICQueryStatus (socket);
    
    while ~strcmp(status,'CODE_STATUS_CHECK_IMPEDANCE_FISNISHED')
        pause(5)
        [ret, status] = MatNICQueryStatus (socket);
        
        if strcmp(status,'CODE_STATUS_CHECK_IMPEDANCE_ABORTED')
            ret = -9;
            disp('NIC has aborted check impedance operation.')
            return;
        end
        
        if strcmp(status,'CODE_STATUS_PROTOCOL_NOT_LOADED')
            ret = -10;
            disp('NIC has not a Protocol loaded.')
            return;
        end
    end
    
    [ret, impedance_set] = MatNICGetImpedance(socket);
    [ret, status] = MatNICQueryStatus (socket);        
end