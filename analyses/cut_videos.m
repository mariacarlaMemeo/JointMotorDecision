

%% Script to cut the video files from the pilot data acquired the 3-4 Nov 2022. Pairs from P100 to P103
%path
path_data = 'Y:\Datasets\JointMotorDecision\Static\Raw';

%% Load each processed mat file per subject
folder_list  = dir(path_data);
folder_list  = folder_list(~ismember({folder_list.name},{'.','..'}));
%List of participants
SUBJECTS     = {folder_list.name};
SUBJECT_LIST = cellfun(@(s) find(contains(s,'P1')),SUBJECTS,'uni',0);
SUBJECT_LIST = ~cellfun(@isempty,SUBJECT_LIST);
SUBJECTS     = SUBJECTS(SUBJECT_LIST);

% Create a table
vid_info     = table();
varName     = {'pair','trial','name_vid','dura_vid','dura_vid_cut','tstart_cut','tstartSample_cut','deltaFrames'};


% The information we need to retrieve is the reaction time. It is in the
% excel file and it depends on the agent that is performing the 2nd trial,
% e.g. if agent 1 starts, we need to show the video of agent 2 with its
% relative reaction time.

% tstart = 200ms + reaction time(without movement time)
% tstop  = end of the video

for p = 1%:length(SUBJECTS)

    % set the path for the video and the rt variables
    path_data_each = fullfile(path_data,SUBJECTS{p},['task\pilotData_' SUBJECTS{p}(2:end) '.xlsx'] );
    path_video     = fullfile(path_data,SUBJECTS{p},'jmd\');
    path_video_cut = fullfile(path_data,SUBJECTS{p},'video_cut\');
    mkdir(path_video_cut);

    % Open excel file to check who's performing the 2nd trial and choose the reaction time of the complementar agent.
    % If you check column 'AgentTakingFirstDecision' you already have the
    % agent whose reaction time you need to use for the video.
    [~,txt,raw] = xlsread(path_data_each);
    raw         = raw(2:end,:);%removed the header

    % The video indeces should be every 6 videos
    %Create a vector with all the first indeces of the  group of 6
    %trials
    vid_list      = dir([path_video '*.avi']);
    each6_vid     = 1:6:length(vid_list);%the first index of 

    for t = 1:length(raw)

        at1stDec_ind  = strcmp('AgentTakingFirstDecision',txt);
        at1stDec      = cell2mat(raw(:,at1stDec_ind));
        if at1stDec(t)==1 %if it's agent1
            rt_ind    = strcmp('A1_rt',txt);
            tstart    = 0.2 + (0.001*raw{t,rt_ind}); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind   = 3;% (the fourth video to be add to the first index) The loop should be every 6 videos. 2 videos from the 2 videocam per trial.
        elseif at1stDec(t)==2
            rt_ind    = strcmp('A2_rt',txt);
            tstart    = 0.2 + (0.001*raw{t,rt_ind}); %The variable is in [s]. Added the 200ms from the pre-acquisition in Vicon
            vid_ind   = 2;% (the third video to be add to the first index) The for loop should be every 6 videos. 2 videos from the 2 videocam per trial.
        end

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
        deltaFrames    =  (v.NumFrames - vidObj.FrameCount);

        % Fill the table
        vid_info(t,:) = {['P' SUBJECTS{p}(2:end)],t,curr_vid,v.Duration,vidObj.Duration,tstart,tstart_frame,deltaFrames,};
        % Close video object
        close(vidObj);
        
        %save variable
        vid_info.Properties.VariableNames = varName;
        writetable(vid_info,['P' SUBJECTS{p}(2:end) '_vidInfo1.xlsx']);

    end
end


