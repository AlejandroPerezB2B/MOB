%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICEEGRecordLSL
%
% This function connects to the COREGUI Remote Stimulation Server and 
% reads the EEG signal for t number of seconds. The LSL server
% is running on the machine where the NIC application runs.
%
% Input:
% period      : number of seconds to read from the stream
% intletEEG   : inlet requested by the user
% n_channels  : number of channels of the device
%
% Output:
% ret           : 0 when success, -1 on error recovering inlet
% eeg_set       : [n_channel x samples] matrix reading the EEG signal
% timestamp_set : [samples] array of timestamps
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 05 Mar 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, eeg_set, timestamp_set] = MatNICEEGRecordLSL(period, n_channels, intletEEG)

    % Return No Error
    ret = 0;
        
    % Read EEG Samples
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sampling_rate  = 500;   % Sampling rate EEG [SPS]
    target_samples = sampling_rate * period;
    n_samples = 0;
    eeg_set = zeros(target_samples, n_channels);
    timestamp_set  = zeros(target_samples, 1);
    while n_samples <= target_samples
        n_samples = n_samples + 1;
        % get data from the inlet
        [eeg,timestamp] = intletEEG.pull_sample();
        eeg_set(n_samples,:) = eeg;
        timestamp = timestamp + intletEEG.time_correction;
        timestamp_set(n_samples) = timestamp;
    end
end
