function EEG = preprocess_eeg(eeg)
    % Convert cell array to numeric array
    eeg_data = eeg(:, 1:end-2);
    
    [numRows, numCols] = size(eeg_data);
    numeric_data = zeros(numRows, numCols); % Pre-allocate for efficiency
    
    for i = 1:numRows
        for j = 1:numCols
            numeric_data(i, j) = str2double(eeg_data{i, j});
        end
    end
    
    eeg_data = double(numeric_data);
    
    % Initialize EEGLAB
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab('nogui');
    
    % Create a structure for the EEG data
    EEG.data = eeg_data';
    EEG.srate = 1000; % Assuming the sampling rate is 1000 Hz, adjust accordingly
    EEG.nbchan = size(eeg_data, 2); % Number of channels
    EEG.trials = 1;
    EEG.pnts = size(eeg_data, 1); % Number of data points
    EEG.xmin = 0;
    EEG.xmax = (size(eeg_data, 1)-1)/EEG.srate; % Duration of the data
    
    % Initialize chanlocs field with dummy labels
    EEG.chanlocs = struct('labels', {'Ch1', 'Ch2', 'Ch3', 'Ch4', 'Ch5', 'Ch6', 'Ch7', 'Ch8'}); % Adjust as needed
    
    % Add required fields
    EEG.setname = 'Raw EEG Data';
    EEG.filename = ''; % No filename yet
    EEG.filepath = ''; % No filepath yet
    EEG.subject = '';
    EEG.group = '';
    EEG.condition = '';
    EEG.session = [];
    EEG.comments = 'Raw EEG data imported into EEGLAB';
    
    % Initialize ICA fields to avoid errors
    EEG.icaweights = [];
    EEG.icasphere = [];
    EEG.icaact = [];
    EEG.icawinv = [];
    EEG.icasplinefile = '';
    EEG.icaquant = [];
    EEG.icachansind = 1:EEG.nbchan; % Set icachansind to all channels
    
    % Check the EEG structure
    EEG = eeg_checkset(EEG);
    
    % Load standard channel locations
    EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp'); % Adjust the path if needed
    
    % Step 3: Basic Preprocessing
    % Remove baseline mean (DC offset)
    EEG = pop_rmbase(EEG, [], []);
    
    % Apply bandpass filter (1-50 Hz as an example)
    EEG = pop_eegfiltnew(EEG, 1, 50, [], 0, [], 0);
    
    % Re-reference the data to the average reference
    EEG = pop_reref(EEG, []);
    
    % Perform ICA
    EEG = pop_runica(EEG, 'extended', 1, 'interrupt', 'off', 'verbose', 'off');

    
    % Diagnostic checks before running ICLabel
    fprintf('Number of ICA components: %d\n', size(EEG.icaweights, 1));
    fprintf('Number of channel locations: %d\n', length(EEG.chanlocs));
    fprintf('Dimensions of icawinv: %s\n', mat2str(size(EEG.icawinv)));
    
    % Use ICLabel to classify components
    try
        if size(EEG.icawinv, 1) == length(EEG.chanlocs)
            EEG = pop_iclabel(EEG, 'default');
            
            % Flag components to reject (e.g., those classified as eye or muscle artifacts)
            EEG = pop_icflag(EEG, [NaN NaN; 0.8 1; NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN]);
            
            % Remove the flagged components
            EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
        else
            warning('ICLabel: Dimensions of icawinv and chanlocs do not match. Skipping ICLabel classification.');
        end
    catch ME
        warning('ICLabel failed: %s', ME.message);
    end
    
    % Save the processed data to the EEGLAB structure
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', 'Preprocessed EEG Data', 'gui', 'off');
    
    % Optionally save the dataset to a file (commented out)
    % EEG = pop_saveset(EEG, 'filename', 'preprocessed_eeg.set', 'filepath', pwd);
    
    % Optionally plot the EEG data to verify preprocessing (commented out)
    % pop_eegplot(EEG, 1, 1, 1);

end
