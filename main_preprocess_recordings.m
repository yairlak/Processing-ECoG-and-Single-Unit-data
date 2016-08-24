clear all; close all; clc

%%
addpath(genpath('NPMK 2.5.5.0'))
addpath(genpath('MatlabToolShani'))

%%
[settings, params] = load_settings_params();

%%
data = load_data(settings, params);
figure;subplot(211);plot(data.audio)
subplot(212);plot(data.NS.Data(1,:))

%%
data.events = get_triggers(data.audio_filtered, settings, params);

%%
data = preprocess_data(data, settings, params);

%%
results = extract_events(data.NS.Data_filtered, data.events, settings, params);
