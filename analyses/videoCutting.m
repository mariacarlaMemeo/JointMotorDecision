% %% Use the cluster - Franklin
clear
close all
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

%%
vidObj.FrameRate  = 100;

% The information we need to retrieve is the reaction time. It is in the
% excel file and it depends on the agent that is performing the 2nd trial,
% e.g. if agent 1 starts, we need to show the video of agent 2 with its
% relative reaction time.

% tstart = 200ms + reaction time(without movement time)
% tstop  = end of the video

for p = length(SUBJECTS)% 1:length(SUBJECTS) 
    
    disp(['Start ' SUBJECTS{p}(2:end)])
    clear vid_info
    % Create a table
    vid_info     = table();
    varName     = {'pair','trial','name_vid','agentActing','rt_agentActing','rt_index','rt_ulna','dura_vid','dura_vid_cut','tstart_cut','tstartSample_cut','tstopSample_cut','nFrames_cut','vid_width','vid_height'};

    % set the path for the video and the rt variables
    path_data_each = fullfile(path_data,SUBJECTS{p},['task\pilotData_' SUBJECTS{p}(2:end) '.xlsx'] );
    path_video     = fullfile(path_data,SUBJECTS{p},'jmd\');
    path_video_cut = fullfile(path_data,SUBJECTS{p},'video_cut\');
    mkdir(path_video_cut);
    %It loads the 'session' struct for each pair of participants
    path_kin_each  = fullfile(path_kin,[SUBJECTS{p},'.mat']);
    
    tic
    load(path_kin_each);
    toc

    %Remove trials in 'session' cell to avoid inserting the (last?) trials in
    %which there's no 'marker' field 
    mark           = cell2mat(cellfun(@(s) isfield(s,'markers'),session,'uni',0));
    sMarkers       = session(mark);
%     %Set the initial trial avoiding the training (different for each pair)
%     if strcmp(SUBJECTS{p},'P103')
%         exp_ind    = 19;%very first trial in Nexus
%     end
%     %Remove the training trials
%     warning("The c3d files of the training trials are NOT included in the list of trials.")
%     session = session(exp_ind:end);

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
    c3d_ind       = 1:3:length(sMarkers);

    for t = 1:length(raw)

        at1stDec_ind   = strcmp('AgentTakingFirstDecision',txt);
        at1stDec       = cell2mat(raw(:,at1stDec_ind));
        if at1stDec(t)==1 %if it's agent1
            rt_ind     = strcmp('A2_rt',txt);
            agentExec  = 'a2';%agent executing the action in the video
            rt_agent   = 0.001*raw{t,rt_ind};
            tstart     = 0.2 + (rt_agent); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind    = 3;% (the fourth video to be add to the first index) The loop should be every 6 videos. 2 videos from the 2 videocam per trial.
        elseif at1stDec(t)==2
            rt_ind     = strcmp('A1_rt',txt);
            agentExec  = 'a1';%agent executing the action in the video
            rt_agent   = 0.001*raw{t,rt_ind};
            tstart     = 0.2 + (rt_agent); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind    = 2;% (the third video to be add to the first index) The for loop should be every 6 videos. 2 videos from the 2 videocam per trial.
        end
        kin_ind    = 1+c3d_ind(t); % always the 2° in case it's the first/second agent acting
        
        % CHECK index and wrist velocity threshold
        vel_th     = 20; %20[mm/s]
        preAcq     = 20; %preacquisition of 200ms == 20 frames
        model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
        samp       = 1:sMarkers{kin_ind}.info.nSamples;
        index      = sMarkers{kin_ind}.markers.([model_name '_index']).Vm;
        ulna       = sMarkers{kin_ind}.markers.([model_name '_ulna']).Vm;
        indexTh    = findTh_cons(index(preAcq:end),vel_th,10);%>20[mm/s] for 5 frames, the first interval
        indexTh    = indexTh + preAcq;
        ulnaTh     = findTh_cons(ulna(preAcq:end),vel_th,10);%>15[mm/s]
        ulnaTh     = ulnaTh + preAcq;

        yPos_text   = max(ulna);
        
        v=figure(); set(v, 'WindowStyle', 'Docked');
        yyaxis left; plot(samp,index);
        yyaxis right; plot(samp,ulna);
        xline(preAcq); text(preAcq,yPos_text-300,' pre: 200ms');
        xline(samp(end)-10); text((samp(end)-10),yPos_text-300,' post');
        xline(rt_agent*vidObj.FrameRate,'Color', [0.4660 0.6740 0.1880]); text((rt_agent*vidObj.FrameRate),yPos_text-300,' RTagent','Color',[0.4660 0.6740 0.1880]);
        if ~isnan(indexTh(1))
        xline(indexTh(1),'Color',[0 0.4470 0.7410]);text(indexTh(1),yPos_text-300,' Index > 20','Color', [0 0.4470 0.7410]);
        end
        if ~isnan(ulnaTh(1))
        xline(ulnaTh(1),'Color',[0.8500 0.3250 0.0980]);text(ulnaTh(1),yPos_text-350,' Ulna > 20','Color', [0.8500 0.3250 0.0980]);
        end
        title(['P' SUBJECTS{p}(2:end) ' trial: ' num2str(sMarkers{kin_ind}.info.trial_id) ' agent: ' agentExec])
        
        % FIND the correct video to cut
        % The video indeces should be every 6 videos
        %Create a vector with all the first indeces of the  group of 6
        %trials
        curr_vid_ind  = each6_vid(t) + vid_ind;
        curr_vid      = vid_list(curr_vid_ind).name; %select the video

        % Cut video based on tstart and tstop
        v                 = VideoReader(fullfile(path_video,curr_vid));
        vidObj            = VideoWriter([path_video_cut,curr_vid(1:end-4)],'MPEG-4');
        open(vidObj);
        % Choose the initial frame between : agent reaction time, index finger/ulna reaction time
        tstart_frame   = ceil(tstart*vidObj.FrameRate);
        startVector    = [tstart_frame,indexTh(1),ulnaTh(1)];
        [~,startFrame] = min(startVector);
        if startFrame ~= 1
            %If the initial frame is from the index/ulna movement, take n
            %frames before as startFrame
            startFrame = startFrame - 10;
        end

        for frame = startFrame:v.NumFrames %from tstart(transformed in frame) to the very last frame
            new_v = read(v,frame);
            writeVideo(vidObj,new_v)
        end
        deltaFrames    =  (v.NumFrames - startFrame);%number of frames in the same video

        % Fill the table
        vid_info(t,:) = {['P' SUBJECTS{p}(2:end)],t,curr_vid,str2num(agentExec(2)),rt_agent,...
                        indexTh(1)/vidObj.FrameRate,ulnaTh(1)/vidObj.FrameRate,...
                        v.Duration,vidObj.Duration,...
                        tstart,startFrame,v.NumFrames,deltaFrames,...
                        v.Width,v.Height};
        % Close video object
        close(vidObj);

        %save variable
        vid_info.Properties.VariableNames = varName;
        writetable(vid_info,fullfile(path_video_cut,['P' SUBJECTS{p}(2:end) '_vidInfo.xlsx']));

    end
    clear sMarkers session
end
