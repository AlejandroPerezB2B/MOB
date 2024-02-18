%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICEEGConnectLSL
%
% This function connects to the COREGUI Remote Stimulation Server
% The LSL server is running on the machine where the NIC application runs.
%
% Input:
% MatNICConnect funtion.
% name        : Name of the LSL into NIC which you wish to connect with
%
% Output:
% ret           : 0 when success, -1 on error recovering inlet
% intletEEG     : inlet requested by the user
%
% Author: Axel Barroso (axel.barroso@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 26 April 2016
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, intletEEG] = MatNICEEGConnectLSL(name)

    % Return No Error
    ret = 0;
    intletEEG = [];
        
    % instantiate the library
    %disp('Loading the library...');
    lib = lsl_loadlib();

    % Search EEG Inlet
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %disp('Resolving an EEG stream...');
    result = {};
    while isempty(result)
        result = lsl_resolve_byprop(lib,'type','EEG');
    end

    % Found the inlet requested by the user    
    found = false;
    for i = 1:length(result)
        intletEEG = lsl_inlet(result{i});

        % Get the name_lsl
        name_lsl = intletEEG.info().name();
        %disp(sprintf('Evaluating %s ...', source_id) )
        if( strfind(name_lsl, name) )
            found = true;
            break;
        end
    end
    if( found == false ) 
        ret = -1;
        return;
    end    
end


