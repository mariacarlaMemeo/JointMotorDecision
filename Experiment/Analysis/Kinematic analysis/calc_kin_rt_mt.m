% -------------------------------------------------------------------------
% MAIN SCRIPT for pre-processing kinematic data from jmd-project.
%
% Written by Mariacarla Memeo & Laura Schmitz
% November 2023
% -------------------------------------------------------------------------

% Functions and scripts called from within here:
% 1. calc_kin_init
% 2. calc_kin_trial
% 3. ave_subj_plotting_new

% NOTE: AFTER RUNNING THE MAIN-C3D-TOOLBOX SCRIPT, COPY THE CREATED
% .MAT FILES FROM THE REPO TO THE HARD DRIVE (SEE PATH KIN)
% !Watch out for pairs S110/S112 where 1/2 trials are missing!

% Data structure in Excel file:
% Each row contains 1 trial, which consists of 3 decisions.
% Trial order is always:
% ODD TRIAL : blue (individual) - yellow (individual) - blue (collective)
% EVEN TRIAL: yellow (individual) - blue (individual) - yellow (collective)

clear
close all

try % main try/catch statement

%% First set flags (1=yes,0=no)
flag_hd    = 1; % retrieve data from hard drive? -> set to 1!
flag_plot  = 1; % 1 plot per agent with all trajectories ("exploratory plots")?
trial_plot = 0; % 1 plot per trial (for cutting and visual inspection)?
med_split  = 1; % median split for confidence?
flag_bin   = 1; % normalize trajectories to 100 bins?
flag_write = 0; % write Excel files and save mat files?

% select which decision to plot: 1 = 1st, 2 = 2nd, 3 = coll., 4 = 1st & 2nd
which_Dec  = 1; 
if which_Dec ~= 2 % save Excel file only for 2nd decision
    flag_write = 0;
end

%%%%%%%%%%%% initialize parameters in separate script %%%%%%%%%%%%%%%%%%%%%
calc_kin_init;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Start pair loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p = 1:length(SUBJECTS) % run through all pairs (1 SUBJECT = 1 pair)

    disp(['Start ' SUBJECTS{p}(2:end)]);
    close all
    early_count = 0; % counter for trials where agent started before prompt
    
    %% Locate and load data for current pair

    % *MAT FILE*: Locate 'session' struct for current pair
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);
    % Load mat file and check time
    tic
    load(path_kin_each);
    toc
    % Create folder to save trial-by-trial plots for this pair    
    mkdir(fullfile(figurepath,SUBJECTS{p}));
    % Remove trials in 'session' cell to avoid inserting the (last?) trials
    % in which the 'marker' field is missing
    mark     = cell2mat(cellfun(@(s) isfield(s,'markers'),session,'uni',0));
    sMarkers = session(mark);

    % *EXCEL FILE*: Locate file for current pair
    path_data_each = fullfile(path_data,SUBJECTS{p},['S' SUBJECTS{p}(2:end) '.xlsx']);
    % Read Excel file
    [~,txt_or,raw] = xlsread(path_data_each);
    
    %% Process "raw" data from Excel file
    raw  = raw(2:end,:); % remove header
    % create header for additional variables (computed and added later)
    txt  = [txt_or{1,:} {'switch' 'rt_final1' 'rt_final2' 'rt_finalColl' ...
                                  'dt_final1' 'dt_final2' 'dt_finalColl' ...
                                  'mt_final1' 'mt_final2' 'mt_finalColl'} ...
                         cellstr(strcat('vel_ind2_',string(1:bin))), ...
                         cellstr(strcat('acc_ind2_',string(1:bin))), ...
                         cellstr(strcat('jrk_ind2_',string(1:bin))), ...
                         cellstr(strcat('vel_uln2_',string(1:bin))), ...
                         cellstr(strcat('acc_uln2_',string(1:bin))), ...
                         cellstr(strcat('jrk_uln2_',string(1:bin))), ...
                         cellstr(strcat('x_ind2_',string(1:bin))), ...
                         cellstr(strcat('x_uln2_',string(1:bin))), ...
                         cellstr(strcat('z_ind2_',string(1:bin))), ...
                         cellstr(strcat('z_uln2_',string(1:bin))), ...
                         'tstart1' 'tmove1' 'tstop1' ...
                         'tstart2' 'tmove2' 'tstop2' ...
                         'tstartColl' 'tmoveColl' 'tstopColl'];
    data = cell2table(raw); % convert to table
    
    % Retrieve the decision data (1st, 2nd, collective)
    at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
    pairS.at1stDec       = cell2mat(raw(:,at1stDec_ind));
    at2ndDec_ind   = strcmp('AgentTakingSecondDecision',txt);
    pairS.at2ndDec       = cell2mat(raw(:,at2ndDec_ind));
    atCollDec_ind  = strcmp('AgentTakingCollDecision',txt);
    pairS.atCollDec      = cell2mat(raw(:,atCollDec_ind));
    % Retrieve the confidence of each agent (blue, yellow)
    blue_Conf_ind  = strcmp('B_conf',txt);
    pairS.blue_Conf      = cell2mat(raw(:,blue_Conf_ind));
    yell_Conf_ind  = strcmp('Y_conf',txt);
    pairS.yell_Conf      = cell2mat(raw(:,yell_Conf_ind));
    Coll_Conf_ind  = strcmp('Coll_conf',txt);
    pairS.Coll_Conf      = cell2mat(raw(:,Coll_Conf_ind));
    % Retrieve the choice of each agent (blue, yellow, collective)
    blue_Dec_ind   = strcmp('B_decision',txt);
    pairS.blue_Dec       = cell2mat(raw(:,blue_Dec_ind));
    yell_Dec_ind   = strcmp('Y_decision',txt);
    pairS.yell_Dec       = cell2mat(raw(:,yell_Dec_ind));
    Coll_Dec_ind   = strcmp('Coll_decision',txt);
    pairS.Coll_Dec       = cell2mat(raw(:,Coll_Dec_ind));
    % Retrieve the RT of each agent (blue, yellow, collective)
    blue_rt_ind    = strcmp('B_rt',txt);
    blue_rt        = cell2mat(raw(:,blue_rt_ind));
    yell_rt_ind    = strcmp('Y_rt',txt);
    yell_rt        = cell2mat(raw(:,yell_rt_ind));
    Coll_rt_ind    = strcmp('Coll_rt',txt);
    Coll_rt        = cell2mat(raw(:,Coll_rt_ind));

    % Indeces for 1st, 2nd and 3rd decision (needed in trial loop)
    % Note: each trial contains 3 decisions (160 trials = 480 decisions)
    faa = trialstart_num *3 - 2; % faa = first agent acting
    saa = trialstart_num *3 - 1; % saa = second agent acting
    caa = trialstart_num *3;     % caa = coll. agent acting

    
    %%%%%%%%%%%%  Start trial loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tic
    calc_kin_trial; % this runs through all trials for one pair
    toc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % check how many times the pair started before decision prompt
    disp(['Number of early starts for pair ' SUBJECTS{p}(2:end) ': ' num2str(early_count)]);

    % Save mat file for each pair XXX check file name
    if flag_write
        save(fullfile(path_kin,[SUBJECTS{p},'_post_absValues']))
    end

    % ---------------------------------------------------------------------    
    % Classify confidence as high and low, using MEDIAN SPLIT
    % -> In our data sets, the median should usually be 3 because it is the
    % value in the middle that is most common (CHECK THIS).
    % Thus, low confidence would be 1-3 and high would be 4-6; see below.
    if med_split % XXX maybe use median(X,'omitnan')? 
        bConf = pairS.blue_Conf;  % re-name to avoid overwriting
        yConf = pairS.yell_Conf;
        bConf(bConf<=median(bConf)) = 1; % if <= median, classify as low (1)
        bConf(bConf>median(bConf))  = 2; % if > median, classify as high (2)
        yConf(yConf<=median(yConf)) = 1;
        yConf(yConf>median(yConf))  = 2;
        pairS.bConf = bConf;
        pairS.yConf = yConf;

    else % if no median split, categorize as 1-3(low) and 4-6(high) anyway
        bConf = pairS.blue_Conf;
        yConf = pairS.yell_Conf;
        bConf(bConf<4)  = 1;
        bConf(bConf>=4) = 2;
        yConf(yConf<4)  = 1; 
        yConf(yConf>=4) = 2;
        
        pairS.bConf = bConf;
        pairS.yConf = yConf;
    end
    % ---------------------------------------------------------------------

    % Re-name vector that specifies who took the 2nd decision
    %SecondDec = at2ndDec;
    
    % display and save exploratory plots (1 plot per agent with all trials)
    if flag_plot
        ave_subj_plotting_new;
    end
    % Write an additional Excel file to record the number of trial lost for early release of the button (per pair and per agent)
    exc{p,1:4} = [str2double(SUBJECTS{p}(2:end)) early_count SecDec_clean];
    exc.Properties.VariableNames = {'pair','early_start','B_2ndDec','Y_2ndDec'};
    writetable(exc,fullfile(path_kin,'SecDec_cleanAll.xlsx'));

    % clear parameters for next pair
    clear sMarkers session bConf yConf blue_Dec yell_Dec
 
end % end of pair loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


catch me
    % Save mat file as a backup in case of crash
    % XXX change file name to indicate that data not complete!!?
    save(fullfile(path_kin,[SUBJECTS{p},'_trial',num2str(t)]))
end

% script version: 1 Nov 2023