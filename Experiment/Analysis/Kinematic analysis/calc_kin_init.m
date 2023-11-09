% -------------------------------------------------------------------------
% Here we set some parameters for the main script calc_kin_rt_mt.m
% -------------------------------------------------------------------------
% Initialize table to create excel file with early release trials or
% excluded trials (if one decision is excluded, all the trial is excluded)
exc = table();

% number of bins for normalization
bin = 100;

% rt minimum number of ms to classify a trial as an 'early start' trial.
% The check is done in calc_kin_trial.m
rt_min = 100;

% -------------------------------------------------------------------------
% Set directory paths:

% 1. Set main data path (where the original EXCEL FILES are located)
if flag_hd % currently we are using the hard drive only!
    path_data = 'F:\jmd_experiment_final\joint-motor-decision\kin_data\Cleaned';
else
    path_data = 'Y:\Datasets\JointMotorDecision\Static\Cleaned';
end

% 2. Set "kin path": MAT FILES created with main-c3d-toolbox
path_kin  = fullfile(path_data,'..\Processed');

% 3. Set figure path for trial-by-trial plots (if necessary at all)
figurepath = fullfile(path_data,'..\Processed\trialPlots');

% 4. Retrieve folder path to create list with pair numbers (S1xx)
% We have 15 pairs: S108, S110-S118, S120-124 
% Note: We need to exclude S119 because the pair had too many early starts.
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'S1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);
% *Change here if you want to check specific pairs only*
% SUBJECTS = [SUBJECTS(2)]; %[SUBJECTS(2) SUBJECTS(4)];
% -------------------------------------------------------------------------


% Initialize time & space matrices for non-normalized trajectories (no bins)
max_samples = 800; % 800 frames = 8 seconds
max_trial   = 320; % 320 decisions XXX why not 160?

if not(flag_bin)
    % for blue agent
    all_time_traj_index_b = NaN*ones(max_samples,3,max_trial);
    all_time_traj_ulna_b  = NaN*ones(max_samples,3,max_trial);
    all_spa_traj_index_b  = NaN*ones(max_samples,3,max_trial);
    all_spa_traj_ulna_b   = NaN*ones(max_samples,3,max_trial);
    % for yellow agent
    all_time_traj_index_y = NaN*ones(max_samples,3,max_trial);
    all_time_traj_ulna_y  = NaN*ones(max_samples,3,max_trial);
    all_spa_traj_index_y  = NaN*ones(max_samples,3,max_trial);
    all_spa_traj_ulna_y   = NaN*ones(max_samples,3,max_trial);
end

% Decide if you want to analyze full data set or 
% if you want to start from backup (in case of previous crash)
crash = input('do you want to start from backup? (1/0)\n','s');
if str2double(crash) 
    [filename, pathname, filterindex] = uigetfile(path_kin,'.mat');
    load(fullfile(pathname,filename));
    data_bkp        = data; % 'data' is now 'data_bkp' to avoid overwriting
    file_split      = split(filename,'_');
    trial_crash_str = cell2mat(file_split(end));
    trialstart_num  = str2double(trial_crash_str(1:end-4)); % start at later trial
else
    trialstart_num = 1;
end


% Random note on median split:
% The median is the value separating the higher half from the lower half 
% of a data sample; it may be thought of as "the middle" value.
% Standard median splits can be used on either continuous or
% ordinal variables to turn them into dichotomous variables (i.e.,
% categorical variables with two groups). This is done by putting all
% cases that are below the median into a "low” group and all cases that
% are above the median into a “high” group.

% script version: 1 Nov 2023