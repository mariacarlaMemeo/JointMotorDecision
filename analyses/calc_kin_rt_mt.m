%% Joint motor decision exp. Pilot data Nov 2022.
% Calculate the reaction time and movement time from kinematic data - wrist and index velocity
% 28.03.2023
clear
close all
%% Initial trial
trialstart_num = 131;

% Check the hard drive
flag_hd = 0;
% Check 2nd decision only
flag_2nd = 1;
% Display plots
flag_plot = 1;
%median split
med_split = 1;

%% Data format - normalization of each trajectory to 100 samples (for now). 
bin = 100;

%% Script to calculate the reaction time and movement time from kinematic data. Files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103 - all the trials
%path
if flag_hd
    path_data = 'F:\JointMotorDecision\Static\Raw';
    %path_data = 'C:\Users\Laura\Desktop\Backups\jmd_local@IIT_01-2023\repo_JointMotorDecision\Static\Raw';
else
    path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';
end

path_kin  = fullfile(path_data,'..\Processed');
%%
path_temp = fullfile(pwd,'data\');
flag_pre  = 0;
trial_plot = 1;
%%

%% Load each processed mat file per subject
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'P1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);

% DON'T LOOK AT PAIR 102
%SUBJECTS = [SUBJECTS(1) SUBJECTS(2) SUBJECTS(4)];%
SUBJECTS = [SUBJECTS(1)];%
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
    
    % Create a table
    raw_clm      = table();

    % set the path for the rt and mt variables
    path_task      = fullfile(path_data,SUBJECTS{p},'task');
    path_data_each = fullfile(path_data,SUBJECTS{p},['task\pilotData_' SUBJECTS{p}(2:end) '.xlsx']);
    if str2double(SUBJECTS{p}(2:end))==101
        path_data_each = fullfile(path_data,SUBJECTS{p},'task\pilotData_101_true3rdtrial.xlsx');
    end

    %It loads the 'session' struct for each pair of participants
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);

%     if p==3%we need to replace the following excel file in the repo
%         path_data_each = 'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Desktop\pilotData_102.xlsx';
%     end

    tic
    load(path_kin_each);
    toc

    % Add path to store figures from cisual check cut
    figurepath = 'Y:\Datasets\JointMotorDecision\Exported\behavioral_kin_data\tstart_tstop';
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
    txt               = [txt_or {'switch' 'rt_final1' 'rt_final2' 'rt_finalColl' 'dt_final1' 'dt_final2' 'dt_finalColl' 'mt_final1' 'mt_final2' 'mt_finalColl'} ...
                         cellstr(strcat('vel_ind2_',string(1:bin))), cellstr(strcat('acc_ind2_',string(1:bin))),cellstr(strcat('jrk_ind2_',string(1:bin))),...
                         cellstr(strcat('vel_uln2_',string(1:bin))), cellstr(strcat('acc_uln2_',string(1:bin))),cellstr(strcat('jrk_uln2_',string(1:bin))),...
                         cellstr(strcat('z_uln2_',string(1:bin)))];

    data              = cell2table(raw);
    data.rt_final1    = zeros(length(raw),1);
    data.rt_final2    = zeros(length(raw),1);
    data.rt_finalColl = zeros(length(raw),1);
    data.mt_final1    = zeros(length(raw),1);
    data.mt_final2    = zeros(length(raw),1);
    data.mt_finalColl = zeros(length(raw),1);

    % Retrieve the agents acting for each decision
    at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
    at1stDec       = cell2mat(raw(:,at1stDec_ind));
    at2ndDec_ind   = strcmp('AgentTakingSecondDecision',txt);
    at2ndDec       = cell2mat(raw(:,at2ndDec_ind));
    atCollDec_ind  = strcmp('AgentTakingCollDecision',txt);
    atCollDec      = cell2mat(raw(:,atCollDec_ind));
    % Retrieve the confidence of each agent. A1 and A2 in these Excel files
    % (pilot data) refer to blue and yellow agents respectively.
    blue_Conf_ind   = strcmp('A1_conf',txt);
    blue_Conf       = cell2mat(raw(:,blue_Conf_ind));
    yell_Conf_ind   = strcmp('A2_conf',txt);
    yell_Conf       = cell2mat(raw(:,yell_Conf_ind));
    %Retrieve the choice of each agent 
    blue_Dec_ind   = strcmp('A1_decision',txt);
    blue_Dec       = cell2mat(raw(:,blue_Dec_ind));
    yell_Dec_ind   = strcmp('A2_decision',txt);
    yell_Dec       = cell2mat(raw(:,yell_Dec_ind));
    Coll_Dec_ind   = strcmp('Coll_decision',txt);
    Coll_Dec       = cell2mat(raw(:,Coll_Dec_ind));
    
    % Indeces for 1st, 2nd and 3rd decision
    faa = trialstart_num *3 - 2;
    saa = trialstart_num *3 - 1;
    caa = trialstart_num *3;

    for t = trialstart_num:length(raw)%%EDIT % trial loop which goes through all three decisions

        % Create the switch column
        if at1stDec(t) == 1
            FirstDec(t) = blue_Dec(t);
        else
            FirstDec(t) = yell_Dec(t);
        end

        if FirstDec(t)==Coll_Dec(t)
            changeMind(t) = 0;
        else
            changeMind(t) = 1;
        end

        agentExec1    = ['a' num2str(at1stDec(t))]; %the first agent acting
        agentExec2    = ['a' num2str(at2ndDec(t))]; 
        agentExecColl = ['a' num2str(atCollDec(t))]; 
        % Check if the agents taking 1st and 2nd decisions are different
        if at1stDec(t)==at2ndDec(t)
            warning('Agents taking 1st and 2nd decisions are the same! Check the data!');
        end

        %function to calculate the movement onset and kinematic variables
        %agent acting as first
        label_agent = 'FIRSTDecision';
        [startFrame1,tmove1,rt_final1,dt_final1,mt_final1,endFrame1] = movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrame1))
            [tindex1,tulna1,sindex1,sulna1,sdindex1,time_traj_index1,time_traj_ulna1,spa_traj_index1,spa_traj_ulna1]    = movement_var(sMarkers,faa,SUBJECTS,p,agentExec1,tmove1,endFrame1);
        else
            tindex1=[NaN NaN NaN]; tulna1=[NaN NaN NaN]; sindex1=[NaN NaN NaN NaN]; sulna1=[NaN NaN NaN NaN]; sdindex1=[NaN NaN NaN NaN]; time_traj_index1 = ones(100,3)*NaN; time_traj_ulna1 = ones(100,3)*NaN; spa_traj_index1 = ones(100,3)*NaN; spa_traj_ulna1 = ones(100,3)*NaN;
        end
        if at1stDec(t) == 1
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
        faa = faa + 3;

        %agent acting as second
        label_agent = 'SECONDDecision';
        [startFrame2,tmove2,rt_final2,dt_final2,mt_final2,endFrame2] = movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrame2))
            [tindex2,tulna2,sindex2,sulna2,sdindex2,time_traj_index2,time_traj_ulna2,spa_traj_index2,spa_traj_ulna2]    = movement_var(sMarkers,saa,SUBJECTS,p,agentExec2,tmove2,endFrame2);
        else
            tindex2=[NaN NaN NaN]; tulna2=[NaN NaN NaN]; sindex2=[NaN NaN NaN NaN]; sulna2=[NaN NaN NaN NaN]; sdindex2=[NaN NaN NaN NaN];time_traj_index2 = ones(100,3)*NaN; time_traj_ulna2 = ones(100,3)*NaN; spa_traj_index2 = ones(100,3)*NaN; spa_traj_ulna2 = ones(100,3)*NaN;
        end
        if at2ndDec(t) == 1
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
        saa = saa + 3;

        %collective decision
        label_agent = 'COLLECTIVEDecision';
        [startFrameColl,tmoveColl,rt_finalColl,dt_finalColl,mt_finalColl,endFrameColl] = movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent,flag_pre,trial_plot,figurepath);
        if not(isnan(startFrameColl))
        [tindexColl,tulnaColl,sindexColl,sulnaColl,sdindexColl,time_traj_indexColl,time_traj_ulnaColl,spa_traj_indexColl,spa_traj_ulnaColl] = movement_var(sMarkers,caa,SUBJECTS,p,agentExecColl,tmoveColl,endFrameColl);
        else
            tindexColl=[NaN NaN NaN]; tulnaColl=[NaN NaN NaN]; sindexColl=[NaN NaN NaN NaN]; sulnaColl=[NaN NaN NaN NaN]; sdindexColl=[NaN NaN NaN NaN]; time_traj_indexColl = ones(100,3)*NaN; time_traj_ulnaColl = ones(100,3)*NaN; spa_traj_indexColl = ones(100,3)*NaN; spa_traj_ulnaColl = ones(100,3)*NaN;
        end      
        caa = caa +3;
        %%%


        % Write the final excel file created during the
        % acquisition
        ol                = length(txt_or);
        data{t,ol+1:ol+10} = [changeMind(t) rt_final1 rt_final2 rt_finalColl dt_final1 dt_final2 dt_finalColl mt_final1 mt_final2 mt_finalColl];

        % Kin data of the normalized 100 samples for index and ulna: ONLY 2nd DECISION
        data{t,ol+11:ol+710} = [time_traj_index2(:,1)' time_traj_index2(:,2)' time_traj_index2(:,3)' time_traj_ulna2(:,1)' time_traj_ulna2(:,2)' time_traj_ulna2(:,3)' spa_traj_ulna2(:,3)'];
        
        %title
        data.Properties.VariableNames = txt;
        if flag_pre
            writetable(data,fullfile(path_temp,['pilotData_' SUBJECTS{p}(2:end) '_kin_model_withPre.xlsx']));
        else
            writetable(data,fullfile(path_temp,['pilotData_' SUBJECTS{p}(2:end) '_kin_model.xlsx']));
        end
    end

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

%     % Remove one ugly trajectory from Yellow agent pair 101. Take the
%     % max of velocity.
%     if strcmp(SUBJECTS{p}(2:end),'101')%yellow participant /vel and acceleration
%         fdec2     = find(at2ndDec==2);
%         [my_vel_dec2,ind_vel_dec2] = max(max(all_time_traj_index_y(:,1,fdec2)));
%         all_time_traj_index_y(:,:,fdec2(ind_vel_dec2)) = nan;
% 
%         [my_acc_dec2,ind_acc_dec2] = max(max(all_time_traj_index_y(:,2,fdec2)));
%         all_time_traj_index_y(:,:,fdec2(ind_acc_dec2)) = nan;
%     
%         [my_z_dec2,ind_z_dec2] = min(min(all_spa_traj_index_y(:,3,fdec2)));
%         all_spa_traj_index_y(:,:,fdec2(ind_z_dec2)) = nan;
% 
%     elseif strcmp(SUBJECTS{p}(2:end),'100')%blue participant /acceleration
%         fdec2     = find(at2ndDec==1);
%       
%         [mb_acc_dec2,ind_acc_dec2] = max(max(all_time_traj_index_b(:,2,fdec2)));
%         all_time_traj_index_b(:,:,fdec2(ind_acc_dec2)) = nan;
% 
%         [mb_z_dec2,ind_z_dec2] = min(min(all_spa_traj_index_b(:,3,fdec2)));
%         all_spa_traj_index_b(:,:,fdec2(ind_z_dec2)) = nan;
%     end
    
    % display exploratory plots
    if flag_plot
        ave_subj_plotting;
    end
    clear sMarkers session bConf yConf blue_Dec yell_Dec
 
end
