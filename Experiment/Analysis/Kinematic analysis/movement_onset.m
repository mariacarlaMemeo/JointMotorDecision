function [startFrame,tmove,rt_final,dt_final,mt_final,endFrame]=movement_onset(sMarkers,t,SUBJECTS,p,agentExec,label_agent,rt_mat,flag_pre,trial_plot,figurepath)

% The variable "rt_mat" is taken from matlab files and represents the time from decision prompt to button release WITHOUT
% PRE-ACQUISITION
% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:}; % frameRate is in Hz (=1/s)
plotxShift = 3.5;
vel_th     = 20; %20[mm/s]
preAcq     = 20; %preacquisition of 200ms == 20 frames (1 frame = 10 ms)
succSample = 10; %samples where to check if the velocity trajectory is higher than vel_th
rt_mat     = round((rt_mat/1000)*frameRate); % (convert ms to s) and multiply by frameRate to get no. of frames
model_name = [SUBJECTS{p} '_' agentExec '_' agentExec];%name of the model in Nexus
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']).Vm;% - mean(sMarkers{t}.markers.([model_name '_index']).Vm(1:preAcq));
ulna       = sMarkers{t}.markers.([model_name '_ulna']).Vm;% - mean(sMarkers{t}.markers.([model_name '_ulna']).Vm(1:preAcq));

%Find velocity peaks and minima ONLY in ulna marker. The function select
%the max peak, the minimum preceding it and gives as output the position of
%the minimum: tmove. This is the beginning of the reaching movement 
tmove = find_tmove(ulna);

% Use the function findTh_cons to find out when the velocity threshold is passed
% start checking from the appearance of the decision prompt onwards
% (i.e., after the preAcqu of 200 ms)
if flag_pre
    indexTh    = findTh_cons(index,vel_th,succSample);%%>20[mm/s] for 10 sample/frames, the first interval
    ulnaTh     = findTh_cons(ulna,vel_th,succSample);
else
    indexTh    = findTh_cons(index(preAcq:end),vel_th,succSample);
    indexTh    = indexTh + preAcq;%I add preAcq because I excluded it from the previous function. The preAcq is going to be removed for the calc of rt
    ulnaTh     = findTh_cons(ulna(preAcq:end),vel_th,succSample);
    ulnaTh     = ulnaTh + preAcq;
end

% if vel threshold is passed after button release, then take button release
% time as starting point
% ulnaTh=30; indexTh=20; 20
% rt=10, then take rt

%z coordinates - to check if the movement has started
indexZ     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,3);% - mean(sMarkers{t}.markers.([model_name '_index']).xyzf(1:preAcq,3));
ulnaZ      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,3);% - mean(sMarkers{t}.markers.([model_name '_ulna']).xyzf(1:preAcq,3));

% Plot the trajectories
yPos_text   = max(ulna);

if trial_plot
    v=figure('Name',['P' SUBJECTS{p}(2:end)]); set(v, 'WindowStyle', 'Docked');
    
    %ulna velocity and Y coord
    yyaxis left; plot(samp,ulna);hold on; plot(samp,ulnaZ); ylabel('Velocity [mm/s]');
    xlim([0 samp(end)]);
    if ~isnan(ulnaTh(1))
        xline(ulnaTh(1),'Color',[0 0.4470 0.7410]);t_uln=text(ulnaTh(1)-plotxShift,yPos_text-350,' tstart ulna','Color', [0 0.4470 0.7410]);set(t_uln,'Rotation',90);
        %plot(ulnaTh(1):(samp(end)-10),ulna(ulnaTh(1):(samp(end)-10)),'-','Color', [0 0.4470 0.7410],'LineWidth',3);
    end
    %  if ~isnan(tmove)
    % xline(tmove,'Color',[0 0.4470 0.7410]);t_mv=text(tmove-plotxShift,yPos_text-350,' tmove','Color', [0 0.4470 0.7410]);set(t_mv,'Rotation',90);
    % end
    hold off;

    %yline(vel_th, '-', [num2str(vel_th) ' mm/s'], 'LineWidth', 1,'LabelVerticalAlignment', 'top','LabelHorizontalAlignment', 'left');
    
    % index velocity and Y coord
    yyaxis right; plot(samp,index);hold on; plot(samp,indexZ); hold off;
    if ~isnan(indexTh(1))
        xline(indexTh(1),'Color',[0.8500 0.3250 0.0980]);t_ind=text(indexTh(1)-plotxShift,yPos_text-300,' tstart index','Color', [0.8500 0.3250 0.0980]);set(t_ind,'Rotation',90);
    end


    xline(preAcq);       t_pre=text(preAcq-plotxShift,yPos_text-300,' decisionPrompt (t0)');set(t_pre,'Rotation',90);
    xline(rt_mat+preAcq);t_rt_mat=text(rt_mat+preAcq-plotxShift,yPos_text-300,' *start* button release (t1)');set(t_rt_mat,'Rotation',90);
    xline(samp(end)-10); t_post=text((samp(end)-10)-plotxShift,yPos_text-300,' tstop: target press');set(t_post,'Rotation',90); %tstop refers to targetbuttonpress (computed by Matlab)
    
    title(['Pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
    xlabel('Samples');

    %Plot bold line on tmove
    %if trial_plot && ~isnan(tmove)
    %    xline(tmove,'LineWidth',3,'Color',[0 0.4470 0.7410]); %plot blue (ulna); orange (index: [0.8500 0.3250 0.0980])
    %end


end

%% 
% As rt_final we choose the minimum value between index finger/ulna rt
% OR the time of button press (if occured earlier than ulna/index threshold)
% NOTE: startFrame INCLUDES the preAcq, i.e., it starts AFTER the preAcq
startVector    = [indexTh(1),ulnaTh(1)]; % take the 1st value that has passed the threshold
[startFrame,ind_start] = min(startVector); % [min value, index of the minimum value]
if startFrame > rt_mat+preAcq
    startFrame = rt_mat;
end

% WARNING - from meeting of 24th of March "we" decided to take always the
%ulna.
% 2nd WARNING - from the meeting of 25th of October "they" decided that we
% should go back to line 80 of this script, i.e. take either the index or
% the ulna threshold but ONLY if they appear before the button press.
% Otherwise the button press is the start. 
% startFrame = ulnaTh(1);

%% save the rt variables (subtract the 200 ms of preAcq (see line 13, right after the findTh_cons function has run)
% NOTE: rt is now measured in frames which corresponds to 1frame=10ms (with frameRate 100Hz), so
% if you divide rt/frameRate, you get SECONDS as the final unit
% (e.g.,10frames/100Hz=0.1s)
if flag_pre 
    rt_index = (indexTh(1))/frameRate;
    rt_ulna  = (ulnaTh(1))/frameRate;
    rt_final = (startFrame)/frameRate;%rt_final should be = to the minimum value between rt_index, rt_ulna or button release (see above)
else
    rt_index   = (indexTh(1)-preAcq)/frameRate;
    rt_ulna    = (ulnaTh(1)-preAcq)/frameRate;
    rt_final   = (startFrame-preAcq)/frameRate;% either rt_index, rt_ulna, or button release (see above)
%     rt_final   = (startFrame-preAcq)/frameRate;%rt_final= to the minimum value between rt_index or rt_ulna
end
endFrame = (samp(end)-10); % END FRAME = TIME OF BUTTON PRESS
% both endFrame and starFrame include preAcq, so we can subtract them to
% get MT
mt_final = (endFrame-startFrame)/frameRate;%mt_final=recording end(includes the preAcq) - 10frames(post acquisition set in Vicon) - startFrame(includes the preAcq)
if startFrame == rt_mat
    mt_final = (endFrame-(startFrame+preAcq))/frameRate;
end

% % if RT is impossibly short, then put NaN -> MAYBE EDIT THIS?
% if rt_final < 0.05 %rt is in seconds
%     rt_index  = NaN;
%     rt_ulna   = NaN;
%     rt_final  = NaN;
%     mt_final  = NaN;
% elseif samp(end) < 55 %In case the video lasts only 20 or 52 frames there was an issue
%     rt_final  = 10000;
%     mt_final  = 10000;
% end

%% Add the possibility to change the tstart and tstop of the script
% visual_check;

% Check if tmove appears before tstart (called startFrame in the script), in that case tmove should be
% changed and set to be as tstart
if ~isnan(tmove)
    if tmove<startFrame && ~isempty(startFrame)
        tmove=startFrame;
        visual_change = 1;
    end
end

% % EDIT
% % we potentially could have new start/endFrame
% if visual_change && not(del_fig)
%     v=figure('Name',['P' SUBJECTS{p}(2:end)]); set(v, 'WindowStyle', 'Docked');
%     yyaxis left; plot(samp,ulna);hold on; plot(samp,ulnaY); ylabel('Velocity [mm/s]');
%     xlim([0 samp(end)]);
%     if ~isnan(startFrame)
%         xline(startFrame,'Color',[0 0.4470 0.7410]);t_uln=text(startFrame-plotxShift,yPos_text-350,' tstart','Color', [0 0.4470 0.7410]);set(t_uln,'Rotation',90);
%         plot(startFrame:endFrame,sMarkers{t}.markers.(mainmarker).Vm(startFrame:endFrame),'-','Color', [0 0.4470 0.7410],'LineWidth',3);
%     end
%     if ~isnan(tmove)
%         xline(tmove,'Color',[0 0.4470 0.7410]);t_mv=text(tmove-plotxShift,yPos_text-250,' tmove','Color', [0 0.4470 0.7410]);set(t_mv,'Rotation',90);
%     end
%     hold off;
%     yline(vel_th, '-', [num2str(vel_th) ' mm/s'], 'LineWidth', 1, 'LabelVerticalAlignment', 'top','LabelHorizontalAlignment', 'left');
%     yyaxis right; plot(samp,index);hold on; plot(samp,indexY); hold off;
%     xline(preAcq);       t_pre=text(preAcq-plotxShift,yPos_text-300,' decisionPrompt (t0)');set(t_pre,'Rotation',90);
%     xline(endFrame); t_post=text(endFrame-plotxShift,yPos_text-300,' tstop');set(t_post,'Rotation',90); %tstop refers to targetbuttonpress (computed by Matlab)
% 
%     title(['Pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
%     xlabel('Samples');
% 
% 
%     %Plot bold line on tmove
%     if trial_plot && ~isnan(tmove)
%         xline(tmove,'LineWidth',3,'Color',[0 0.4470 0.7410]); %plot blue (ulna); orange (index: [0.8500 0.3250 0.0980])
%     end
% 
%     %save the new figure
%     saveas(gcf,strcat(jpg_title,'_v1.png'))
% 
% 
%     %Calculate the new rt and mt
%     rt_final   = (startFrame-preAcq)/frameRate;%rt_final= to the minimum value between rt_index or rt_ulna
%     mt_final   = (endFrame-startFrame)/frameRate;%
% end


%Calculate the deliberation time: tmove - startFrame(=tstart)
dt_final = (tmove-startFrame)/frameRate;

% %In case we decide to eliminate the trial
% if del_fig
%     startFrame=NaN; tmove=NaN; rt_final=NaN; dt_final=NaN; mt_final=NaN; endFrame=NaN;
% end

close all

end
