function [settings, params] = load_settings_params()
%% Settings
settings.path2file = fullfile('..\..\Data\ICHILOV Data\G006\raw');
settings.file_name_stem = '20090103-003458';

%% Experiment details
settings.data_type = 'ECoG'; % ECoG/Single-unit (case sensitive!)

% Start/end time-points of current run, according to audio data and its sampling rate
settings.run = 1;
settings.run_start_time = 1.19e6/30000; % in [sec]
settings.run_end_time = 1.58e7/30000; % in [sec]

settings.ns = 3;

settings.phonemes_language = 'Hebrew';
switch settings.phonemes_language
    case 'English'
    case 'Hebrew'
        settings.path2stimuli = '..\..\Stimuli';
end

%% Params
params.line_frequency = 50; % [Hz]
params.freqncyRangeToExtract=0:1:140;
params.time_before_onset = 500; % time from zero when trial start in ms (zero is the fixation cross appearing).
params.time_after_onset = 1000; % time from zero instruction start in ms

params.samplingRate_microphone = 3e4; % [Hz]
params.samplingRate_stimuli=44100; % [Hz]
switch settings.data_type
    case 'ECoG'
        params.samplingRate_data = 2e3; % [Hz]
    case 'Single-unit'
        params.samplingRate_data = 3e4; % [Hz]
end


end