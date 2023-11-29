% -------------------------------------------------------------------------
% -> Here we inspect the trial visually and make manual changes if needed.
% -------------------------------------------------------------------------
% This script is called from "movement_onset.m"

% Set some parameters first
visual_change = []; % did you make changes after visual inspection?
del_fig       = []; % do you want to eliminate the trial?
repeatTrial   = 1;

jpg_title     = [fullfile(figurepath,SUBJECTS{p}) '\trial_' num2str(sMarkers{t}.info.trial_id) ...
    '_agent_' agentExec];
x_width       = 18;
y_width       = 12;


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
%fprintf(['Trial n. ' num2str(sMarkers{t}.info.trial_id) '\n']);
fprintf(1, '\n');
fprintf(['START criterion: ' label_criterion '\n']);
fprintf(1, '\n');

%%%%%%%%%%%%%%%%%% SHOW FIGURE AND ASK FOR USER INPUT %%%%%%%%%%%%%%%%%%%%%

drawnow; % updates figure immediately (needed to draw red line for delete)

while repeatTrial

    visual_change = 0;
    del_fig       = 0;

    % display options for user
    % if all is good, you can put ENTER or anything (it will be set to 9)
    mod = input(['Any CHANGES?\n' ...
        '1 = Change TSTART\n2 = Change TMOVE\n' ...
        '3 = Change TSTOP\n4 = Change TMOVE TSTOP\n' ...
        '5 = Change START TMOVE TSTOP\n' ...
        '6 = Erase trial (be careful!)\n' ...
        '--> If ALL GOOD, press ENTER!\n'],'s');

    % If mod is empty or non of the required inputs, then put 9
    if isempty(mod) || sum([strcmp(mod,'1'),strcmp(mod,'2'),strcmp(mod,'3'),...
                            strcmp(mod,'4'), strcmp(mod,'5'),strcmp(mod,'6'),...
                            strcmp(mod,'9'),]) == 0
        mod = '9';
    end

    switch str2double(mod) % depending on user input, check respective case

        case 9 % no changes necessary
            disp('Good: no changes to figure!');
            set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
            saveas(gcf,strcat(jpg_title,'_v0.png'));

        case 1 % change tstart and save original figure
            if ~exist(strcat(jpg_title,'_v0.png'),'file')
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,strcat(jpg_title,'_v0.png'))
            end
            disp('Insert tstart ');
            [x,~]  = ginput(1); % user input: x-position of cursor position
            rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
            % define startFrame as minimum value in selected range
            startFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
            visual_change = 1;

        case 2 % change tmove and save original figure
            if ~exist(strcat(jpg_title,'_v0.png'),'file')
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,strcat(jpg_title,'_v0.png'))
            end
            disp('Insert tmove ');
            [x,~]  = ginput(1); % user input: x-position of cursor position
            rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
            % define tmove as minimum value in selected range
            tmove  = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
            visual_change = 1;

        case 3 % change tstop and save original figure
            if ~exist(strcat(jpg_title,'_v0.png'),'file')
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,strcat(jpg_title,'_v0.png'))
            end
            disp('Insert tstop ');
            [x,~] = ginput(1); % user input: x-position of cursor position
            rangex = (round(x)-3):(round(x)+3); % range of +-3 of selected x
            % define endFrame as minimum value in selected range
            endFrame = rangex(sMarkers{t}.markers.(mainmarker).Vm(rangex)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex)));
            visual_change = 1;

        case 4 % change tmove and tstop; save original figure
            if ~exist(strcat(jpg_title,'_v0.png'),'file')
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,strcat(jpg_title,'_v0.png'))
            end
            disp('Insert tmove and tstop ');
            [x,~]    = ginput(2); % user inputs: select positions one after other
            rangex1  = (round(x(1))-3):(round(x(1))+3);
            rangex2  = (round(x(2))-3):(round(x(2))+3);
            tmove    = rangex1(sMarkers{t}.markers.(mainmarker).Vm(rangex1)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex1)));
            endFrame = rangex2(sMarkers{t}.markers.(mainmarker).Vm(rangex2)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex2)));
            visual_change = 1;

        case 5 % change tstart, tmove, tstop; save original figure
            if ~exist(strcat(jpg_title,'_v0.png'),'file')
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,strcat(jpg_title,'_v0.png'))
            end
            disp('Insert tstart tmove and tstop ');
            [x,~]    = ginput(3); % user inputs: select positions one after other
            rangex1  = (round(x(1))-3):(round(x(1))+3);
            rangex2  = (round(x(2))-3):(round(x(2))+3);
            rangex3  = (round(x(3))-3):(round(x(3))+3);
            startFrame  = rangex1(sMarkers{t}.markers.(mainmarker).Vm(rangex1)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex1)));
            tmove       = rangex2(sMarkers{t}.markers.(mainmarker).Vm(rangex2)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex2)));
            endFrame    = rangex3(sMarkers{t}.markers.(mainmarker).Vm(rangex3)== ...
                min(sMarkers{t}.markers.(mainmarker).Vm(rangex3)));
            visual_change = 1;

        case 6  % delete trial but save figure anyway, with red diagonal line
            yyaxis left;
            hold on;
            redline = plot([1,sMarkers{t}.info.nSamples],[0 max(indexV)], 'r', 'LineWidth',5);
            redline.Annotation.LegendInformation.IconDisplayStyle = 'off';
            hold off;
            del_fig = 1;
            set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
            saveas(gcf,strcat(jpg_title,'_elim.png'));

    end

    % "target change": insert yes/no depending on whether agent changed target
    % (first left, then right, etc.)
    trg_check = 1;
    while trg_check
        trg = input('\nTARGET CHOICE: Did agent change (1) or not (0)? ');
        if trg == 0
            disp('Agent did not change target.'); %fprintf(1, '\n');
            trg_check = 0;
        elseif trg == 1
            disp('Agent changed target!'); %fprintf(1, '\n');
            trg_check = 0;
        else
            disp('Your input was invalid! Please choose again.'); %fprintf(1, '\n');
            trg_check = 1;
        end
    end

    % do you want to repeat the decision or confirm to move on?
    nxt = 1;
    while nxt
        nextStep = input('\nNEXT STEP: Go on (0), repeat (1) or exit (2)? ');
        if nextStep == 0
            disp('Go on, all fine.'); %fprintf(1, '\n');
            repeatTrial = 0;
            nxt = 0;
        elseif nextStep == 1
            disp('REEEEPEAAAT.'); %fprintf(1, '\n');
            repeatTrial = 1;
            nxt = 0;
        elseif nextStep == 2
            disp('EXIT (after 3rd dec), keep calm and SAVE.'); fprintf(1, '\n');
            repeatTrial = 0;
            savemat = 1;
            nxt = 0;
        else
            disp('Your input was invalid! Please choose again.'); %fprintf(1, '\n');
            nxt = 1;
        end
    end

end

% script version: Nov 2023