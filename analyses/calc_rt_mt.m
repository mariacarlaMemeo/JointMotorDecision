%% Joint motor decision exp. Pilot data Nov 2022.
% Calculate the reaction time and movement time from kinematic data - wrist and index velocity
clear
close all


%% Script to calculate the reaction time and movement time from kinematic data. Files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103 - all the trials
%path
path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';
path_kin  = fullfile(path_data,'..\Processed');
%%
path_temp = 'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Desktop\jmd\';
flag_pre  = 0;
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
    txt               = [txt_or {'rt_final1' 'rt_final2' 'rt_finalColl' 'mt_final1' 'mt_final2' 'mt_finalColl'}];
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

        %function to calculate the movement onset
        %agent acting as first
        label_agent = 'FIRSTDecision';
        [rt_final1,mt_final1]=movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent,flag_pre);
        faa = faa + 3;
        %agent acting as first
        label_agent = 'SECONDDecision';
        [rt_final2,mt_final2]=movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent,flag_pre);
        saa = saa + 3;
        %agent acting as first
        label_agent = 'COLLECTIVEDecision';
        [rt_finalColl,mt_finalColl]=movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent,flag_pre);
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
        data.Properties.VariableNames = txt;
        writetable(data,fullfile(path_temp,['pilotData_' SUBJECTS{p}(2:end) '.xlsx']));
    end


    clear sMarkers session
end
