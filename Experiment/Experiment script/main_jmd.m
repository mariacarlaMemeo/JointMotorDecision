% May 2023, C'MoN Lab; Project: Joint Motor Decisions
% Original script based on: Bang et al. (2017). Confidence matching in
% group decision-making. Nature Human Behaviour, 1(6), 1-7.

clear; close all; clc; % clean up

% Header for output  file
head = {'Pair','Trial','StimDuration','cwCCW','baseContrast','deltaContrast',...
        'targetContrast','firstSecondInterval','targetLoc','B_decision','B_acc','B_rt',...
        'B_movtime','B_conf','B_confRT','Y_decision','Y_acc','Y_rt','Y_movtime',...
        'Y_conf','Y_confRT','Coll_decision','Coll_acc','Coll_rt','Coll_movtime',...
        'Coll_conf','Coll_confRT','AgentTakingFirstDecision','AgentTakingSecondDecision','AgentTakingCollDecision'...
        'early_release_A1','early_release_A2','early_release_Coll'};
try
    
    disp('Starting Exp. 1 Collective decision-making...');
    init_jmd; % initialize and define parameters in separate script
    disp(' ');
    disp('Initialization done.');
    
    
    % create data output file
    data.output = {};
    
    %% Present experiment instructions
    %----------------------------------------------------------------------
    cgflip(background(1),background(2),background(3)); % clear background color to gray
    
    % if practice, show instruction text
    if data.isExperiment == 0
        practice_instr_ita; % show instructions during practice session
    end
    
    %% Start experiment loop: rounds / blocks / trials
    %
    % round: practice (0) or experiment (1)
    % block: 2
    % trials total: 160 (80 per block; 40 trialsInBlock (per agent))
    trial_count = 0;
    %----------------------------------------------------------------------
    for rnd = 1 : rounds % always only 1 round (as we use it)
        
        for block = 1 : blocksInRound
            
            if data.display == 1 % 1 screen
                cgflip(background(1),background(2),background(3)); % clear background color to gray
                cgfont('Arial',fontsizebig);
                cgtext(['Blocco ' num2str(block) 'di ' num2str(blocksInRound)],0,100); % create buffer with text for starting trial
                fixation(fix_size,'+'); % create buffer with fixation cross
                cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                waitkeydown(inf); % stay on screen infinitely waiting for a key press
                fixation(fix_size,'+');
                cgflip(background(1),background(2),background(3));
            else % 2 screens
                if block == 1
                    cgflip(background(1),background(2),background(3)); % clear background color to gray
                    cgfont('Arial',fontsizebig);
                    cgtext(['Blocco ' num2str(block) ' di ' num2str(blocksInRound)],mWidth,0); % create buffer with text for starting trial
                    cgtext(['Blocco ' num2str(block) ' di ' num2str(blocksInRound)],-mWidth,0); % create buffer with text for starting trial
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    waitkeydown(inf,71); % start the block with spacebar press
                else
                    % Short break after first block
                    cgfont('Arial',fontsizebig);
                    cgtext('Pausa',mWidth,0);
                    cgtext('Pausa',-mWidth,0);
                    
                    cgpencol(1,1,1); % white
                    %Calculate the joint accuracy
                    interim_acc = sum([data.output{:,23}])/length(data.output(:,23)); % no. of correct trials/total trial no.
                    %show interim accuracy
                    cgtext(['Punteggio di squadra: ' num2str(sum([data.output{:,23}])) ' su ' num2str(length(data.output(:,23))) ' punti (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
                    cgtext(['Punteggio di squadra: ' num2str(sum([data.output{:,23}])) ' su ' num2str(length(data.output(:,23))) ' punti (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    % start new block with spacebar; then 3 sec pause
                    waitkeydown(inf,71);
                    
                    cgflip(background(1),background(2),background(3)); % clear background color to gray
                    cgpencol(0,0,0); % black
                    cgfont('Arial',fontsizebig);
                    cgtext(['Blocco ' num2str(block) ' di ' num2str(blocksInRound)],mWidth,0); % create buffer with text for starting trial
                    cgtext(['Blocco ' num2str(block) ' di ' num2str(blocksInRound)],-mWidth,0); % create buffer with text for starting trial
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    waitkeydown(inf,71); % start the block with spacebar press
                end
            end
            
            % CONTRAST RANDOMIZATION (per agent per block)
            % (not necessary for practice because order is fixed)
            rng('shuffle'); % initialize random number generator (generates a different sequence of random numbers after each call to rng)
            if data.isExperiment == 1
                randIndex_B = randperm(length(conds_B));
                randIndex_Y = randperm(length(conds_Y));
                conds_B = conds_B(randIndex_B,:);
                conds_Y = conds_Y(randIndex_Y,:);          
            end
                       
            %--------------------------------------------------------------
            % START TRIAL LOOP
            %--------------------------------------------------------------
            counter_B = 0;
            counter_Y = 0;
            
            for trial = 1 : trialsInBlock*2 % no. of trials PER BLOCK
                
                trial_count = trial_count+1;
                
                if trial==trialsInBlock+1 % short break at halftime of block
                    
                    %Calculate the joint accuracy
                    interim_acc = sum([data.output{:,23}])/length(data.output(:,23)); % no. of correct trials/total trial no.
                    % Short break after each block
                    cgfont('Arial',fontsizebig);
                    cgtext('Pausa',mWidth,0);
                    cgtext('Pausa',-mWidth,0);
                    %show interim accuracy
                    cgpencol(1,1,1); % white
                    cgtext(['Punteggio di squadra: ' num2str(sum([data.output{:,23}])) ' su ' num2str((length(data.output(:,23)))) ' punti (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
                    cgtext(['Punteggio di squadra: ' num2str(sum([data.output{:,23}])) ' su ' num2str((length(data.output(:,23)))) ' punti (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);
                    cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
                    cgpencol(0,0,0); % black
                    waitkeydown(inf,71);
                end
                
                if mod(trial,2) == 1 % B starts in all odd trials (1, 3, 5, etc.)
                    counter_B = counter_B+1;
                    stimuli.deltaCon         = conds_B(counter_B,2); % current contrast
                    stimuli.firstSecond      = conds_B(counter_B,1); % oddball in 1st or 2nd?
                else
                    counter_Y = counter_Y+1;
                    stimuli.deltaCon         = conds_Y(counter_Y,2); % current contrast
                    stimuli.firstSecond      = conds_Y(counter_Y,1); % oddball in 1st or 2nd?
                end
                
                fprintf('Current trial number: %d\n',trial_count); % just checkin
                stimuli.trial            = trial_count;
                stimuli.R                = 120;
                stimuli.duration         = 85; % stimulus duration in ms (85)
                stimuli.cwCCW            = 1;  % -1 = CW, 1 = CCW
                stimuli.deltaTheta       = 0; % angle
                stimuli.baseCont         = data.pedestal; % always 0.1 (see init)
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
                stimuli.B.noise         = data.noise.B; % if any
                stimuli.B.side          = -1;
                stimuli.Y.noise         = data.noise.Y; % if any
                stimuli.Y.side          = 1;
                
                % record total trial num
                stimuli.trialsInBlock    = trialsInBlock*2;
                
                next_trial_jmd; % announce who starts next trial
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %----------------------------------------------------------
                % call function (pass on stimuli params defined above)
                % -> trial procedure happens inside function
                stimuli = trial_jmd(stimuli,mWidth,trial,add,cogent,agentYhomebutton,show_acc);
                %----------------------------------------------------------
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if stimuli.ABORT && (data.isExperiment == 1 || data.isExperiment == 0)% if trial loop is disrupted
                    stop_cogent;
                    % create output table with DVs
                    data.output = [head; data.output];
                    save(fullfile(save_dir,resultFileName),'data');
                    writecell(data.output,fullfile(save_dir,resultFileName_exel))
                    return
                end
                
                data.output = [data.output; ...
                    {data.group.id ...
                    stimuli.trial ...
                    stimuli.duration ...
                    stimuli.cwCCW    ...
                    stimuli.baseCont  ...
                    stimuli.deltaCon  ...
                    stimuli.tarCont ...
                    stimuli.firstSecond ...
                    stimuli.targetLoc ...
                    stimuli.resp.AgentB.firstSec ...
                    double(stimuli.resp.AgentB.acc) ...
                    stimuli.resp.AgentB.rt ...
                    stimuli.resp.AgentB.movtime ...
                    stimuli.resp.AgentB.conf ...
                    stimuli.resp.AgentB.confRT ...
                    stimuli.resp.AgentY.firstSec ...
                    double(stimuli.resp.AgentY.acc) ...
                    stimuli.resp.AgentY.rt ...
                    stimuli.resp.AgentY.movtime ...
                    stimuli.resp.AgentY.conf ...
                    stimuli.resp.AgentY.confRT ...
                    stimuli.resp.Coll.firstSec ...
                    double(stimuli.resp.Coll.acc) ...
                    stimuli.resp.Coll.rt ...
                    stimuli.resp.Coll.movtime ...
                    stimuli.resp.Coll.conf ...
                    stimuli.resp.Coll.confRT ...
                    stimuli.resp.firstdecision ...
                    stimuli.resp.seconddecision ...
                    stimuli.resp.colldecision...
                    stimuli.release_flag(1)...
                    stimuli.release_flag(2)...
                    stimuli.release_flag(3)} ...
                    ];

                data.stimuli(rnd,block,trial) = stimuli;
                % save results after each trial
                if data.isExperiment == 1
                    save(fullfile(save_dir,resultFileName),'data'); % save current results in main folder
                end

            end % end of trial loop
            %--------------------------------------------------------------
        end % end of block loop
        %------------------------------------------------------------------
        
        % Show final accuracy
        cgpencol(1,1,1); % white
        %Calculate the joint accuracy
        interim_acc = sum([data.output{:,23}])/length(data.output(:,23));
        %show interim accuracy
        cgtext(['Punteggio finale: ' num2str(sum([data.output{:,23}])) ' su ' num2str((length(data.output(:,23)))) ' punti (' num2str(round(interim_acc*100)) ' %)'],mWidth,-200);
        cgtext(['Punteggio finale: ' num2str(sum([data.output{:,23}])) ' su ' num2str((length(data.output(:,23)))) ' punti (' num2str(round(interim_acc*100)) ' %)'],-mWidth,-200);
        cgflip(background(1),background(2),background(3)); % display the two buffers created above (text and fixation cross)
        waitkeydown(inf,71);
        
    end % end of round loop
    %----------------------------------------------------------------------
    % stop Cogent 
    stop_cogent;
    
    % save results
    if data.isExperiment == 1
        data.output = [head; data.output];
        save(fullfile(save_dir,resultFileName),'data'); % save final result file in data-folder
        writecell(data.output,fullfile(save_dir,resultFileName_exel))
    end
    
catch me
    stop_cogent;
    rethrow(me);
end