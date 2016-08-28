function data = load_data(settings, params)
%% Load ns3/ns5 files into a struct (data)
file_name = sprintf('%s-%03i.ns%i', settings.file_name_stem, settings.run, settings.ns);
data.NS = openNSx(fullfile(settings.path2data,file_name),'precision','double','skipfactor',1);
% Extract only relevant data for this run
start_run_time = round(settings.run_start_time * params.samplingRate_data);
end_run_time = round(settings.run_end_time * params.samplingRate_data);
data.NS.Data = data.NS.Data(:, start_run_time:end_run_time); 

%%
data.labels = {data.NS.ElectrodesInfo.Label}';
data.samplingRate = data.NS.MetaTags.SamplingFreq;

%% If audio is recorded (microphone) - comment out if not
switch settings.microphone_data
    case 'NS'
        settings.ns = 5; % Audio data (microphone) is found in ns5 files.
        file_name = sprintf('%s-%03i.ns%i', settings.file_name_stem, settings.run, settings.ns);
        NS=openNSx(fullfile(settings.path2data,file_name),'precision','double','skipfactor',1);
        data.audio = NS.Data(3,:); % Take the audio (microphone) channel of this recording.
        data.samplingRate_audio = NS.MetaTags.SamplingFreq;
        data.audio = data.audio - mean(data.audio);
        audiowrite(fullfile(settings.path2output, ['microphone_', file_name(1:end-4), '.wav']), data.audio, params.samplingRate_microphone)
        % Extract microphone audio only for current run times
        data.audio = data.audio(settings.run_start_time*params.samplingRate_microphone:settings.run_end_time*params.samplingRate_microphone); 
        data.audio_filtered = LowPass_Signal(2000, params.samplingRate_microphone, data.audio);
    case 'FILE'
        [data.audio, ~] = audioread(fullfile(settings.path2data, settings.microphone_filename));
        data.audio = data.audio(round(settings.run_start_time*params.samplingRate_microphone):round(settings.run_end_time*params.samplingRate_microphone)); 
        data.audio_filtered = data.audio; % Assuming the mic file is already filtered
end

if settings.view_data
    figure;set(gcf, 'color', [1 1 1])
    subplot(211);plot(data.audio_filtered);title('microphone') % Plot microphone and channel example
    subplot(212);plot(data.NS.Data(1,:));title('channel')
end

end

function sig = LowPass_Signal(high_cut, SamplingRate, vec)

   [b_low, a_low] = butter(4, (high_cut/SamplingRate)*2); % used to be 4
   sig = filtfilt(b_low, a_low, vec);

end