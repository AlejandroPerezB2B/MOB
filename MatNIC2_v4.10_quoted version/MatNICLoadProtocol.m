%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICLoadProtocol
%
% This function sends to NIC the name of the
% protocol to be loaded. By sending the protocol name the remote
% session is requested to the server. If the protocol exists
% and the NIC users accepts the remote session the protocol script
% starts.
%
% The NIC waits for the client to send the name of the 
% protocol that the client wants to use.
%
% Input:
% templateName: Name of the protocol to be loaded on NIC.
% If the NIC user accepts the remote control session, the template is
% loaded and the client is informed when the system is ready to start the
% protocol.
% socket: The socket variable that is returned by the
% MatNICConnect funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: Error writing template name.
%       -3: Error reading from server.
%       -5: Error writing command to the server.
%       -6: Empty protocol name.
%       -7: NIC is running a Protocol.
%       -8: NIC is already loading a Protocol.
%       -9: NIC has not loaded a Protocol.
%       -10: NIC is synchronizing.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2015
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICLoadProtocol (protocolName, socket)
    ret = 0;

    % Check if protocolName is empty
    if isempty(protocolName) 
       ret = -6;
       disp(['Empty protocol name'])
       return;
    end
    
    % Prevent starting/stopping EEG when in stimulation mode
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_SYNCHRONIZING'
            ret = -7;
            disp('NIC  is synchronizing. Please wait until it is finished')
            return;
        case 'CODE_STATUS_PROTOCOL_RUNNING'
            ret = -7;
            disp('NIC is running a Protocol. Please call MatNICAbortProtocol')
            return;
        case 'CODE_STATUS_PROTOCOL_LOADING'
            ret = -8;
            disp('NIC is already loading a Protocol. Please wait until the Protocol is loaded')
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
        commandID = protocolSet('CODE_COMMAND_LOAD_PROTOCOL');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return
    end

    % Send template name
    try
        dOutputStream.writeBytes(protocolName);
        % The name of the template shall be ended with one of the following
        % characters:
        % '\0', '\n', '\r' so the server can know when the template name
        % finishes.
        dOutputStream.writeByte(0); % string terminator character for the NIC
                                    % to start processing the template name
        dOutputStream.flush;
    catch
        ret = -2;
        return
    end

    
    % Wait for response
    isReceivedProtocolLoadingResponse = false;
    retries = 0;
    max_retries = 20;
    while (isReceivedProtocolLoadingResponse == false)
        
        % Read the current status of the server
        [ret, status] = MatNICQueryStatus (socket);    
        if (ret < 0 || retries == max_retries)
            disp('No response from server');
            return
        end
        switch status
            case 'CODE_STATUS_PROTOCOL_LOADED'
                disp('INFO: Template successfully loaded. Protocol ready to be started')
                % Only signal to start stimualtion when template was loaded
                isReceivedProtocolLoadingResponse = true;
                               
            case 'CODE_STATUS_PROTOCOL_NOT_LOADED'
                ret = -9;
                disp(['WARNING: Wrong protocol or not allowed to remotely control the', ...
                                                        ' protocol session']);
                isReceivedProtocolLoadingResponse = true;
            case 'CODE_STATUS_TEMPLATE_LOADING'
                disp('INFO: Protocol is currently loading.');
            otherwise                
                %fprintf('* (%s) Loading template (%d out of %d) ... \n', status, retries, max_retries);                
        end
        

        if( ret >= 0)
            % Pause execution for 1 second
            pause(1);
            retries = retries+1;
        end
        
    end
    
end