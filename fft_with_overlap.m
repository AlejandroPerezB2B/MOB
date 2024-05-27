function [fft_data] = fft_with_overlap(data, overlap, window_count, pad)
    % Create a buffer of zeros round the vector length up
    buffer = zeros(1, overlap, size(data, 1));
    data_buff = 0;
    
    % Create the hanning window
    han_win = hann(window_count);
    
    % Calculate how many trials of the desired window length can be computed
    % from the current data
    trial_count = length(data) / window_count;
    
    % Calculate how many zeros need to be added to round the data length to
    % one divisible by the window length
    z_add = ceil(length(data) / 1000) * 1000;
    
    % How many of those zeros need to be added to the end of the vector, and
    % then create the two zero vectors
    z_end = (z_add - size(data, 2));
    z_begin_vec = zeros(size(data, 1), overlap);
    z_end_vec = zeros(size(data, 1), z_end);
    
    % Concatenate the zero vectors with the eeg data
    z_before = [z_begin_vec, data, z_end_vec];
    z_after = [z_end_vec, data, z_begin_vec];
    
    % Reshape the data to allow the fft analysis to be run across all data
    % windows simultaneously
    before_permute = reshape(z_before.', 1, length(data) + (size(z_begin_vec, 2) ...
        + size(z_end_vec, 2)), size(data, 1));
    after_permute = reshape(z_after.', 1, length(data) + (size(z_begin_vec, 2) ...
        + size(z_end_vec, 2)), size(data, 1));
    
    if size(after_permute, 2) / ceil(trial_count) ~= window_count
        after_permute = [buffer, after_permute];
        before_permute = [before_permute, buffer];
        trial_count = trial_count + 1;
        data_buff = 1;
    end
    
    before_permute = permute(reshape(before_permute, ...
        [window_count, ceil(trial_count), size(data, 1)]), [2, 1, 3]);
    after_permute = permute(reshape(after_permute, ...
        [window_count, ceil(trial_count), size(data, 1)]), [2, 1, 3]);
    
    if data_buff == 1
        before_permute(end, :, :) = [];
        after_permute(1, :, :) = [];
    end
    
    all_permute = vertcat(before_permute, after_permute);
    
    % Apply the hanning window to the data
    han_perm = all_permute .* han_win.';
    
    % Zero pad the data 
    zero_pad = zeros(size(all_permute, 1), pad, size(all_permute, 3));
    han_perm = [zero_pad, han_perm, zero_pad];
    
    % Run the fft
    fft_data = abs(abs(fft(han_perm, [], 2) / size(han_perm, 2)).^2);
end