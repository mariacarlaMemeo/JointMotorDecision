
%% SHOW FIGURES AND ASK FOR USER INPUT
visual_change = [];%flag to know if there was a change in the time indeces due to visual inspection
del_fig         = [];%flag to know if there we need to eliminate the trial

drawnow
% figure name
jpg_title = [fullfile(figurepath,SUBJECTS{p}) '\' num2str(sMarkers{t}.info.trial_id) '_trial_' agent_name];
% show question about correct tstart and tstop identification
mainmarker = [model_name '_ulna'];
fprintf(['Trial n. ' num2str(sMarkers{t}.info.trial_id) '\n']);
mod = input('0 = Erase trial;\n1 = Change TSTART;\n2 = Change TMOVE;\n3 = Change TSTOP;\n4 = Change ALL\n999 = ALL GOOD\n','s');
if isempty(mod) || sum([strcmp(mod,'0'),strcmp(mod,'1'),strcmp(mod,'2'),strcmp(mod,'3'), strcmp(mod,'4')]) == 0
    mod = '999';
end
switch str2double(mod)
    case 999
        disp('Good');
        visual_change = 0;
        saveas(gcf,strcat(jpg_title,'_v0.png'))
        del_fig         = 0; 
    case 0
        % if mod is = 0
        % then save the figure anyway but with a
        % red line crossing the plot
        yyaxis left
        plot([1,sMarkers{t}.info.nSamples],[-20 1700], 'r', 'LineWidth',5)
        saveas(gcf,strcat(jpg_title,'_elim.png'))
        visual_change = 0;
        del_fig         = 1;

    case 1
        % if mod = 1, change tstart and save the new
        % tstart where needed
        % but first, save the original figure
        if ~exist(strcat(jpg_title,'_v0.png'))
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstart ')
        [x,~] = ginput(1);
        %tstop must be the x with minor velocity within a range
        %of +-3 from the selected x
        rangex = [(round(x)-3):(round(x)+3)];
        startFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig         = 0;

    case 2
        % if mod = 2, change tmove and save the new
        % tmove where needed
        % but first, save the original figure
        if ~exist(strcat(jpg_title,'_v0.png'))
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tmove ')
        [x,~] = ginput(1);
        %tmove must be the x with minor velocity within a range
        %of +-3 from the selected x
        rangex = [(round(x)-3):(round(x)+3)];
        tmove = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig         = 0;

    case 3
        % if mod = 3, change tstop and save the new
        % tstop where needed
        % but first, save the original figure
        if ~exist(strcat(jpg_title,'_v0.png'))
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstop ')
        [x,~] = ginput(1);
        %tstop must be the x with minor velocity within a range
        %of +-3 from the selected x
        rangex = [(round(x)-3):(round(x)+3)];
        endFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig         = 0;

    case 4
        % if mod = 4, then change tstart, tmove and tstop
        % and save the new info where needed
        % but first, save the original figure
        if ~exist( strcat(jpg_title,'_v0.png'))
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstart, tmove and tstop ')
        [x,~] = ginput(3);
        %tstart, tmove and tstop must be the xwith minor
        %velocity within a range of +-3from the
        %selected x
        rangex1 = [(round(x(1))-3):(round(x(1))+3)];
        startFrame = rangex1(sMarkers{t}.markers.(mainmarker).Vm(rangex1)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex1)));

        rangex2 = [(round(x(2))-3):(round(x(2))+3)];
        tmove = rangex2(sMarkers{t}.markers.(mainmarker).Vm(rangex2)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex2)));

        rangex3 = [(round(x(3))-3):(round(x(3))+3)];
        endFrame = rangex3(sMarkers{t}.markers.(mainmarker).Vm(rangex3)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex3)));

        visual_change = 1;
        del_fig         = 0;
end

