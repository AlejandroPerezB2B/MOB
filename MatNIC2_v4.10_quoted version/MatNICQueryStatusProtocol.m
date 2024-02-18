%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICQueryStatusProtocol
%
% This function sends queries the status of the protocol.
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
% CODE_STATUS_IDLE                            (204)
% CODE_STATUS_STIMULATION_RAMPUP              (216)
% CODE_STATUS_STIMULATION_FULL                (217)
% CODE_STATUS_STIMULATION_RAMPDOWN            (218)
% CODE_STATUS_STIMULATION_FINISHED            (219)
% CODE_STATUS_WAITING_FOR_SECOND_SHAM         (220)
%
% Author:  Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 28 Nov 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, status] = MatNICQueryStatusProtocol (socket)
    
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
        commandID = protocolSet('CODE_COMMAND_QUERY_STATUS_PROTOCOL');
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