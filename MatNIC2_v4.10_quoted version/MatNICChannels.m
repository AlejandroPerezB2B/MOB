%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICChannels
%
% This function asks the number of Channels of current device.
%
% Input:
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: Error communicating with the server.
%       -3: Error reading from server.
%       -5: Error writing command to the server.
%
% Author:  Axel Barroso (axel.barroso@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 26 Feb 2016
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, status] = MatNICChannels (socket)
    
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
        commandID = protocolSet('CODE_COMMAND_VERSION');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    
    % Send parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    try
        dOutputStream.writeBytes(protocolSet('MATNIC_VERSION'));
        dOutputStream.writeByte(0);
        dOutputStream.flush;
    catch
        ret = -2;
        return
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