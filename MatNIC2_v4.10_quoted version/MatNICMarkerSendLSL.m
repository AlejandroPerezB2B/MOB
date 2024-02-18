%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICMarkerSendLSL
%
% This function sends a marker to the NIC LSL marker service. The LSL server
% is running on the machine where the NIC application runs.
%
% Input:
% outlet  : outlet LSL stream to be used for sending
% code    : code to be sent via LSL
%
% Output:
% ret        : 0 when success, -1 on error recovering inlet
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, outlet] = MatNICMarkerSendLSL(code, outlet)

    % Return No Error
    ret = 0;

    % Send marker through LSL
    outlet.push_sample( code )

end


