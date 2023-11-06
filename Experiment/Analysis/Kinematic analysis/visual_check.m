% -------------------------------------------------------------------------
% -> Here we inspect the trial visually and make manual changes if needed.
% -------------------------------------------------------------------------
% This script is called from "movement_onset.m"

% Set some parameters first
visual_change = []; % did you make changes after visual inspection?
del_fig       = []; % do you want to eliminate the trial?
jpg_title     = [fullfile(figurepath,SUBJECTS{p}) '\' num2str(sMarkers{t}.info.trial_id) ...
                '_trial_' agentExec];
% criterion to select the startFrame: it shows the markers accordingly
switch start_criterion
    case 1
        mainmarker      = [model_name '_index']; 
        label_criterion = 'Index';
    case 2
        mainmarker    = [model_name '_ulna']; 
        label_criterion = 'Ulna';
    case 3
        mainmarker    = [model_name '_index']; % this is related to the button release and we chose to select the startFrame on the index trajectories
        label_criterion = 'Button';
end


% display trial number in command window
fprintf(['Trial n. ' num2str(sMarkers{t}.info.trial_id) '\n']);
fprintf([label_criterion ' as the start criterion \n']);

%%%%%%%%%%%%%%%%%% SHOW FIGURE AND ASK FOR USER INPUT %%%%%%%%%%%%%%%%%%%%%

drawnow % this is to show changes to figure immediately

% display options for user
mod = input('0 = Erase trial;\n1 = Change TSTART;\n2 = Change TMOVE;\n3 = Change TSTOP;\n4 = Change TSTART and TSTOP\n999 = ALL GOOD\n','s');

% If mod is empty or non of the required inputs, then put 999
if isempty(mod) || sum([strcmp(mod,'0'),strcmp(mod,'1'),strcmp(mod,'2'),strcmp(mod,'3'), strcmp(mod,'4')]) == 0
    mod = '999';
end

switch str2double(mod) % depending on user input, check respective case
    
    case 999 % no changes necessary
        disp('Good'); 
        visual_change = 0;
        del_fig       = 0; 
        saveas(gcf,strcat(jpg_title,'_v0.png'));        
    
    case 0  % delete trial but save figure anyway, with red diagonal line
        yyaxis left;
        plot([1,sMarkers{t}.info.nSamples],[-20 1700], 'r', 'LineWidth',5)
        visual_change = 0;
        del_fig       = 1;
        saveas(gcf,strcat(jpg_title,'_elim.png'));
    
    case 1 % change tstart and save original and new figure
        if ~exist(strcat(jpg_title,'_v0.png'),'file')
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstart ');
        [x,~]  = ginput(1); % user input: x-position of cursor position
        rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
        % define startFrame as minimum value in selected range
        startFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                        min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig       = 0;
    
    case 2 % change tmove and save original and new figure
        if ~exist(strcat(jpg_title,'_v0.png'),'file')
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tmove ');
        [x,~]  = ginput(1); % user input: x-position of cursor position
        rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
        % define tmove as minimum value in selected range
        tmove  = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                    min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig       = 0;

    case 3 % change tstop and save original and new figure
        if ~exist(strcat(jpg_title,'_v0.png'),'file')
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstop ');
        [x,~] = ginput(1); % user input: x-position of cursor position
        rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
        % define endFrame as minimum value in selected range
        endFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                      min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
        visual_change = 1;
        del_fig       = 0;

    case 4 % change tstart and tstop; save original and new figure
        if ~exist(strcat(jpg_title,'_v0.png'),'file')
            saveas(gcf,strcat(jpg_title,'_v0.png'))
        end
        disp('Insert tstart and tstop ');
        [x,~] = ginput(2); % 2(!) user inputs: select positions one after other
        rangex1 = (round(x(1))-3):(round(x(1))+3);
        rangex2 = (round(x(2))-3):(round(x(2))+3);
        %rangex3 = (round(x(3))-3):(round(x(3))+3);
        startFrame = rangex1(sMarkers{t}.markers.(mainmarker).Vm(rangex1)== ...
                         min(sMarkers{t}.markers.(mainmarker).Vm(rangex1)));       
        endFrame   = rangex2(sMarkers{t}.markers.(mainmarker).Vm(rangex2)== ...
                         min(sMarkers{t}.markers.(mainmarker).Vm(rangex2)));        
        %tmove      = rangex3(sMarkers{t}.markers.(mainmarker).Vm(rangex3)== ...
        %                 min(sMarkers{t}.markers.(mainmarker).Vm(rangex3)));
        visual_change = 1;
        del_fig       = 0;
end

% script version: 1 Nov 2023