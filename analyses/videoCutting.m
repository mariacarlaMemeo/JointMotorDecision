% %% Use the cluster - Franklin
clear
% addpath('C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Documents\MATLAB\IntegrationScripts\franklin')
% c = parcluster;
%
% c.AdditionalProperties.QueueName = 'gpu';
% % Specify the walltime (e.g.1 hour)
% c.AdditionalProperties.WallTime = '00:30:00';
% % Specify an account to use for MATLAB jobs
% c.AdditionalProperties.AccountName = 'mmemeo';
% % Specify e-mail address to receive notifications about your job
% c.AdditionalProperties.EmailAddress = 'mariacarla.memeo@iit.it';
% % Specify job placement to run job anywhere
% c.AdditionalProperties.JobPlacement = 'free';
% c.AdditionalProperties.RequireExclusiveNode = false;
% c.saveProfile
%
% % % Run on GPU
% % c.AdditionalProperties.GpusPerNode = 1;
% % c.AdditionalProperties.QueueName = 'gpu';
% % gpu_j = c.batch(@calc_mandelbrot,4,{'gpuArray'}, 'CurrentFolder','.');
%
% %path
% script_path = 'C:\Users\MMemeo\OneDrive - Fondazione Istituto Italiano Tecnologia\Documents\GitHub\joint-motor-decision\analyses';
% path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';
% out_path  = 'Y:\Datasets\JointMotorDecision\Static\Raw\P100\video_cut\';
% % Submit job to query where MATLAB is running on the cluster
% j = c.batch(@cut_videos, 0, {}, 'CurrentFolder','.', 'AutoAddClientPath',true,'AutoAttachFiles',true,'AdditionalPaths',{script_path,path_data,out_path});
%



%% Script to cut the video files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103
%path
path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';
path_kin  = fullfile(path_data,'..\Processed');

%% Load each processed mat file per subject
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'P1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);


% The information we need to retrieve is the reaction time. It is in the
% excel file and it depends on the agent that is performing the 2nd trial,
% e.g. if agent 1 starts, we need to show the video of agent 2 with its
% relative reaction time.

% tstart = 200ms + reaction time(without movement time)
% tstop  = end of the video

for p = length(SUBJECTS)% 1:length(SUBJECTS) 
    
    clear session

    disp(['Start ' SUBJECTS{p}(2:end)])
    clear vid_info
    % Create a table
    vid_info     = table();
    varName     = {'pair','trial','name_vid','agentActing','rt_agentActing','dura_vid','dura_vid_cut','tstart_cut','tstartSample_cut','tstopSample_cut','nFrames_cut','vid_width','vid_height'};

    % set the path for the video and the rt variables
    path_data_each = fullfile(path_data,SUBJECTS{p},['task\pilotData_' SUBJECTS{p}(2:end) '.xlsx'] );
    path_video     = fullfile(path_data,SUBJECTS{p},'jmd\');
    path_video_cut = fullfile(path_data,SUBJECTS{p},'video_cut\');
    mkdir(path_video_cut);
    %It loads the 'session' struct for each pair of participants
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);
    %Set the initial trial avoiding the training (different for each pari)
    if strcmp(SUBJECTS{p},'P103')
        exp_ind    = 19;%very first trial in Nexus
    end
    session = session(exp_ind:end);

    % Open excel file to check who's performing the 2nd trial and choose the reaction time of the complementar agent.
    % If you check column 'AgentTakingFirstDecision' you already have the
    % agent whose reaction time you need to use for the video.
    [~,txt,raw] = xlsread(path_data_each);
    raw         = raw(2:end,:);%removed the header

    % The video indeces should be every 6 videos
    %Create a vector with all the first indeces of the  group of 6 trials
    vid_list      = dir([path_video '*.avi']);
    each6_vid     = 1:6:length(vid_list);%the first index of
    %Create a vector with all the first indeces of the  group of 3 trials
    c3d_ind       = 1:3:length(session);

    for t = 1:length(raw)

        at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
        at1stDec       = cell2mat(raw(:,at1stDec_ind));
        if at1stDec(t)==1 %if it's agent1
            rt_ind     = strcmp('A2_rt',txt);
            agentExec  = 'a2';%agent executing the action in the video
            rt_agent   = 0.001*raw{t,rt_ind};
            tstart     = 0.2 + (rt_agent); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind    = 3;% (the fourth video to be add to the first index) The loop should be every 6 videos. 2 videos from the 2 videocam per trial.
            kin_ind    = 1+c3d_ind(t); % the 2° in case it's the second agent acting
        elseif at1stDec(t)==2
            rt_ind     = strcmp('A1_rt',txt);
            agentExec  = 'a1';%agent executing the action in the video
            rt_agent   = 0.001*raw{t,rt_ind};
            tstart     = 0.2 + (rt_agent); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind    = 2;% (the third video to be add to the first index) The for loop should be every 6 videos. 2 videos from the 2 videocam per trial.
            kin_ind    = c3d_ind(t); % the 1° in case it's the first agent acting
        end
        
        % CHECK index and wrist velocity threshold
        vel_th     = 20; %20[mm/s]
        preAcq     = 20; %preacquisition of 200ms == 20 frames
        model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
        samp       = 1:session{kin_ind}.info.nSamples;
        index      = session{kin_ind}.markers.([model_name '_index']).Vm;
        ulna       = session{kin_ind}.markers.([model_name '_ulna']).Vm;
        indexTh    = findTh_cons(index(preAcq:end),vel_th,10);%>20[mm/s] for 5 frames, the first interval
        ulnaTh     = findTh_cons(ulna(preAcq:end),vel_th-5,5);%>15[mm/s]
        
        yPos_text   = max([index; ulna]);
        
        v=figure(); set(v, 'WindowStyle', 'Docked');
        yyaxis left; plot(samp,index);
        yyaxis right; plot(samp,ulna);
        xline(preAcq); text(preAcq,yPos_text-200,' pre: 200ms');
        xline(samp(end)-10); text((samp(end)-10),yPos_text-200,' post: 100ms');
        xline(indexTh(1),'b');text(indexTh(1),yPos_text-250,' Index > 20','Color', 'b');
        xline(ulnaTh(1),'r');text(ulnaTh(1),yPos_text-300,' Ulna > 20','Color', 'r');
        title()

        % FIND the correct video to cut
        % The video indeces should be every 6 videos
        %Create a vector with all the first indeces of the  group of 6
        %trials
        curr_vid_ind  = each6_vid(t) + vid_ind;
        curr_vid      = vid_list(curr_vid_ind).name; %select the video

        % Cut video based on tstart and tstop
        v                 = VideoReader(fullfile(path_video,curr_vid));
        vidObj            = VideoWriter([path_video_cut,curr_vid(1:end-4)],'MPEG-4');
        vidObj.FrameRate  = 100;
        open(vidObj);
        tstart_frame   = ceil(tstart*vidObj.FrameRate);
        for frame = tstart_frame:v.NumFrames %from tstart(transformed in frame) to the very last frame
            new_v = read(v,frame);
            writeVideo(vidObj,new_v)
        end
        deltaFrames    =  (v.NumFrames - tstart_frame);%number of frames in the same video

        % Fill the table
        vid_info(t,:) = {['P' SUBJECTS{p}(2:end)],t,curr_vid,str2num(agentExec(2)),rt_agent,...
                        v.Duration,vidObj.Duration,...
                        tstart,tstart_frame,v.NumFrames,deltaFrames,...
                        v.Width,v.Height};
        % Close video object
        close(vidObj);

        %save variable
        vid_info.Properties.VariableNames = varName;
        writetable(vid_info,fullfile(path_video_cut,['P' SUBJECTS{p}(2:end) '_vidInfo.xlsx']));

    end
end
