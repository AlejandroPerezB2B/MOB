%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICConnect
%
% This function connects to the NIC Remote Stimulation Server. The server
% is running on the machine where the NIC application runs on the port
% 1235.
%
% Input:
% host: Name or IP of the host where NIC is running.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host.
%       -2: Error communicating with the server.
%       -3: Error reading from server.
%       -4: Remote Control rejected.
%       -5: Error writing command to the server.
%
% status: NIC status 
% socket: The socket that holds the connection information that might be
% passed as argument to the other COREGUI Remote Stimulation Server related
% functions.
%
% Author: Javier Acedo (javier.acedo@starlab.es)
%         Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, status, socket] = MatNICConnect (host)

    ret = 0;
    socket = 0;
    status = 0;
    version = '';
    n_channels = 0;
    
    % Check whether host parameter is present
    if ~exist('host','var') || isempty(host)
      host='localhost';
    end

    % Select port and create socket
    port = 1235;
    try
        socket = java.net.Socket( host, port );
        socket.setSoTimeout(10000); % Wait 10 seconds for a response
        socket.setKeepAlive(true);
    catch
        ret = -1;
        return
    end    
    
    
    disp('INFO: Sending current MatNIC version to NIC')
    retries = 0;
    max_retries = 25;
    while (retries < max_retries)
    
        [ret,status] = MatNICVersion(socket);
        if( ret < 0 )
            disp('No response from server. Aborting');
            return;
        end
        if( strcmp(status,'CODE_STATUS_SYNCHRONIZING') == 1 )
           disp('Device is synchronizing. Please, wait')
        end
        if( strcmp(status,'CODE_STATUS_IDLE') == 1 )
            break;
        end
        if( strcmp(status,'CODE_STATUS_DEVICE_NOT_PRESENT') == 1 )
           disp('* Device is not present')
           return;
        end
        
        % Pause execution for 1 second
        pause(1);
        retries = retries+1;
    end
    
    % Error Validation
    if(retries == max_retries)
        disp('INFO: MATNIC Version has not been received.')
        socket.close();
    end
    
    % Query Status - It pops up the warning in COREGUI
    disp('INFO: Asking for Remote Control permission. Please press "Yes" in NIC Dialog')
    retries = 0;
    max_retries = 20;
    while (retries < max_retries)
    
        [ret,status] = MatNICQueryStatus(socket);
        if( ret < 0 )
            disp('No response from server. Aborting');
            return;
        end

        if( strcmp(status,'CODE_STATUS_REMOTE_CONTROL_ALLOWED') == 1 )
            break;
        end
        if( strcmp(status,'CODE_STATUS_DEVICE_NOT_PRESENT') == 1 )
           disp('* Receiver not present')
        end
        if( strcmp(status,'CODE_STATUS_SYNCHRONIZING') == 1 )
           disp('Device is synchronizing. Please, wait')
        end
        if( strcmp(status,'CODE_STATUS_REMOTE_CONTROL_REJECTED') == 1 )
           ret = -4;
           disp('Remote Control rejected')
           return;
        end
        
        % Pause execution for 1 second
        pause(1);
        retries = retries+1;
    end
    
    % Error Validation
    if(retries == max_retries)
        disp('INFO: Connection Aborted after 20 secs. Closing socket')
        disp('INFO: Did you confirm remote access? Is receiver present?')
        socket.close();
    end
    
    [ret, version, n_channels, deviceSettings] = MatNICSetUp (socket);    
end