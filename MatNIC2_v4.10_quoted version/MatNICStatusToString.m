%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICStatusToString
%
% Returns a string according to the command code
%
% Input:
% statusCode : command code from which return a string
%
% Output:
% ret: string representing the code
%
% Author:  Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 28 Nov 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [status] = MatNICStatusToString (statusCode)
    
    status = 0;
    [protocolSet] = MatNICProtocolSet();
    keys   = protocolSet.keys;
    values = protocolSet.values;   
    for i = 1:length(protocolSet.values)
        if( values{i} == statusCode )
            status = keys{i};
        end 
    end
      
end