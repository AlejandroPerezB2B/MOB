%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICDisconnect
%
% This function disconnects from the NIC Remote Stimulation Server.
% This function needs to be called in order to allow further new
% connections to NIC through the MatNICConnect function.
%
% Input:
% socket: The socket variable for disconnecting from NIC
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: The socket passed is invalid or alredy discconected.
%
% Author: Javier Acedo (javier.acedo@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 8 Jan 2019
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICDisconnect (socket)

    ret = 0;
    try
		socket.close();
    catch
        ret = -1;
    end    
	
end