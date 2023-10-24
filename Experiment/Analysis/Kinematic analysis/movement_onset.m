function [startFrame,tmove,rt_final,dt_final,mt_final,endFrame]=movement_onset(sMarkers,t,SUBJECTS,p,agentExec,label_agent,flag_pre,trial_plot,figurepath)

% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:};
plotxShift = 3.5;
vel_th     = 20; %20[mm/s]
preAcq     = 20; %preacquisition of 200ms == 20 frames
succSample = 10; %samples where to check if the velocity trajectory is higher than vel_th
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


%y coordinates - to check if the movement has started
indexY     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,2);%-  mean(sMarkers{t}.markers.([model_name '_index']).xyzf(1:preAcq,3));
ulnaY      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,2);% - mean(sMarkers{t}.markers.([model_name '_ulna']).xyzf(1:preAcq,3));

% Plot the trajectories
yPos_text   = max(ulna);

if trial_plot
    v=figure('Name',['P' SUBJECTS{p}(2:end)]); set(v, 'WindowStyle', 'Docked');

    yyaxis left; plot(samp,ulna);hold on; plot(samp,ulnaY); ylabel('Velocity [mm/s]');
    xlim([0 samp(end)]);
    if ~isnan(ulnaTh(1))
        xline(ulnaTh(1),'Color',[0 0.4470 0.7410]);t_uln=text(ulnaTh(1)-plotxShift,yPos_text-350,' tstart','Color', [0 0.4470 0.7410]);set(t_uln,'Rotation',90);
        plot(ulnaTh(1):(samp(end)-10),ulna(ulnaTh(1):(samp(end)-10)),'-','Color', [0 0.4470 0.7410],'LineWidth',3);
    end
    if ~isnan(tmove)
        xline(tmove,'Color',[0 0.4470 0.7410]);t_mv=text(tmove-plotxShift,yPos_text-350,' tmove','Color', [0 0.4470 0.7410]);set(t_mv,'Rotation',90);
    end
    hold off;

    yline(vel_th, '-', [num2str(vel_th) ' mm/s'], 'LineWidth', 1,'LabelVerticalAlignment', 'top','LabelHorizontalAlignment', 'left');
    yyaxis right; plot(samp,index);hold on; plot(samp,indexY); hold off;
    xline(preAcq);       t_pre=text(preAcq-plotxShift,yPos_text-300,' decisionPrompt (t0)');set(t_pre,'Rotation',90);
    xline(samp(end)-10); t_post=text((samp(end)-10)-plotxShift,yPos_text-300,' tstop');set(t_post,'Rotation',90); %tstop refers to targetbuttonpress (computed by Matlab)

    %     if ~isnan(indexTh(1))
    %         xline(indexTh(1),'Color',[0 0.4470 0.7410]);t_ind=text(indexTh(1)-plotxShift,yPos_text-300,' tstart_index','Color', [0 0.4470 0.7410]);set(t_ind,'Rotation',90);
    %     end

    agent_name = agentExec;
    
    title(['Pair: ' SUBJECTS{p} '; agent: ' agent_name '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
    xlabel('Samples');

    %Plot bold line on tmove
    if trial_plot && ~isnan(tmove)
        xline(tmove,'LineWidth',3,'Color',[0 0.4470 0.7410]); %plot blue (ulna); orange (index: [0.8500 0.3250 0.0980])
    end


end
% As rt_final we choose the minimum value between index finger/ulna
% reaction time
%threshold -> 'startVector    = [indexTh(1),ulnaTh(1)];' becomes %'startVector    = ulnaTh(1);'
%startVector    = ulnaTh(1); % take the 1st value that has passed the threshold
%[startFrame,ind_start] = min(startVector); % [min value, index of the minimum value]

%WARNING - from meeting of 24th of March we decided to take always the ulna
startFrame = ulnaTh(1);

%select the startframe %%%EDIT
% if p==3 && t==17
%     startFrame = 58;
% elseif p==3 && t==18
%     startFrame = 48;
% end

%save the rt variables (subtract the 200 ms of preAcqu (see line 13, right after the findTh_cons function has run)

if flag_pre %include preAcq because participants released button before decision prompt
    rt_index = (indexTh(1))/frameRate;
    rt_ulna  = (ulnaTh(1))/frameRate;
    rt_final = (startFrame)/frameRate;%rt_final should be = to the minimum value between rt_index or rt_ulna
else

    startFrame = (startFrame);%(startFrame-preAcq);
    rt_index   = (indexTh(1)-preAcq)/frameRate;
    rt_ulna    = (ulnaTh(1)-preAcq)/frameRate;
    rt_final   = (startFrame-preAcq)/frameRate;%rt_final= to the minimum value between rt_index or rt_ulna
end
endFrame = (samp(end)-10);
mt_final = (endFrame-startFrame)/frameRate;%mt_final=recording end(includes the preAcq) - 10frames(post acquisition set in Vicon) - startFrame(includes the preAcq)


%In case the video lasts only 20 or 52 frames there was an issue
%in the acquisition: the trial is discarded
if rt_final < 0.05
    rt_index  = NaN;
    rt_ulna   = NaN;
    rt_final  = NaN;
    mt_final  = NaN;
elseif samp(end) < 55
    rt_final  = 10000;
    mt_final  = 10000;
end

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
%     agent_name = agentExec;
% 
%     title(['Pair: ' SUBJECTS{p} '; agent: ' agent_name '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
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
