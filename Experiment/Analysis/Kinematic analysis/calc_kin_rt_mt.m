% -------------------------------------------------------------------------
% MAIN SCRIPT for pre-processing kinematic data from jmd-project.
%
% Written by Mariacarla Memeo & Laura Schmitz
% November 2023
% -------------------------------------------------------------------------

% Functions and scripts called from within here:
% 1. userInput
% 2. calc_kin_init
% 3. calc_kin_trial
% 4. ave_subj_plotting_new

% Data organization in original Excel file:
% Each row contains 1 trial, which consists of 3 decisions.
% Trial order is always:
% ODD TRIAL : blue (individual) - yellow (individual) - blue (collective)
% EVEN TRIAL: yellow (individual) - blue (individual) - yellow (collective)

clear
close all
clc

try % main try/catch statement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First ask for user input and set flags 
userInput;
% Then initialize parameters in separate script
calc_kin_init;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Start pair loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p = 1:length(SUBJECTS) % run through all pairs (1 SUBJECT = 1 pair)

    % clear variables before loading next pair
    if length(SUBJECTS)>1
        clear sMarkers session bConf yConf blue_Dec yell_Dec
    end
    
    disp(['Start ' SUBJECTS{p}(2:end)]);
    close all
    % re-set flags before starting new pair
    early_count    = 0; % counter for trials where agent started before prompt
    excl_trial     = 0; % counter for additional exclusions (should be 0) 
    % create file names for current pair
    %filenameExcel = fullfile(path_kin,['expData_' SUBJECTS{p}(2:end) '_kin_model.xlsx']);
    filenameExcel = fullfile(path_kin,['jmdData_S' SUBJECTS{p}(2:end) '.xlsx']);
    filenameMat   = fullfile(path_kin,[SUBJECTS{p},'_post.mat']);

    %% Locate and load data for current pair

    % *MAT FILE*: Locate 'session' struct for current pair
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);
    % Load mat file
    load(path_kin_each);
    
    % Delete/Create folder to save trial-by-trial plots for this pair
    % -> delete folder only if you are plotting trials, if folder already
    % exists,if you dont start from backup and if you are not debugging
%     if trial_plot && isfolder(fullfile(figurepath,SUBJECTS{p})) && ...
%                      str2double(crash)==0 && debug==0
%         rmdir(fullfile(figurepath,SUBJECTS{p}),'s'); % delete folder incl. plots
%     end
%     if trial_plot
%         mkdir(fullfile(figurepath,SUBJECTS{p})); % create folder
%     end
    % DO THIS INSTEAD (SAFER, AVOIDS DELETING BY MISTAKE)
    if trial_plot
        if isfolder(fullfile(figurepath,SUBJECTS{p}))
            promptMessage = sprintf('The trial plot folder already exists. Do you want to delete it?');
            titleBarCaption = 'Delete?';
            buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
            if strcmpi(buttonText, 'No')
                deletePlots = false;
            elseif strcmpi(buttonText, 'Yes')
                deletePlots = true;
            end
            if deletePlots
                rmdir(fullfile(figurepath,SUBJECTS{p}),'s'); % delete folder incl. plots
                mkdir(fullfile(figurepath,SUBJECTS{p})); % create empty folder
            end
        else
            mkdir(fullfile(figurepath,SUBJECTS{p})); % create empty folder
        end
    end
    
    % Remove trials in 'session' cell to avoid inserting the (last?) trials
    % in which the 'marker' field is missing
    mark     = cell2mat(cellfun(@(s) isfield(s,'markers'),session,'uni',0));
    sMarkers = session(mark);
%     checkPairName = cell2mat(cellfun(@(s) all(contains(fieldnames(s.markers),SUBJECTS{p})),sMarkers,'uni',0))

    % *EXCEL FILE*: Locate file for current pair
    path_data_each = fullfile(path_data,SUBJECTS{p},['S' SUBJECTS{p}(2:end) '.xlsx']);
    % Read Excel file
    [~,txt_or,raw] = xlsread(path_data_each);
    
    %% Process "raw" data from Excel file
    raw  = raw(2:end,:); % remove header
    % create header for additional variables (computed and added later)
    txt  = [txt_or{1,:} 'switch' 'rt_final1' 'rt_final2' 'rt_finalColl' ...
                                  'dt_final1' 'dt_final2' 'dt_finalColl' ...
                                  'mt_final1' 'mt_final2' 'mt_finalColl' ...
                         cellstr(strcat('vel_ind2_',string(1:bin))), ...
                         cellstr(strcat('acc_ind2_',string(1:bin))), ...
                         cellstr(strcat('jrk_ind2_',string(1:bin))), ...
                         cellstr(strcat('vel_uln2_',string(1:bin))), ...
                         cellstr(strcat('acc_uln2_',string(1:bin))), ...
                         cellstr(strcat('jrk_uln2_',string(1:bin))), ...
                         cellstr(strcat('x_ind2_',string(1:bin))), ...
                         cellstr(strcat('z_ind2_',string(1:bin))), ...
                         cellstr(strcat('x_uln2_',string(1:bin))), ...
                         cellstr(strcat('z_uln2_',string(1:bin))), ...
                         'tstart1' 'tmove1' 'tstop1' ...
                         'tstart2' 'tmove2' 'tstop2' ...
                         'tstartColl' 'tmoveColl' 'tstopColl' ...
                         'trgChange1' 'trgChange2' 'trgChangeColl' ...
                         'mod1' 'mod2' 'modColl'...
                         'startCrt1' 'startCrt2' 'startCrtColl'...
                         'npIndex1' 'npIndex2' 'npIndexColl' ...
                         'npUlna1' 'npUlna2' 'npUlnaColl' ...
                         'peaksIndex1' 'peaksIndex2' 'peaksIndexColl' ...
                         'peaksUlna1' 'peaksUlna2' 'peaksUlnaColl' ...
                         'peaksLocIndex1' 'peaksLocIndex2' 'peaksLocIndexColl' ...
                         'peaksLocUlna1' 'peaksLocUlna2' 'peaksLocUlnaColl'];
    data = cell2table(raw); % convert to table
    
    % Retrieve information from Excel file and save in *pairS structure*
    % Retrieve WHICH AGENT took which decision (1st, 2nd, collective)
    at1stDec_ind    = strcmp('AgentTakingFirstDecision',txt);
    pairS.at1stDec  = cell2mat(raw(:,at1stDec_ind));
    at2ndDec_ind    = strcmp('AgentTakingSecondDecision',txt);
    pairS.at2ndDec  = cell2mat(raw(:,at2ndDec_ind));
    atCollDec_ind   = strcmp('AgentTakingCollDecision',txt);
    pairS.atCollDec = cell2mat(raw(:,atCollDec_ind));
    % Retrieve the CONFIDENCE of each agent (blue, yellow, collective)
    blue_Conf_ind   = strcmp('B_conf',txt);
    pairS.blue_Conf = cell2mat(raw(:,blue_Conf_ind));
    yell_Conf_ind   = strcmp('Y_conf',txt);
    pairS.yell_Conf = cell2mat(raw(:,yell_Conf_ind));
    Coll_Conf_ind   = strcmp('Coll_conf',txt);
    pairS.Coll_Conf = cell2mat(raw(:,Coll_Conf_ind));
    % Retrieve the DECISION of each agent (blue, yellow, collective)
    blue_Dec_ind    = strcmp('B_decision',txt);
    pairS.blue_Dec  = cell2mat(raw(:,blue_Dec_ind));
    yell_Dec_ind    = strcmp('Y_decision',txt);
    pairS.yell_Dec  = cell2mat(raw(:,yell_Dec_ind));
    Coll_Dec_ind    = strcmp('Coll_decision',txt);
    pairS.Coll_Dec  = cell2mat(raw(:,Coll_Dec_ind));
    % Retrieve the RT of each agent (blue, yellow, collective)
    blue_rt_ind     = strcmp('B_rt',txt);
    blue_rt         = cell2mat(raw(:,blue_rt_ind));
    yell_rt_ind     = strcmp('Y_rt',txt);
    yell_rt         = cell2mat(raw(:,yell_rt_ind));
    Coll_rt_ind     = strcmp('Coll_rt',txt);
    Coll_rt         = cell2mat(raw(:,Coll_rt_ind));

    % ---------------------------------------------------------------------
    % Classify confidence as high and low, using MEDIAN SPLIT
    % -> In our data sets, the median should usually be 3 because it is the
    % value in the middle that is most common (CHECK THIS).
    % Thus, low confidence would be 1-3 and high would be 4-6; see below.
    if med_split % XXX maybe use median(X,'omitnan')?
        bConf    = pairS.blue_Conf; % re-name to avoid overwriting
        yConf    = pairS.yell_Conf;
        collConf = pairS.Coll_Conf;
        bConf(bConf<=median(bConf)) = 1; % if <= median, classify as low (1)
        bConf(bConf>median(bConf))  = 2; % if > median, classify as high (2)
        yConf(yConf<=median(yConf)) = 1;
        yConf(yConf>median(yConf))  = 2;
        collConf(collConf<=median(collConf)) = 1;
        collConf(collConf>median(collConf))  = 2;
        pairS.bConf = bConf; % save high/low confidence in pairS structure
        pairS.yConf = yConf;
        pairS.collConf = collConf;

    else % if no median split, categorize as 1-3(low) and 4-6(high) anyway
        bConf = pairS.blue_Conf;
        yConf = pairS.yell_Conf;
        collConf = pairS.Coll_Conf;
        bConf(bConf<4)  = 1;
        bConf(bConf>=4) = 2;
        yConf(yConf<4)  = 1;
        yConf(yConf>=4) = 2;
        collConf(collConf<4)  = 1;
        collConf(collConf>=4) = 2;
        pairS.bConf = bConf;
        pairS.yConf = yConf;
        pairS.collConf = collConf;
    end
    % ---------------------------------------------------------------------

    % Indices for 1st, 2nd and 3rd decision (needed in trial loop)
    % Note: each trial contains 3 decisions (160 trials = 480 decisions)
    faa = trialstart_num *3 - 2; % faa = first agent acting
    saa = trialstart_num *3 - 1; % saa = second agent acting
    caa = trialstart_num *3;     % caa = coll. agent acting

    
    %%%%%%%%%%%%  Start trial loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    t_trialstart = tic;
    calc_kin_trial; % this runs through all trials for current pair p
    trialtime = toc(t_trialstart);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Display trial processing time and "early starts" (starts before decision prompt)
    disp(['Processing time for pair ' SUBJECTS{p}(2:end) ': ' num2str(round(trialtime,1)) ' seconds']);
    disp(['Number of early starts for pair ' SUBJECTS{p}(2:end) ': ' num2str(early_count)]);
    disp(['Number of additional exclusions for pair ' SUBJECTS{p}(2:end) ': ' num2str(excl_trial)]);

    % Save mat file for each pair
    if flag_write && ~any([savemat1,savemat2,savematColl])
        if exist(filenameMat,'file') == 2
            % if .mat file already exists, ask user before overwriting
            promptMessage = sprintf('This file already exists:\n%s\nDo you want to overwrite it?', filenameMat);
            titleBarCaption = 'Overwrite?';
            % ButtonName = questdlg(Question, Title, Btn1, Btn2, DEFAULT);
            buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
            if strcmpi(buttonText, 'No') % User does not want to overwrite.
                overwriteMatFile = false;
            elseif strcmpi(buttonText, 'Yes')
                overwriteMatFile = true;
            end
            if overwriteMatFile % User wants to overwrite: delete old file and write new file
                delete(filenameMat);
                save(filenameMat); % save all the variables in workspace
                % add "_post" to distinguish from original acquisition .mat file
                fprintf(1, '\n');
                disp(['Complete "_post" matfile saved for pair ', num2str(SUBJECTS{p}), '.']);
            end
        else
            save(filenameMat); % save all the variables in workspace
            % add "_post" to distinguish from original acquisition .mat file
            fprintf(1, '\n');
            disp(['Complete "_post" matfile saved for pair ', num2str(SUBJECTS{p}), '.']);
        end
   end
    
    % display and save exploratory plots (1 plot per agent with all trials)
    if flag_plot
        ave_subj_plotting_new;
    end

    % Write additional Excel file to record the number of excluded trials
    % early_start = if agent starts before decision prompt (on pair basis)
    % short_rt = if startFrame=NaN in movement_onset (on pair basis) -> should be 0
    % B_2ndDec = no. of plotted (i.e., clean!) trials in which B takes 2nd decision
    % Y_2ndDec = no. of plotted (i.e., clean!) trials in which Y takes 2nd decision
    % -> B_2ndDec + Y_2ndDec            = total number of clean trials for the pair
    % -> 160 - (early_start + short_rt) = total number of clean trials for the pair
    % NOTE: this file is created only if plots are created for dec1 or dec2
    if flag_plot == 1 && (which_Dec == 1 || which_Dec == 2)
        exc{p,1:5} = [str2double(SUBJECTS{p}(2:end)) early_count excl_trial trials_clean];
        exc.Properties.VariableNames = {'pair','early_start','short_rt','B_2ndDec','Y_2ndDec'};
        writetable(exc,fullfile(path_kin,'overview_exclusions.xlsx'));
    end

end % end of pair loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


catch me
    % Save backup files in case of crash
    % NOTE: Only save in case of "true" crash, i.e., do not save here if
    % the data was already saved earlier (i.e., if savemat=1) because
    % the user decided to exit the script intentionally (i.e., no crash).
    if ~any([savemat1,savemat2,savematColl])
        % CAREFUL: if you re-name this file (the "_end"-part), then the
        % bkp-function will NOT WORK anymore (see userInput, line 41 where the
        % trial number is identified by checking last part of file name)
        save(fullfile(path_kin,[SUBJECTS{p},'_end',num2str(t),'_bkp']));
        writetable(data,fullfile(path_kin,['jmdData_S' SUBJECTS{p}(2:end) '_end' num2str(t) '_bkp.xlsx']));
        disp(['CRASH in trial ', num2str(t), '. BACKUP MATFILE HAS BEEN SAVED SUCCESSFULLY.']); fprintf(1, '\n');
    end
end

% script version: Nov 2023