function results = extract_events(data, events, settings, params)
% This function gets a continuous data from all channels and extract neural
% activation around the events only.
%
% Input variables:
% data: num_channels * num_time_points
% event: struct; Each field corresponds to an event type (phoneme), 
% containing all starting points of the stimuli.
%
% Ouput variables:
% results: struct; Each field corresponds to an event type, consisting of a
% matrix (rows - observations, columns (number of time points).

num_channels = size(data, 1);
conditions = fieldnames(events);
for channel = 1:num_channels
    curr_channel_data = data(channel,:);
    for cond = 1:length(conditions)
        % Take current condition (phoneme)
        curr_cond = conditions{cond};
        results(channel).(curr_cond) = [];
        
        % Loop over all event for this condition
        event_start_times = events.(curr_cond);
        num_events = length(event_start_times);
        for event = 1:num_events
            start_time = event_start_times(event);
            event_data = curr_channel_data(round(start_time*params.samplingRate_data - params.time_before_onset*1e-3*params.samplingRate_data):round(start_time*params.samplingRate_data + params.time_after_onset*1e-3*params.samplingRate_data));
            results(channel).(curr_cond) = [results(channel).(curr_cond); event_data];
        end
        
    end
end
end