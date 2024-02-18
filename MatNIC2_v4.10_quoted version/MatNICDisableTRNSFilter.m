%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICDisableTRNSFilter
%
% This function sends a request to the NIC Remote Stimulation Server to
% disable the tRNS filter
%
% Input:
% socket: The socket variable that is returned by the
% MatNICDisableTRNSFilter funtion.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host
%       -2: Command Successful
%       -5: Error writing command to the server.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 27 Nov 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICTRNSFilter ( socket )

    % Return value   
    ret = 0;
    
    % Recover Input/Output stream
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end

    % Recover ProtocolSet
    [protocolSet] = MatNICProtocolSet();
    
    % Send commandId
    try
        %dOutputStream.writeByte(247);
        commandID = protocolSet('CODE_COMMAND_DISABLE_TRNS_FILTER');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
       
end