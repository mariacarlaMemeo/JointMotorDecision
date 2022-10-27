function stimuli = trial_jmd(stimuli,mWidth,trial,add,cogent,a2homebutton)


% ---------------- first define some more variables --------------------- %

keyversion = 0; % set to 1 if START keys (instead of buttons) are used
% (THE KEYVERSION WORKS IF YOU HAVE ONLY 4 BUTTONS FOR THE DECISION)

% re-set global variables (because unknown inside function)
global background;      % background color
global imSize;          % image size
global fontsizebig;     % Arial 30
% global fontsizesmall;   % Arial 20
% global fix_size;        % can be used for fixation cross

% CONFIDENCE SCALE
confLineLength = 96; confStepsN = 6;
confDispStep = confLineLength/confStepsN;
zeroLineLength = 10;

% CONFIDENCE KEYS
% Note: for joint decision, conf. keys are adjusted as necessary in script
% confidence keys A1
firstA1Key      = 82; % Agent1 7 -> down
secondA1Key     = 76; % Agent1 1 -> up
confirmA1Key    = 79; % Agent1 4 -> confirm
% confidence keys A2
firstA2Key      = 83; % Agent2 8 -> down
secondA2Key     = 77; % Agent2  2 -> up
confirmA2Key    = 80; % Agent2 5 -> confirm

% % confidence keys A1
% firstA1Key      = 3; % Agent1 C -> down
% secondA1Key     = 5; % Agent1 E -> up
% confirmA1Key    = 4; % Agent1 D -> confirm
% % confidence keys A2
% firstA2Key      = 2; % Agent2 B -> down
% secondA2Key     = 20;% Agent2 T -> up
% confirmA2Key    = 7; % Agent2 G -> confirm

% JITTER BEFORE STIMULUS PRESENTATION
jitterTimeMin   = 500;
jitterTimeAdded = 1000;%500;

% SCREEN DIMENSIONS FOR SPRITES
spriteWidth     = 1280/2; % half of the full screen for each agent
spriteHeight    = 1024/2;

% OTHER
gam = 2.2;      % ?
abortKey = 52;  % ESC
cgfont('Arial',fontsizebig); % set font to big

% instruction texts
getReady        = 'Get ready for the next trial.';
PartnerGetReady = 'Your partner starts the next trial.';
wait4partner    = 'Please turn away and wait for your partner.';
return2start    = 'Place your finger on the start position.';
decisionPrompt  = '1° stimolo               ?               2° stimolo';
confidenceQ     = 'How confident are you?';
observePartner  = 'Please observe your partner.';
decisionPromptJ = 'Please take the JOINT decision now.';
partnerDecidesJ_1 = 'Now observe your partner';
partnerDecidesJ_2 = 'who takes the JOINT decision.';

% Prepare the recorded voice file
loadsound('tone.wav', 1) %Puts sound in buffer 1.

%% ------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% GENERATE GABOR PATCHES %%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Note: all parameters in pixels

% gabor(size,freq,sigma,phase,Ltheta,Gtheta,fdist,xoff,yoff,cutoff,[show])
lamda =12.5;               % wavelength in pixels
sigma = 3 * imSize ./ 20;  % gaussian standard deviation in pixels
phase =0;                  % phase 0:1
deltaTheta = stimuli.deltaTheta;
Ltheta= 0 + stimuli.cwCCW .* (deltaTheta);  % local orientation in degrees (clockwise from vertical)
Gtheta=0;                  % global orientation in degrees (clockwise from vertical)
fdist=0;                   % distance between target and flankes in pixels
xoff=0;                    % horizontal offset position of gabor in pixels
yoff=0;                    % vertical offset position of gabor in pixels
% for cutoff:
% if positive, applies threshold of gauss>cutoff to produce sharp edges and no smooth fading
% if negative, trims off gauss > abs(cutoff) while preserving fading in remaining regions
cutoff = -.005; %.1;
showme=0;                  % if present, display result
im = gabor_pix(imSize, lamda, sigma, phase, Ltheta, Gtheta, fdist, xoff, yoff, cutoff, showme);
% im(im>0) = 1;
% im(im<0) = -1;

% define baseline and target contrasts
base   = im .* stimuli.baseCont; % baseline patches
target = im .* stimuli.tarCont;  % oddball patch
% assign these numbers for later creation of Gabor patches
targetSpriteA1 = 5;
targetSpriteA2 = 6;
% create vectors
distSpriteA1 = targetSpriteA2    +1 : targetSpriteA2+stimuli.setSize; %7:12
distSpriteA2 = max(distSpriteA1) +1 : max(distSpriteA1)+stimuli.setSize; %13:18

%--------------------------------------------------------------------------
% Add NOISE to the target and base, then make TargetStim and BaseStim.
% Note: We currently DO NOT add any noise!

xOff=0;
yOff=0;
% prepare for A1
randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.A1.noise);
targetPlusNoise = target + randNoise;
targetPlusNoise(targetPlusNoise>1) = 1;
targetPlusNoise(targetPlusNoise<-1) = -1;
targetPlusNoise = (targetPlusNoise+1) ./2;
targetStim = targetPlusNoise .^ (1 / gam); % target stimulus
cgloadarray(targetSpriteA1, imSize, imSize, [targetStim(:) targetStim(:) targetStim(:)]);
for dSp = 1 : length(distSpriteA1) %1:6
    randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.A1.noise);
    basePlusNoise = base + randNoise;
    basePlusNoise(basePlusNoise>1) = 1;
    basePlusNoise(basePlusNoise<-1) = -1;
    basePlusNoise = (basePlusNoise+1) ./2;
    baseStim = basePlusNoise .^ (1 / gam); % baseline stimulus
    cgloadarray(distSpriteA1(dSp), imSize, imSize, [baseStim(:) baseStim(:) baseStim(:)]);
end
% prepare for A2
randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.A2.noise);
targetPlusNoise = target + randNoise;
targetPlusNoise(targetPlusNoise>1) = 1;
targetPlusNoise(targetPlusNoise<-1) = -1;
targetPlusNoise = (targetPlusNoise+1) ./2;
targetStim = targetPlusNoise .^ (1 / gam);
cgloadarray(targetSpriteA2, imSize, imSize, [targetStim(:) targetStim(:) targetStim(:)]);
for dSp = 1 : length(distSpriteA2)
    randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.A2.noise);
    basePlusNoise = base + randNoise;
    basePlusNoise(basePlusNoise>1) = 1;
    basePlusNoise(basePlusNoise<-1) = -1;
    basePlusNoise = (basePlusNoise+1) ./2;
    baseStim = basePlusNoise .^ (1 / gam);
    cgloadarray(distSpriteA2(dSp), imSize, imSize, [baseStim(:) baseStim(:) baseStim(:)]);
end
%--------------------------------------------------------------------------

% assign numbers to the two intervals (for A1 and A2)
firstIntSpriteA1   = 1;
secondIntSpriteA1  = 2;
firstIntSpriteA2   = 3;
secondIntSpriteA2  = 4;

% draw all Gabor patches (for both intervals, for both agents)
for intervalSp = [firstIntSpriteA1 secondIntSpriteA1 firstIntSpriteA2 secondIntSpriteA2]
    cgmakesprite(intervalSp,spriteWidth,spriteHeight,background(1),background(2),background(3));
    cgsetsprite(intervalSp);
    cgtext('+',0,0);
    % draw for A1 (left side of screen)
    if intervalSp < 3
        for stimSp = 1 : stimuli.setSize % from 1-6 Gabor patches
            cgdrawsprite(distSpriteA1(stimSp),stimuli.location(stimSp,1),stimuli.location(stimSp,2))
        end
        if intervalSp == stimuli.firstSecond % if this is target interval, draw target
            cgdrawsprite(targetSpriteA1,stimuli.location(stimuli.targetLoc,1),stimuli.location(stimuli.targetLoc,2))
        end
    end
    % draw for A2 (right side of screen)
    if intervalSp > 2
        for stimSp = 1 : stimuli.setSize % from 1-6 Gabor patches
            cgdrawsprite(distSpriteA2(stimSp),stimuli.location(stimSp,1),stimuli.location(stimSp,2))
        end
        if intervalSp-2 == stimuli.firstSecond % if this is target interval, draw target
            cgdrawsprite(targetSpriteA2,stimuli.location(stimuli.targetLoc,1),stimuli.location(stimuli.targetLoc,2))
        end
    end
end

%% ------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%% INDIVIDUAL DECISIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% ORDER A1-A2 (A1 indiv. decision, A2 indiv. decision, A1 joint decision)

if mod(trial,2) == 1 % A1 starts in all odd trials
    
    % save the order (A1-A2-A1)
    stimuli.resp.firstdecision = 1;
    stimuli.resp.seconddecision = 2;
    stimuli.resp.colldecision = 1;
    
    % Vicon ready
    io64(cogent.io.ioObj,add.out_address,3); % set LPT to 3
        
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR A1
    %----------------------------------------------------------------------
    
    % Tell A2 to wait and A1 to get ready
    cgsetsprite(0);
    cgtext(PartnerGetReady,mWidth,0);
    cgtext(getReady,-mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(2000);
    
    % SANITY CHECK AT TRIAL START
    % Is target button stuck? If so: display message for experimenter.
    data_in=io64(cogent.io.ioObj,add.inp_address);
    while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
        cgtext('Check target buttons!',-mWidth,0);
        cgflip(background(1),background(2),background(3));
        data_in=io64(cogent.io.ioObj,add.inp_address);
    end
    
    if keyversion == 0
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address);
        % if A1 is not pressing home button (63), wait until button is pressed
        % also check for the unlikely case that, if A1 presses the home button,
        % A2 might be pressing a target button at the same time (55/47)
        if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
            while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                cgtext(return2start,-mWidth,0);
                cgtext(wait4partner,mWidth,0);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address);
            end
            % once button press is registered, show blank grey screen and
            % shortly pause (2s) before showing the two 2 stimulus intervals
            cgtext(wait4partner,mWidth,0);
            cgflip(background(1),background(2),background(3));
            pause(2);
        end
    end
    
    % IF PARTICIPANT READY, SHOW FIXATION CROSS
    % here one could use fixation(fix_size,'+') instead?
    cgsetsprite(0);
    cgtext('+',0+(stimuli.A1.side*spriteWidth/2),0);
    cgtext(wait4partner,mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(jitterTimeMin+rand*jitterTimeAdded); %500 + [0-1000]
    
    % STIMULUS INTERVAL 1
    % prepare stimulus
    cgdrawsprite(firstIntSpriteA1,0+(stimuli.A1.side*spriteWidth/2),0);
    cgtext(wait4partner,mWidth,0);
    % show stimulus
    stimuli.firstA1.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.firstA1.OnsetTime+stimuli.duration);
    cgtext(wait4partner,mWidth,0);
    stimuli.firstA1.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.firstA1.actualDuration  = stimuli.firstA1.OffsetTime - stimuli.firstA1.OnsetTime;
    wait(stimuli.ISI); % wait 1000 ms
    
    % STIMULUS INTERVAL 2
    % prepare stimulus
    cgdrawsprite(secondIntSpriteA1,0+(stimuli.A1.side*spriteWidth/2),0);
    cgtext(wait4partner,mWidth,0);
    % show stimulus
    stimuli.secondA1.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.secondA1.OnsetTime+stimuli.duration);
    cgtext(wait4partner,mWidth,0);
    stimuli.secondA1.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.secondA1.actualDuration  = stimuli.secondA1.OffsetTime - stimuli.secondA1.OnsetTime;
    wait(stimuli.ISI/2); % wait 500 ms
    
    %----------------------------------------------------------------------
    % DECISION A1
    %----------------------------------------------------------------------
    
    % DISPLAY DECISION PROMPT (t = 0)
    cgsetsprite(0);
    cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
    cgtext(wait4partner,mWidth,0);
    % t0 = time when decision prompt appears (i.e., screen flips)
    t0 = cgflip(background(1),background(2),background(3)).*1000;
    % start Vicon recording (once home button is released)
    io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
    
    if keyversion == 0
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address);
        % keep checking for release while home button A1 (63) is pressed
        % (or while home button plus any other button is pressed)
        while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
    else
        waitkeydown(inf);
    end
    
    % MOVEMENT START (t = 1)
    cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
    t1 = cgflip(background(1),background(2),background(3)).*1000;
    % record RT for A1
    stimuli.resp.Agent1.rt = t1 - t0; 
      
    % WAIT FOR TARGET PRESS
    waitrespA1 = 1;
    while waitrespA1
        data_in=io64(cogent.io.ioObj,add.inp_address);
        switch data_in
            case {95, 79, 87} % leftA1 + leftA1 and left or right A2
                stimuli.resp.Agent1.firstSec = 1; % save decision
                waitrespA1 = 0;
            case {255, 239, 247}  % rightA1 + rightA1 and left or right A2
                stimuli.resp.Agent1.firstSec = 2; % save decision
                waitrespA1 = 0;
        end
    end
    
%     % keyboard version
%     cgtext('(here we will wait for the decision key to be pressed)',-mWidth,0);
%     cgtext('(Now press A (1st interval) or D (2nd interval))',-mWidth,-100);
%     cgflip(background(1),background(2),background(3));
    
    % TARGET REACHED (t = 2)
    t2 = cgflip(background(1),background(2),background(3)).*1000;
    % stop Vicon recording (once target has been pressed)
    io64(cogent.io.ioObj,add.out_address,0);
    % save MT
    stimuli.resp.Agent1.movtime = t2-t1;
    
    %----------------------------------------------------------------------
    % CONFIDENCE A1
    %----------------------------------------------------------------------
    
    % DISPLAY CONFIDENCE SCALE (1-6)
    cgfont('Arial',fontsizebig);
    cgtext(confidenceQ,-mWidth,300);
    % horizontal line (base)
    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
    % vertical line (scale)
    cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
    % blue marker
    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
    
    t0confA1 = cgflip(background(1),background(2),background(3)).*1000;
    
    % set keys
    readkeys;
    A1key = [];
    A1nresp = 0;
    A1respConfirmed = 0;
    A1conf = 0; % set confidence rating to zero initially
    
    % READ INPUT (until decision is confirmed)
    while ~A1respConfirmed
        readkeys;
        if A1nresp == 0
            [A1key, A1t, A1nresp] = getkeydown([firstA1Key secondA1Key confirmA1Key abortKey]);
        end
        if ~isempty(A1key)
            switch A1key(1)
                case firstA1Key % move down on scale
                    A1conf = A1conf-1;
                    if A1conf < 0 % marker cannot go below zero
                        A1conf = 0;
                    end
                    cgtext(confidenceQ,-mWidth,300);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % blue marker
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                    A1key=[]; A1t=[]; A1nresp=0;
                case secondA1Key % move up on scale
                    A1conf = A1conf+1;
                    if A1conf > confStepsN
                        A1conf = confStepsN;
                    end
                    cgtext(confidenceQ,-mWidth,300);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % blue marker
                    cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                    A1key=[]; A1t=[]; A1nresp=0;
                case confirmA1Key
                    if A1conf == 0 % confidence cannot be zero
                        cgtext(confidenceQ,-mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                        A1key=[]; A1t=[]; A1nresp=0;
                    else
                        A1respConfirmed = 1;
                        stimuli.resp.Agent1.time = A1t(1);
                        % record decision time (confRT) for A1
                        stimuli.resp.Agent1.confRT = stimuli.resp.Agent1.time - t0confA1;
                        stimuli.ABORT = 0;
                    end
                case abortKey
                    A1respConfirmed = 1;
                    stimuli.ABORT = 1;
                otherwise
            end
        else
            cgtext(confidenceQ,-mWidth,300);
            % horizontal line (base)
            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
            % vertical line (scale)
            cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
            % blue marker
            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
        end
        cgflip(background(1),background(2),background(3));
    end
    cgflip(background(1),background(2),background(3));
    % record confidence for A1
    stimuli.resp.Agent1.conf = A1conf;
    wait(stimuli.ISI/2) % wait for 500 ms
    
    % A2 is next; tell A1 to observe A2's movement
    % ADD VOICE HERE: ITS YOUR TURN (A2) and PLEASE OBSERVE (A1)
    playsound(1);
    cgtext(observePartner,-mWidth,0);
    cgtext(getReady,mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(2000);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR A2
    %----------------------------------------------------------------------
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        pause(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 111 || data_in == 119
            cgtext('Check target buttons!',mWidth,0);
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        if keyversion == 0
            % CHECK IF PARTICIPANT IS READY TO START
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            if data_in ~= a2homebutton
                while data_in ~= a2homebutton
                    cgtext(return2start,mWidth,0);
                    cgtext(observePartner,-mWidth,0);
                    cgflip(background(1),background(2),background(3));
                    data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
                end
                cgtext(observePartner,-mWidth,0);
                cgflip(background(1),background(2),background(3));
                pause(2);
            end
        end
        
        % IF PARTICIPANT READY, SHOW FIXATION CROSS
        cgsetsprite(0);
        cgtext('+',0+(stimuli.A2.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        cgflip(background(1),background(2),background(3));
        wait(jitterTimeMin+rand*jitterTimeAdded);
        
        % STIMULUS INTERVAL 1
        % prepare stimulus
        cgdrawsprite(firstIntSpriteA2,0+(stimuli.A2.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        % show stimulus
        stimuli.firstA2.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.firstA2.OnsetTime+stimuli.duration);
        cgtext(observePartner,-mWidth,0);
        stimuli.firstA2.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.firstA2.actualDuration  = stimuli.firstA2.OffsetTime - stimuli.firstA2.OnsetTime;
        wait(stimuli.ISI);
        
        % STIMULUS INTERVAL 2
        % prepare stimulus
        cgdrawsprite(secondIntSpriteA2,0+(stimuli.A2.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        % show stimulus
        stimuli.secondA2.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.secondA2.OnsetTime+stimuli.duration);
        cgtext(observePartner,-mWidth,0);
        stimuli.secondA2.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.secondA2.actualDuration  = stimuli.secondA2.OffsetTime - stimuli.secondA2.OnsetTime;
        wait(stimuli.ISI/2);
        
        %------------------------------------------------------------------
        % DECISION A2
        %------------------------------------------------------------------
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        t0_a2 = cgflip(background(1),background(2),background(3)).*1000;
        %                 start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2);
        
        if keyversion == 0
            % WAIT FOR MOVEMENT START (i.e., home button release)
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            while data_in == a2homebutton
                data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            end
        else
            waitkeydown(inf);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
        t1_a2 = cgflip(background(1),background(2),background(3)).*1000;

        % record RT for A2
        stimuli.resp.Agent2.rt = t1_a2 - t0_a2;
        
        % WAIT FOR TARGET PRESS
        waitrespA2 = 1;
        while waitrespA2
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {119 , 87 , 247 , 55} % leftA2 + leftA2 and left or right or home A1
                    stimuli.resp.Agent2.firstSec = 1; % save decision
                    waitrespA2 = 0;
                case {111 , 239 , 79 , 47} % rightA2 + rightA2 and left or right or home A1
                    stimuli.resp.Agent2.firstSec = 2; % save decision
                    waitrespA2 = 0;
            end
        end
                
%         % keyboard version
%         cgtext('(here we will wait for the decision key to be pressed)',mWidth,0);
%         cgtext('(Now press F (1st interval) or H (2nd interval))',mWidth,-100);
%         cgflip(background(1),background(2),background(3));
                     
        % TARGET REACHED (t = 2)
        t2_a2 = cgflip(background(1),background(2),background(3)).*1000;
        % stop Vicon recording
        io64(cogent.io.ioObj,add.out_address,0);
        % record MT for A2
        stimuli.resp.Agent2.movtime = t2_a2-t1_a2;
                
        %------------------------------------------------------------------
        % CONFIDENCE A2
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,mWidth,300);
        % horizontal line (base)
        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % yellow marker
        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 0]);
        
        t0confA2 = cgflip(background(1),background(2),background(3)).*1000;
        
        readkeys;
        A2key = [];
        A2nresp=0;
        A2respConfirmed = 0;
        A2conf = 0; % set confidence rating to zero initially

        while ~A2respConfirmed
            readkeys;
            if A2nresp == 0
                [A2key, A2t, A2nresp] = getkeydown([firstA2Key secondA2Key confirmA2Key abortKey]);
            end
            if ~isempty(A2key)
                switch A2key(1)
                    case firstA2Key
                        A2conf = A2conf-1;
                        if A2conf < 0 % marker cannot go below zero
                            A2conf = 0;
                        end
                        cgtext(confidenceQ,mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                        A2key=[]; A2t=[]; A2nresp=0;
                    case secondA2Key
                        A2conf = A2conf+1;
                        if A2conf > confStepsN
                            A2conf = confStepsN;
                        end
                        cgtext(confidenceQ,mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                        A2key=[]; A2t=[]; A2nresp=0;
                    case confirmA2Key
                        if A2conf == 0
                            cgtext(confidenceQ,mWidth,300);
                            % horizontal line (base)
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            % vertical line (scale)
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            % yellow marker
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                            A2key=[]; A2t=[]; A2nresp=0;
                        else
                            A2respConfirmed = 1;
                            stimuli.resp.Agent2.time = A2t(1);
                            % record decision time (confRT) for A2
                            stimuli.resp.Agent2.confRT = stimuli.resp.Agent2.time - t0confA2;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        A2respConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,mWidth,300);
                % horizontal line (base)
                cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                % vertical line (scale)
                cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                % yellow marker
                cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record confidence for A2
        stimuli.resp.Agent2.conf = A2conf;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER A2-A1 (A2 indiv. decision, A1 indiv. decision, A2 joint decision)
    
elseif mod(trial,2) == 0 % A2 starts in all even trials
    
    % save the order (A2-A1-A2)
    stimuli.resp.firstdecision = 2;
    stimuli.resp.seconddecision = 1;
    stimuli.resp.colldecision = 2;
    
    % Vicon ready
    io64(cogent.io.ioObj,add.out_address,3);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR A2
    %----------------------------------------------------------------------
    
    % Tell A1 to wait and A2 to get ready
    cgsetsprite(0);
    cgtext(PartnerGetReady,-mWidth,0);
    cgtext(getReady,mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(2000);
       
    % SANITY CHECK AT TRIAL START
    % Is target button stuck? If so: display message for experimenter.
    data_in=io64(cogent.io.ioObj,add.inp_address);
    while data_in == 111 || data_in == 119
        cgtext('Check target buttons!',mWidth,0);
        cgflip(background(1),background(2),background(3))
        data_in=io64(cogent.io.ioObj,add.inp_address);
    end
    
    if keyversion == 0
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        if data_in ~= a2homebutton
            while data_in ~= a2homebutton
                cgtext(return2start,mWidth,0);
                cgtext(wait4partner,-mWidth,0);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            end
            cgtext(wait4partner,-mWidth,0);
            cgflip(background(1),background(2),background(3));
            pause(2);
        end
    end
    
    % IF PARTICIPANT READY, SHOW FIXATION CROSS
    cgsetsprite(0);
    cgtext('+',0+(stimuli.A2.side*spriteWidth/2),0);
    cgtext(wait4partner,-mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(jitterTimeMin+rand*jitterTimeAdded);
    
    % STIMULUS INTERVAL 1
    % prepare stimulus
    cgdrawsprite(firstIntSpriteA2,0+(stimuli.A2.side*spriteWidth/2),0);
    cgtext(wait4partner,-mWidth,0);
    % show stimulus
    stimuli.firstA2.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.firstA2.OnsetTime+stimuli.duration);
    cgtext(wait4partner,-mWidth,0);
    stimuli.firstA2.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.firstA2.actualDuration  = stimuli.firstA2.OffsetTime - stimuli.firstA2.OnsetTime;
    wait(stimuli.ISI);
    
    % STIMULUS INTERVAL 2
    % prepare stimulus
    cgdrawsprite(secondIntSpriteA2,0+(stimuli.A2.side*spriteWidth/2),0);
    cgtext(wait4partner,-mWidth,0);
    % show stimulus
    stimuli.secondA2.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.secondA2.OnsetTime+stimuli.duration);
    cgtext(wait4partner,-mWidth,0);
    stimuli.secondA2.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.secondA2.actualDuration  = stimuli.secondA2.OffsetTime - stimuli.secondA2.OnsetTime;
    wait(stimuli.ISI/2);
    
    %----------------------------------------------------------------------
    % DECISION A2
    %----------------------------------------------------------------------
    
    % DISPLAY DECISION PROMPT (t = 0)
    cgsetsprite(0);
    cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
    cgtext(wait4partner,-mWidth,0);
    t0_a2 = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
    io64(cogent.io.ioObj,add.out_address,2);
    
    if keyversion == 0
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        while data_in == a2homebutton
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        end
    else
        waitkeydown(inf);
    end
    
    % MOVEMENT START (t = 1)
    cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
    
    t1_a2 = cgflip(background(1),background(2),background(3)).*1000;

    % record RT for A2
    stimuli.resp.Agent2.rt = t1_a2 - t0_a2;
    
    % WAIT FOR TARGET PRESS   
    waitrespA2 = 1;
    while waitrespA2
        data_in=io64(cogent.io.ioObj,add.inp_address);
        switch data_in
            case {119 , 87 , 247 , 55} % leftA2 + leftA2 and left or right or home A1
                stimuli.resp.Agent2.firstSec = 1; % save decision
                waitrespA2 = 0;
            case {111 , 239 , 79 , 47} % rightA2 + rightA2 and left or right or home A1
                stimuli.resp.Agent2.firstSec = 2; % save decision
                waitrespA2 = 0;
        end
    end
    
%     % keyboard version
%     cgtext('(here we will wait for the decision key to be pressed)',mWidth,0);
%     cgtext('(Now press F (1st interval) or H (2nd interval))',mWidth,-100);
%     cgflip(background(1),background(2),background(3));
    
    % TARGET REACHED (t = 2)
    t2_a2 = cgflip(background(1),background(2),background(3)).*1000;
    % stop Vicon recording
    io64(cogent.io.ioObj,add.out_address,0);
    % record MT for A2
    stimuli.resp.Agent2.movtime = t2_a2-t1_a2;
        
    %----------------------------------------------------------------------
    % CONFIDENCE A2
    %----------------------------------------------------------------------
    
    % DISPLAY CONFIDENCE SCALE (1-6)
    cgfont('Arial',fontsizebig);
    cgtext(confidenceQ,mWidth,300);
    % horizontal line (base)
    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
    % vertical line (scale)
    cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
    % yellow marker
    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 0]);
    
    t0confA2 = cgflip(background(1),background(2),background(3)).*1000;
    
    readkeys;
    A2key = [];
    A2nresp=0;
    A2respConfirmed = 0;
    A2conf = 0; % set confidence rating to zero initially
       
    while ~A2respConfirmed
        readkeys;
        if A2nresp == 0
            [A2key, A2t, A2nresp] = getkeydown([firstA2Key secondA2Key confirmA2Key abortKey]);
        end
        if ~isempty(A2key)
            switch A2key(1)
                case firstA2Key
                    A2conf = A2conf-1;
                    if A2conf < 0 % marker cannot go below zero
                        A2conf = 0;
                    end
                    cgtext(confidenceQ,mWidth,300);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % yellow marker
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                    A2key=[]; A2t=[]; A2nresp=0;
                case secondA2Key
                    A2conf = A2conf+1;
                    if A2conf > confStepsN
                        A2conf = confStepsN;
                    end
                    cgtext(confidenceQ,mWidth,300);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % yellow marker
                    cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                    A2key=[]; A2t=[]; A2nresp=0;
                case confirmA2Key
                    if A2conf == 0
                        cgtext(confidenceQ,mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
                        A2key=[]; A2t=[]; A2nresp=0;
                    else
                        A2respConfirmed = 1;
                        stimuli.resp.Agent2.time = A2t(1);
                        % record decision time (confRT) for A2
                        stimuli.resp.Agent2.confRT = stimuli.resp.Agent2.time - t0confA2;
                        stimuli.ABORT = 0;
                    end
                case abortKey
                    A2respConfirmed = 1;
                    stimuli.ABORT = 1;
                otherwise
            end
        else
            cgtext(confidenceQ,mWidth,300);
            % horizontal line (base)
            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
            % vertical line (scale)
            cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
            % yellow marker
            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),A2conf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),A2conf * confDispStep,[1 1 0]);
        end
        cgflip(background(1),background(2),background(3));
    end
    cgflip(background(1),background(2),background(3));
    % record confidence for A2
    stimuli.resp.Agent2.conf = A2conf;
    wait(stimuli.ISI/2);
    
    % A1 is next; tell A2 to observe A1's movement
    % ADD VOICE HERE: ITS YOUR TURN (A1) and PLEASE OBSERVE (A2)
    playsound(1);
    cgtext(observePartner,mWidth,0);
    cgtext(getReady,-mWidth,0);
    cgflip(background(1),background(2),background(3));
    wait(2000);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR A1
    %----------------------------------------------------------------------
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        pause(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
            cgtext('Check target buttons!',-mWidth,0);
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        if keyversion == 0
            % CHECK IF PARTICIPANT IS READY TO START
            data_in=io64(cogent.io.ioObj,add.inp_address);
            if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                    cgtext(return2start,-mWidth,0);
                    cgtext(observePartner,mWidth,0);
                    cgflip(background(1),background(2),background(3));
                    data_in=io64(cogent.io.ioObj,add.inp_address);
                end
                cgtext(observePartner,mWidth,0);
                cgflip(background(1),background(2),background(3));
                pause(2);
            end
        end
        
        % IF PARTICIPANT READY, SHOW FIXATION CROSS
        cgsetsprite(0);
        cgtext('+',0+(stimuli.A1.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        cgflip(background(1),background(2),background(3));
        wait(jitterTimeMin+rand*jitterTimeAdded);
        
        % STIMULUS INTERVAL 1
        % prepare stimulus
        cgdrawsprite(firstIntSpriteA1,0+(stimuli.A1.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % show stimulus
        stimuli.firstA1.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.firstA1.OnsetTime+stimuli.duration);
        cgtext(observePartner,mWidth,0);
        stimuli.firstA1.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.firstA1.actualDuration  = stimuli.firstA1.OffsetTime - stimuli.firstA1.OnsetTime;
        wait(stimuli.ISI);
        
        % STIMULUS INTERVAL 2
        % prepare stimulus
        cgdrawsprite(secondIntSpriteA1,0+(stimuli.A1.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % show stimulus
        stimuli.secondA1.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.secondA1.OnsetTime+stimuli.duration);
        cgtext(observePartner,mWidth,0);
        stimuli.secondA1.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.secondA1.actualDuration  = stimuli.secondA1.OffsetTime - stimuli.secondA1.OnsetTime;
        wait(stimuli.ISI/2);
        
        %------------------------------------------------------------------
        % DECISION A1
        %------------------------------------------------------------------
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0 = cgflip(background(1),background(2),background(3)).*1000;
                % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
        
        if keyversion == 0
            % WAIT FOR MOVEMENT START (i.e., home button release)
            data_in=io64(cogent.io.ioObj,add.inp_address);
            % keep checking for release while home button A1 (63) is pressed
            % (or while home button plus any other button is pressed)
            while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
                data_in=io64(cogent.io.ioObj,add.inp_address);
            end
        else
            waitkeydown(inf);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
        t1 = cgflip(background(1),background(2),background(3)).*1000;

        % record RT for A1
        stimuli.resp.Agent1.rt = t1 - t0; 
        
        % WAIT FOR TARGET PRESS
        waitrespA1 = 1;
        while waitrespA1
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {95, 79, 87} % leftA1 + leftA1 and left or right A2
                    stimuli.resp.Agent1.firstSec = 1; % save decision
                    waitrespA1 = 0;
                case {255, 239, 247}  % rightA1 + rightA1 and left or right A2
                    stimuli.resp.Agent1.firstSec = 2; % save decision
                    waitrespA1 = 0;
            end
        end
        
        %     % keyboard version
        %     cgtext('(here we will wait for the decision key to be pressed)',-mWidth,0);
        %     cgtext('(Now press A (1st interval) or D (2nd interval))',-mWidth,-100);
        %     cgflip(background(1),background(2),background(3));
        
        % TARGET REACHED (t = 2)
        t2 = cgflip(background(1),background(2),background(3)).*1000;
        % stop Vicon recording (once target has been pressed)
        io64(cogent.io.ioObj,add.out_address,0);
        % save MT for A1
        stimuli.resp.Agent1.movtime = t2-t1;
                      
        %------------------------------------------------------------------
        % CONFIDENCE A1
        %------------------------------------------------------------------
       
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,-mWidth,300);
        % horizontal line (base)
        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % blue marker
        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
        
        t0confA1 = cgflip(background(1),background(2),background(3)).*1000;
        
        readkeys;
        A1key = [];
        A1nresp=0;
        A1respConfirmed = 0;
        A1conf = 0; % set confidence rating to zero initially
        
        while ~A1respConfirmed
            readkeys;
            if A1nresp == 0
                [A1key, A1t, A1nresp] = getkeydown([firstA1Key secondA1Key confirmA1Key abortKey]);
            end
            if ~isempty(A1key)
                switch A1key(1)
                    case firstA1Key
                        A1conf = A1conf-1;
                        if A1conf < 0 % marker cannot go below zero
                            A1conf = 0;
                        end
                        cgtext(confidenceQ,-mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                        A1key=[]; A1t=[]; A1nresp=0;
                    case secondA1Key
                        A1conf = A1conf+1;
                        if A1conf > confStepsN
                            A1conf = confStepsN;
                        end
                        cgtext(confidenceQ,-mWidth,300);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                        A1key=[]; A1t=[]; A1nresp=0;
                    case confirmA1Key
                        if A1conf == 0
                            cgtext(confidenceQ,-mWidth,300);
                            % horizontal line (base)
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            % vertical line (scale)
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            % blue marker
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
                            A1key=[]; A1t=[]; A1nresp=0;
                        else
                            A1respConfirmed = 1;
                            stimuli.resp.Agent1.time = A1t(1);
                            % record decision time (confRT) for A1
                            stimuli.resp.Agent1.confRT = stimuli.resp.Agent1.time - t0confA1;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        A1respConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,-mWidth,300);
                % horizontal line (base)
                cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                % vertical line (scale)
                cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                % blue marker
                cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),A1conf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),A1conf * confDispStep,[0 0 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record confidence A1
        stimuli.resp.Agent1.conf = A1conf;
    end
end % END OF INDIVIDUAL DECISION PHASE


% DISPLAY INDIVIDUAL DECISIONS FOR BOTH AGENTS XXX
display_decisions_jmd; % call separate script here


%% ------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%% COLLECTIVE DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% A1 takes joint decision (in odd trials)
if mod(trial,2) == 1
    
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        pause(0.3);
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
            cgtext('Check target buttons!',-mWidth,0);
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        if keyversion == 0
            cgtext(decisionPromptJ,-mWidth,0);
            cgtext(partnerDecidesJ_1,mWidth,50);
            cgtext(partnerDecidesJ_2,mWidth,-50);
            cgflip(background(1),background(2),background(3));
            wait(2000);
            % CHECK IF PARTICIPANT IS READY TO START
            data_in=io64(cogent.io.ioObj,add.inp_address); % XXX
            % if A1 is not pressing home button (63), wait until button is pressed
            % also check for the unlikely case that, if A1 presses the home button,
            % A2 might be pressing a target button at the same time (55/47)
            if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                    cgtext(return2start,-mWidth,0);
                    cgtext(partnerDecidesJ_1,mWidth,50);
                    cgtext(partnerDecidesJ_2,mWidth,-50);
                    cgflip(background(1),background(2),background(3));
                    data_in=io64(cogent.io.ioObj,add.inp_address);
                end
                % once button press is registered, show blank grey screen and
                % shortly pause (1s) before showing the decision prompt
                cgtext(partnerDecidesJ_1,mWidth,50);
                cgtext(partnerDecidesJ_2,mWidth,-50);
                cgflip(background(1),background(2),background(3));
                pause(1);
            end
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
        cgtext(partnerDecidesJ_1,mWidth,50);
        cgtext(partnerDecidesJ_2,mWidth,-50);
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0_coll = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
    
        if keyversion == 0
            % WAIT FOR MOVEMENT START (i.e., home button release)
            data_in=io64(cogent.io.ioObj,add.inp_address);
            % keep checking for release while home button A1 (63) is pressed
            % (or while home button plus any other button is pressed)
            while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
                data_in=io64(cogent.io.ioObj,add.inp_address);
            end
        else
            waitkeydown(inf);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.A1.side*spriteWidth/2),0);
        t1_coll = cgflip(background(1),background(2),background(3)).*1000;

        % record RT for A1 in joint decision
        stimuli.resp.Coll.rt = t1_coll - t0_coll;
        
        % WAIT FOR TARGET PRESS
        waitrespColl = 1;
        while waitrespColl
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {95, 79, 87} % leftA1 + leftA1 and left or right A2
                    stimuli.resp.Coll.firstSec = 1; % save decision
                    waitrespColl = 0;
                case {255, 239, 247}  % rightA1 + rightA1 and left or right A2
                    stimuli.resp.Coll.firstSec = 2; % save decision
                    waitrespColl = 0;
            end
        end
        
        %     % keyboard version
        %     cgtext('(here we will wait for the decision key to be pressed)',-mWidth,0);
        %     cgtext('(Now press A (1st interval) or D (2nd interval))',-mWidth,-100);
        %     cgflip(background(1),background(2),background(3));
        
        % TARGET REACHED (t = 2)
        t2_coll = cgflip(background(1),background(2),background(3)).*1000;
        % stop Vicon recording (once target has been pressed)
        io64(cogent.io.ioObj,add.out_address,0);
        % save MT for A1 in joint decision
        stimuli.resp.Coll.movtime = t2_coll-t1_coll;
        
        %------------------------------------------------------------------
        % CONFIDENCE A1 (for joint decision)
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,-mWidth,300);
        % horizontal line (base)
        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % blue marker
        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
        
        t0confColl = cgflip(background(1),background(2),background(3)).*1000;
        
        % set keys
        readkeys;
        Collkey = [];
        Collnresp = 0;
        CollrespConfirmed = 0;
        Collconf = 0; % set confidence rating to zero initially
        
        % confidence keys A1 (for joint decision)
        firstCollKey      = 82; % Agent1 7 -> down
        secondCollKey     = 76; % Agent1 1 -> up
        confirmCollKey    = 79; % Agent1 4 -> confirm
        
        
        % READ INPUT (until decision is confirmed)
        while ~CollrespConfirmed
            readkeys;
            if Collnresp == 0
                [Collkey, Collt, Collnresp] = getkeydown([firstCollKey secondCollKey confirmCollKey abortKey]);
            end
            if ~isempty(Collkey) % if a key has been pressed, check which
                switch Collkey(1)
                    case firstCollKey % if down-key was pressed, move down the scale
                        Collconf = Collconf-1; % update confidence rating
                        if Collconf < 0 % cannot move below zero
                            Collconf = 0;
                        end
                        cgtext(confidenceQ,-mWidth,300);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0; % reset to continue checking for input                        
                    case secondCollKey % if up-key was pressed, move up the scale
                        Collconf = Collconf+1;  % update confidence rating
                        if Collconf > confStepsN % cannot move past end of scale (6)
                            Collconf = confStepsN;
                        end
                        cgtext(confidenceQ,-mWidth,300);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;                        
                    case confirmCollKey % if confirm-key was pressed
                        if Collconf == 0 % if zero, continue (because conf=zero is not allowed)
                            cgtext(confidenceQ,-mWidth,300);
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                            Collkey=[]; Collt=[]; Collnresp=0;
                        else
                            CollrespConfirmed = 1; % confidence confirmed
                            stimuli.resp.Coll.time = Collt(1); % save timepoint
                            % record decision time (confRT) for joint
                            stimuli.resp.Coll.confRT = stimuli.resp.Coll.time - t0confColl;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        CollrespConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,-mWidth,300);
                cgdraw(0+(stimuli.A1.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A1.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                cgdraw(0+(stimuli.A1.side*spriteWidth/2),0,0+(stimuli.A1.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                cgdraw(0+(stimuli.A1.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A1.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record joint confidence
        stimuli.resp.Coll.conf = Collconf;
        wait(stimuli.ISI/2); % wait 500 ms before feedback is displayed
    end
    
%--------------------------------------------------------------------------
% A2 takes joint decision (in even trials)

elseif mod(trial,2) == 0
    
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        pause(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 111 || data_in == 119
            cgtext('Check target buttons!',mWidth,0);
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        if keyversion == 0
            cgtext(decisionPromptJ,mWidth,0);
            cgtext(partnerDecidesJ_1,-mWidth,50);
            cgtext(partnerDecidesJ_2,-mWidth,-50);
            wait(2000);
            % CHECK IF PARTICIPANT IS READY TO START
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2); %XXX
            if data_in ~= a2homebutton
                while data_in ~= a2homebutton
                    cgtext(return2start,mWidth,0);
                    cgtext(partnerDecidesJ_1,-mWidth,50);
                    cgtext(partnerDecidesJ_2,-mWidth,-50);
                    cgflip(background(1),background(2),background(3));
                    data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
                end
                cgtext(partnerDecidesJ_1,-mWidth,50);
                cgtext(partnerDecidesJ_2,-mWidth,-50);
                cgflip(background(1),background(2),background(3));
                pause(1); % short pause (1s) before decision prompt
            end
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
        cgtext(partnerDecidesJ_1,-mWidth,50);
        cgtext(partnerDecidesJ_2,-mWidth,-50);
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0_coll = cgflip(background(1),background(2),background(3)).*1000;
                % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2);
        
        if keyversion == 0
            % WAIT FOR MOVEMENT START (i.e., home button release)
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            while data_in == a2homebutton
                data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            end
        else
            waitkeydown(inf);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.A2.side*spriteWidth/2),0);
        t1_coll = cgflip(background(1),background(2),background(3)).*1000;

        % record RT for A2 in joint decision
        stimuli.resp.Coll.rt = t1_coll - t0_coll;
        
        % WAIT FOR TARGET PRESS
        waitrespColl = 1;
        while waitrespColl
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {119 , 87 , 247 , 55} % leftA2 + leftA2 and left or right or home A1
                    stimuli.resp.Coll.firstSec = 1; % save decision
                    waitrespColl = 0;
                case {111 , 239 , 79 , 47} % rightA2 + rightA2 and left or right or home A1
                    stimuli.resp.Coll.firstSec = 2; % save decision
                    waitrespColl = 0;
            end
        end
        
        %         % keyboard version
        %         cgtext('(here we will wait for the decision key to be pressed)',mWidth,0);
        %         cgtext('(Now press F (1st interval) or H (2nd interval))',mWidth,-100);
        %         cgflip(background(1),background(2),background(3));
        
        % TARGET REACHED (t = 2)
        t2_coll = cgflip(background(1),background(2),background(3)).*1000;
        % stop Vicon recording
        io64(cogent.io.ioObj,add.out_address,0);
        % record MT for A2 in joint decision
        stimuli.resp.Coll.movtime = t2_coll-t1_coll;
        
        %------------------------------------------------------------------
        % CONFIDENCE A2 (for joint decision)
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,mWidth,300);
        % horizontal line (base)
        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % white marker
        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 1]);
        
        t0confColl = cgflip(background(1),background(2),background(3)).*1000;
        
        % set keys
        readkeys;
        Collkey = [];
        Collnresp=0;
        CollrespConfirmed = 0;
        Collconf = 0; % set confidence rating to zero initially
        
        % confidence keys A2 (for joint decision)
        firstCollKey       = 83; % Agent2 8 -> down
        secondCollKey      = 77;% Agent2  2 -> up
        confirmCollKey     = 80; % Agent2 5 -> confirm
        
        
        % READ INPUT (until decision is confirmed)
        while ~CollrespConfirmed
            readkeys;
            if Collnresp == 0
                [Collkey, Collt, Collnresp] = getkeydown([firstCollKey secondCollKey confirmCollKey abortKey]);
            end
            if ~isempty(Collkey)
                switch Collkey(1)
                    case firstCollKey
                        Collconf = Collconf-1;
                        if Collconf < 0
                            Collconf = 0;
                        end
                        cgtext(confidenceQ,mWidth,300);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;
                    case secondCollKey
                        Collconf = Collconf+1;
                        if Collconf > confStepsN
                            Collconf = confStepsN;
                        end
                        cgtext(confidenceQ,mWidth,300);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;
                    case confirmCollKey
                        if Collconf == 0
                            cgtext(confidenceQ,mWidth,300);
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                            Collkey=[]; Collt=[]; Collnresp=0;
                        else
                            CollrespConfirmed = 1;
                            stimuli.resp.Coll.time = Collt(1);
                            % record decision time (confRT) for joint
                            stimuli.resp.Coll.confRT = stimuli.resp.Coll.time - t0confColl;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        CollrespConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,mWidth,300);
                cgdraw(0+(stimuli.A2.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.A2.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                cgdraw(0+(stimuli.A2.side*spriteWidth/2),0,0+(stimuli.A2.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                cgdraw(0+(stimuli.A2.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.A2.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record joint confidence
        stimuli.resp.Coll.conf = Collconf;
        wait(stimuli.ISI/2); % wait 500 ms before feedback is displayed
    end
    
end % end of joint decision phase

%% ------------------------------------------------------------------------
%%%%% CALCULATE ACCURACIES, SHOW FEEDBACK, MOVE ON TO NEXT TRIAL %%%%%%%%%%
%--------------------------------------------------------------------------

if ~stimuli.ABORT
    cgpencol(0,0,0); % black font color
    % check whether Agent's response corresponds to actual target interval
    if stimuli.firstSecond==1 % if target is in 1st interval
        % for Agent1 observer
        stimuli.resp.Agent1.acc = stimuli.resp.Agent1.firstSec == 1;
        % for Agent2 observer
        stimuli.resp.Agent2.acc = stimuli.resp.Agent2.firstSec == 1;
        % for consensus
        stimuli.resp.Coll.acc = stimuli.resp.Coll.firstSec == 1;
    elseif stimuli.firstSecond==2 % if target is in 2nd interval
        % for Agent1 observer
        stimuli.resp.Agent1.acc = stimuli.resp.Agent1.firstSec == 2;
        % for Agent2 observer
        stimuli.resp.Agent2.acc = stimuli.resp.Agent2.firstSec == 2;
        % for consensus
        stimuli.resp.Coll.acc = stimuli.resp.Coll.firstSec == 2;
    end
    
    %----------------------------------------------------------------------
    % PREPARE FEEDBACK TEXT (for A1, A2, and Joint)
    %----------------------------------------------------------------------
    if stimuli.resp.Agent2.acc
        Agent2Feedback.text = 'correct';
    else
        Agent2Feedback.text = 'wrong';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Feedback.text = 'correct';
    else
        Agent1Feedback.text = 'wrong';
    end
    
    if stimuli.resp.Coll.acc
        CollFeedback.text = 'correct';
    else
        CollFeedback.text = 'wrong';
    end
    
    % show feedback aligned horizontally (A1 - joint - A2)
    Agent1Feedback.y = 0; Agent2Feedback.y = 0; CollFeedback.y = 0;
    cgpencol(0,0,1); % blue
    cgtext(Agent1Feedback.text,-mWidth-mWidth/2,Agent1Feedback.y);
    cgtext(Agent1Feedback.text,mWidth/2,Agent1Feedback.y);
    cgpencol(1,1,0); % yellow
    cgtext(Agent2Feedback.text,-mWidth/2,Agent2Feedback.y);
    cgtext(Agent2Feedback.text,mWidth+mWidth/2,Agent2Feedback.y);
    cgpencol(1,1,1); % white
    cgtext(CollFeedback.text,-mWidth,CollFeedback.y);
    cgtext(CollFeedback.text,mWidth,CollFeedback.y);
    cgflip(background(1),background(2),background(3));
    wait(2000); % display for 2 seconds, then proceed automatically
    
    %----------------------------------------------------------------------
%     % ANNOUNCE NEXT TRIAL (and wait for keypress)
%     if stimuli.trial < stimuli.trialsInBlock
%         % announce which agent will start next trial
%         if mod(trial,2) == 0 % if curr. trial is even, next one will be odd
%             cgpencol(0,0,1);
%             cgtext(nextA1,-mWidth,0);
%             cgtext(nextA1,mWidth,0);
%         elseif mod(trial,2) == 1 % if curr. trial is odd, next one will be even
%             cgpencol(1,1,0);
%             cgtext(nextA2,-mWidth,0);
%             cgtext(nextA2,mWidth,0);
%         end
%         cgflip(background(1),background(2),background(3));
%         waitkeydown(inf,71); % start new trial with spacebar press
%     end
%     cgflip(background(1),background(2),background(3));
%     cgpencol(0,0,0)
else
    stimuli.ABORT = true;
end

