function data = preprocess_data(data, settings, params)
% Pre-processing for either ECoG or single-unit recordings.
% ECoG: Filter noise.
% Single-unit: Filter noise, spike sorting.

switch settings.data_type
    case 'ECoG'
    % Line filter channels
    num_channels = size(data.NS.Data, 1);
    for channel = 1:num_channels;
        fprintf('Line filtering channel #%i (%i)\n', channel, num_channels)
        curr_channel_data = data.NS.Data(channel, :);
        data.NS.Data_filtered(channel, :) = remove_line_noise(curr_channel_data,params.line_frequency,params.samplingRate_data);
        data.NS.Data_filtered(channel, :) = HighPass_Signal(params.ECoG_lowCut_freq, params.ECoG_highCut_freq, params.samplingRate_data, data.NS.Data_filtered(channel, :));
        
    end
    
    case 'Single-unit'
end
        
end

function sig = HighPass_Signal(low_cut, high_cut, SamplingRate, vec)
   [b, a] = butter(4, ([low_cut, high_cut]/(SamplingRate/2)), 'bandpass'); % used to be 4
   sig = filtfilt(b, a, vec);
end