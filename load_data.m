function data = load_data(settings, params)
%% Load ns3/ns5 files into a struct (data)
file_name = sprintf('%s-%03i.ns%i', settings.file_name_stem, settings.run, settings.ns);
data.NS = openNSx(fullfile(settings.path2file,file_name),'precision','double','skipfactor',1);
% Extract only relevant data for this run
start_run_time = round(settings.run_start_time * params.samplingRate_data);
end_run_time = round(settings.run_end_time * params.samplingRate_data);
data.NS.Data = data.NS.Data(:, start_run_time:end_run_time); 

%%
data.labels = {data.NS.ElectrodesInfo.Label}';
data.samplingRate = data.NS.MetaTags.SamplingFreq;

%% If audio is recorded (microphone) - comment out if not
settings.ns = 5; % Audio data (microphone) is found in ns5 files.
file_name = sprintf('%s-%03i.ns%i', settings.file_name_stem, settings.run, settings.ns);
NS=openNSx(fullfile(settings.path2file,file_name),'precision','double','skipfactor',1);
data.audio = NS.Data(3,:); % Take the audio (microphone) channel of this recording.
data.samplingRate_audio = NS.MetaTags.SamplingFreq;
data.audio = data.audio - mean(data.audio);
% Extract microphone audio only for current run times
data.audio = data.audio(settings.run_start_time*params.samplingRate_microphone:settings.run_end_time*params.samplingRate_microphone); 
data.audio_filtered = LowPass_Signal(2000, params.samplingRate_microphone, data.audio);


end

function sig = LowPass_Signal(high_cut, SamplingRate, vec)

   [b_low, a_low] = butter(4, (high_cut/SamplingRate)*2); % used to be 4
   sig = filtfilt(b_low, a_low, vec);

end