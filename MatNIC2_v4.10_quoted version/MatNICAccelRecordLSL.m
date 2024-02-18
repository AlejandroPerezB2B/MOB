%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICAccelRecordLSL
%
% This function connects to the COREGUI Remote Stimulation Server and 
% reads the EEG signal for t number of seconds. The LSL server
% is running on the machine where the COREGUI application runs.
%
% Input:
% period      : number of seconds to read from the stream
% name        : Name of the LSL into COREGUI which you wish to connect with
%
% Output:
% ret           : 0 when success, -1 on error recovering inlet
% accel_set     : [n_channel x samples] matrix reading the Accelerometer signal
% timestamp_set : [samples] array of timestamps
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, accel_set, timestamp_set] = MatNICAccelRecordLSL(period, name)

% Return No Error
ret = 0;

% instantiate the library
%disp('Loading the library...');
lib = lsl_loadlib();

% Search ACCEL Inlet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Resolving an Accel stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','Accelerometer');
end

% Found the inlet requested by the user
intletAccel = [];
for i = 1:length(result)
    intletAccel = lsl_inlet(result{i});
    
    % Get the name_lsl
    name_lsl = intletAccel.info().name();
    %disp(sprintf('Evaluating %s ...', source_id) )
    if( strfind(name_lsl, name) )
        %disp('Found!')
        break;
    end
end

% Read Accel Samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sampling_rate  = 100;   % Sampling rate accelerometer [SPS]
target_samples = sampling_rate * period;
n_samples = 0;
accel_set = zeros(target_samples, 3);
timestamp_set = zeros(target_samples, 1);
while n_samples <= target_samples
    n_samples = n_samples + 1;
    % get data from the inlet
    [accel,timestamp] = intletAccel.pull_sample();
    accel_set(n_samples,:) = accel;
    timestamp_set(n_samples) = timestamp;   
end


end


