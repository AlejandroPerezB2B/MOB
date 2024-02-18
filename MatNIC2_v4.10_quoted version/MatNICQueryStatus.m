%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICQueryStatus
%
% This function sends queries the status of the device.
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
% status: status of the device as per defined in the following list
% 
% CODE_STATUS_REMOTE_CONTROL_ALLOWED          (200)
% CODE_STATUS_REMOTE_CONTROL_REJECTED         (201)
% CODE_STATUS_VERSION_RECEIVED                (202)
% CODE_STATUS_SYNCHRONIZING                   (203)
% CODE_STATUS_IDLE                            (204)
% CODE_STATUS_PROTOCOL_NOT_LOADED             (205)
% CODE_STATUS_PROTOCOL_LOADING                (206)
% CODE_STATUS_PROTOCOL_LOADED                 (207)
% CODE_STATUS_PROTOCOL_RUNNING                (208)
% CODE_STATUS_PROTOCOL_ERROR                  (209)
% CODE_STATUS_PROTOCOL_FINISHED               (210)
% CODE_STATUS_PROTOCOL_PAUSED                 (211)
% CODE_STATUS_PROTOCOL_ABORTED                (212)
% CODE_STATUS_PROTOCOL_ABORTING               (213)
% CODE_STATUS_EEG_ON                          (214)
% CODE_STATUS_EEG_OFF                         (215)
% CODE_STATUS_CHECK_IMPEDANCE                 (221)
% CODE_STATUS_CHECK_IMPEDANCE_FISNISHED       (222)
% CODE_STATUS_CHECK_IMPEDANCE_ABORTING        (223)
% CODE_STATUS_CHECK_IMPEDANCE_ABORTED         (224)
% CODE_STATUS_PULSE_DISABLE                   (225)
% CODE_STATUS_PULSE_ENABLE                    (226)
%
% Author:  Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 28 Nov 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, status] = MatNICQueryStatus (socket)
    
    ret = 0;
    status = 0;

   
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
        commandID = protocolSet('CODE_COMMAND_QUERY_STATUS');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Read status from server
    try
        inputStream = socket.getInputStream;
        dInputStream = java.io.DataInputStream(inputStream);
    catch
        ret = -1;
        return
    end
    
    try
        statusCode = dInputStream.readByte();
    catch
        ret = -3;
        %disp('ERROR: No response from QueryStatus')
        return;
    end
    
    % Convert from two's complement
    statusCode = 256 + statusCode;

    % Recover descriptive string
    status = MatNICStatusToString(statusCode);
    
end