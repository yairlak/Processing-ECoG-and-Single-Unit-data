clear all; close all; clc
%%
addpath(genpath('NPMK 2.5.5.0'))
addpath(genpath('MatlabToolShani'))

%% Load settings and parameters
[settings, params] = load_settings_params();

%% Load raw recording data and triggers
data = load_data(settings, params);

%% Preprocess data (filtering, spike sorting, etc.)
data = preprocess_data(data, settings, params);

%% Arrange triggers in a struct (either from a microphone or a file).
data.events = get_triggers(data, settings, params);

%% Extract and arrange events from continuous data according to triggers
results = extract_events(data.NS.Data_filtered, data.events, settings, params);

%% Save results for this run to output directory
file_name = sprintf('%s_%s_%s_run_%i', settings.patient, settings.file_name_stem, settings.phonemes_language, settings.run);
save(fullfile(settings.path2output, file_name), 'results', 'settings', 'params')