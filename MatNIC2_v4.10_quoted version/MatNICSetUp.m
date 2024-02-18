%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICSetUp
%
% This function checks the current version of MATNIC used by the Software 
% and the number of channels of the Enobio or StarStim device.
%
% Input:
% host: Name or IP of the host where NIC is running.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -3: Error reading from server.
%       -5: Error writing command to the server.
% status: String represengting the status according to
% socket: The socket that holds the connection information that might be
% passed as argument to the other NIC Remote Stimulation Server related
% functions.
% n_channels
% deviceSettings: Struct that contains:
%					- Firmware version
%					- Network Address
%					- Communication Type
%					- Device Type
%
% Author: Axel Barroso (axel.barroso@neuroelectrics.com)
%
% Company: Neuroelectrics
% Created: 26 Feb 2016
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, version, n_channels, deviceSettings] = MatNICSetUp (socket)
    
    ret = 0;
    version = '';
    n_channels = 0;
    % Ask for the MatNIC version 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get Input/Output stream
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end
    
    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_READ_MATNIC_VERSION');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Read the response from the server
    try       
        in = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream));
    catch        
        ret = -1;
        return
    end
    try
        version = char(in.readLine());
    catch
        ret = -3;
        return;
    end
    
    % Ask for the number of channels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get Input/Output stream
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end
    
    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_READ_CHANNELS');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Read the response from the server
    try
        inputStream = socket.getInputStream;
        dInputStream = java.io.DataInputStream(inputStream);
    catch
        ret = -1;
        return
    end
    
    try
        n_channels = dInputStream.readByte();
    catch
        ret = -3;
        %disp('ERROR: No response from QueryStatus')
        return;
    end
    
%     % Ask for firmware version
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Get Input/Output stream

    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_READ_DEVICE_SETTINGS');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    % Read the response from the server
    try       
        in = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream));
    catch        
        ret = -1;
        return
    end
    try
        settings = char(in.readLine());
    catch
        ret = -3;
        return;
    end
    
    settings = strsplit(settings,'\t');
    deviceSettings.firmwareVersion = settings(1);
    deviceSettings.networkAddress = settings(2);
    deviceSettings.communicationType = settings(3);
    deviceSettings.deviceType = settings(4);
    
    if strcmp(version, protocolSet('MATNIC_VERSION') ) == false
        disp('WARNING: Current MatNIC version is not supported by NIC')
        disp(sprintf('COREGUI supported version :%s', version))
        disp(sprintf('MatNIC version            : %s', protocolSet('MATNIC_VERSION')))
        disp('  Please contact support@neuroelectrics.com to avoid this issue')
    else
        disp('Current MatNIC version is supported by NIC')
        disp(sprintf('Number of Channels: %u', n_channels))
        disp(sprintf('Device Type       : %s', settings{4}(:)'))
        disp(sprintf('Firmware version  : %s', settings{1}(:)'))
        disp(sprintf('Network Address   : %s', settings{2}(:)'))
        disp(sprintf('Communication Type: %s', settings{3}(:)'))
    end
    
end