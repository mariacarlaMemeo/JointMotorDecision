% jmd experiment - observation part
% Analysis of pilot data
% December 2022

clear
clc

%% specify file directory
% path with eprime logfiles (.txt format)
pathLogFile = 'C:\Users\Laura\Sync\00_Research\2022_UKE\Confidence from motion\05_Observation task\data\';
%% 


dataset = {};
counter = 0;
cleaneddata = {};
for pair = 100:103 % loops run through all pairs / agents
    for agent = 1:2
        filename = [pathLogFile 'P' num2str(pair) '_A' num2str(agent) '.txt'];
        counter = counter+1;
        if exist(filename) == 2 % 2 = name is a file with extension (.m, .mlx, .mlapp), or the name of a file with a non-registered file extension (.mat, .fig, .txt)
            dataset{counter,1} = readtable(filename);
            cleaneddata{counter,1} = dataset{counter,1}(strcmp(dataset{counter,1}.Procedure,'ShowStim'),[1 31 32 33 39 40 42 48 52 53 62 67]);
            cleaneddata{counter,1} = movevars(cleaneddata{counter,1},'Video','After','ExperimentName');
            cleaneddata{counter,1} = movevars(cleaneddata{counter,1},'StaticMs','After','Video');
            cleaneddata{counter,1} = movevars(cleaneddata{counter,1},'DurataVideo','After','StaticMs');
            cleaneddata{counter,1}.ITI_RESP(isnan(cleaneddata{counter,1}.ITI_RESP)) = 0;
            cleaneddata{counter,1}.MovieStart_RESP(isnan(cleaneddata{counter,1}.MovieStart_RESP)) = 0;
            cleaneddata{counter,1}.SubjResp = cleaneddata{counter,1}.ITI_RESP + cleaneddata{counter,1}.MovieStart_RESP;
            cleaneddata{counter,1}.SubjAcc = cleaneddata{counter,1}.SubjResp == cleaneddata{counter,1}.CorrResp;
            for trial = 1:height(cleaneddata{counter,1}.MovieStart_RT)
                % if the participant's response was too late (>4s), put NaN (instead of 0) in the data file
                if cleaneddata{counter,1}.SubjResp(trial) == 0 
                    cleaneddata{counter,1}.SubjRTnorm(trial) = NaN;
                    cleaneddata{counter,1}.SubjResp(trial) = NaN;
                % if MovieStart_RT=0, the participant answered after the video -> so RT is (video duration + iti rt)/video duration
                elseif cleaneddata{counter,1}.MovieStart_RT(trial) == 0 
                    cleaneddata{counter,1}.SubjRTnorm(trial) = (cleaneddata{counter,1}.DurataVideo(trial) + cleaneddata{counter,1}.ITI_RT(trial))/cleaneddata{counter,1}.DurataVideo(trial);
                % else: participant answered during the video -> so RT is moviestart rt/video duration
                else
                    cleaneddata{counter,1}.SubjRTnorm(trial) = cleaneddata{counter,1}.MovieStart_RT(trial)/cleaneddata{counter,1}.DurataVideo(trial);
                end
            end
            writetable(cleaneddata{counter,1},[pathLogFile 'Results_fromEprime.xlsx'],'Sheet',['P' num2str(pair) '_A' num2str(agent)])
        end
    end
end
