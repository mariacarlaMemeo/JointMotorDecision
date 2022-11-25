%% Joint motor decision exp. Pilot data Nov 2022.
% Video cutting for the observation exp
clear
close all

%%
% Pilot data
% - P100. Vicon(2.10.3) crashed at trial 93. In Nexus the corresponding trials are missing, i.e. 277-279. Instead in MAtlab they are present.
% - P101. Vicon(2.10.3) crashed at trial 3. In Nexus there is continuity among the trials, so the trials 31-33 are related to the trial n.4

% %% Use the cluster - Franklin
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
frameRate  = 100;

% The information we need to retrieve is the reaction time. It is in the
% excel file and it depends on the agent that is performing the 2nd trial,
% e.g. if agent 1 starts, we need to show the video of agent 2 with its
% relative reaction time.

% tstart = 200ms + reaction time(without movement time)
% tstop  = end of the video

for p = 1%:length(SUBJECTS)

    disp(['Start ' SUBJECTS{p}(2:end)])
    clear vid_info vidObj v
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
        if p==2 && t>=116 && t<=137%there is misalignment of 1 trial for this subejct (cannot figure it out)
            kin_ind    = c3d_ind(t);
        elseif p==2 && t>=138 %there is misalignment of 1 trial for this subejct (cannot figure it out)
            kin_ind    = c3d_ind(t)-1;
        else
            kin_ind    = 1+c3d_ind(t); % always the 2° in case it's the first/second agent acting
        end

        % CHECK index and wrist velocity threshold
        vel_th     = 20; %20[mm/s]
        preAcq     = 20; %preacquisition of 200ms == 20 frames
        succSample = 15; %samples where to check if the kinematic threshold is higher than 
        model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
        samp       = 1:sMarkers{kin_ind}.info.nSamples;
        index      = sMarkers{kin_ind}.markers.([model_name '_index']).Vm;% - mean(sMarkers{kin_ind}.markers.([model_name '_index']).Vm(1:preAcq));
        ulna       = sMarkers{kin_ind}.markers.([model_name '_ulna']).Vm;% - mean(sMarkers{kin_ind}.markers.([model_name '_ulna']).Vm(1:preAcq));
        indexTh    = findTh_cons(index(preAcq:end),vel_th,succSample);%>20[mm/s] for 5 frames, the first interval
        indexTh    = indexTh + preAcq;%I add preAcq because I excluded it from the previous function
        ulnaTh     = findTh_cons(ulna(preAcq:end),vel_th,succSample); 
        ulnaTh     = ulnaTh + preAcq; 

        %z coordinates
        indexZ     = sMarkers{kin_ind}.markers.([model_name '_index']).xyzf(:,3);%-  mean(sMarkers{kin_ind}.markers.([model_name '_index']).xyzf(1:preAcq,3));
        ulnaZ      = sMarkers{kin_ind}.markers.([model_name '_ulna']).xyzf(:,3);% - mean(sMarkers{kin_ind}.markers.([model_name '_ulna']).xyzf(1:preAcq,3));

        % FIND the correct video to cut
        % The video indeces should be every 6 videos
        %Create a vector with all the first indeces of the  group of 6
        %trials
        curr_vid_ind  = each6_vid(t) + vid_ind;
        curr_vid      = vid_list(curr_vid_ind).name; %select the video


        yPos_text   = max(ulna);

        v=figure('Name',['P' SUBJECTS{p}(2:end)]); set(v, 'WindowStyle', 'Docked');
        yyaxis left; plot(samp,index);hold on; plot(samp,indexZ); hold off;
        yyaxis right; plot(samp,ulna);hold on; plot(samp,ulnaZ); hold off;
        xline(preAcq); text(preAcq,yPos_text-300,' pre: 200ms');
        xline(samp(end)-10); text((samp(end)-10),yPos_text-300,' post');
        xline(tstart*frameRate,'Color', [0.4660 0.6740 0.1880]); text((tstart*frameRate),yPos_text-300,' RTagent','Color',[0.4660 0.6740 0.1880]);
        if ~isnan(indexTh(1))
            xline(indexTh(1),'Color',[0 0.4470 0.7410]);text(indexTh(1),yPos_text-300,' Index > 20','Color', [0 0.4470 0.7410]);
        end
        if ~isnan(ulnaTh(1))
            xline(ulnaTh(1),'Color',[0.8500 0.3250 0.0980]);text(ulnaTh(1),yPos_text-350,' Ulna > 20','Color', [0.8500 0.3250 0.0980]);
        end
        title(['matTrial: ' sMarkers{kin_ind}.info.fullpath(end-11:end) '; kinTrial: ' num2str(sMarkers{kin_ind}.info.trial_id) '; agent: ' agentExec '; video: ' vid_list(curr_vid_ind).name(1:12)])

        % Cut video based on tstart and tstop
        v                 = VideoReader(fullfile(path_video,curr_vid));
        vidObj            = VideoWriter([path_video_cut,curr_vid(1:end-4)],'MPEG-4');
        vidObj.FrameRate  = 100;
        open(vidObj);
        % Choose the initial frame between : agent reaction time, index finger/ulna reaction time
        tstart_frame   = ceil(tstart*frameRate);
        startVector    = [indexTh(1),ulnaTh(1)];
        [startFrame,ind_start] = min(startVector);

        %If the initial frame is from the index/ulna movement, take n
        %frames before as startFrame
        startFrame = startFrame - 10;
        if startFrame<=0
            startFrame = 1;
        end

        %In case the video lasts only 20 or 50 frames there was an issue
        %in the acquisition: the video is discarded
        if v.NumFrames > 50
            stopFrame  = v.NumFrames-10;
            for frame = startFrame:stopFrame %from tstart(transformed in frame) to the last frame - 10 (100ms were added to the video by matlab script)
                new_v = read(v,frame);
                writeVideo(vidObj,new_v)
            end
            deltaFrames    =  (stopFrame - startFrame);%number of frames in the same video
            cutVideo_dur   = vidObj.Duration;
        else
            indexTh(1)   = NaN;
            ulnaTh(1)    = NaN;
            stopFrame    = v.NumFrames-10;
            deltaFrames  = 0;
            cutVideo_dur = 0;
        end

        % Fill the table
        vid_info(t,:) = {['P' SUBJECTS{p}(2:end)],t,curr_vid,str2num(agentExec(2)),rt_agent,...
            indexTh(1)/frameRate,ulnaTh(1)/frameRate,...
            v.Duration,vidObj.Duration,...
            tstart,startFrame,stopFrame,deltaFrames,...
            v.Width,v.Height};
        % Close video object
        close(vidObj);

        %save variable
        vid_info.Properties.VariableNames = varName;
        writetable(vid_info,fullfile(path_video_cut,['P' SUBJECTS{p}(2:end) '_vidInfo.xlsx']));

    end
    clear sMarkers session
end
