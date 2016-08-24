function stimuliArrayNew = get_triggers(microphone_data, settings, params)
microphone_data = microphone_data - mean(microphone_data);
max_audio_recording = max(microphone_data);
%%
[stimuliArrayNew,phonemes] = CreateStructure(settings.phonemes_language);

switch settings.phonemes_language
    % Start/end time and number of instances
    case 'Hebrew' 
        num_of_instances_per_phoneme = 2;
    case 'English'
        num_of_instances_per_phoneme = 8;
end

%%
for ph=1:length(phonemes)
    curr_ph = phonemes{ph};
    if strcmp(curr_ph, 'zja'); curr_ph = 'z''a'; end
    
    switch ceil(ph/27)
        case 1
            speaker = 'Aviad';
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
    Results=[];     
    [c,lags] = xcorr(CurrentStimulus_resampled', microphone_data, 'none');
    [pks, locs] = findpeaks(c,'minpeakheight',0);
    [~,IX] = sort(pks, 'descend');
    Results =  [Results;abs(lags(locs(IX)))]';
    
    %
    current_start_points = [];
    current_rejection = [];
    for r=1:size(Results,1)
        % Stop if all phoneme tokens were found
        if (length(current_start_points)==num_of_instances_per_phoneme)
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
        
        % Ask user if it's ok and get start point
        if (exist==0)
            repeat=0;
            while repeat==0
                phoneme_start_point = Results(r);
                sound_extracted = microphone_data(phoneme_start_point:phoneme_start_point+params.samplingRate_microphone);
                sound(sound_extracted,params.samplingRate_microphone);
                x = input([curr_ph ' start time: ' num2str(phoneme_start_point/params.samplingRate_microphone) 'secs; 1 - accept, 2 - reject, 3 - repeat']);
                if (x==1)
                    stimuliArrayNew.(phonemes{ph}) = [stimuliArrayNew.(phonemes{ph}) phoneme_start_point/params.samplingRate_microphone];
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


function [stimuliArrayNew,phonemes]=CreateStructure(phoneme_language)
    switch phoneme_language
        case 'Hebrew'
            phonemes = {'A' 'ba' 'tsa' };%'da' 'dja' 'e' 'fa' 'ga' 'ha' 'i' 'ka' 'la' 'ma' 'na' 'o' 'pa' 'ra' 'sa' 'sha' 'ta' 'tsha' 'u' 'va' 'xa' 'ya' 'za' 'zja'},1,3);
%             phonemes = repmat({'A' 'ba' 'tsa' 'da' 'dja' 'e' 'fa' 'ga' 'ha' 'i' 'ka' 'la' 'ma' 'na' 'o' 'pa' 'ra' 'sa' 'sha' 'ta' 'tsha' 'u' 'va' 'xa' 'ya' 'za' 'zja'},1,3);
        case 'English'
            phonemes = {'a' 'ba' 'cha' 'da' 'dha' 'dja' 'e' 'fa' 'ga' 'gna' 'ha' 'i' 'ka' 'la' 'ma' 'na' 'o' 'pa' 'ra' 'sa' 'sha' 'ta' 'tha' 'u' 'va' 'wa' 'ya' 'za' 'zja'};
    end

    for i=1:length(phonemes)
        stimuliArrayNew.(phonemes{i}) = [];
    end

end