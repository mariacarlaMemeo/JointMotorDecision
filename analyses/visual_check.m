
%% SHOW FIGURES AND ASK FOR USER INPUT
visual_change = [];

drawnow
% show question about correct tstart and tstop identification
mainmarker = [model_name '_ulna'];
fprintf(['Trial n. ' num2str(t) '\n']);
mod = input(['To delete trial ==> 0; To change tstart ==> 1; To change tstop ==> 2; To change both ==> 3'...
    '\n'],'s');
if isempty(mod) || sum([strcmp(mod,'0'),strcmp(mod,'1'),strcmp(mod,'2'),strcmp(mod,'3'), strcmp(mod,'4'), strcmp(mod,'5')]) == 0
    mod = '999';
end
switch str2double(mod)
    case 999
        % if mod is different from 0, 1, 2 or 3
        % then do nothing
        disp('Good');
        visual_change = 0;
    case 0
        % if mod is = 0
        % then save the figure anyway but with a
        % red line crossing the plot
        yyaxis left
        plot([1,sMarkers{t}.info.nSamples],[-20 1700], 'r', 'LineWidth',5)
        saveas(gcf,[fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_elim.png'])
        visual_change = 0;
       
    case 1
        % if mod = 1, change tstart and save the new
        % tstart where needed
        % but first, save the original figure
        if ~exist([fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
            saveas(gcf,[fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
        end
        disp('Insert tstart ')
        [x,~] = ginput(1);
        %tstop must be the x with minor velocity within a range
        %of +-3 from the selected x
        rangex = [(round(x)-3):(round(x)+3)];
        startFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
     
    case 2
        % if mod = 2, change tstop and save the new
        % tstop where needed
        % but first, save the original figure
        if ~exist([fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
            saveas(gcf,[fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
        end
        disp('Insert tstop ')
        [x,~] = ginput(1);
        %tstop must be the x with minor velocity within a range
        %of +-3 from the selected x
        rangex = [(round(x)-3):(round(x)+3)];
        endFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;

    case 3
        % if mod = 3, then change tstart and tstop
        % and save the new info where needed
        % but first, save the original figure
        if ~exist( [fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
            saveas(gcf,[fullfile(figurepath,SUBJECTS{p}) '\' agent_name, '_trial_' num2str(t) '_v0.png'])
        end
        disp('Insert tstart and tstop ')
        [x,~] = ginput(2);
        %tstop and tstart must be the xwith minor
        %velocity within a range of +-3from the
        %selected x
        rangex1 = [(round(x(1))-3):(round(x(1))+3)];
        startFrame = rangex1(sMarkers{t}.markers.(mainmarker).Vm(rangex1)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex1)));
        
        rangex2 = [(round(x(2))-3):(round(x(2))+3)];
        endFrame = rangex2(sMarkers{t}.markers.(mainmarker).Vm(rangex2)==min(sMarkers{t}.markers.(mainmarker).Vm(rangex2)));
        visual_change = 1;
end

