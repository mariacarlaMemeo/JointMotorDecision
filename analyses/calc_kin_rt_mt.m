%% Joint motor decision exp. Pilot data Nov 2022.
% Calculate the reaction time and movement time from kinematic data - wrist and index velocity
clear
close all


%% Script to calculate the reaction time and movement time from kinematic data. Files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103 - all the trials
%path
path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';
path_kin  = fullfile(path_data,'..\Processed');
%%
path_temp = 'Y:\Datasets\JointMotorDecision\Exported\behavioral_kin_data';
flag_pre  = 0;
trial_plot = 0;
%%

%% Load each processed mat file per subject
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'P1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);

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
    varName_exp  = {'targetContrast','firstSecondInterval','targetLoc',...
                    'A1_decision','A1_acc','A1_conf','A1_confRT',...
                    'A2_decision','A2_acc','A2_conf','A2_confRT',...
                    'Coll_decision','Coll_acc','Coll_conf','Coll_confRT',...
                    'AgentTakingFirstDecision','AgentTakingSecondDecision','AgentTakingCollDecision'};

    % set the path for the rt and mt variables
    path_task      = fullfile(path_data,SUBJECTS{p},'task');
    path_data_each = fullfile(path_data,SUBJECTS{p},['task\pilotData_' SUBJECTS{p}(2:end) '.xlsx'] );

    %It loads the 'session' struct for each pair of participants
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);

    if p==3%we need to replace the following excel file in the repo
        path_data_each = 'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Desktop\pilotData_102.xlsx';
    end

    tic
    load(path_kin_each);
    toc

    %Remove trials in 'session' cell to avoid inserting the (last?) trials in
    %which there's no 'marker' field
    mark           = cell2mat(cellfun(@(s) isfield(s,'markers'),session,'uni',0));
    sMarkers       = session(mark);

    % Open the excel file to check who's performing the 2nd trial and choose the reaction time of the complementar agent.
    % If you check column 'AgentTakingFirstDecision' you already have the
    % agent whose reaction time you need to use for the video.
    [~,txt_or,raw]    = xlsread(path_data_each);
    raw               = raw(2:end,:);%removed the header
    txt               = [txt_or {'rt_final1' 'rt_final2' 'rt_finalColl' 'mt_final1' 'mt_final2' 'mt_finalColl' ...
                                 'ave_vel_index1' 'ave_acc_index1' 'ave_jrk_index1' 'ave_vel_ulna1' 'ave_acc_ulna1' 'ave_jrk_ulna1'...
                                 'peak_z_index1' 'min_z_index1' 'ave_z_index1' 'area_z_index1' 'peak_z_ulna1' 'min_z_ulna1' 'ave_z_ulna1' 'area_z_ulna1'...
                                 'area_dev1' 'max_dev1' 'min_dev1' 'ave_area_dev1'...
                                 'ave_vel_index2' 'ave_acc_index2' 'ave_jrk_index2' 'ave_vel_ulna2' 'ave_acc_ulna2' 'ave_jrk_ulna2'...
                                 'peak_z_index2' 'min_z_index2' 'ave_z_index2' 'area_z_index2' 'peak_z_ulna2' 'min_z_ulna2' 'ave_z_ulna2' 'area_z_ulna2'...
                                 'area_dev2' 'max_dev2' 'min_dev2' 'ave_area_dev2'...
                                 'ave_vel_indexColl' 'ave_acc_indexColl' 'ave_jrk_indexColl' 'ave_vel_ulnaColl' 'ave_acc_ulnaColl' 'ave_jrk_ulnaColl'...
                                 'peak_z_indexColl' 'min_z_indexColl' 'ave_z_indexColl' 'area_z_indexColl' 'peak_z_ulnaColl' 'min_z_ulnaColl' 'ave_z_ulnaColl' 'area_z_ulnaColl'...
                                 'area_devColl' 'max_devColl' 'min_devColl' 'ave_area_devColl'}];
    data              = cell2table(raw);
    data.rt_final1    = zeros(length(raw),1);
    data.rt_final2    = zeros(length(raw),1);
    data.rt_finalColl = zeros(length(raw),1);
    data.mt_final1    = zeros(length(raw),1);
    data.mt_final2    = zeros(length(raw),1);
    data.mt_finalColl = zeros(length(raw),1);

    %Retrieve the agents acting for each decision
    at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
    at1stDec       = cell2mat(raw(:,at1stDec_ind));
    at2ndDec_ind   = strcmp('AgentTakingSecondDecision',txt);
    at2ndDec       = cell2mat(raw(:,at2ndDec_ind));
    atCollDec_ind  = strcmp('AgentTakingCollDecision',txt);
    atCollDec      = cell2mat(raw(:,atCollDec_ind));

    %
    faa = 1;
    saa = 2;
    caa = 3;

    for t = 1:length(raw)

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
        [startFrame1,rt_final1,mt_final1,endFrame1] = movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent,flag_pre,trial_plot);
        if not(isnan(startFrame1))
            [tindex1,tulna1,sindex1,sulna1,sdindex1,time_traj_index1,time_traj_ulna1,spa_traj_index1,spa_traj_ulna1]    = movement_var(sMarkers,faa,SUBJECTS,p,agentExec1,startFrame1,endFrame1);
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
        [startFrame2,rt_final2,mt_final2,endFrame2] = movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent,flag_pre,trial_plot);
        if not(isnan(startFrame2))
            [tindex2,tulna2,sindex2,sulna2,sdindex2,time_traj_index2,time_traj_ulna2,spa_traj_index2,spa_traj_ulna2]    = movement_var(sMarkers,saa,SUBJECTS,p,agentExec2,startFrame2,endFrame2);
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
        [startFrameColl,rt_finalColl,mt_finalColl,endFrameColl] = movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent,flag_pre,trial_plot);
        if not(isnan(startFrameColl))
        [tindexColl,tulnaColl,sindexColl,sulnaColl,sdindexColl,time_traj_indexColl,time_traj_ulnaColl,spa_traj_indexColl,spa_traj_ulnaColl] = movement_var(sMarkers,caa,SUBJECTS,p,agentExecColl,startFrameColl,endFrameColl);
        else
            tindexColl=[NaN NaN NaN]; tulnaColl=[NaN NaN NaN]; sindexColl=[NaN NaN NaN NaN]; sulnaColl=[NaN NaN NaN NaN]; sdindexColl=[NaN NaN NaN NaN];
        end      
        caa = caa +3;
        %%%


        % Write the final rt in the excel file created during the
        % acquisition
        if p==2 && t==115 %participant moved before decision prompt
            rt_final1 = NaN;
            mt_final1 = NaN;
        end
        ol           = length(txt_or);
        data{t,ol+1} = rt_final1;
        data{t,ol+2} = rt_final2;
        data{t,ol+3} = rt_finalColl;
        data{t,ol+4} = mt_final1;
        data{t,ol+5} = mt_final2;
        data{t,ol+6} = mt_finalColl;
        %kin agent 1
        data{t,ol+7:ol+9}   = tindex1;
        data{t,ol+10:ol+12} = tulna1;
        data{t,ol+13:ol+16} = sindex1;
        data{t,ol+17:ol+20} = sulna1;
        data{t,ol+21:ol+24} = sdindex1;
        %kin agent 2
        data{t,ol+25:ol+27} = tindex2;
        data{t,ol+28:ol+30} = tulna2;
        data{t,ol+31:ol+34} = sindex2;
        data{t,ol+35:ol+38} = sulna2;
        data{t,ol+39:ol+42} = sdindex2;
        %kin agent coll
        data{t,ol+43:ol+45} = tindexColl;
        data{t,ol+46:ol+48} = tulnaColl;
        data{t,ol+49:ol+52} = sindexColl;
        data{t,ol+53:ol+56} = sulnaColl;
        data{t,ol+57:ol+60} = sdindexColl;
        %title
        data.Properties.VariableNames = txt;
        if flag_pre
            writetable(data,fullfile(path_temp,['pilotData_' SUBJECTS{p}(2:end) '_kin_withPre.xlsx']));
        else
            writetable(data,fullfile(path_temp,['pilotData_' SUBJECTS{p}(2:end) '_kin.xlsx']));
        end
    end

    % Plot the average and standard deviation of values of resampled time vectors of Vm,Am,Jm and filter spatial
    % coordinates x,y,z per subject, for index(tip) and ulna markers.
    ave_subj_plotting;
    
    clear sMarkers session
end
