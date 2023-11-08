function [startFrame,tmove,rt_final,dt_final,mt_final,endFrame]= ...
    movement_onset(sMarkers,t,SUBJECTS,p,agentExec,label_agent,rt_mat,trial_plot,figurepath)

% -------------------------------------------------------------------------
% -> Here we identify START and END of each movement, to then cut the trial.
% -------------------------------------------------------------------------
% This function is called from calc_kin_rt_mt.m
% Functions and scripts called from within here:
% 1. findTh_cons
% 2. find_tmove
% 3. visual_check

% Note: input argument "figurepath" is needed for visual_check
start_criterion  = 0; %1=index;2=ulna;3=button release
%% Retrieve and define parameters
% retrieve information from Vicon recording
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:}; % retrieve acquisition frame rate in Hz (Hz = 1 event per sec)
model_name = [SUBJECTS{p} '_' agentExec '_' agentExec]; % retrieve names of hand models in Nexus, e.g., "S108_blue_blue"
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']).Vm; % velocity module for index
ulna       = sMarkers{t}.markers.([model_name '_ulna']).Vm;  % velocity module for ulna
indexZ     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,3); % height for index
ulnaZ      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,3);  % height for ulna
% define variables
vel_th     = 20; % set velocity threshold at 20 [mm/s]
succSample = 10; % number of continuous samples that should pass the velocity threshold
% NOTE on preAcq: Vicon recording started with display of decision prompt in Matlab;
% then 20 frames were added before that moment in Vicon, i.e., recording start = prompt-20
preAcq     = 20; % preacquisition duration: 200 ms == 20 frames (10ms/0.01s = 1 frame)
% figure settings
plotxShift = 3.5; % default x-position for vertical text (left of line)
yPos_text  = max(index); % yPos_text-300 is default position for start of vertical text
blueCol    = [0 0.4470 0.7410]; % blue for ulna
orangeCol  = [0.8500 0.3250 0.0980]; % orange for index
startCol   = [0.3922 0.8314 0.0745]; % green for start
moveCol    = [1 0 0]; % red for actual movement start (tmove)
% *Reaction Time*:
% "rt_mat" has been recorded during acquisition (and saved in original Matfile)
% rt_mat = time from decision prompt to button release (i.e., without pre-acquisition)
% RT conversion: (convert rt from ms to s) and multiply by frameRate to get no. of frames
rt_mat = round((rt_mat/1000)*frameRate);

%% Find out when velocity threshold is passed (-> function *findTh_cons*)
indexTh    = findTh_cons(index,vel_th,succSample);
ulnaTh     = findTh_cons(ulna,vel_th,succSample);

%% Find movement start in a different way (-> function *find_tmove*)
% This can be used to define movement start but is currently (Oct 2023) NOT used!
% Functionality: Selects the maximum peak and the minimum preceding it.
% The output gives you the index of the minimum; this is tmove.
tmove = find_tmove(ulna); % here we apply this to the ulna only

%% Define TRIAL START (startFrame) & TRIAL END (endFrame), i.e., where to cut the movement
% *startFrame* = indexTh or ulnaTh (whichever comes first) OR
%                the moment of start button release
%                (IF the release occurs *before* indexTh/ulnaTh)
%                NOTE: startFrame INCLUDES the 20 frames of preAcq
% *endFrame*   = target press
startVector            = [indexTh(1),ulnaTh(1)]; % take the 1st value that passed threshold
[startFrame,ind_start] = min(startVector); % choose smaller value and its index [min value, index min value]
if ind_start == 1
    start_criterion = 1;
elseif ind_start == 2
    start_criterion = 2;
end

if startFrame > rt_mat+preAcq % if chosen startFrame occurs later than button release, then re-define
    startFrame = rt_mat+preAcq;
    start_criterion = 3;
end

endFrame               = (samp(end)-10); % time of target button press

% Check if the movement started *after* decision prompt
if startFrame > preAcq

    % Notes on cutting --------------------------------------------------------
    % 24-05-23: decision to use *only the ulna* for finding movement start
    % 25-10-23: decision to use either ulna or index (whichever crosses the
    % velocity threshold first), but only if this happens *before* button release .
    % If button release occurs before passing of threshold, then the button
    % release is taken as movement start.
    % -------------------------------------------------------------------------

    %% Plot movement trajectories for one single trial (= one decision)
    if trial_plot % -----------------------------------------------------------

        v=figure('Name',['P' SUBJECTS{p}(2:end)]); % create figure v
        set(v, 'WindowStyle', 'Docked'); % dock figure

        % 1. plot velocity and height for ULNA; use *left* y-axis of plot
        yyaxis left;
        plot(samp,ulna);  % ulna velocity ("ulna")
        hold on;
        plot(samp,ulnaZ); % ulna height ("ulnaZ")
        ylabel('Velocity [mm/s]'); % label for left y-axis
        hold off;
        % plot blue vertical line (+ label) to illustrate passing of velocity threshold ulnaTh
        if ~isnan(ulnaTh(1))
            xline(ulnaTh(1), 'Color',blueCol);
            t_uln = text(ulnaTh(1)-plotxShift, yPos_text-300,' tstart ulna','Color',blueCol);
            set(t_uln,'Rotation',90);
            %         % optional: make trajectory bold (from passing of threshold until button press)
            %         plot(ulnaTh(1):(samp(end)-10),ulna(ulnaTh(1):(samp(end)-10)),'-', 'Color',blueCol,'LineWidth',3);
        end

        % 2. plot velocity and height for INDEX; use *right* y-axis of plot
        yyaxis right;
        plot(samp,index);  % index velocity ("index")
        hold on;
        plot(samp,indexZ); % index height ("indexZ")
        hold off;
        % plot orange vertical line (+ label) to illustrate passing of velocity threshold indexTh
        if ~isnan(indexTh(1))
            xline(indexTh(1), 'Color',orangeCol);
            t_ind = text(indexTh(1)-plotxShift,yPos_text-300,' tstart index','Color', orangeCol);
            set(t_ind,'Rotation',90);
        end

        % 3. plot three more vertical lines:
        xline(preAcq); % "t0": decision prompt (= start of recording + 20 frames of preAcq)
        t_pre    = text(preAcq-plotxShift,yPos_text-300,' decision prompt (t0)'); set(t_pre,'Rotation',90);
        xline(rt_mat+preAcq); % "t1": moment of button release
        t_rt_mat = text(rt_mat+preAcq-plotxShift,yPos_text-450,' button release (t1)'); set(t_rt_mat,'Rotation',90);
        xline(samp(end)-10);  % "t2": moment of button press (i.e., 10 frames before end of recording)
        t_post   = text((samp(end)-10)-plotxShift,yPos_text-300,' target press (t2)'); set(t_post,'Rotation',90);

        % set x-axis limit as end of sample (=100 if normalized)
        xlim([0 samp(end)]);
        % add title with pair no., acting agent, marker, matTrial, actual trial
        title(['Pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
        xlabel('Samples');

        % *optional* stuff to add ---------------------------------------------
        %     % plot horizontal line to indicate height of velocity threshold
        %     % of 20 mm/s (this is difficult if left and right axis have different units)
        %     yline(vel_th,'-',[num2str(vel_th) ' mm/s'], 'LineWidth',1, 'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');
        %     % plot vertical bold red line on tmove
        xline(startFrame, 'LineWidth',3, 'Color',startCol);
        % ---------------------------------------------------------------------

    end % end of trial plot ---------------------------------------------------

    %% Define REACTION TIME and MOVEMENT TIME accordingly
    % rt_final = time from decision prompt until startFrame (see above)
    % NOTE: RT is now measured in frames such that 1 frame = 10ms (with frameRate 100Hz),
    %       so if you divide RT/frameRate, you get *SECONDS as final unit* (e.g., 10frames/100Hz = 0.1s)
    rt_index = (indexTh(1)-preAcq)/frameRate;
    rt_ulna  = (ulnaTh(1)-preAcq)/frameRate;
    rt_final = (startFrame-preAcq)/frameRate;

    % mt_final = time between movement start and target press
    % both startFrame and endFrame include preAcq, so it is fine so simply
    % subtract startFrame from endFrame to get MT
    mt_final = (endFrame-startFrame)/frameRate;


    %% Add possibility to change startFrame and endFrame MANUALLY
    if trial_plot
        visual_check;

        % optional: if we decide to use "tmove"
        % % Check if tmove appears before startFrame - in that case tmove=startFrame
        % if ~isnan(tmove)
        %     if tmove<startFrame && ~isempty(startFrame)
        %         tmove         = startFrame;
        %         visual_change = 1;
        %     end
        % end

        % Update start/endFrame (if visual_change is set to 1 in visual_check)
        if visual_change && not(del_fig)% ----------------------------------------

            v=figure('Name',['P' SUBJECTS{p}(2:end)]); % create figure v
            set(v, 'WindowStyle', 'Docked'); % dock figure

            % 1. plot velocity and height for ULNA; use *left* y-axis of plot
            yyaxis left;
            plot(samp,ulna);  % ulna velocity ("ulna")
            hold on;
            plot(samp,ulnaZ); % ulna height ("ulnaZ")
            ylabel('Velocity [mm/s]'); % label for left y-axis
            hold off;
            % plot blue vertical line (+ label) to illustrate passing of velocity threshold ulnaTh
            if ~isnan(ulnaTh(1))
                xline(ulnaTh(1), 'Color',blueCol);
                t_uln = text(ulnaTh(1)-plotxShift, yPos_text-300,' tstart ulna','Color',blueCol);
                set(t_uln,'Rotation',90);
            end

            % 2. plot velocity and height for INDEX; use *right* y-axis of plot
            yyaxis right;
            plot(samp,index);  % index velocity ("index")
            hold on;
            plot(samp,indexZ); % index height ("indexZ")
            hold off;
            % plot orange vertical line (+ label) to illustrate passing of velocity threshold indexTh
            if ~isnan(indexTh(1))
                xline(indexTh(1), 'Color',orangeCol);
                t_ind = text(indexTh(1)-plotxShift,yPos_text-300,' tstart index','Color', orangeCol);
                set(t_ind,'Rotation',90);
            end

            % 3. plot vertical line for startFrame (ulnaTh, indexTh, or button release)
            if ~isnan(startFrame)
                xline(startFrame, 'LineWidth',3, 'Color',startCol); % plot in bold
                t_start=text(startFrame-plotxShift,yPos_text-300,' tstart', 'Color',startCol);
                set(t_start,'Rotation',90);
            end

            % 4. plot three more vertical lines:
            xline(preAcq); % "t0": decision prompt (= start of recording + 20 frames of preAcq)
            t_pre    = text(preAcq-plotxShift,yPos_text-300,' decision prompt (t0)'); set(t_pre,'Rotation',90);
            xline(rt_mat+preAcq); % "t1": moment of button release
            t_rt_mat = text(rt_mat+preAcq-plotxShift,yPos_text-450,' button release (t1)'); set(t_rt_mat,'Rotation',90);
            xline(samp(end)-10);  % "t2": moment of button press (i.e., 10 frames before end of recording)
            t_post   = text((samp(end)-10)-plotxShift,yPos_text-300,' target press (t2)'); set(t_post,'Rotation',90);

            % optional: if we decide to use "tmove"
            %     % plot vertical line for tmove
            %     if ~isnan(tmove)
            %         xline(tmove, 'LineWidth',3, 'Color',moveCol); % plot in bold
            %         t_mv = text(tmove-plotxShift,yPos_text-300,' tmove', 'Color',moveCol);
            %         set(t_mv,'Rotation',90);
            %     end

            % set x-axis limit as end of sample (=100 if normalized)
            xlim([0 samp(end)]);
            % add title with pair no., acting agent, marker, matTrial, actual trial
            title(['Pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
            xlabel('Samples');

            % save the new figure
            saveas(gcf,strcat(jpg_title,'_v1.png'))

            % Update RT and MT according to new start/endFrame
            rt_final = (startFrame-preAcq)/frameRate;
            mt_final = (endFrame-startFrame)/frameRate;

        end % end of plotting after visual_check ----------------------------------

    end

    % Calculate deliberation time: tmove - startFrame - CURRENTLY NOT USED
    dt_final = (tmove-startFrame)/frameRate;

else
    startFrame=NaN; tmove=NaN; rt_final=NaN; dt_final=NaN; mt_final=NaN; endFrame=NaN;
end

% If we decide to eliminate the trial in visual_check: fill with NaN values
if exist('del_fig') && del_fig
    startFrame=NaN; tmove=NaN; rt_final=NaN; dt_final=NaN; mt_final=NaN; endFrame=NaN;
end

close all % close figure(s)


end % end of function -> go back into calc_rt_mt.m

% script version: 1 Nov 2023