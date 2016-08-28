function events = get_triggers(data, settings, params)
switch settings.triggers_method
    case 'Trigger_file' % Stimulus triggers were sent to recording device
        % --- Fill in ----
    case 'Microphone' % Experiment was recorded with a mic
        microphone_data = data.audio_filtered;
        max_audio_recording = max(microphone_data);
        
        %% Loop over all phoneme tokens and search location in waveform
        for ph=1:length(settings.phonemes)
            curr_ph = settings.phonemes{ph}          
            if strcmp(curr_ph, 'zja'); curr_ph = 'z''a'; end
            switch ceil(ph/(length(settings.phonemes)/3))
                case 1
                    speaker = 'Aviad';
                    events.(settings.phonemes{ph}) = [];
                case 2
                    speaker = 'Limor';
                case 3
                    speaker = 'Yair';
            end
            
            % Load stimulus and resample it
            file_name = sprintf('%s_%s_trial.wav', speaker, curr_ph);
            [CurrentStimulus, ~] = audioread(fullfile(settings.path2stimuli, settings.phonemes_language, file_name));
            CurrentStimulus_resampled = resample(CurrentStimulus, params.samplingRate_microphone, params.samplingRate_stimuli);
            CurrentStimulus_resampled = CurrentStimulus_resampled - mean(CurrentStimulus_resampled);
            max_curr_stimulus = max(CurrentStimulus_resampled);
            CurrentStimulus_resampled = CurrentStimulus_resampled * max_audio_recording/max_curr_stimulus;
            % Cross-correlation with microphone
            [c, lags] = xcorr(CurrentStimulus_resampled', microphone_data, 'none');
            dr = diff(c);
            IX = find(dr(1:end-1) .* dr(2:end) <= 0) + 1;
            c = c(IX);
            lags = lags(IX);
            [~,perm] = sort(c, 'descend');
            lags = lags(perm);
            Results = [];     
            Results =  [Results; abs(lags)]';
            
            if ~settings.listen2triggers
                % Take two highest results
                start_points = abs(Results(1:settings.num_of_instances_per_phoneme));
                events.(settings.phonemes{ph}) = [events.(settings.phonemes{ph}) start_points'/params.samplingRate_microphone];
            else
                % Go Over best fit (between stimulus and microphone) locations in descending order. 
                current_start_points = [];
                current_rejection = [];
                for r=1:size(Results,1)
                    % Stop if all phoneme tokens were found
                    if (length(current_start_points)==settings.num_of_instances_per_phoneme)
                        break;            
                    end

                    % Check if current suspect is not among previous ones
                    exist = 0;
                    for ur=1:length(current_start_points)
                        if ~(Results(r)+params.samplingRate_microphone<current_start_points(ur) || Results(r)>(current_start_points(ur)+params.samplingRate_microphone))
                            exist = 1;
                            break;
                        end
                    end        
                    for ur=1:length(current_rejection)
                        if ~(Results(r)+params.samplingRate_microphone<current_rejection(ur) || Results(r)>(current_rejection(ur)+params.samplingRate_microphone))
                            exist = 1;
                            break;
                        end
                    end    

                    % Ask user if it's ok and get stimulus' start point
                    if (exist==0)
                        repeat=0;
                        while repeat==0
                            phoneme_start_point = Results(r);
                            sound_extracted = microphone_data(phoneme_start_point-0.05*params.samplingRate_microphone:phoneme_start_point+params.samplingRate_microphone);
                            sound(sound_extracted,params.samplingRate_microphone);
                            x = input([curr_ph ' start time: ' num2str(phoneme_start_point/params.samplingRate_microphone) 'secs; 1 - accept, 2 - reject, 3 - repeat']);
                            if (x==1)
                                events.(settings.phonemes{ph}) = [events.(settings.phonemes{ph}) phoneme_start_point/params.samplingRate_microphone];
                                current_start_points = [current_start_points phoneme_start_point]
                                repeat=1;
                            elseif (x==2)
                                ['rejected']
                                current_rejection = [current_rejection phoneme_start_point];
                                current_start_points
                                repeat=1;
                            end
                        end
                    end
                end
            end    
        end
end

end