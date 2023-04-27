function [startFrame,rt_final,mt_final,endFrame]=movement_onset(sMarkers,t,SUBJECTS,p,agentExec,label_agent,flag_pre,trial_plot)

% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:};
plotxShift = 3;
vel_th     = 20; %20[mm/s]
preAcq     = 20; %preacquisition of 200ms == 20 frames
succSample = 10; %samples where to check if the velocity trajectory is higher than vel_th
model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']).Vm;% - mean(sMarkers{t}.markers.([model_name '_index']).Vm(1:preAcq));
ulna       = sMarkers{t}.markers.([model_name '_ulna']).Vm;% - mean(sMarkers{t}.markers.([model_name '_ulna']).Vm(1:preAcq));
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


%z coordinates
indexZ     = sMarkers{t}.markers.([model_name '_index']).xyzf(:,3);%-  mean(sMarkers{t}.markers.([model_name '_index']).xyzf(1:preAcq,3));
ulnaZ      = sMarkers{t}.markers.([model_name '_ulna']).xyzf(:,3);% - mean(sMarkers{t}.markers.([model_name '_ulna']).xyzf(1:preAcq,3));

% Plot the trajectories
yPos_text   = max(ulna);

if trial_plot
    v=figure('Name',['P' SUBJECTS{p}(2:end)]); set(v, 'WindowStyle', 'Docked');
    yyaxis left; plot(samp,index);hold on; plot(samp,indexZ); ylabel('Velocity [mm/s]');hold off;
    yyaxis right; plot(samp,ulna);hold on; plot(samp,ulnaZ); hold off;
    xline(preAcq);       t_pre=text(preAcq-plotxShift,yPos_text-300,' decisionPrompt (t0)');set(t_pre,'Rotation',90);
    xline(samp(end)-10); t_post=text((samp(end)-10)-plotxShift,yPos_text-300,' targetButtonPress');set(t_post,'Rotation',90);
    if ~isnan(indexTh(1))
        xline(indexTh(1),'Color',[0 0.4470 0.7410]);t_ind=text(indexTh(1)-plotxShift,yPos_text-300,' Index>20[mm/s]','Color', [0 0.4470 0.7410]);set(t_ind,'Rotation',90);
    end
    if ~isnan(ulnaTh(1))
        xline(ulnaTh(1),'Color',[0.8500 0.3250 0.0980]);t_uln=text(ulnaTh(1)-plotxShift,yPos_text-350,' Ulna>20[mm/s]','Color', [0.8500 0.3250 0.0980]);set(t_uln,'Rotation',90);
    end
    title(['Pair: ' SUBJECTS{p} '; agent: ' agentExec '; ' label_agent '; matTrial: ' sMarkers{t}.info.fullpath(end-11:end) '; trial: ' num2str(sMarkers{t}.info.trial_id)])
    xlabel('Samples');
end
% As rt_final we choose the minimum value between index finger/ulna
% reaction time
%WARNING - from meeting of 24th of March we decided to take only the ulna
%threshold -> 'startVector    = [indexTh(1),ulnaTh(1)];' becomes %'startVector    = ulnaTh(1);'
startVector    = ulnaTh(1); % take the 1st value that has passed the threshold
[startFrame,ind_start] = min(startVector); % [min value, index of the minimum value]
ind_start = 2;

%select the startframe
if p==3 && t==17
    startFrame = 58;
elseif p==3 && t==18
    startFrame = 48;
end

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

%Plot rt_final
if trial_plot
    if ind_start==1
        xline(startFrame,'LineWidth',2,'Color',[0 0.4470 0.7410]);
    else
        xline(startFrame,'LineWidth',2,'Color',[0.8500 0.3250 0.0980]);
    end
end


end
