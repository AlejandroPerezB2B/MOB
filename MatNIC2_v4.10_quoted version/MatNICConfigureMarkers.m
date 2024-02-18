%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICConfigureMarkers
%
%
% This function sends a request to the NIC. The request will
% configure a marker name.
%
% Input:
% markerName: indicates the name of the marker.
% markerId  : ID of the marker
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
%       -6: MarkerId is not correct.
%       -7: MarkerName is empty.
%       -8: NIC is running a Protocol.
%
% Author:  Axel Barroso (axel.barroso@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 27 May 2016
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICConfigureMarkers (markerName, markerId, socket)
    
    ret = 0;
    
    if(isempty(markerName))
        disp('ERROR: markerName is empty.')
        ret = -7;
        return;
    end
    
    if(markerId > 9 || markerId < 0)
        disp('ERROR: markerId is not correct.')
        ret = -6;
        return;
    end
    
    % Prevent unadequate status
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_PROTOCOL_RUNNING'
            disp('NIC is running a Protocol. Call MatNICAbortProtocol before configuring the files.')
            ret = -8;
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
    
    % Send command ID
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        [protocolSet] = MatNICProtocolSet();
        commandID = protocolSet('CODE_COMMAND_CONFIGURE_MARKERS');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -3;
        return;
    end
    
    
    % Send parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        dOutputStream.writeBytes(markerName);
        dOutputStream.writeBytes(';');
        dOutputStream.writeBytes(int2str(markerId));
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
    
end