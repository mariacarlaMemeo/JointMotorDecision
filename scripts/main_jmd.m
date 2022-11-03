% October 2022, C'MoN Lab; Project: Joint Motor Decisions
% Original script based on: Bang et al. (2017). Confidence matching in
% group decision-making. Nature Human Behaviour, 1(6), 1-7.

clear; close all; clc; % clean up

try
    
    disp('Starting Exp. 1 Collective decision-making...');
    init_jmd; % initialize and define parameters in separate script
    disp(' ');
    disp('Initialization done.');
    
    
    % create data output file
    data.output = [];
    
    %% Present experiment instructions
    %----------------------------------------------------------------------
    cgflip(background(1),background(2),background(3)); % clear background color to gray
    % Note: in the following, "screen" refers to a window on the screen,
    % not an actual physical screen; we always use 2 (for A1 and A2) - the
    % 1 screen option is not functional
    if data.display == 1 % 1 screen
        cgtext('Start the Experiment ',0,100); % create buffer with text for starting trial
        fixation(fix_size,'+'); % create buffer with fixation cross
        cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
        waitkeydown(inf); % stay on screen infinitely waiting for a key press
        fixation(fix_size,'+'); % after key press, show fixation cross only
        cgflip(background(1),background(2),background(3));
    else % 2 screens
        if data.isExperiment == 0 
            practice_instr; % show instructions during practice session
        end
    end
    
    %% Start experiment loop: rounds / blocks / trials
    %
    % round: practice or experiment proper
    % block: how many do we need? participants should switch chairs in the
    % middle of the experiment
    % trials: 200 max. (in total)
    %----------------------------------------------------------------------
    for rnd = 1 : rounds % always only 1 round (as we use it)
        
        for block = 1 : blocksInRound
            
            if data.display == 1 % 1 screen
                cgflip(background(1),background(2),background(3)); % clear background color to gray
                cgfont('Arial',fontsizebig);
                cgtext(['Block ' num2str(block) 'of ' num2str(blocksInRound)],0,100); % create buffer with text for starting trial
                fixation(fix_size,'+'); % create buffer with fixation cross
                cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                waitkeydown(inf); % stay on screen infinitely waiting for a key press
                fixation(fix_size,'+');
                cgflip(background(1),background(2),background(3));
            else % 2 screens
                if block == 1
                    cgflip(background(1),background(2),background(3)); % clear background color to gray
                    cgfont('Arial',fontsizebig);
                    cgtext(['Block ' num2str(block) ' of ' num2str(blocksInRound)],mWidth,0); % create buffer with text for starting trial
                    cgtext(['Block ' num2str(block) ' of ' num2str(blocksInRound)],-mWidth,0); % create buffer with text for starting trial
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    waitkeydown(inf,71); % start the block with spacebar press
                else
                    % Short break after first block
                    cgfont('Arial',fontsizebig);
                    cgtext('Short break',mWidth,0);
                    cgtext('Short break',-mWidth,0);
                    
                    cgpencol(1,1,1); % white
                    %Calculate the joint accuracy
                    interim_acc = sum(data.output(:,21))/length(data.output(:,21)); % no. of correct trials/total trial no.
                    %show interim accuracy
                    cgtext(['Your team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str(length(data.output(:,21))) ' points (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
                    cgtext(['Your team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str(length(data.output(:,21))) ' points (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);                    
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    % start new block with spacebar; then 3 sec pause
                    waitkeydown(inf,71);
                    
                    cgflip(background(1),background(2),background(3)); % clear background color to gray
                    cgpencol(0,0,0); % black
                    cgfont('Arial',fontsizebig);
                    cgtext(['Block ' num2str(block) ' of ' num2str(blocksInRound)],mWidth,0); % create buffer with text for starting trial
                    cgtext(['Block ' num2str(block) ' of ' num2str(blocksInRound)],-mWidth,0); % create buffer with text for starting trial
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    waitkeydown(inf,71); % start the block with spacebar press
                end
                
            end
            
            % CONTRAST RANDOMIZATION/COUNTERBALANCING
            randIndex_a1 = randperm(length(conds_a1));
            randIndex_a2 = randperm(length(conds_a2));
            conds_a1 = conds_a1(randIndex_a1,:);
            conds_a2 = conds_a2(randIndex_a2,:);
            
            %--------------------------------------------------------------
            % START TRIAL LOOP
            %--------------------------------------------------------------
            counter_a1 = 0;
            counter_a2 = 0;
            for trial = 1 : trialsInBlock*2
                
                if trial==trialsInBlock+1 % short break at halftime of block
                    
                    %Calculate the joint accuracy
                    interim_acc = sum(data.output(:,21))/length(data.output(:,21)); % no. of correct trials/total trial no.
                    % Short break after each block
                    cgfont('Arial',fontsizebig);
                    cgtext('Short break',mWidth,0);
                    cgtext('Short break',-mWidth,0);
                    %show interim accuracy
                    cgpencol(1,1,1); % white
                    cgtext(['Your team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str((length(data.output(:,21)))) ' points (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
                    cgtext(['Your team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str((length(data.output(:,21)))) ' points (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);                   
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    cgpencol(0,0,0); % black
                    waitkeydown(inf,71);
                end
                
                if mod(trial,2) == 1 % A1 starts in all odd trials
                    counter_a1 = counter_a1+1;
                    stimuli.deltaCon         = conds_a1(counter_a1,2); % current contrast
                    stimuli.firstSecond      = conds_a1(counter_a1,1); % oddball in 1st or 2nd?
                else
                    counter_a2 = counter_a2+1;
                    stimuli.deltaCon         = conds_a2(counter_a2,2); % current contrast
                    stimuli.firstSecond      = conds_a2(counter_a2,1); % oddball in 1st or 2nd?
                end
                
                fprintf('Current trial number: %d\n',trial); % just checkin
                stimuli.trial            = trial;
                stimuli.R                = 120;
                stimuli.duration         = 85; % stimulus duration in ms (85)
                stimuli.cwCCW            = 1;  % -1 = CW, 1 = CCW
                stimuli.deltaTheta       = 0; % angle
                stimuli.baseCont         = data.pedestal;
                stimuli.responseInterval = 2400;
                stimuli.tarCont          = stimuli.baseCont + stimuli.deltaCon; % actual contrast
                stimuli.setSize          = 6; % 6 Gabor patches
                stimuli.location         = [];
                % call setStimXY function
                [stimuli.location(:,1), ...
                    stimuli.location(:,2)]  = setStimXY(stimuli);
                % randomly select target location (1-6)
                stimuli.targetLoc        = randsample(1:stimuli.setSize,1);
                stimuli.ISI              = 1; % inter stim. interval
                stimuli.A1.noise         = data.noise.A1; % if any
                stimuli.A1.side          = -1;
                stimuli.A2.noise         = data.noise.A2; % if any
                stimuli.A2.side          = 1;
                
                % record total trial num and current trial num
                stimuli.trialsInBlock    = trialsInBlock*2;
                stimuli.trial            = trial;
                
                next_trial_jmd; % announce who starts next trial
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %----------------------------------------------------------
                % call function (pass on stimuli params defined above)
                % -> trial procedure happens inside function
                stimuli = trial_jmd(stimuli,mWidth,trial,add,cogent,a2homebutton,show_acc);
                %----------------------------------------------------------
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if stimuli.ABORT % if trial loop is disrupted
                    stop_cogent;
                    % create output table with DVs
                    data.output_table = array2table(data.output,'VariableNames',{'StimDuration','cwCCW','baseContrast','deltaContrast',...
                        'targetContrast','firstSecondInterval','targetLoc','A1_decision','A1_acc','A1_rt',...
                        'A1_movtime','A1_conf','A1_confRT','A2_decision','A2_acc','A2_rt','A2_movtime',...
                        'A2_conf','A2_confRT','Coll_decision','Coll_acc','Coll_rt','Coll_movtime',...
                        'Coll_conf','Coll_confRT','AgentTakingFirstDecision','AgentTakingSecondDecision','AgentTakingCollDecision'});
                    save(resultFileName,'data');
                    return
                end
                
                data.output = [ data.output; ...
                    stimuli.duration ...
                    stimuli.cwCCW    ...
                    stimuli.baseCont  ...
                    stimuli.deltaCon  ...
                    stimuli.tarCont ...
                    stimuli.firstSecond ...
                    stimuli.targetLoc ...
                    stimuli.resp.Agent1.firstSec ...
                    stimuli.resp.Agent1.acc ...
                    stimuli.resp.Agent1.rt ...
                    stimuli.resp.Agent1.movtime ...
                    stimuli.resp.Agent1.conf ...
                    stimuli.resp.Agent1.confRT ...
                    stimuli.resp.Agent2.firstSec ...
                    stimuli.resp.Agent2.acc ...
                    stimuli.resp.Agent2.rt ...
                    stimuli.resp.Agent2.movtime ...
                    stimuli.resp.Agent2.conf ...
                    stimuli.resp.Agent2.confRT ...
                    stimuli.resp.Coll.firstSec ...
                    stimuli.resp.Coll.acc ...
                    stimuli.resp.Coll.rt ...
                    stimuli.resp.Coll.movtime ...
                    stimuli.resp.Coll.conf ...
                    stimuli.resp.Coll.confRT ...
                    stimuli.resp.firstdecision ...
                    stimuli.resp.seconddecision ...
                    stimuli.resp.colldecision ...
                    ];
                
                data.stimuli(rnd,block,trial) = stimuli;
                save(resultFileName,'data');
            end % end of trial loop
            %--------------------------------------------------------------
        end % end of block loop
        %------------------------------------------------------------------
        
        % Show final accuracy
        cgpencol(1,1,1); % white
        %Calculate the joint accuracy
        interim_acc = sum(data.output(:,21))/length(data.output(:,21));
        %show interim accuracy
        cgtext(['Your final team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str((length(data.output(:,21)))) ' points (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
        cgtext(['Your final team score is ' num2str(sum(data.output(:,21))) ' out of ' num2str((length(data.output(:,21)))) ' points (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);
        cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
        waitkeydown(inf,71);
        
    end % end of round loop
    %----------------------------------------------------------------------
    
    % create output table with DVs
    data.output_table = array2table(data.output,'VariableNames',{'StimDuration','cwCCW','baseContrast','deltaContrast',...
        'targetContrast','firstSecondInterval','targetLoc','A1_decision','A1_acc','A1_rt',...
        'A1_movtime','A1_conf','A1_confRT','A2_decision','A2_acc','A2_rt','A2_movtime',...
        'A2_conf','A2_confRT','Coll_decision','Coll_acc','Coll_rt','Coll_movtime',...
        'Coll_conf','Coll_confRT','AgentTakingFirstDecision','AgentTakingSecondDecision','AgentTakingCollDecision'});
    
    % stop Cogent and save results
    stop_cogent;
    save(fullfile(save_dir,resultFileName),'data');
    
catch me
    stop_cogent;
    rethrow(me);
end