function fft_results = run_fft(eeg, chan_label, overlap, window_count, pad)
    % Extract data from the specified channel
    chan_numb = find(strcmp({EEG.chanlocs.labels}, chan_label));
    
    if isempty(chan_numb)
        error('Channel %s not found', chan_label);
    end
    
    data = EEG.data(chan_numb, :);
    
    % Run FFT with overlap
    fft_data = fft_with_overlap(data, overlap, window_count, pad);
    fft_data = mean(fft_data(:, 1:1250, :), 1);
    fft_data = squeeze(fft_data);
    fft_results = fft_data;
end