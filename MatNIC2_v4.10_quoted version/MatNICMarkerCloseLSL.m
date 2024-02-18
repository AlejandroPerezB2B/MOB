%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICMarkerCloseLSL
%
% This function closes the communication with the NIC LSL marker service. 
% The LSL server is running on the machine where the NIC application runs.
%
% Input:
% name  : name of the LSL Marker stream
%
% Output:
% ret        : 0 when success, -1 on error recovering inlet
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICMarkerCloseLSL(outlet)

    % Return No Error
    ret = 0;

    % Delete the LSL Stream
    outlet.info.delete
    outlet.delete

end


