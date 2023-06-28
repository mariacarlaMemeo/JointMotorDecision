function stimuli = trial_jmd(stimuli,mWidth,trial,add,cogent,agentYhomebutton,show_acc)


% ---------------- first define some more variables --------------------- %
% re-set global variables (because unknown inside function)
global background;      % background color
global imSize;          % image size
global fontsizebig;     % Arial 30
% global fontsizesmall;   % Arial 20
% global fix_size;        % can be used for fixation cross
stimuli.release_flag   = [0 0 0];

% CONFIDENCE SCALE
confLineLength = 144; confStepsN = 6;
confDispStep   = confLineLength/confStepsN;
zeroLineLength = 15;

% CONFIDENCE KEYS
% Note: for joint decision, conf. keys are adjusted as necessary in script
% confidence keys B agent
firstBKey      = 82; % AgentB 7 -> down
secondBKey     = 76; % AgentB 1 -> up
confirmBKey    = 79; % AgentB 4 -> confirm
% firstBKey      = 3; % AgentB C -> down
% secondBKey     = 5; % AgentB E -> up
% confirmBKey    = 4; % AgentB D -> confirm

% confidence keys Y agent
firstYKey      = 83; % AgentY 8 -> down
secondYKey     = 77; % AgentY  2 -> up
confirmYKey    = 80; % AgentY 5 -> confirm
% firstYKey      = 2; % AgentY B -> down
% secondYKey     = 20;% AgentY T -> up
% confirmYKey    = 7; % AgentY G -> confirm

% JITTER BEFORE STIMULUS PRESENTATION
jitterTimeMin    = 0.5;
jitterTimeAdded  = 1;
jitterTimeMinJ   = 0.75;
jitterTimeAddedJ = 0.5;

% SCREEN DIMENSIONS FOR SPRITES
spriteWidth     = 1280/2; % half of the full screen for each agent
spriteHeight    = 1024/2;

% OTHER
gam = 2.2;      % ?
abortKey = 52;  % ESC
cgfont('Arial',fontsizebig); % set font to big

% instruction texts
wait4partner_1        = 'GIRATI';%'TURN AWAY';
wait4partner_2        = 'mentre il tuo partner prende la sua decisione';%'while partner acts';
return2start_1st_1    = 'TOCCA A TE';%'YOU START';
return2start_1st_2    = 'Premi il pulsante di start';%'Press start button';
return2start_2nd_1    = 'E'' IL TUO TURNO';%'YOUR TURN';
return2start_2nd_2    = 'Premi il pulsante di start';%'Press start button';
return2startJ_1       = 'Premi il pulsante di start';%'Press start button';
return2startJ_2       = 'per prendere la decisione di SQUADRA';%'and take TEAM decision';
decisionPrompt        = '1° stimolo               ?               2° stimolo';
observePartner        = 'OSSERVA il tuo partner';%'OBSERVE partner';
partnerDecidesJ_1     = 'Il tuo partner prende la decisione di SQUADRA';%'Partner takes TEAM decision';
partnerDecidesJ_2     = 'OSSERVA il tuo partner adesso';%'OBSERVE partner now';
confidenceQ           = 'Quanto sei sicuro/a della tua scelta?';%'How confident are you?';
fullyConf             = 'Moltissimo';%'Fully confident';
zeroConf              = 'Pochissimo';%'Not confident';

% Prepare the recorded sound file
loadsound('tone.wav', 1) %Puts sound in buffer 1.

% display text positions
yPos = 50;

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
targetSpriteB = 5;
targetSpriteY = 6;
% create vectors
distSpriteB = targetSpriteY    +1 : targetSpriteY+stimuli.setSize; %7:12
distSpriteY = max(distSpriteB) +1 : max(distSpriteB)+stimuli.setSize; %13:18

%--------------------------------------------------------------------------
% Add NOISE to the target and base, then make TargetStim and BaseStim.
% Note: We currently DO NOT add any noise!

xOff=0;
yOff=0;
% prepare for B
randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.B.noise);
targetPlusNoise = target + randNoise;
targetPlusNoise(targetPlusNoise>1) = 1;
targetPlusNoise(targetPlusNoise<-1) = -1;
targetPlusNoise = (targetPlusNoise+1) ./2;
targetStim = targetPlusNoise .^ (1 / gam); % target stimulus
cgloadarray(targetSpriteB, imSize, imSize, [targetStim(:) targetStim(:) targetStim(:)]);
for dSp = 1 : length(distSpriteB) %1:6
    randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.B.noise);
    basePlusNoise = base + randNoise;
    basePlusNoise(basePlusNoise>1) = 1;
    basePlusNoise(basePlusNoise<-1) = -1;
    basePlusNoise = (basePlusNoise+1) ./2;
    baseStim = basePlusNoise .^ (1 / gam); % baseline stimulus
    cgloadarray(distSpriteB(dSp), imSize, imSize, [baseStim(:) baseStim(:) baseStim(:)]);
end
% prepare for Y
randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.Y.noise);
targetPlusNoise = target + randNoise;
targetPlusNoise(targetPlusNoise>1) = 1;
targetPlusNoise(targetPlusNoise<-1) = -1;
targetPlusNoise = (targetPlusNoise+1) ./2;
targetStim = targetPlusNoise .^ (1 / gam);
cgloadarray(targetSpriteY, imSize, imSize, [targetStim(:) targetStim(:) targetStim(:)]);
for dSp = 1 : length(distSpriteY)
    randNoise = genRandNoise(imSize,xOff,yOff,sigma,stimuli.Y.noise);
    basePlusNoise = base + randNoise;
    basePlusNoise(basePlusNoise>1) = 1;
    basePlusNoise(basePlusNoise<-1) = -1;
    basePlusNoise = (basePlusNoise+1) ./2;
    baseStim = basePlusNoise .^ (1 / gam);
    cgloadarray(distSpriteY(dSp), imSize, imSize, [baseStim(:) baseStim(:) baseStim(:)]);
end
%--------------------------------------------------------------------------

% assign numbers to the two intervals (for B and Y)
firstIntSpriteB   = 1;
secondIntSpriteB  = 2;
firstIntSpriteY   = 3;
secondIntSpriteY  = 4;

% draw all Gabor patches (for both intervals, for both agents)
for intervalSp = [firstIntSpriteB secondIntSpriteB firstIntSpriteY secondIntSpriteY]
    cgmakesprite(intervalSp,spriteWidth,spriteHeight,background(1),background(2),background(3));
    cgsetsprite(intervalSp);
    cgtext('+',0,0);
    % draw for B (left side of screen)
    if intervalSp < 3
        for stimSp = 1 : stimuli.setSize % from 1-6 Gabor patches
            cgdrawsprite(distSpriteB(stimSp),stimuli.location(stimSp,1),stimuli.location(stimSp,2))
        end
        if intervalSp == stimuli.firstSecond % if this is target interval, draw target
            cgdrawsprite(targetSpriteB,stimuli.location(stimuli.targetLoc,1),stimuli.location(stimuli.targetLoc,2))
        end
    end
    % draw for Y (right side of screen)
    if intervalSp > 2
        for stimSp = 1 : stimuli.setSize % from 1-6 Gabor patches
            cgdrawsprite(distSpriteY(stimSp),stimuli.location(stimSp,1),stimuli.location(stimSp,2))
        end
        if intervalSp-2 == stimuli.firstSecond % if this is target interval, draw target
            cgdrawsprite(targetSpriteY,stimuli.location(stimuli.targetLoc,1),stimuli.location(stimuli.targetLoc,2))
        end
    end
end

%% ------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%% INDIVIDUAL DECISIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% ORDER B-Y (B indiv. decision, Y indiv. decision, B joint decision)

if mod(trial,2) == 1 % B starts in all odd trials
    
    % save the order (B-Y-B)
    stimuli.resp.firstdecision = 'B';
    stimuli.resp.seconddecision = 'Y';
    stimuli.resp.colldecision = 'B';
    
    % Vicon ready
    io64(cogent.io.ioObj,add.out_address,3); % set LPT to 3
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR B
    %----------------------------------------------------------------------
    
    % Tell Y to wait and B to get ready
    cgsetsprite(0);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    cgtext(return2start_1st_1,-mWidth,yPos);
    cgtext(return2start_1st_2,-mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(2);
    
    % SANITY CHECK AT TRIAL START
    % Is target button stuck? If so: display message for experimenter.
    data_in=io64(cogent.io.ioObj,add.inp_address);
    while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
        cgtext('Check target buttons!',-mWidth,0); % should only appear in case of error!
        cgflip(background(1),background(2),background(3));
        data_in=io64(cogent.io.ioObj,add.inp_address);
    end
    
    
    % CHECK IF PARTICIPANT IS READY TO START
    data_in=io64(cogent.io.ioObj,add.inp_address);
    % if B is not pressing home button (63), wait until button is pressed
    % also check for the unlikely case that, if B presses the home button,
    % Y might be pressing a target button at the same time (55/47)
    if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
        while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
            cgtext(return2start_1st_1,-mWidth,yPos);
            cgtext(return2start_1st_2,-mWidth,-yPos);
            cgtext(wait4partner_1,mWidth,yPos);
            cgtext(wait4partner_2,mWidth,-yPos);
            cgflip(background(1),background(2),background(3));
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        % once button press is registered, show blank grey screen and
        % shortly pause (2s) before showing the two 2 stimulus intervals
        cgtext(wait4partner_1,mWidth,yPos);
        cgtext(wait4partner_2,mWidth,-yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(2);
    end
    
    % IF PARTICIPANT READY, SHOW FIXATION CROSS
    % here one could use fixation(fix_size,'+') instead?
    cgsetsprite(0);
    cgtext('+',0+(stimuli.B.side*spriteWidth/2),0);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(jitterTimeMin+rand*jitterTimeAdded); %500 + [0-1000]
    
    % STIMULUS INTERVAL 1
    % prepare stimulus
    cgdrawsprite(firstIntSpriteB,0+(stimuli.B.side*spriteWidth/2),0);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    % show stimulus
    stimuli.firstB.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.firstB.OnsetTime+stimuli.duration);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    stimuli.firstB.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.firstB.actualDuration  = stimuli.firstB.OffsetTime - stimuli.firstB.OnsetTime;
    WaitSecs(stimuli.ISI); % wait 1000 ms
    
    % STIMULUS INTERVAL 2
    % prepare stimulus
    cgdrawsprite(secondIntSpriteB,0+(stimuli.B.side*spriteWidth/2),0);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    % show stimulus
    stimuli.secondB.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.secondB.OnsetTime+stimuli.duration);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    stimuli.secondB.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.secondB.actualDuration  = stimuli.secondB.OffsetTime - stimuli.secondB.OnsetTime;
    WaitSecs(stimuli.ISI/2); % wait 500 ms
    
    %----------------------------------------------------------------------
    % DECISION B
    %----------------------------------------------------------------------
        
    % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
    data_in=io64(cogent.io.ioObj,add.inp_address);
    %blue participant released because of 'add.inp_address'
    if data_in == 127
        stimuli.release_flag(1) = 1;
    end
    
    % DISPLAY DECISION PROMPT (t = 0)
    cgsetsprite(0);
    cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
    cgtext(wait4partner_1,mWidth,yPos);
    cgtext(wait4partner_2,mWidth,-yPos);
    % t0 = time when decision prompt appears (i.e., screen flips)
    t0 = cgflip(background(1),background(2),background(3)).*1000;
    % start Vicon recording (once home button is released) - added 200ms of
    % pre-acquisition in vicon. 
    io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
    
    
    % WAIT FOR MOVEMENT START (i.e., home button release)
    data_in=io64(cogent.io.ioObj,add.inp_address);

    % keep checking for release while home button B (63) is pressed
    % (or while home button plus any other button is pressed)
    while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
        data_in=io64(cogent.io.ioObj,add.inp_address);
    end
    
    % MOVEMENT START (t = 1)
    cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
    t1 = cgflip(background(1),background(2),background(3)).*1000;
    % record RT for B
    stimuli.resp.AgentB.rt = t1 - t0;
    
    % WAIT FOR TARGET PRESS
    waitrespB = 1;
    while waitrespB
        data_in=io64(cogent.io.ioObj,add.inp_address);
        switch data_in
            case {95, 79, 87} % leftB + leftB and left or right Y
                stimuli.resp.AgentB.firstSec = 1; % save decision
                waitrespB = 0;
            case {255, 239, 247}  % rightB + rightB and left or right Y
                stimuli.resp.AgentB.firstSec = 2; % save decision
                waitrespB = 0;
        end
    end
    
    % TARGET REACHED (t = 2)
    t2 = cgflip(background(1),background(2),background(3)).*1000;
    WaitSecs(0.1);
    % stop Vicon recording (once target has been pressed)
    io64(cogent.io.ioObj,add.out_address,0);
    % save MT
    stimuli.resp.AgentB.movtime = t2-t1;
    
    %----------------------------------------------------------------------
    % CONFIDENCE B
    %----------------------------------------------------------------------
    
    % DISPLAY CONFIDENCE SCALE (1-6)
    cgfont('Arial',fontsizebig);
    cgtext(confidenceQ,-mWidth,confLineLength+200);
    cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
    cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
    % horizontal line (base)
    cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
    % vertical line (scale)
    cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
    % blue marker
    cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
    t0confB = cgflip(background(1),background(2),background(3)).*1000;
    
    % set keys
    readkeys;
    Bkey = [];
    Bnresp = 0;
    BrespConfirmed = 0;
    Bncount = 0;%it counts the number of key pressed
    Bconf = randi(6); % set confidence rating to random value(1:6) initially
    
    % READ INPUT (until decision is confirmed)
    while ~BrespConfirmed
        readkeys;
        if Bnresp == 0
            [Bkey, Bt, Bnresp] = getkeydown([firstBKey secondBKey confirmBKey abortKey]);
        end
        if ~isempty(Bkey)            
            switch Bkey(1)
                case firstBKey % move down on scale
                    Bconf = Bconf-1;
                    if Bconf < 0 % marker cannot go below zero
                        Bconf = 0;
                    end
                    cgtext(confidenceQ,-mWidth,confLineLength+200);
                    cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                    cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % blue marker
                    cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                    Bkey=[]; Bt=[]; Bnresp=0;
                    Bncount = Bncount + 1;
                case secondBKey % move up on scale
                    Bconf = Bconf+1;
                    if Bconf > confStepsN
                        Bconf = confStepsN;
                    end
                    cgtext(confidenceQ,-mWidth,confLineLength+200);
                    cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                    cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % blue marker
                    cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                    Bkey=[]; Bt=[]; Bnresp=0;
                    Bncount = Bncount + 1;
                case confirmBKey
                    if Bconf == 0 || Bncount == 0% confidence cannot be zero and at least 1 key should be pressed
                        cgtext(confidenceQ,-mWidth,confLineLength+200);
                        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                        Bkey=[]; Bt=[]; Bnresp=0;
                    else
                        BrespConfirmed = 1;
                        stimuli.resp.AgentB.time = Bt(1);
                        % record decision time (confRT) for B
                        stimuli.resp.AgentB.confRT = stimuli.resp.AgentB.time - t0confB;
                        stimuli.ABORT = 0;
                    end
                case abortKey
                    BrespConfirmed = 1;
                    stimuli.ABORT = 1;
                otherwise
            end
        else
            cgtext(confidenceQ,-mWidth,confLineLength+200);
            cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
            cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
            % horizontal line (base)
            cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
            % vertical line (scale)
            cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
            % blue marker
            cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
        end
        cgflip(background(1),background(2),background(3));
    end
    cgflip(background(1),background(2),background(3));
    % record confidence for B
    stimuli.resp.AgentB.conf = Bconf;
    WaitSecs(stimuli.ISI/2) % wait for 500 ms
    
    % Y acts next and B should observe Y's movement -> beep sound
    playsound(1);
    cgtext(observePartner,-mWidth,0);
    cgtext(return2start_2nd_1,mWidth,yPos);
    cgtext(return2start_2nd_2,mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(2);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR Y
    %----------------------------------------------------------------------
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        WaitSecs(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 111 || data_in == 119
            cgtext('Check target buttons!',mWidth,0);% should only appear in case of error!
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
                
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        if data_in ~= agentYhomebutton
            while data_in ~= agentYhomebutton
                cgtext(return2start_2nd_1,mWidth,yPos);
                cgtext(return2start_2nd_2,mWidth,-yPos);
                cgtext(observePartner,-mWidth,0);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            end
            cgtext(observePartner,-mWidth,0);
            cgflip(background(1),background(2),background(3));
            WaitSecs(2);
        end
                
        % IF PARTICIPANT READY, SHOW FIXATION CROSS
        cgsetsprite(0);
        cgtext('+',0+(stimuli.Y.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        cgflip(background(1),background(2),background(3));
        WaitSecs(jitterTimeMin+rand*jitterTimeAdded);
        
        % STIMULUS INTERVAL 1
        % prepare stimulus
        cgdrawsprite(firstIntSpriteY,0+(stimuli.Y.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        % show stimulus
        stimuli.firstY.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.firstY.OnsetTime+stimuli.duration);
        cgtext(observePartner,-mWidth,0);
        stimuli.firstY.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.firstY.actualDuration  = stimuli.firstY.OffsetTime - stimuli.firstY.OnsetTime;
        WaitSecs(stimuli.ISI);
        
        % STIMULUS INTERVAL 2
        % prepare stimulus
        cgdrawsprite(secondIntSpriteY,0+(stimuli.Y.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        % show stimulus
        stimuli.secondY.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.secondY.OnsetTime+stimuli.duration);
        cgtext(observePartner,-mWidth,0);
        stimuli.secondY.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.secondY.actualDuration  = stimuli.secondY.OffsetTime - stimuli.secondY.OnsetTime;
        WaitSecs(stimuli.ISI/2);
        
        %------------------------------------------------------------------
        % DECISION Y
        %------------------------------------------------------------------

        % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        %yellow participant released because of 'add.inp_address_startSubj2'
        if data_in == 12
            stimuli.release_flag(2) = 1;
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
        cgtext(observePartner,-mWidth,0);
        t0_Y = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2);
                
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);

        while data_in == agentYhomebutton
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
        t1_Y = cgflip(background(1),background(2),background(3)).*1000;
        
        % record RT for Y
        stimuli.resp.AgentY.rt = t1_Y - t0_Y;
        
        % WAIT FOR TARGET PRESS
        waitrespY = 1;
        while waitrespY
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {119 , 87 , 247 , 55} % leftY + leftY and left or right or home B
                    stimuli.resp.AgentY.firstSec = 1; % save decision
                    waitrespY = 0;
                case {111 , 239 , 79 , 47} % rightY + rightY and left or right or home B
                    stimuli.resp.AgentY.firstSec = 2; % save decision
                    waitrespY = 0;
            end
        end
        
        % TARGET REACHED (t = 2)
        t2_Y = cgflip(background(1),background(2),background(3)).*1000;
        WaitSecs(0.1);
        % stop Vicon recording
        io64(cogent.io.ioObj,add.out_address,0);
        % record MT for Y
        stimuli.resp.AgentY.movtime = t2_Y-t1_Y;
        
        %------------------------------------------------------------------
        % CONFIDENCE Y
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,mWidth,confLineLength+200);
        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
        % horizontal line (base)
        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % yellow marker
        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 0]);
        
        t0confY = cgflip(background(1),background(2),background(3)).*1000;
        
        readkeys;
        Ykey = [];
        Ynresp=0;
        YrespConfirmed = 0;
        
        Yncount = 0;%it counts the number of key pressed
        Yconf = randi(6); % set confidence rating to random value(1:6) initially
        
        while ~YrespConfirmed
            readkeys;
            if Ynresp == 0
                [Ykey, Yt, Ynresp] = getkeydown([firstYKey secondYKey confirmYKey abortKey]);
            end
            if ~isempty(Ykey)
                switch Ykey(1)
                    case firstYKey
                        Yconf = Yconf-1;
                        if Yconf < 0 % marker cannot go below zero
                            Yconf = 0;
                        end
                        cgtext(confidenceQ,mWidth,confLineLength+200);
                        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                        Ykey=[]; Yt=[]; Ynresp=0;
                        Yncount = Yncount + 1;
                    case secondYKey
                        Yconf = Yconf+1;
                        if Yconf > confStepsN
                            Yconf = confStepsN;
                        end
                        cgtext(confidenceQ,mWidth,confLineLength+200);
                        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                        Ykey=[]; Yt=[]; Ynresp=0;
                        Yncount = Yncount + 1;
                    case confirmYKey
                        if Yconf == 0 || Yncount ==0
                            cgtext(confidenceQ,mWidth,confLineLength+200);
                            cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                            cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                            % horizontal line (base)
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            % vertical line (scale)
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            % yellow marker
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                            Ykey=[]; Yt=[]; Ynresp=0;
                        else
                            YrespConfirmed = 1;
                            stimuli.resp.AgentY.time = Yt(1);
                            % record decision time (confRT) for Y
                            stimuli.resp.AgentY.confRT = stimuli.resp.AgentY.time - t0confY;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        YrespConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,mWidth,confLineLength+200);
                cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                % horizontal line (base)
                cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                % vertical line (scale)
                cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                % yellow marker
                cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record confidence for Y
        stimuli.resp.AgentY.conf = Yconf;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ORDER Y-B (Y indiv. decision, B indiv. decision, Y joint decision)
    
elseif mod(trial,2) == 0 % Y starts in all even trials
    
    % save the order (Y-B-Y)
    stimuli.resp.firstdecision = 'Y';
    stimuli.resp.seconddecision = 'B';
    stimuli.resp.colldecision = 'Y';
    
    % Vicon ready
    io64(cogent.io.ioObj,add.out_address,3);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR Y
    %----------------------------------------------------------------------
    
    % Tell B to wait and Y to get ready
    cgsetsprite(0);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    cgtext(return2start_1st_1,mWidth,yPos);
    cgtext(return2start_1st_2,mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(2);
    
    % SANITY CHECK AT TRIAL START
    % Is target button stuck? If so: display message for experimenter.
    data_in=io64(cogent.io.ioObj,add.inp_address);
    while data_in == 111 || data_in == 119
        cgtext('Check target buttons!',mWidth,0);% should only appear in case of error!
        cgflip(background(1),background(2),background(3))
        data_in=io64(cogent.io.ioObj,add.inp_address);
    end
        
    % CHECK IF PARTICIPANT IS READY TO START
    data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
    if data_in ~= agentYhomebutton
        while data_in ~= agentYhomebutton
            cgtext(return2start_1st_1,mWidth,yPos);
            cgtext(return2start_1st_2,mWidth,-yPos);
            cgtext(wait4partner_1,-mWidth,yPos);
            cgtext(wait4partner_2,-mWidth,-yPos);
            cgflip(background(1),background(2),background(3));
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        end
        cgtext(wait4partner_1,-mWidth,yPos);
        cgtext(wait4partner_2,-mWidth,-yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(2);
    end
        
    % IF PARTICIPANT READY, SHOW FIXATION CROSS
    cgsetsprite(0);
    cgtext('+',0+(stimuli.Y.side*spriteWidth/2),0);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(jitterTimeMin+rand*jitterTimeAdded);
    
    % STIMULUS INTERVAL 1
    % prepare stimulus
    cgdrawsprite(firstIntSpriteY,0+(stimuli.Y.side*spriteWidth/2),0);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    % show stimulus
    stimuli.firstY.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.firstY.OnsetTime+stimuli.duration);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    stimuli.firstY.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.firstY.actualDuration  = stimuli.firstY.OffsetTime - stimuli.firstY.OnsetTime;
    WaitSecs(stimuli.ISI);
    
    % STIMULUS INTERVAL 2
    % prepare stimulus
    cgdrawsprite(secondIntSpriteY,0+(stimuli.Y.side*spriteWidth/2),0);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    % show stimulus
    stimuli.secondY.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    waituntil(stimuli.secondY.OnsetTime+stimuli.duration);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    stimuli.secondY.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
    stimuli.secondY.actualDuration  = stimuli.secondY.OffsetTime - stimuli.secondY.OnsetTime;
    WaitSecs(stimuli.ISI/2);
    
    %----------------------------------------------------------------------
    % DECISION Y
    %----------------------------------------------------------------------

    % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
    data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
    %yellow participant released because of 'add.inp_address_startSubj2'
    if data_in == 12
        stimuli.release_flag(1) = 1;
    end
    
    % DISPLAY DECISION PROMPT (t = 0)
    cgsetsprite(0);
    cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
    cgtext(wait4partner_1,-mWidth,yPos);
    cgtext(wait4partner_2,-mWidth,-yPos);
    t0_Y = cgflip(background(1),background(2),background(3)).*1000;
    % start Vicon recording (once home button is released)
    io64(cogent.io.ioObj,add.out_address,2);
    
    % WAIT FOR MOVEMENT START (i.e., home button release)
    data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);

    while data_in == agentYhomebutton
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
    end
        
    % MOVEMENT START (t = 1)
    cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
    
    t1_Y = cgflip(background(1),background(2),background(3)).*1000;
    
    % record RT for Y
    stimuli.resp.AgentY.rt = t1_Y - t0_Y;
    
    % WAIT FOR TARGET PRESS
    waitrespY = 1;
    while waitrespY
        data_in=io64(cogent.io.ioObj,add.inp_address);
        switch data_in
            case {119 , 87 , 247 , 55} % leftY + leftY and left or right or home B
                stimuli.resp.AgentY.firstSec = 1; % save decision
                waitrespY = 0;
            case {111 , 239 , 79 , 47} % rightY + rightY and left or right or home B
                stimuli.resp.AgentY.firstSec = 2; % save decision
                waitrespY = 0;
        end
    end
    
    % TARGET REACHED (t = 2)
    t2_Y = cgflip(background(1),background(2),background(3)).*1000;
    WaitSecs(0.1);
    % stop Vicon recording
    io64(cogent.io.ioObj,add.out_address,0);
    % record MT for Y
    stimuli.resp.AgentY.movtime = t2_Y-t1_Y;
    
    %----------------------------------------------------------------------
    % CONFIDENCE Y
    %----------------------------------------------------------------------
    
    % DISPLAY CONFIDENCE SCALE (1-6)
    cgfont('Arial',fontsizebig);
    cgtext(confidenceQ,mWidth,confLineLength+200);
    cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
    cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
    % horizontal line (base)
    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
    % vertical line (scale)
    cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
    % yellow marker
    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 0]);
    
    t0confY = cgflip(background(1),background(2),background(3)).*1000;
    
    readkeys;
    Ykey = [];
    Ynresp=0;
    YrespConfirmed = 0;        
    Yncount = 0;%it counts the number of key pressed
    Yconf = randi(6); % set confidence rating to random value(1:6) initially
    
    while ~YrespConfirmed
        readkeys;
        if Ynresp == 0
            [Ykey, Yt, Ynresp] = getkeydown([firstYKey secondYKey confirmYKey abortKey]);
        end
        if ~isempty(Ykey)
            switch Ykey(1)
                case firstYKey
                    Yconf = Yconf-1;
                    if Yconf < 0 % marker cannot go below zero
                        Yconf = 0;
                    end
                    cgtext(confidenceQ,mWidth,confLineLength+200);
                    cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                    cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % yellow marker
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                    Ykey=[]; Yt=[]; Ynresp=0;
                    Yncount = Yncount + 1;
                case secondYKey
                    Yconf = Yconf+1;
                    if Yconf > confStepsN
                        Yconf = confStepsN;
                    end
                    cgtext(confidenceQ,mWidth,confLineLength+200);
                    cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                    cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                    % horizontal line (base)
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                    % vertical line (scale)
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                    % yellow marker
                    cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                    Ykey=[]; Yt=[]; Ynresp=0;
                    Yncount = Yncount + 1;
                case confirmYKey
                    if Yconf == 0 || Yncount == 0
                        cgtext(confidenceQ,mWidth,confLineLength+200);
                        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % yellow marker
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
                        Ykey=[]; Yt=[]; Ynresp=0;
                    else
                        YrespConfirmed = 1;
                        stimuli.resp.AgentY.time = Yt(1);
                        % record decision time (confRT) for Y
                        stimuli.resp.AgentY.confRT = stimuli.resp.AgentY.time - t0confY;
                        stimuli.ABORT = 0;
                    end
                case abortKey
                    YrespConfirmed = 1;
                    stimuli.ABORT = 1;
                otherwise
            end
        else
            cgtext(confidenceQ,mWidth,confLineLength+200);
            cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
            cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
            % horizontal line (base)
            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
            % vertical line (scale)
            cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
            % yellow marker
            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Yconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Yconf * confDispStep,[1 1 0]);
        end
        cgflip(background(1),background(2),background(3));
    end
    cgflip(background(1),background(2),background(3));
    % record confidence for Y
    stimuli.resp.AgentY.conf = Yconf;
    WaitSecs(stimuli.ISI/2);
    
    % B acts next and Y should observe B's movement
    playsound(1);
    cgtext(observePartner,mWidth,0);
    cgtext(return2start_2nd_1,-mWidth,yPos);
    cgtext(return2start_2nd_2,-mWidth,-yPos);
    cgflip(background(1),background(2),background(3));
    WaitSecs(2);
    
    %----------------------------------------------------------------------
    % DISPLAY STIMULI FOR B
    %----------------------------------------------------------------------
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        WaitSecs(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
            cgtext('Check target buttons!',-mWidth,0);% should only appear in case of error!
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address);
        if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
            while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                cgtext(return2start_2nd_1,-mWidth,yPos);
                cgtext(return2start_2nd_2,-mWidth,-yPos);
                cgtext(observePartner,mWidth,0);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address);
            end
            cgtext(observePartner,mWidth,0);
            cgflip(background(1),background(2),background(3));
            WaitSecs(2);
        end
        
        % IF PARTICIPANT READY, SHOW FIXATION CROSS
        cgsetsprite(0);
        cgtext('+',0+(stimuli.B.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        cgflip(background(1),background(2),background(3));
        WaitSecs(jitterTimeMin+rand*jitterTimeAdded);
        
        % STIMULUS INTERVAL 1
        % prepare stimulus
        cgdrawsprite(firstIntSpriteB,0+(stimuli.B.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % show stimulus
        stimuli.firstB.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.firstB.OnsetTime+stimuli.duration);
        cgtext(observePartner,mWidth,0);
        stimuli.firstB.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.firstB.actualDuration  = stimuli.firstB.OffsetTime - stimuli.firstB.OnsetTime;
        WaitSecs(stimuli.ISI);
        
        % STIMULUS INTERVAL 2
        % prepare stimulus
        cgdrawsprite(secondIntSpriteB,0+(stimuli.B.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % show stimulus
        stimuli.secondB.OnsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        waituntil(stimuli.secondB.OnsetTime+stimuli.duration);
        cgtext(observePartner,mWidth,0);
        stimuli.secondB.OffsetTime = cgflip(background(1),background(2),background(3)) .* 1000;
        stimuli.secondB.actualDuration  = stimuli.secondB.OffsetTime - stimuli.secondB.OnsetTime;
        WaitSecs(stimuli.ISI/2);
        
        %------------------------------------------------------------------
        % DECISION B
        %------------------------------------------------------------------

        % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
        data_in=io64(cogent.io.ioObj,add.inp_address);
        %blue participant released because of 'add.inp_address'
        if data_in == 127
            stimuli.release_flag(2) = 1;
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgsetsprite(0);
        cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
        cgtext(observePartner,mWidth,0);
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0 = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
        
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address);

        % keep checking for release while home button B (63) is pressed
        % (or while home button plus any other button is pressed)
        while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
                
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
        t1 = cgflip(background(1),background(2),background(3)).*1000;
        
        % record RT for B
        stimuli.resp.AgentB.rt = t1 - t0;
        
        % WAIT FOR TARGET PRESS
        waitrespB = 1;
        while waitrespB
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {95, 79, 87} % leftB + leftB and left or right Y
                    stimuli.resp.AgentB.firstSec = 1; % save decision
                    waitrespB = 0;
                case {255, 239, 247}  % rightB + rightB and left or right Y
                    stimuli.resp.AgentB.firstSec = 2; % save decision
                    waitrespB = 0;
            end
        end
        
        % TARGET REACHED (t = 2)
        t2 = cgflip(background(1),background(2),background(3)).*1000;
        WaitSecs(0.1);
        % stop Vicon recording (once target has been pressed)
        io64(cogent.io.ioObj,add.out_address,0);
        % save MT for B
        stimuli.resp.AgentB.movtime = t2-t1;
        
        %------------------------------------------------------------------
        % CONFIDENCE B
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,-mWidth,confLineLength+200);
        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
        % horizontal line (base)
        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % blue marker
        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
        
        t0confB = cgflip(background(1),background(2),background(3)).*1000;
        
        readkeys;
        Bkey = [];
        Bnresp=0;
        BrespConfirmed = 0;
        Bncount = 0;%it counts the number of key pressed
        Bconf = randi(6); % set confidence rating to random value(1:6) initially
        
        while ~BrespConfirmed
            readkeys;
            if Bnresp == 0
                [Bkey, Bt, Bnresp] = getkeydown([firstBKey secondBKey confirmBKey abortKey]);
            end
            if ~isempty(Bkey)
                switch Bkey(1)
                    case firstBKey
                        Bconf = Bconf-1;
                        if Bconf < 0 % marker cannot go below zero
                            Bconf = 0;
                        end
                        cgtext(confidenceQ,-mWidth,confLineLength+200);
                        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                        Bkey=[]; Bt=[]; Bnresp=0;
                        Bncount = Bncount + 1;
                    case secondBKey
                        Bconf = Bconf+1;
                        if Bconf > confStepsN
                            Bconf = confStepsN;
                        end
                        cgtext(confidenceQ,-mWidth,confLineLength+200);
                        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                        % horizontal line (base)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        % vertical line (scale)
                        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        % blue marker
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                        Bkey=[]; Bt=[]; Bnresp=0;
                        Bncount = Bncount + 1;
                    case confirmBKey
                        if Bconf == 0 || Bncount == 0
                            cgtext(confidenceQ,-mWidth,confLineLength+200);
                            cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                            cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                            % horizontal line (base)
                            cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            % vertical line (scale)
                            cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            % blue marker
                            cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
                            Bkey=[]; Bt=[]; Bnresp=0;
                        else
                            BrespConfirmed = 1;
                            stimuli.resp.AgentB.time = Bt(1);
                            % record decision time (confRT) for B
                            stimuli.resp.AgentB.confRT = stimuli.resp.AgentB.time - t0confB;
                            stimuli.ABORT = 0;
                        end
                    case abortKey
                        BrespConfirmed = 1;
                        stimuli.ABORT = 1;
                    otherwise
                end
            else
                cgtext(confidenceQ,-mWidth,confLineLength+200);
                cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                % horizontal line (base)
                cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                % vertical line (scale)
                cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                % blue marker
                cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Bconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Bconf * confDispStep,[0 0 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record confidence B
        stimuli.resp.AgentB.conf = Bconf;
    end
end % END OF INDIVIDUAL DECISION PHASE


% DISPLAY INDIVIDUAL DECISIONS FOR BOTH AGENTS
tic
display_decisions_jmd; % call separate script here
toc

%% ------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%% COLLECTIVE DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% B takes joint decision (in odd trials)
if mod(trial,2) == 1
    
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        WaitSecs(0.3);
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 191 || data_in == 31 || data_in == 255 || data_in == 95
            cgtext('Check target buttons!',-mWidth,0);% should only appear in case of error!
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        % show decisions aligned horizontally (B - Y)
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(2);
        
        % show decisions + action prompts
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgpencol(0,0,0); % return to black font
        cgtext(return2startJ_1,-mWidth,-yPos);
        cgtext(return2startJ_2,-mWidth,-2*yPos);
        cgtext(partnerDecidesJ_1,mWidth,-yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(1);
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address); % XXX
        % if B is not pressing home button (63), wait until button is pressed
        % also check for the unlikely case that, if B presses the home button,
        % Y might be pressing a target button at the same time (55/47)
        if data_in ~= 63 && data_in ~= 55 && data_in ~= 47
            while data_in ~= 63 && data_in ~= 55 && data_in ~= 47
                cgpencol(0,0,1);
                cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
                cgtext(AgentBDecision.text,mWidth/2,2*yPos);
                cgpencol(1,1,0);
                cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
                cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
                cgpencol(0,0,0); % return to black font
                cgtext(return2startJ_1,-mWidth,-yPos);
                cgtext(return2startJ_2,-mWidth,-2*yPos);
                cgtext(partnerDecidesJ_1,mWidth,-yPos);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address);
            end
        end
        
        % DISPLAY Observation PROMPT
        cgsetsprite(0); % is this really needed?
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgpencol(0,0,0); % return to black font
        cgtext(return2startJ_1,-mWidth,-yPos);
        cgtext(return2startJ_2,-mWidth,-2*yPos);
        cgtext(partnerDecidesJ_2,mWidth,-yPos); % display observation prompt
        cgflip(background(1),background(2),background(3));
        % add jittered delay before the decision prompt joint decision
        WaitSecs(jitterTimeMinJ+rand*jitterTimeAddedJ); %750ms + [0-500ms]

        % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
        data_in=io64(cogent.io.ioObj,add.inp_address);
        %blue participant released because of 'add.inp_address'
        if data_in == 127
            stimuli.release_flag(3) = 1;
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgtext(partnerDecidesJ_2,mWidth,-yPos); % display observation prompt
        cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0_coll = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2); % set LPT to 2
        
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address);

        % keep checking for release while home button B (63) is pressed
        % (or while home button plus any other button is pressed)
        while data_in == 63 || data_in == 55 || data_in == 47 || data_in == 191 || data_in == 31
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.B.side*spriteWidth/2),0);
        t1_coll = cgflip(background(1),background(2),background(3)).*1000;
        
        % record RT for B in joint decision
        stimuli.resp.Coll.rt = t1_coll - t0_coll;
        
        % WAIT FOR TARGET PRESS
        waitrespColl = 1;
        while waitrespColl
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {95, 79, 87} % leftB + leftB and left or right Y
                    stimuli.resp.Coll.firstSec = 1; % save decision
                    waitrespColl = 0;
                case {255, 239, 247}  % rightB + rightB and left or right Y
                    stimuli.resp.Coll.firstSec = 2; % save decision
                    waitrespColl = 0;
            end
        end
        
        % TARGET REACHED (t = 2)
        t2_coll = cgflip(background(1),background(2),background(3)).*1000;
        WaitSecs(0.1);
        % stop Vicon recording (once target has been pressed)
        io64(cogent.io.ioObj,add.out_address,0);
        % save MT for B in joint decision
        stimuli.resp.Coll.movtime = t2_coll-t1_coll;
        
        %------------------------------------------------------------------
        % CONFIDENCE B (for joint decision)
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,-mWidth,confLineLength+200);
        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
        % horizontal line (base)
        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % blue marker
        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),0,[0 0 1]);
        
        t0confColl = cgflip(background(1),background(2),background(3)).*1000;
        
        % set keys
        readkeys;
        Collkey = [];
        Collnresp = 0;
        CollrespConfirmed = 0;
        Collncount = 0;%it counts the number of key pressed
        Collconf = randi(6); % set confidence rating to random value(1:6) initially
        
        % confidence keys B (for joint decision)
        firstCollKey      = 82; % AgentB 7 -> down
        secondCollKey     = 76; % AgentB 1 -> up
        confirmCollKey    = 79; % AgentB 4 -> confirm
        %firstCollKey      = 3; % AgentB C -> down
        %secondCollKey     = 5; % AgentB E -> up
        %confirmCollKey    = 4; % AgentB D -> confirm
        
        
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
                        cgtext(confidenceQ,-mWidth,confLineLength+200);
                        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0; % reset to continue checking for input
                        Collncount = Collncount + 1;
                        
                    case secondCollKey % if up-key was pressed, move up the scale
                        Collconf = Collconf+1;  % update confidence rating
                        if Collconf > confStepsN % cannot move past end of scale (6)
                            Collconf = confStepsN;
                        end
                        cgtext(confidenceQ,-mWidth,confLineLength+200);
                        cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;
                        Collncount = Collncount + 1;
                        
                    case confirmCollKey % if confirm-key was pressed
                        if Collconf == 0 || Collncount == 0 % if zero, continue (because conf=zero is not allowed)
                            cgtext(confidenceQ,-mWidth,confLineLength+200);
                            cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                            cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                            cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
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
                cgtext(confidenceQ,-mWidth,confLineLength+200);
                cgtext(fullyConf,-mWidth+mWidth/2,confLineLength);
                cgtext(zeroConf,-mWidth+mWidth/2,confDispStep);
                cgdraw(0+(stimuli.B.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.B.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                cgdraw(0+(stimuli.B.side*spriteWidth/2),0,0+(stimuli.B.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                cgdraw(0+(stimuli.B.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.B.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record joint confidence
        stimuli.resp.Coll.conf = Collconf;
        WaitSecs(stimuli.ISI/2); % wait 500 ms before feedback is displayed
    end
    
    %--------------------------------------------------------------------------
    % Y takes joint decision (in even trials)
    
elseif mod(trial,2) == 0
    
    if ~stimuli.ABORT
        
        % Vicon ready
        io64(cogent.io.ioObj,add.out_address,3);
        WaitSecs(0.3); % insert this pause to prevent Vicon timing issue
        
        % SANITY CHECK AT TRIAL START
        % Is target button stuck? If so: display message for experimenter.
        data_in=io64(cogent.io.ioObj,add.inp_address);
        while data_in == 111 || data_in == 119
            cgtext('Check target buttons!',mWidth,0);% should only appear in case of error!
            cgflip(background(1),background(2),background(3))
            data_in=io64(cogent.io.ioObj,add.inp_address);
        end
        
        % show decisions aligned horizontally (B - Y)
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(2);
        
        % show decisions + action prompts
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgpencol(0,0,0); % return to black font
        cgtext(return2startJ_1,mWidth,-yPos);
        cgtext(return2startJ_2,mWidth,-2*yPos);
        cgtext(partnerDecidesJ_1,-mWidth,-yPos);
        cgflip(background(1),background(2),background(3));
        WaitSecs(1);
        % CHECK IF PARTICIPANT IS READY TO START
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2); %XXX
        if data_in ~= agentYhomebutton
            while data_in ~= agentYhomebutton
                cgpencol(0,0,1);
                cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
                cgtext(AgentBDecision.text,mWidth/2,2*yPos);
                cgpencol(1,1,0);
                cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
                cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
                cgpencol(0,0,0); % return to black font
                cgtext(return2startJ_1,mWidth,-yPos);
                cgtext(return2startJ_2,mWidth,-2*yPos);
                cgtext(partnerDecidesJ_1,-mWidth,-yPos);
                cgflip(background(1),background(2),background(3));
                data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
            end
        end
        
        % DISPLAY Observation PROMPT
        cgsetsprite(0); % is this really needed?
        cgpencol(0,0,1);
        cgtext(AgentBDecision.text,-mWidth-mWidth/2,2*yPos);
        cgtext(AgentBDecision.text,mWidth/2,2*yPos);
        cgpencol(1,1,0);
        cgtext(AgentYDecision.text,-mWidth/2,2*yPos);
        cgtext(AgentYDecision.text,mWidth+mWidth/2,2*yPos);
        cgpencol(0,0,0); % return to black font
        cgtext(return2startJ_1,mWidth,-yPos);
        cgtext(return2startJ_2,mWidth,-2*yPos);
        cgtext(partnerDecidesJ_2,-mWidth,-yPos); % display observation prompt
        cgflip(background(1),background(2),background(3));
        % add jittered delay before the decision prompt for joint decision
        WaitSecs(jitterTimeMinJ+rand*jitterTimeAddedJ); %750ms + [0-500ms]
        
        % CHECK IF PARTICIPANT RELEASED THE START BUTTON TOO EARLY
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        %blue participant released because of 'add.inp_address_startSubj2'
        if data_in == 12
            stimuli.release_flag(3) = 1;
        end
        
        % DISPLAY DECISION PROMPT (t = 0)
        cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
        cgtext(partnerDecidesJ_2,-mWidth,-yPos); % display observation prompt
        % t0 = time when decision prompt appears (i.e., screen flips)
        t0_coll = cgflip(background(1),background(2),background(3)).*1000;
        % start Vicon recording (once home button is released)
        io64(cogent.io.ioObj,add.out_address,2);
        
        % WAIT FOR MOVEMENT START (i.e., home button release)
        data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);

        while data_in == agentYhomebutton
            data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2);
        end
        
        % MOVEMENT START (t = 1)
        cgtext(decisionPrompt,0+(stimuli.Y.side*spriteWidth/2),0);
        t1_coll = cgflip(background(1),background(2),background(3)).*1000;
        
        % record RT for Y in joint decision
        stimuli.resp.Coll.rt = t1_coll - t0_coll;
        
        % WAIT FOR TARGET PRESS
        waitrespColl = 1;
        while waitrespColl
            data_in=io64(cogent.io.ioObj,add.inp_address);
            switch data_in
                case {119 , 87 , 247 , 55} % leftY + leftY and left or right or home B
                    stimuli.resp.Coll.firstSec = 1; % save decision
                    waitrespColl = 0;
                case {111 , 239 , 79 , 47} % rightY + rightY and left or right or home B
                    stimuli.resp.Coll.firstSec = 2; % save decision
                    waitrespColl = 0;
            end
        end
        
        % TARGET REACHED (t = 2)
        t2_coll = cgflip(background(1),background(2),background(3)).*1000;
        WaitSecs(0.1);
        % stop Vicon recording
        io64(cogent.io.ioObj,add.out_address,0);
        % record MT for Y in joint decision
        stimuli.resp.Coll.movtime = t2_coll-t1_coll;
        
        %------------------------------------------------------------------
        % CONFIDENCE Y (for joint decision)
        %------------------------------------------------------------------
        
        % DISPLAY CONFIDENCE SCALE (1-6)
        cgfont('Arial',fontsizebig);
        cgtext(confidenceQ,mWidth,confLineLength+200);
        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
        % horizontal line (base)
        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
        % vertical line (scale)
        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
        % white marker
        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),0,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),0,[1 1 1]);
        
        t0confColl = cgflip(background(1),background(2),background(3)).*1000;
        
        % set keys
        readkeys;
        Collkey = [];
        Collnresp=0;
        CollrespConfirmed = 0;
        Collncount = 0;%it counts the number of key pressed
        Collconf = randi(6); % set confidence rating to random value(1:6) initially
        
        % confidence keys Y (for joint decision)
        firstCollKey       = 83; % AgentY 8 -> down
        secondCollKey      = 77;% AgentY  2 -> up
        confirmCollKey     = 80; % AgentY 5 -> confirm
        
        
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
                        cgtext(confidenceQ,mWidth,confLineLength+200);
                        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;
                        Collncount = Collncount + 1;
                        
                    case secondCollKey
                        Collconf = Collconf+1;
                        if Collconf > confStepsN
                            Collconf = confStepsN;
                        end
                        cgtext(confidenceQ,mWidth,confLineLength+200);
                        cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                        cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                        cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
                        Collkey=[]; Collt=[]; Collnresp=0;
                        Collncount = Collncount + 1;
                        
                    case confirmCollKey
                        if Collconf == 0 || Collncount == 0
                            cgtext(confidenceQ,mWidth,confLineLength+200);
                            cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                            cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                            cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
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
                cgtext(confidenceQ,mWidth,confLineLength+200);
                cgtext(fullyConf,mWidth+mWidth/2,confLineLength);
                cgtext(zeroConf,mWidth+mWidth/2,confDispStep);
                cgdraw(0+(stimuli.Y.side*spriteWidth/2)-zeroLineLength,0,0+(stimuli.Y.side*spriteWidth/2)+zeroLineLength,0,[0 0 0]);
                cgdraw(0+(stimuli.Y.side*spriteWidth/2),0,0+(stimuli.Y.side*spriteWidth/2),0+confLineLength,[0 0 0]);
                cgdraw(0+(stimuli.Y.side*spriteWidth/2)-(zeroLineLength/2),Collconf * confDispStep,0+(stimuli.Y.side*spriteWidth/2)+(zeroLineLength/2),Collconf * confDispStep,[1 1 1]);
            end
            cgflip(background(1),background(2),background(3));
        end
        cgflip(background(1),background(2),background(3));
        % record joint confidence
        stimuli.resp.Coll.conf = Collconf;
        WaitSecs(stimuli.ISI/2); % wait 500 ms before feedback is displayed
    end
    
end % end of joint decision phase

%% ------------------------------------------------------------------------
%%%%% CALCULATE ACCURACIES, SHOW FEEDBACK, MOVE ON TO NEXT TRIAL %%%%%%%%%%
%--------------------------------------------------------------------------

if ~stimuli.ABORT
    cgpencol(0,0,0); % black font color
    % check whether Agent's response corresponds to actual target interval
    if stimuli.firstSecond==1 % if target is in 1st interval
        % for AgentB observer
        stimuli.resp.AgentB.acc = stimuli.resp.AgentB.firstSec == 1;
        % for AgentY observer
        stimuli.resp.AgentY.acc = stimuli.resp.AgentY.firstSec == 1;
        % for consensus
        stimuli.resp.Coll.acc = stimuli.resp.Coll.firstSec == 1;
    elseif stimuli.firstSecond==2 % if target is in 2nd interval
        % for AgentB observer
        stimuli.resp.AgentB.acc = stimuli.resp.AgentB.firstSec == 2;
        % for AgentY observer
        stimuli.resp.AgentY.acc = stimuli.resp.AgentY.firstSec == 2;
        % for consensus
        stimuli.resp.Coll.acc = stimuli.resp.Coll.firstSec == 2;
    end
    
    %----------------------------------------------------------------------
    % PREPARE FEEDBACK TEXT (for B, Y, and Joint)
    %----------------------------------------------------------------------
    display_acc_jmd;
    
else
    stimuli.ABORT = true;
end

