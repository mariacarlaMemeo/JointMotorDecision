%% Joint motor decision exp. Pilot data Nov 2022.
% First script of the kinematic analyses. 
% Calculate the reaction time and movement time from kinematic data - wrist and index velocity
% 17.10.2023
% NOTE: AFTER RUNNING THE MAIN-C3D-TOOLBOX SCRIPT, YOU NEED TO COPY THE CREATED .MAT FILES
% FROM THE REPO TO THE HARD DRIVE (SEE PATH KIN)
clear
close all

try 
%% Initial trial

% Check the hard drive
flag_hd = 1; %should be 1
% Check only the 2nd decision (%EDIT % Check 1st,2nd or collective decision: 1,2,3 respectively)
flag_2nd = 1;
% Do we want to create the trajectory plots (all trajectories per subject)?
flag_plot = 1;
% Do we want to create one plot for each trial? (use for cutting only!)
trial_plot = 0;
% median split
med_split = 1;
% Check also the sample before the button release
flag_pre  = 1;
% Bin the trials and calculate the normalized trajectories
flag_bin = 0;

% Data format - normalization of each trajectory to 100 samples (for now). 
bin = 100;

%% Initialize time and space matrices ONLY because we need to plot not normalize trajectories (no bins)
max_samples = 800; % this corresponds to 8 seconds
max_trial   = 320;

all_time_traj_index_b = NaN*ones(max_samples,3,max_trial);
all_time_traj_ulna_b  = NaN*ones(max_samples,3,max_trial);
all_spa_traj_index_b  = NaN*ones(max_samples,3,max_trial);
all_spa_traj_ulna_b   = NaN*ones(max_samples,3,max_trial);

all_time_traj_index_y = NaN*ones(max_samples,3,max_trial);
all_time_traj_ulna_y  = NaN*ones(max_samples,3,max_trial);
all_spa_traj_index_y  = NaN*ones(max_samples,3,max_trial);
all_spa_traj_ulna_y   = NaN*ones(max_samples,3,max_trial);


%% Script to calculate the reaction time and movement time from kinematic data. Files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103 - all the trials
%path
if flag_hd %currently (25.10.) we are using the hard drive only!!!
    path_data = 'F:\jmd_experiment_final\joint-motor-decision\kin_data\Cleaned'; %EXCEL FILE FROM EXPERIMENT
else
    path_data = 'Y:\Datasets\JointMotorDecision\Static\Cleaned';
end

path_kin  = fullfile(path_data,'..\Processed'); %MAT FILES CREATED WITH MAIN-C3D-TOOLBOX
% path_kin_save = fullfile(pwd,'..\..\Data\Kinematic\');

%%
% path_trial_traj = 'Y:\Datasets\JointMotorDecision\Static\Processed';%'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Documents\GitHub\joint-motor-decision\analyses\data\trial_trajectories\';
crash = input('do you want to start from backup? (1/0)\n','s');
if str2num(crash)
    [filename, pathname, filterindex] = uigetfile(path_kin,'.mat');
    load(fullfile(pathname,filename));
    % Change name to the 'data' variable to not overwrite it after in the
    % script
    data_bkp        = data;
    file_split      = split(filename,'_');
    trial_crash_str = cell2mat(file_split(end));
    trialstart_num  = str2num(trial_crash_str(1:end-4));
else
    trialstart_num = 1;
end

%% Load each processed mat file per subject
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'S1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);

% EDIT - Look only at S111 for now
% SUBJECTS = [SUBJECTS(1)];%[SUBJECTS(2) SUBJECTS(4)];

%%
% The information we need to calculate is the reaction time and movement time. They are already in the
% excel file and they depend on the agent that is performing the decision: they were calculated according to the buttons release(rt) and press(mt).
% We need to recalculate them based on the index/wrist speed threshold. 
% For each row in the Excel file there are 3 decisions.
% Retrieve the rt and mt for each trial. Trial order is always:
% - ODD TRIAL  - agent1(individual decision)-agent2(individual decision)-agent1(collective decision)
% - EVEN TRIAL - agent2-agent1-agent2

for p = 1:length(SUBJECTS)

    disp(['Start ' SUBJECTS{p}(2:end)])
    clear v raw_clm
    close all
    early_count = 0;
    
    % Create a table
    raw_clm      = table();

    % set the path for the rt and mt variables
    path_task      = fullfile(path_data,SUBJECTS{p});
    path_data_each = fullfile(path_data,SUBJECTS{p},['S' SUBJECTS{p}(2:end) '.xlsx']);

    %It loads the 'session' struct for each pair of participants
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);

    %Check the loading time
    tic
    load(path_kin_each);
    toc

    % EDIT - Add path to store figures from visual check cut
    figurepath = 'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Desktop\jmd\example plots\tstart_tstop';
    mkdir(fullfile(figurepath,SUBJECTS{p}))

    %Remove trials in 'session' cell to avoid inserting the (last?) trials in
    %which there's no 'marker' field
    mark           = cell2mat(cellfun(@(s) isfield(s,'markers'),session,'uni',0));
    sMarkers       = session(mark);

    % Open the excel file to check who's performing the 2nd trial and choose the reaction time of the complementar agent.
    % If you check column 'AgentTakingFirstDecision' you already have the
    % agent whose reaction time you need to use for the video.
    [~,txt_or,raw]    = xlsread(path_data_each);
    raw               = raw(2:end,:);%removed the header
    txt               = [txt_or{1,:} {'switch' 'rt_final1' 'rt_final2' 'rt_finalColl' 'dt_final1' 'dt_final2' 'dt_finalColl' 'mt_final1' 'mt_final2' 'mt_finalColl'} ...
                         cellstr(strcat('vel_ind2_',string(1:bin))), cellstr(strcat('acc_ind2_',string(1:bin))),cellstr(strcat('jrk_ind2_',string(1:bin))),...
                         cellstr(strcat('vel_uln2_',string(1:bin))), cellstr(strcat('acc_uln2_',string(1:bin))),cellstr(strcat('jrk_uln2_',string(1:bin))),...
                         cellstr(strcat('z_uln2_',string(1:bin))),...
                         'tstart1' 'tmove1' 'tstop1' 'tstart2' 'tmove2' 'tstop2' 'tstartColl' 'tmoveColl' 'tstopColl' ];
    % File created during acquisition
    data              = cell2table(raw);
    
    % Fill the data with 0s for all the additional columns (txt)
    %table_zero = array2table(zeros(size(data,1),length(txt)-size(data,2)));
    %data       = [data table_zero];


    % Retrieve the agents acting for each decision
    at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
    at1stDec       = cell2mat(raw(:,at1stDec_ind));
    at2ndDec_ind   = strcmp('AgentTakingSecondDecision',txt);
    at2ndDec       = cell2mat(raw(:,at2ndDec_ind));
    atCollDec_ind  = strcmp('AgentTakingCollDecision',txt);
    atCollDec      = cell2mat(raw(:,atCollDec_ind));
    % Retrieve the confidence of each agent. A1 and A2 in these Excel files
    % (pilot data) refer to blue and yellow agents respectively.
    blue_Conf_ind   = strcmp('B_conf',txt);
    blue_Conf       = cell2mat(raw(:,blue_Conf_ind));
    yell_Conf_ind   = strcmp('Y_conf',txt);
    yell_Conf       = cell2mat(raw(:,yell_Conf_ind));
    %Retrieve the choice of each agent 
    blue_Dec_ind   = strcmp('B_decision',txt);
    blue_Dec       = cell2mat(raw(:,blue_Dec_ind));
    yell_Dec_ind   = strcmp('Y_decision',txt);
    yell_Dec       = cell2mat(raw(:,yell_Dec_ind));
    Coll_Dec_ind   = strcmp('Coll_decision',txt);
    Coll_Dec       = cell2mat(raw(:,Coll_Dec_ind));
    % Retrieve the rt of each agent
    blue_rt_ind   = strcmp('B_rt',txt);
    blue_rt       = cell2mat(raw(:,blue_rt_ind));
    yell_rt_ind   = strcmp('Y_rt',txt);
    yell_rt       = cell2mat(raw(:,yell_rt_ind));
    Coll_rt_ind   = strcmp('Coll_rt',txt);
    Coll_rt       = cell2mat(raw(:,Coll_rt_ind));

    % Indeces for 1st, 2nd and 3rd decision
    faa = trialstart_num *3 - 2;
    saa = trialstart_num *3 - 1;
    caa = trialstart_num *3;

    tic
    
    for t = trialstart_num:length(raw)%%EDIT % trial loop which goes through all three decisions

        % CHECK whether early_release_A1/A2/Coll == 1. If yes, exclude
        % entire trial!
        early = 0;
        if (any([raw{t,end-2:end}])) || (blue_rt(t)<100) || (yell_rt(t)<100) || (Coll_rt(t)<100)
            early = 1;
            early_count = early_count+1;
        end

        % Include a few trials because they start too early but were not
        % captured by the early-start-flag
        % t==63,
       
        if at1stDec(t) == 'B'
            FirstDec(t) = blue_Dec(t);
        else
            FirstDec(t) = yell_Dec(t);
        end
        % Create the switch column
        if FirstDec(t)==Coll_Dec(t)
            changeMind(t) = 0;
        else
            changeMind(t) = 1;
        end

        agentExec1    = lower(at1stDec(t)); %the first agent acting
        agentExec2    = lower(at2ndDec(t)); 
        agentExecColl = lower(atCollDec(t)); 

        % assign rts to first, second, coll
         if at1stDec(t) == 'B'
            FirstRT = blue_rt(t);
            SecRT = yell_rt(t);
        else
            FirstRT = yell_rt(t);
            SecRT = blue_rt(t);
         end
         CollRT = Coll_rt(t);


        % Check if the agents taking 1st and 2nd decisions are different
        if at1stDec(t)==at2ndDec(t)
            warning('Agents taking 1st and 2nd decisions are the same! Check the data!');
        end

        %function to calculate the movement onset and kinematic variables
        %agent acting as first
        label_agent = 'FIRSTDecision';
        [startFrame1,tmove1,rt_final1,dt_final1,mt_final1,endFrame1] = movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent,FirstRT,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrame1)) && not(early) % start frame exists and start button was NOT pressed too early
            [tindex1,tulna1,sindex1,sulna1,sdindex1,time_traj_index1,time_traj_ulna1,spa_traj_index1,spa_traj_ulna1]    = movement_var(sMarkers,faa,SUBJECTS,p,agentExec1,startFrame1,endFrame1,flag_bin);
        else
            tindex1=[NaN NaN NaN]; tulna1=[NaN NaN NaN]; sindex1=[NaN NaN NaN NaN]; sulna1=[NaN NaN NaN NaN]; sdindex1=[NaN NaN NaN NaN]; time_traj_index1 = ones(100,3)*NaN; time_traj_ulna1 = ones(100,3)*NaN; spa_traj_index1 = ones(100,3)*NaN; spa_traj_ulna1 = ones(100,3)*NaN;
        end

        if flag_bin %only for binned trajectories
            if at1stDec(t) == 'B'
                all_time_traj_index_b(:,:,t) = time_traj_index1;
                all_time_traj_ulna_b(:,:,t) = time_traj_ulna1;
                all_spa_traj_index_b(:,:,t) = spa_traj_index1;
                all_spa_traj_ulna_b(:,:,t) = spa_traj_ulna1;
            else
                all_time_traj_index_y(:,:,t) = time_traj_index1;
                all_time_traj_ulna_y(:,:,t) = time_traj_ulna1;
                all_spa_traj_index_y(:,:,t) = spa_traj_index1;
                all_spa_traj_ulna_y(:,:,t) = spa_traj_ulna1;
            end
        else %only for not notmalized trajectories
            if length(time_traj_index1) > max_samples
                if at1stDec(t) == 'B'
                    all_time_traj_index_b(:,:,t) = NaN*ones(max_samples,3);
                    all_time_traj_ulna_b(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_index_b(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_ulna_b(:,:,t)   = NaN*ones(max_samples,3);
                else
                    all_time_traj_index_y(:,:,t) = NaN*ones(max_samples,3);
                    all_time_traj_ulna_y(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_index_y(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_ulna_y(:,:,t)   = NaN*ones(max_samples,3);
                end
            else
                if at1stDec(t) == 'B'
                    all_time_traj_index_b(:,:,t) = [time_traj_index1;NaN*ones((max_samples-length(time_traj_index1)),3)];%b=[b;NaN*ones((max_samples-length(b)),3)]
                    all_time_traj_ulna_b(:,:,t)  = [time_traj_ulna1;NaN*ones((max_samples-length(time_traj_ulna1)),3)];
                    all_spa_traj_index_b(:,:,t)  = [spa_traj_index1;NaN*ones((max_samples-length(spa_traj_index1)),3)];
                    all_spa_traj_ulna_b(:,:,t)   = [spa_traj_ulna1;NaN*ones((max_samples-length(spa_traj_ulna1)),3)];
                else
                    all_time_traj_index_y(:,:,t) = [time_traj_index1;NaN*ones((max_samples-length(time_traj_index1)),3)];%b=[b;NaN*ones((max_samples-length(b)),3)]
                    all_time_traj_ulna_y(:,:,t)  = [time_traj_ulna1;NaN*ones((max_samples-length(time_traj_ulna1)),3)];
                    all_spa_traj_index_y(:,:,t)  = [spa_traj_index1;NaN*ones((max_samples-length(spa_traj_index1)),3)];
                    all_spa_traj_ulna_y(:,:,t)   = [spa_traj_ulna1;NaN*ones((max_samples-length(spa_traj_ulna1)),3)];
                end
            end
        end
     
        faa = faa + 3;

        %agent acting as second
        label_agent = 'SECONDDecision';
        [startFrame2,tmove2,rt_final2,dt_final2,mt_final2,endFrame2] = movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent,SecRT,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrame2)) && not(early) % start frame exists and start button was NOT pressed too early
            [tindex2,tulna2,sindex2,sulna2,sdindex2,time_traj_index2,time_traj_ulna2,spa_traj_index2,spa_traj_ulna2]    = movement_var(sMarkers,saa,SUBJECTS,p,agentExec2,startFrame2,endFrame2,flag_bin);
        else
            tindex2=[NaN NaN NaN]; tulna2=[NaN NaN NaN]; sindex2=[NaN NaN NaN NaN]; sulna2=[NaN NaN NaN NaN]; sdindex2=[NaN NaN NaN NaN];time_traj_index2 = ones(100,3)*NaN; time_traj_ulna2 = ones(100,3)*NaN; spa_traj_index2 = ones(100,3)*NaN; spa_traj_ulna2 = ones(100,3)*NaN;
        end

        if flag_bin %only for binned trajectories
            if at2ndDec(t) == 'B'
                all_time_traj_index_b(:,:,t) = time_traj_index2;
                all_time_traj_ulna_b(:,:,t) = time_traj_ulna2;
                all_spa_traj_index_b(:,:,t) = spa_traj_index2;
                all_spa_traj_ulna_b(:,:,t) = spa_traj_ulna2;
            else
                all_time_traj_index_y(:,:,t) = time_traj_index2;
                all_time_traj_ulna_y(:,:,t) = time_traj_ulna2;
                all_spa_traj_index_y(:,:,t) = spa_traj_index2;
                all_spa_traj_ulna_y(:,:,t) = spa_traj_ulna2;
            end
        else %only for not notmalized trajectories
            if length(time_traj_index2) > max_samples
                if at2ndDec(t) == 'B'
                    all_time_traj_index_b(:,:,t) = NaN*ones(max_samples,3);
                    all_time_traj_ulna_b(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_index_b(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_ulna_b(:,:,t)   = NaN*ones(max_samples,3);
                else
                    all_time_traj_index_y(:,:,t) = NaN*ones(max_samples,3);
                    all_time_traj_ulna_y(:,:,t)  = NaN*ones(max_samples,3); 
                    all_spa_traj_index_y(:,:,t)  = NaN*ones(max_samples,3);
                    all_spa_traj_ulna_y(:,:,t)   = NaN*ones(max_samples,3);
                end
            else
                if at2ndDec(t) == 'B'
                    all_time_traj_index_b(:,:,t) = [time_traj_index2;NaN*ones((max_samples-length(time_traj_index2)),3)];
                    all_time_traj_ulna_b(:,:,t)  = [time_traj_ulna2;NaN*ones((max_samples-length(time_traj_ulna2)),3)];
                    all_spa_traj_index_b(:,:,t)  = [spa_traj_index2;NaN*ones((max_samples-length(spa_traj_index2)),3)];
                    all_spa_traj_ulna_b(:,:,t)   = [spa_traj_ulna2;NaN*ones((max_samples-length(spa_traj_ulna2)),3)];
                else
                    all_time_traj_index_y(:,:,t) = [time_traj_index2;NaN*ones((max_samples-length(time_traj_index2)),3)];
                    all_time_traj_ulna_y(:,:,t)  = [time_traj_ulna2;NaN*ones((max_samples-length(time_traj_ulna2)),3)];
                    all_spa_traj_index_y(:,:,t)  = [spa_traj_index2;NaN*ones((max_samples-length(spa_traj_index2)),3)];
                    all_spa_traj_ulna_y(:,:,t)   = [spa_traj_ulna2;NaN*ones((max_samples-length(spa_traj_ulna2)),3)];
                end
            end
        end
        saa = saa + 3;

        %collective decision
        label_agent = 'COLLECTIVEDecision';
        [startFrameColl,tmoveColl,rt_finalColl,dt_finalColl,mt_finalColl,endFrameColl] = movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent,CollRT,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrameColl)) && not(early) % start frame exists and start button was NOT pressed too early
        [tindexColl,tulnaColl,sindexColl,sulnaColl,sdindexColl,time_traj_indexColl,time_traj_ulnaColl,spa_traj_indexColl,spa_traj_ulnaColl] = movement_var(sMarkers,caa,SUBJECTS,p,agentExecColl,startFrameColl,endFrameColl,flag_bin);
        else
            tindexColl=[NaN NaN NaN]; tulnaColl=[NaN NaN NaN]; sindexColl=[NaN NaN NaN NaN]; sulnaColl=[NaN NaN NaN NaN]; sdindexColl=[NaN NaN NaN NaN]; time_traj_indexColl = ones(100,3)*NaN; time_traj_ulnaColl = ones(100,3)*NaN; spa_traj_indexColl = ones(100,3)*NaN; spa_traj_ulnaColl = ones(100,3)*NaN;
        end      
        caa = caa +3;
        %%%

        if (flag_bin)
            % Write the final excel file, merging the new parameters with the excel file created during the acquisition
            % NOTE: this doesnt work for some reason; you need to combine the
            % bkp-data and the new data manually afterwards (command line 127)
            ol                       = size(txt_or); %#ok<UNRCH> 
            data{t,ol(2)+1:ol(2)+10} = [changeMind(t) rt_final1 rt_final2 rt_finalColl dt_final1 dt_final2 dt_finalColl mt_final1 mt_final2 mt_finalColl];

            % Kin data of the normalized 100 samples for index and ulna: ONLY 2nd DECISION
            data{t,ol(2)+11:ol(2)+719} = [time_traj_index2(:,1)' time_traj_index2(:,2)' time_traj_index2(:,3)' time_traj_ulna2(:,1)' time_traj_ulna2(:,2)' time_traj_ulna2(:,3)' spa_traj_ulna2(:,3)'...
                startFrame1 tmove1 endFrame1 startFrame2 tmove2 endFrame2 startFrameColl tmoveColl endFrameColl];

            % table header
            data.Properties.VariableNames = txt;
            if str2num(crash)
                data(1:trialstart_num-1,:) = data_bkp(1:trialstart_num-1,:);
                crash = '0';
            end


            if flag_pre
                writetable(data,fullfile(path_kin,['expData_' SUBJECTS{p}(2:end) '_kin_model_withPre.xlsx']));
            else
                writetable(data,fullfile(path_kin,['expData_' SUBJECTS{p}(2:end) '_kin_model.xlsx']));
            end
        end

    end
    toc
    disp(['Number of early starts for pair ' SUBJECTS{p}(2:end) ': ' num2str(early_count)])

    % Save matfile after each pair
%     if t==length(raw)
     save(fullfile(path_kin,[SUBJECTS{p},'_post_absValues_withPre']))
%     else
%         save(fullfile(path_kin,[SUBJECTS{p}, '_fromtrialc3d_',sMarkers{t}.info.fullpath(end-11:end),'_tilltrialMat_',num2str(t)]))
%     end


    % Plot the average and standard deviation of values of resampled time vectors of Vm,Am,Jm and filter spatial
    % coordinates x,y,z per subject, for index(tip) and ulna markers.

    %Classify confidence as high and low
    if med_split
        bConf = blue_Conf; yConf = yell_Conf;
        bConf(bConf<=median(bConf))=1; bConf(bConf>median(bConf))=2; 
        yConf(yConf<=median(yConf))=1; yConf(yConf>median(yConf))=2; 
    else
        bConf = blue_Conf; yConf = yell_Conf; %#ok<UNRCH>
        bConf(bConf<4)=1; bConf(bConf>=4)=2;
        yConf(yConf<4)=1; yConf(yConf>=4)=2;
    end
    %vector specifying the agent who took the 2nd decision (1=blue Agent, 2=yellow Agent)
    SecondDec = at2ndDec;
    
    % display and save exploratory plots
    if flag_plot
        ave_subj_plotting_new;
    end
    clear sMarkers session bConf yConf blue_Dec yell_Dec
 
end

catch me
    % Save mat file as a backup
    %     if t==length(raw)
    save(fullfile(path_kin,[SUBJECTS{p},'_trial',num2str(t)]))
    %     else
    %         save(fullfile(path_kin,[SUBJECTS{p}, '_tilltrialc3d_',sMarkers{t}.info.fullpath(end-11:end),'_tilltrialMat_',num2str(t)]))
    %     end
end
