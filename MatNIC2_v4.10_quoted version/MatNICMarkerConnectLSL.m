%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICMarkerConnectLSL
%
% This function connects to the COREGUI LSL marker service. The LSL server
% is running on the machine where the COREGUI application runs.
%
% Input:
% name  : name of the LSL Marker stream
%
% Output:
% ret        : 0 when success, -1 on error recovering inlet
% outlet     : object with which connect to the LSL Marker stream
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, outlet] = MatNICMarkerConnectLSL(name)

    % Return No Error
    ret = 0;

    % instantiate the library
    lib = lsl_loadlib();

    % Create LSL Stream and outlet
    info   = lsl_streaminfo(lib, name, 'Markers', 1, 0,'cf_int32', datestr(clock, 30) )
    outlet = lsl_outlet(info);

end


