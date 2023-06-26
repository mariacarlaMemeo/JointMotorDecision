%% Check the trial length for pilota data of the Joint Motor Decision experiment
clear
close all

%path
path_project = 'Y:\Datasets\JointMotorDecision\Static\';
path_cleaned = fullfile(path_project, 'Cleaned\');
path_processed = fullfile(path_project, 'Processed\');

%% Load each processed mat file per subject
folder_list = dir([path_processed,'\*.mat']);
folder_list = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};

%Initialize table for all the results
l_samp     = [];

for subj = 4:length(SUBJECTS)
    
    clear tsamp

    %load the data
    path_data_each = fullfile(path_processed,SUBJECTS{subj});
    load(path_data_each);

    if subj==1
        session = {session{1,1:477}};
    elseif subj==2 || subj==3 
        session = {session{1,25:end}};
    elseif subj==4
        session = {session{1,19:end}};
    end

    %open mat file and check trial length and assign 1 if the legnth is
    %smaller than 30 samples (trial is shorter than 300ms)
    l_samp = table(int8(cell2mat(cellfun(@(s) s.info.nSamples,session,'uni',0))<30)');

    writetable(l_samp,[SUBJECTS{subj}(1:4) '_tsamples.xlsx'])
end


