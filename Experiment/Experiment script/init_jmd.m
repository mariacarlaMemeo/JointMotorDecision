% ------------------------- initialization ------------------------------ %


%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Ask user for input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Input group ID
while 1
    data.group.id = input('Please enter group ID (101-199): ');
    if data.group.id < 101 || data.group.id > 199
        disp('Wrong group ID - choose value between 101 and 199!');
    else
        break
    end
end

% Practice (run 0) or proper Experiment (run 1)
data.isExperiment      =  input ('Practice (0) or Experiment (1) = '); %

if (data.isExperiment)
    data.AgentB.name    =  input ('AgentB Name: ','s'); % Subject's initials e.g. NK
    data.AgentY.name    =  input ('AgentY Name: ','s');
end

% We fill this information manually afterwards, now just put placeholders
data.AgentB.gender  =  'FM';
data.AgentB.age     =  99;
data.AgentY.gender  =  'FM';
data.AgentY.age     =  99;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Create results file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Create result file using group ID and run number (practice/exp).
resultFileName       =  ['S', int2str(data.group.id) '_run' int2str(data.isExperiment) , '_jmd.mat' ];
resultFileName_exel  =  ['S', int2str(data.group.id) '.xlsx' ];

% directory where data should be saved
save_dir = fullfile(pwd,'data\');
addpath(save_dir);

% If file with same gID exists, prompt to choose a different file name.
if exist(fullfile(save_dir,resultFileName),'file')
    overwrite = input('Existing Results file... Overwrite (0=No; 1=Yes)? ');
    if ~overwrite
        error('Existing Results file... Please choose another name!');
    end
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Display settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% 'window' means small on-screen window
% WE USE THE FULL SCREEN IF WE HAVE TWO DUPLICATE MONITORS and if we set
% FullScreen mode in the NVIDIA panel. Resolution is 1280x1024.
mode = 1;  %window = 0, fullscreen = 1, second screen = 2

gam = 2.2;
mWidth = 1280/4; % use spritewidth/2 for now (1280/4=320)
resolution = 5; %1=640x480, 2=800x600, 3=1024x768, 4=1152x864, 5=1280x1024, 6=1600x1200
nbuffers = 10;
number_of_bits = 0;
scale = 0;
fontname = 'Arial';

% Globalize the following variables:
global background;
global foreground;
global fix_size;
global fontsizesmall;
global fontsizebig;
global imSize;

% Clear background as mid-gray
background = [0.5 0.5 0.5] .^ (1 / gam);
% Note: [0.8 0.8 0.8] .^ (1 / gam) was used in original behavioural study,
% but we use 0.5 here.
foreground = [0 0 0]; % black foreground
fontsizebig = 30;
fontsizesmall = 20;
fix_size = 15;
imSize = 50;

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Parallel port config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

%create an instance of the io64 object
config_io;

% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;

if(cogent.io.status ~= 0 )
    error('inp/outp installation failed');
end

% Note: on the MoCap Lab PC, the LPT name is B010
add.out_address = hex2dec('3FF8');     % LPT3 output port address - for sending triggers to Vicon
add.inp_address = 1 + hex2dec('3FF8'); % LPT3 input port address - for receiving input from subjects' buttons
add.inp_address_startSubj2 = 2 + hex2dec('3FF8');  % LPT3 input port address - for receiving input from subject 2 starting position
% Note: home button Y is different from all others (can be IN and OUT)
% It should be 0 or 8 (when not pressed); otherwise 4 or 12
agentYhomebutton=io64(cogent.io.ioObj,add.inp_address_startSubj2)-4;

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Define parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Display (or not) the accuracy feedback.
% 1 = nothing
% 2 = only joint
% 3 = B, Y, joint.
show_acc = 1;

% NOTE: we could get rid of the round-variable; it's always 1 now
% the only thing we vary is the number of blocks (within the "round")
rounds   =  1;

% moved the shuffle to main_jmd
% rng('shuffle'); % initialize random number generator (generates a different sequence of random numbers after each call to rng)

% DISPLAY: show display 1 or 2 times (we always want 2)
data.display        =  2; % Display (1:single common;  2:dual separate')
% BASELINE GABOR CONTRAST
data.pedestal       =  0.1; % baseline contrast of non-target square-wave gratings
% NOISE
data.noise.B       =  0; % Noise level for AgentB between [0 - 1.0]
data.noise.Y       =  0; % Noise level for AgentY between [0 - 1.0]
% data.task           =  2; % Task (1:first/second;  2:confidence rating')

% Set constrasts for oddball, for practice (run=1) and experiment (run=1)
% This contrast is then added to the baseline contrast (0.100)
% if data.isExperiment == 0
%     contrastSteps = [0.0350
%         0.0700
%         0.1000
%         0.2000];
% else
    contrastSteps = [0.0150
        0.0350
        0.0700
        0.1500];
% end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%% Trials, blocks, randomization %%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Important: trialsInBlock must be a multiple of 4
% - 'trialsInBlock' is the no. of trials PER agent per block
% - total trial no. per block = 'trialsInBlock' * 2
% - NOTE: rationale for trial no.: The minimum per agent is 4 because there
% are 4 target contrasts. (Each agent needs to experience each of these
% in 1st or 2nd interval, and as first and second agent).
if data.isExperiment == 0 % practice
    trialsInBlock = 8; % no. of trials for each agent taking first decision PER BLOCK
    blocksInRound = 1; % 1 block only
elseif data.isExperiment == 1 % experiment
    trialsInBlock = 8*5; % no. of trials for each agent taking first decision PER BLOCK
    blocksInRound = 2;  % 2 blocks
else
    error('isExperiment should be 0 or 1')
end

if mod(trialsInBlock,8) > 0
    error('Trial no. cannot be divided by 8.')
end

% CREATE TRIAL LIST: DETERMINE no. of CONTRASTS and assign to INTERVALS
if data.isExperiment == 0
    % 16 practice trials with FIXED number and order of target contrasts: 
    % 10 easy trials (contrast 1) and 2 trials for each remaining contrast
    % Note: the first 2 trials are for learning the procedure only.
    firstSecond = repmat(1:2,2,4);
    firstSecond = firstSecond(:);  
    cs          = contrastSteps; % rename for brevity
    list_cs     = [repmat(cs(4),1,10), repmat(cs(3),1,2), repmat(cs(2),1,2) repmat(cs(1),1,2)]';
    list        = [firstSecond list_cs];
    conds_B     = list(1:2:end,:);
    conds_Y     = list(2:2:end,:);
elseif data.isExperiment == 1
    % firstSecond: oddball to appear in 1st and 2nd interval equally often
    firstSecond   = [ones(trialsInBlock/2,1); 2*ones(trialsInBlock/2,1)];
    % contConds = contrast conditions (4 different contrasts are used)
    contConds     = repmat(contrastSteps,trialsInBlock/4,1);
    % which interval + which contrast (matrix with 2 columns)
    conds_B      = [firstSecond contConds];
    conds_Y      = [firstSecond contConds];
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Cogent configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

config_display(mode, resolution, background, foreground, fontname, fontsizebig, nbuffers, number_of_bits, scale);
config_keyboard;
config_sound;
start_cogent;

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%% Participant instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% see separate script practice_instr

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%% Matlab sanity checks (dummy calls) %%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
KbCheck(-1);
WaitSecs(0.1);
GetSecs;