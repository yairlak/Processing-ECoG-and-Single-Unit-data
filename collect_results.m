clear all; close all; clc

%%
[settings, params] = load_settings_params();
first_run = true;
for run = 1:2
    file_name = sprintf('%s_%s_%s_run_%i', settings.patient, settings.file_name_stem, settings.phonemes_language, settings.run);
    data(run) = load(fullfile(settings.path2output, file_name), 'results');
    for channel = 1:length(data(run).results)
        phonemes = fieldnames(data(run).results(channel));
        for ph = 1:length(phonemes)
            curr_ph = phonemes{ph};
            if first_run
                results_all(channel).(curr_ph) = [];
            end            
            results_all(channel).(curr_ph) = [results_all(channel).(curr_ph); data(run).results(channel).(curr_ph)];
        end
    end
    first_run = false;
end

channels = 1:length(results_all);
% channels = 1;
total_activation = zeros(length(channels), length(phonemes));
for channel = channels
   phonemes = fieldnames(results_all(channel));
   for ph = 1:length(phonemes)
        curr_ph = phonemes{ph};
        fprintf('Channel %i phoneme %s\n', channel, curr_ph)
        figure('visible', 'off');
        set(gcf,'color',[1 1 1])
        times = (-params.time_before_onset*1e-3*params.samplingRate_data:params.time_after_onset*1e-3*params.samplingRate_data)/params.samplingRate_data*1000;
        mean_activity = mean(results_all(channel).(curr_ph));
        plot(times, mean_activity, 'linewidth', 2)
        
        st = round(125*1e-3*params.samplingRate_data);
        ed = round(175*1e-3*params.samplingRate_data);
        total_activation(channel, ph) = sum(mean_activity(st:ed));
        
        xlabel('Time (ms)', 'fontsize', 14)
        ylabel('Response', 'fontsize', 14)
        file_name = sprintf('ERP_channel_%i_ph_%s', channel, curr_ph);
        title(strrep(file_name, '_', ' '))
        saveas(gcf, fullfile(settings.path2figures, [file_name, '.png']), 'png')
        close
        
   end
   
    figure('visible', 'off')
    bar(total_activation(channel,:))
    set(gca, 'xtick', 1:length(phonemes),'xticklabel',phonemes)
    saveas(gcf, fullfile(settings.path2figures, ['channel ' num2str(channel) '.png']), 'png')
    close
end