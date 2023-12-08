function [startFrame,tmove,rt_final,dt_final,mt_final,endFrame,trg,pksInd,pksUlna,savemat,mod,start_criterion]= ...
    movement_onset(sMarkers,t,SUBJECTS,p,agentExec,label_agent,rt_mat,trial_plot,figurepath)

% -------------------------------------------------------------------------
% -> Here we identify START and END of each movement, to then cut the trial.
% -------------------------------------------------------------------------
% This function is called from calc_kin_rt_mt.m
% Functions and scripts called from within here:
% 1. findTh_cons
% 2. find_tmove, find_minstart
% 3. visual_check
% 4. nPeaks

% ***WATCH OUT***
% 1. t refers to decision number faa/saa/caa (not trial number as in calc_kin_trial)
% 2. Do not remove input argument "figurepath" (needed for visual_check)

%% Retrieve and define parameters

% Set parameters to NaN as default (needed if we don't go into visual_check)
% NOTE: trg and mode will only be set if we check trial by trial
trg = NaN; % trg-paramter: did agent change target (first left, then right) or not?
mod = NaN; % mod indicates whether tstart/tmove/tend was manually changed
pksInd.peaks_index=NaN;pksInd.peak_loc_index=NaN;pksInd.npIndex=NaN; % peak struct (value,location,number)
pksUlna.peaks_ulna=NaN;pksUlna.peak_loc_ulna=NaN;pksUlna.npUlna=NaN;
savemat = 0; % flag to exit and save a backup (exit if savemat=1)

% Retrieve information from Vicon recording
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:}; % retrieve acquisition frame rate: 100Hz (Hz = 1 event per sec)
model_name = [SUBJECTS{p} '_' agentExec '_' agentExec]; % retrieve names of hand models in Nexus, e.g., "S108_b_b"
samp       = 1:sMarkers{t}.info.nSamples;
indexV     = sMarkers{t}.markers.([model_name '_index']).Vm; % velocity module for index
ulnaV      = sMarkers{t}.markers.([model_name '_ulna']).Vm;  % velocity module for ulna
indexZ     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,3); % height for index
ulnaZ      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,3);  % height for ulna
indexY     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,2); % y-axis (forward) for index
ulnaY      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,2);  % y-axis (forward) for ulna

% Define variables
vel_th     = 20; % set velocity threshold at 20 [mm/s]
succSample = 10; % number of continuous samples that should pass the velocity threshold
% NOTE on preAcq: Vicon recording started with display of decision prompt in Matlab;
% then 20 frames were added before that moment in Vicon, i.e., recording start = prompt-20
preAcq     = 20; % preacquisition duration: 200 ms == 20 frames (10ms/0.01s = 1 frame)
% *Reaction Time*:
% "rt_mat" has been recorded during acquisition (and saved in original Matfile)
% rt_mat = time from decision prompt to button release (i.e., without pre-acquisition)
% RT conversion: (convert rt from ms to s) and multiply by frameRate to get no. of frames
rt_mat           = round((rt_mat/1000)*frameRate);
start_criterion  = 0; % which criterion was used to identify startFrame? (1=index;2=ulna;3=button)

% Figure settings
blueCol    = [0 0.4470 0.7410]; % blue for ulna
orangeCol  = [0.8500 0.3250 0.0980]; % orange for index
startCol   = [0.3922 0.8314 0.0745]; % green for start
startCol_2 = [0.2196 0.9608 0.2588]; % dark green for "final" start
stopCol    = [0.6353 0.0784 0.1843]; % red for end
stopCol_2  = [0.9020 0.1961 0.3255]; % bright red for "final" end
x_width    = 18; % figure width
y_width    = 12; % figure height


%% Find out when velocity threshold is passed (-> function *findTh_cons*)
indexTh    = findTh_cons(indexV,vel_th,succSample);
ulnaTh     = findTh_cons(ulnaV,vel_th,succSample);


%% Define TRIAL START (startFrame) & TRIAL END (endFrame), i.e., where to cut the movement
% *startFrame* = indexTh or ulnaTh (whichever comes first) OR
%                the moment of start button release
%                (IF the release occurs *before* indexTh/ulnaTh)
%                NOTE: startFrame INCLUDES the 20 frames of preAcq
% *endFrame*   = target press or velocity minimum

% Notes on cutting --------------------------------------------------------
% 24-05-23: decision to use *only the ulna* for finding movement start
% 25-10-23: decision to use either ulna or index (whichever crosses the
% velocity threshold first), but only if this happens *before* button release .
% If button release occurs before passing of threshold, then the button
% release is taken as movement start.
% 24-11.23: first we looked for velocity threshold also within preAcqu),
% but then this trial was automatically excluded if startFrame>preAcqu, so
% we decided to change that (see below) so that we can also inspect those
% trials
% startVector            = [indexTh(1),ulnaTh(1)]; % take the 1st value that passed threshold
% [startFrame,ind_start] = min(startVector); % choose smaller value and its index [min value, index min value]
% -------------------------------------------------------------------------

% Check for index and ulna the earliest passing of velocity threshold
% NOTE: this moment must be AFTER preAcqu, i.e., index must be > preAcqu
indCount=1; ulnCount=1;
% 1. check for index
while indexTh(indCount) <= preAcq % go until index is > preAcqu
     indCount = indCount+1;
end
% 2. check for ulna
while ulnaTh(ulnCount) <= preAcq
     ulnCount = ulnCount+1;
end
% 3. define respective startFrames for index and ulna
startIndex = indexTh(indCount);
startUlna  = ulnaTh(ulnCount);
% 4. finally, set startFrame as the one (index or ulna) that occured earlier
[startFrame,ind_start] = min([startIndex,startUlna]);

if ind_start == 1
    start_criterion = 1; % index
elseif ind_start == 2
    start_criterion = 2; % ulna
end

% Check if chosen startFrame (based on index or ulna velocity threshold)
% occurs later than button release (rt_mat+preAcqu), then re-define start:
% -> startFrame = button release
if startFrame > rt_mat+preAcq 
    startFrame = rt_mat+preAcq;
    start_criterion = 3;
end

% Check which criterion was used to define the startFrame
if start_criterion == 1
    move_marker = indexV;
elseif start_criterion == 2
    move_marker = ulnaV;
elseif start_criterion == 3
    if ind_start == 1
        move_marker = indexV;
    elseif ind_start == 2
        move_marker = ulnaV;
    end
end

% NOTE: if startFrame based on velocity threshold, then use find_minstart
% to find the velocity minimum right before the threshold was passed
if start_criterion == 1 || start_criterion == 2
    startFrame = find_minstart(move_marker,startFrame);
end

% define endFrame
lastFrame = (samp(end)-10); % time of target button press
% If the minimum of index velocity occurs before or after the button press,
% then use this minimum as endFrame
% FUNCTION HERE
endFrame = find_tstop(indexV);
if isnan(endFrame)
    endFrame = lastFrame;
end

% Find movement start in a different way (-> function *find_tmove*)
% Functionality: Selects the maximum peak and the minimum preceding it.
% The output gives you the index of the minimum; this is tmove.
% NOTE: the function is applied to the marker which has been previously
% used to define the startFrame.
% EDIT (05.12.23): ALWAYS use index velocity to define tmove
tmove = find_tmove(indexV); % call find_tmove function
if tmove < startFrame || isnan(tmove)
    tmove = startFrame;
end

%% START PLOTTING LOOP only if startFrame *after* decision prompt
if startFrame > preAcq

    %% Plot movement trajectories for one single trial (= one decision)
    if trial_plot % -----------------------------------------------------------

        v=figure('Name',['P' SUBJECTS{p}(2:end)]); % create figure v
        set(v, 'WindowStyle', 'Docked'); % dock figure

        % 1. plot velocity and height for ULNA; use *left* y-axis of plot
        yyaxis left;
        uv=plot(samp,ulnaV, 'Color',blueCol);  % ulna velocity ("ulna")
        hold on;
        uz=plot(samp,ulnaY, 'Color',blueCol, 'LineStyle','--'); % ulna forward ("ulnaY")
        uz.Annotation.LegendInformation.IconDisplayStyle = 'off';
        ylabel('Velocity [mm/s]'); % label for left y-axis
        % plot blue vertical line (+ label) to illustrate passing of velocity threshold ulnaTh
        if ~isnan(startUlna)
            xl = xline(startUlna,':'); xl.LineWidth = 1; xl.Color = blueCol;
            xl.Label = 'tstart ulna';
            xl.LabelHorizontalAlignment = "center"; xl.LabelVerticalAlignment = "top";
            xl.Annotation.LegendInformation.IconDisplayStyle = 'off';
            % optional: make trajectory bold (from passing of threshold until button press)
            %plot(startUlna:(samp(end)-10),ulna(startUlna:(samp(end)-10)),'-', 'Color',blueCol,'LineWidth',3);
        end
        hold off;

        % 2. plot velocity and height for INDEX; use *right* y-axis of plot
        yyaxis right;
        iv=plot(samp,indexV, 'Color',orangeCol);  % index velocity ("index")
        hold on;
        iz=plot(samp,indexY, 'Color',orangeCol, 'LineStyle','--'); % index forward ("indexY")
        iz.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % plot orange vertical line (+ label) to illustrate passing of velocity threshold indexTh
        if ~isnan(startIndex)
            xl = xline(startIndex,':'); xl.LineWidth = 1; xl.Color = orangeCol;
            xl.Label = 'tstart index';
            xl.LabelHorizontalAlignment = "center"; xl.LabelVerticalAlignment = "top";
            xl.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        hold off;

        % create legend with only ulna and index labeled
        legend([uv,iv], {'ulna', 'index'}, 'Location','northwest');
        

        % 3. plot bold green vertical line on startFrame (ulnaTh, indexTh, or button release)
        xl_start = xline(startFrame, 'LineWidth',4, 'Color',startCol);
        xl_start.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xl_start.Alpha = 0.5; % transparency of line (0.7 is default)

        % red line for endFrame
        xl_tstop = xline(endFrame, 'LineWidth',4, 'Color',stopCol);
        xl_tstop.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xl_tstop.Alpha = 0.4; % transparency of line (0.7 is default)

        % 4. plot three more vertical lines for t0, t1, t2
        xl_t0 = xline(preAcq,'-'); % "t0": decision prompt (= start of recording + 20 frames of preAcq)
        xl_t1 = xline(rt_mat+preAcq,'-'); % "t1": moment of button release
        xl_t2 = xline(lastFrame,'-');  % "t2": moment of button press (i.e., 10 frames before end of recording)
        xl_t3 = xline(tmove,'--');  % tmove        
        xl_t0.LineWidth = 0.8; xl_t0.Label = 'decision prompt t0'; xl_t0.LabelHorizontalAlignment = "center"; xl_t0.LabelVerticalAlignment = "middle";
        xl_t1.LineWidth = 0.8; xl_t1.Label = 'button release t1'; xl_t1.LabelHorizontalAlignment = "center"; xl_t1.LabelVerticalAlignment = "middle";
        xl_t2.LineWidth = 0.8; xl_t2.Label = 'target press t2'; xl_t2.LabelHorizontalAlignment = "center"; xl_t2.LabelVerticalAlignment = "middle";
        xl_t3.LineWidth = 0.8; xl_t3.Label = 'tmove'; xl_t3.LabelHorizontalAlignment = "center"; xl_t3.LabelVerticalAlignment = "top";
        xl_t0.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xl_t1.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xl_t2.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xl_t3.Annotation.LegendInformation.IconDisplayStyle = 'off';

        % set x-axis limit as end of sample
        xlim([0 samp(end)]);

        % add title with pair no., acting agent, marker, matTrial, actual trial
        title(['pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
        xlabel('Samples (1sample=10ms)');

        % *optional* stuff to add ---------------------------------------------
        %     % plot horizontal line to indicate height of velocity threshold
        %     % (this is difficult if left and right axis have different units)
        %     yline(vel_th,'-',[num2str(vel_th) ' mm/s'], 'LineWidth',1, 'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');
        % ---------------------------------------------------------------------

    end % end of trial plot ---------------------------------------------------

    %% Define REACTION TIME and MOVEMENT TIME accordingly
    % rt_final = time from decision prompt until startFrame (see above)
    % NOTE: RT is now measured in frames such that 1 frame = 10ms (with frameRate 100Hz),
    %       so if you divide RT/frameRate, you get *SECONDS as final unit* (e.g., 10frames/100Hz = 0.1s)
    rt_index = (startIndex-preAcq)/frameRate;
    rt_ulna  = (startUlna-preAcq)/frameRate;
    rt_final = (startFrame-preAcq)/frameRate;

    % mt_final = time between movement start and target press
    % both startFrame and endFrame include preAcq, so it is fine so simply
    % subtract startFrame from endFrame to get MT
    mt_final = (endFrame-startFrame)/frameRate;


    %% Add possibility to change startFrame and endFrame MANUALLY
    if trial_plot
        
        visual_check; % go into visual_check.m

        % Check if tmove appears before startFrame - in that case tmove=startFrame
        if ~isnan(tmove)
            if tmove<startFrame && ~isempty(startFrame)
                tmove         = startFrame;
                visual_change = 1;
            end
        end

        % Update start/endFrame (if visual_change is set to 1 in visual_check)
        if visual_change && not(del_fig) % --------------------------------

            v=figure('Name',['P' SUBJECTS{p}(2:end)]); % create figure v
            set(v, 'WindowStyle', 'Docked'); % dock figure

            % 1. plot velocity and height for ULNA; use *left* y-axis of plot
            yyaxis left;
            uv=plot(samp,ulnaV, 'Color',blueCol);  % ulna velocity ("ulna")
            hold on;
            uz=plot(samp,ulnaY, 'Color',blueCol, 'LineStyle','--'); % ulna forward ("ulnaY")
            uz.Annotation.LegendInformation.IconDisplayStyle = 'off';
            ylabel('Velocity [mm/s]'); % label for left y-axis
            % plot blue vertical line (+ label) to illustrate passing of velocity threshold ulnaTh
            if ~isnan(startUlna)
                xl = xline(startUlna,':'); xl.LineWidth = 1; xl.Color = blueCol;
                xl.Label = 'tstart ulna';
                xl.LabelHorizontalAlignment = "center"; xl.LabelVerticalAlignment = "top";
                xl.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold off;

            % 2. plot velocity and height for INDEX; use *right* y-axis of plot
            yyaxis right;
            iv=plot(samp,indexV, 'Color',orangeCol);  % index velocity ("index")
            hold on;
            iz=plot(samp,indexY, 'Color',orangeCol, 'LineStyle','--'); % index forward ("indexY")
            iz.Annotation.LegendInformation.IconDisplayStyle = 'off';
            % plot orange vertical line (+ label) to illustrate passing of velocity threshold indexTh
            if ~isnan(startIndex)
                xl = xline(startIndex,':'); xl.LineWidth = 1; xl.Color = orangeCol;
                xl.Label = 'tstart index';
                xl.LabelHorizontalAlignment = "center"; xl.LabelVerticalAlignment = "top";
                xl.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold off;

            % create legend with only ulna and index labeled
            legend([uv,iv], {'ulna', 'index'}, 'Location','northwest');

            % 3. plot bold green vertical line on FINAL startFrame
            if ~isnan(startFrame)
                xl_start = xline(startFrame, 'LineWidth',4, 'Color',startCol_2);
                xl_start.Annotation.LegendInformation.IconDisplayStyle = 'off';
                xl_start.Alpha = 0.5; % transparency of line (0.7 is default)
                %xl_start.Label = 'tstart';
                %xl_start.LabelHorizontalAlignment = "center"; xl_start.LabelVerticalAlignment = "bottom";              
            end

            % red line for tstop (final endFrame)
            xl_tstop = xline(endFrame, 'LineWidth',4, 'Color',stopCol_2);  % tstop (potentially manually adjusted)
            xl_tstop.Annotation.LegendInformation.IconDisplayStyle = 'off';
            xl_tstop.Alpha = 0.4; % transparency of line (0.7 is default)
            
            % 4. plot three more vertical lines for t0, t1, t2
            xl_t0 = xline(preAcq,'-'); % "t0": decision prompt (= start of recording + 20 frames of preAcq)
            xl_t1 = xline(rt_mat+preAcq,'-'); % "t1": moment of button release
            xl_t2 = xline(lastFrame,'-');  % "t2": moment of button press (i.e., 10 frames before end of recording)
            xl_t3 = xline(tmove,'--');  % tmove
            xl_t0.LineWidth = 0.8; xl_t0.Label = 'decision prompt t0'; xl_t0.LabelHorizontalAlignment = "center"; xl_t0.LabelVerticalAlignment = "middle";
            xl_t1.LineWidth = 0.8; xl_t1.Label = 'button release t1'; xl_t1.LabelHorizontalAlignment = "center"; xl_t1.LabelVerticalAlignment = "middle";
            xl_t2.LineWidth = 0.8; xl_t2.Label = 'target press t2'; xl_t2.LabelHorizontalAlignment = "center"; xl_t2.LabelVerticalAlignment = "middle";
            xl_t3.LineWidth = 0.8; xl_t3.Label = 'tmove'; xl_t3.LabelHorizontalAlignment = "center"; xl_t3.LabelVerticalAlignment = "top";
            xl_t0.Annotation.LegendInformation.IconDisplayStyle = 'off';
            xl_t1.Annotation.LegendInformation.IconDisplayStyle = 'off';
            xl_t2.Annotation.LegendInformation.IconDisplayStyle = 'off';
            xl_t3.Annotation.LegendInformation.IconDisplayStyle = 'off';

            % set x-axis limit as end of sample
            xlim([0 samp(end)]);

            % add title with pair no., acting agent, marker, matTrial, actual trial
            title(['pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
            xlabel('Samples (1sample=10ms)');

            % save the new figure
            set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
            saveas(gcf,strcat(jpg_title,'_v1.png'));

            % Update RT and MT according to new start/endFrame
            rt_final = (startFrame-preAcq)/frameRate;
            mt_final = (endFrame-startFrame)/frameRate;

        end % end of plotting after visual_check --------------------------

    end

    % Calculate deliberation time: tmove - startFrame
    dt_final = (tmove-startFrame)/frameRate;

    % find peaks for ulna and index (only segmented trial)
    [pksInd,pksUlna] = nPeaks(indexV(startFrame:endFrame),ulnaV(startFrame:endFrame));

else % if startFrame < preAcqu: movement started too early -> NaN
    startFrame=NaN; tmove=NaN; rt_final=NaN; dt_final=NaN; mt_final=NaN; endFrame=NaN;
end

% If we decide to eliminate the trial in visual_check: fill with NaN values
if exist('del_fig','var') && del_fig % if del_fig exists and equals 1
    startFrame=NaN; tmove=NaN; rt_final=NaN; dt_final=NaN; mt_final=NaN; endFrame=NaN;
end

close all % close figure(s)


end % end of function -> go back into calc_rt_mt.m

% script version: Nov 2023