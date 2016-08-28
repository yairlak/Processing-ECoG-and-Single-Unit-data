function [settings, params] = load_settings_params()
%% Settings
settings.patient = 'G006';
settings.path2data = fullfile('..\..\Data\ICHILOV Data\G006\raw');
settings.file_name_stem = '20090103-003458';
settings.path2output = '..\..\Output';
settings.path2figures = '..\..\Figures';
settings.microphone_data = 'FILE'; % NS/FILE/NONE corresponds to take-from-ns-data/take-from-other-file(referred below)/no-mic-data
settings.microphone_filename = 'microphone_20090103-003458-001.wav';

%% Experiment details
settings.data_type = 'ECoG'; % ECoG/Single-unit (case sensitive!)
settings.triggers_method = 'Microphone'; % Trigger_file/Microphone (case sensitive!)
settings.listen2triggers = false; % Do you want to verify the cross-correlation procedure for finding the triggers?
% Start/end time-points of current run, according to audio data and its sampling rate
settings.run = 1;
switch settings.run
    case 1 % RUN 1:
        settings.run_start_time = 1.1e6/30000 - 0.5; % in [sec]
        settings.run_end_time = 1.58e7/30000; % in [sec]
    case 2 % RUN 2:
        settings.run_start_time = 4.6e5/30000; % in [sec]
        settings.run_end_time = 1.517e7/30000; % in [sec]
end

settings.ns = 3;

settings.phonemes_language = 'Hebrew';
switch settings.phonemes_language
    case 'English'
        settings.path2stimuli = '..\..\Stimuli\English';
        settings.num_of_instances_per_phoneme = 8;
        settings.phonemes = {'a' 'ba' 'cha' 'da' 'dha' 'dja' 'e' 'fa' 'ga' 'gna' 'ha' 'i' 'ka' 'la' 'ma' 'na' 'o' 'pa' 'ra' 'sa' 'sha' 'ta' 'tha' 'u' 'va' 'wa' 'ya' 'za' 'zja'};
    case 'Hebrew'
        settings.path2stimuli = '..\..\Stimuli';
        settings.num_of_instances_per_phoneme = 2;
        % Replicate by 3 for Hebrew (three speakers)
        settings.phonemes = repmat({'A' 'ba' 'tsa' 'da' 'dja' 'e' 'fa' 'ga' 'ha' 'i' 'ka' 'la' 'ma' 'na' 'o' 'pa' 'ra' 'sa' 'sha' 'ta' 'tsha' 'u' 'va' 'xa' 'ya' 'za' 'zja'}, 1, 3);
%         settings.phonemes = repmat({'A' 'ba' 'tsa'}, 1, 3);
end

%% What to plot
settings.view_data = false;

%% Params
params.line_frequency = 50; % [Hz]
params.freqncyRangeToExtract = 0:1:140;
params.time_before_onset = 500; % [ms] time window before stimulus onset.
params.time_after_onset = 1000; % [ms] time window of the trial after onset.

params.samplingRate_microphone = 3e4; % [Hz] of audio channel
params.samplingRate_stimuli=44100; % [Hz] of audio stimuli
switch settings.data_type
    case 'ECoG'
        params.samplingRate_data = 2e3; % [Hz]
    case 'Single-unit'
        params.samplingRate_data = 3e4; % [Hz]
end

params.ECoG_lowCut_freq  = 75; % [Hz]
params.ECoG_highCut_freq = 150; % [Hz]

end