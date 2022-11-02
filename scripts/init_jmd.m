% ------------------------- initialization ------------------------------ %


%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Ask user for input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Input group ID
while 1
    data.group.id = input('Please enter group ID (100-199): ');
    if data.group.id < 100 || data.group.id > 199
        disp('Wrong group ID - choose value between 100 and 199!');
    else
        break
    end
end

% Practice (run 0) or proper Experiment (run 1)
data.isExperiment      =  input ('Practice (0) or Experiment (1) = '); %

if (data.isExperiment)
    data.Agent1.name    =  input ('Agent1 Name: ','s'); % Subject's initials e.g. NK
    data.Agent1.gender  =  input ('Agent1 Biological sex = ','s');
    data.Agent1.age     =  input ('Agent1 Age = ');
    
    data.Agent2.name    =  input ('Agent2 Name: ','s');
    data.Agent2.gender  =  input ('Agent2 Biological sex = ','s');
    data.Agent2.age     =  input ('Agent2 Age = ');
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Create results file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Create result file using group ID and run number (practice/exp).
resultFileName      =  ['gID', int2str(data.group.id) '_run' int2str(data.isExperiment) , '_jomode.mat' ];

% directory where data should be saved
save_dir = fullfile(pwd,'data\');

% If file with same gID exists, prompt to choose a different file name.
if exist(resultFileName,'file')
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
% Note: home button A2 is different from all others (can be IN and OUT)
% It should be 0 or 8 (when not pressed; otherwise 4 or 12)
a2homebutton=io64(cogent.io.ioObj,add.inp_address_startSubj2)-4; 

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%% Define parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Display (or not) the accuracy feedback. 
% 1 = nothing
% 2 = only joint
% 3 = A1, A2, joint.
show_acc = 1;

% NOTE: we could get rid of the round-variable; it's always 1 now
% the only thing we vary is the number of blocks (within the "round")
rounds              =  1;

rng('shuffle') % initialize random number generator (generates a different sequence of random numbers after each call to rng)

% DISPLAY: show display 1 or 2 times (we always want 2)
data.display        =  2; % Display (1:single common;  2:dual separate')
% BASELINE GABOR CONTRAST
data.pedestal       =  0.1; % baseline contrast of non-target square-wave gratings
% NOISE
data.noise.A1       =  0; % Noise level for Agent1 between [0 - 1.0]
data.noise.A2       =  0; % Noise level for Agent2 between [0 - 1.0]
% data.task           =  2; % Task (1:first/second;  2:confidence rating')

% Set constrasts for oddball, for practice (run=1) and experiment (run=1)
% This contrast is then added to the baseline contrast (0.100)
if data.isExperiment == 0
    contrastSteps = [0.0350
        0.0700
        0.1000
        0.2000];
else
    contrastSteps = [0.0150
        0.0350
        0.0700
        0.1500];
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%% Trials, blocks, counterbalancing %%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

% Important: trialsInBlock must be a multiple of 8
% 'trialsInBlock' is the no. of trials PER agent per block
% total trial no. per block = 'trialsInBlock' * 2
% NOTE: rationale for trial no.: The minimum per agent is 8 (4 target
% contrasts, appearing either in 1st or 2nd interval). Each agent needs to
% experience each of these in the position as joint-decision-maker (and as
% the one who does not take the joint decision).
if data.isExperiment == 0 % practice
    trialsInBlock = 8*1; % no. of trials for each agent taking first decision
    blocksInRound = 1; % 1 block only
elseif data.isExperiment == 1 % experiment
    trialsInBlock = 8*5; % no. of trials for each agent taking first decision
    blocksInRound = 2;  % 2 blocks
else
    error('isExperiment should be 0 or 1')
end

if mod(trialsInBlock,8) > 0
    error('Trial no. cannot be divided by 8.')
end

% firstSecond: oddball to appear in 1st and 2nd interval equally often
firstSecond   = [ones(trialsInBlock/2,1); 2*ones(trialsInBlock/2,1)];
% contConds = contrast conditions (4 different contrasts are used)
contConds     = repmat(contrastSteps,trialsInBlock/4,1);
% which interval + which contrast (matrix with 2 columns)
conds_a1      = [firstSecond contConds];
conds_a2      = [firstSecond contConds];

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
exp_instr_0     = 'Welcome to the experiment!';
exp_instr_1     = 'You will perform a perceptual decision-making task.';
exp_instr_2     = 'You will see 2 stimulus intervals and decide which contained an oddball.';
exp_instr_3     = 'For the 1st interval, press the left button.';
exp_instr_4     = 'For the 2nd interval, press the right button.';
exp_instr_5     = 'Keep your finger on the start position until you decide.';
exp_instr_end   = 'This is the end of the experiment. Thank you!';

% exp_instr_1_0     = 'Thank you for taking part in this experiment.';
% exp_instr_1_1     = 'Please read the following instructions carefully.';
% exp_instr_1_2     = 'If you have any questions, please ask the experimenter.';
% 
% exp_instr_2_0     = 'Your task:';
% exp_instr_2_1     = 'Thank you for taking part in this experiment.';
% exp_instr_2_2     = 'Thank you for taking part in this experiment.';
% exp_instr_2_3     = 'Thank you for taking part in this experiment.';
% 
% 
% exp_instr_3     = 'For the 1st interval, press the left button.';
% exp_instr_4     = 'For the 2nd interval, press the right button.';
% exp_instr_5     = 'Keep your finger on the start position until you decide.';
% exp_instr_end   = 'This is the end of the experiment. Thank you!';



%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%% Matlab sanity checks (dummy calls) %%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
KbCheck(-1);
WaitSecs(0.1);
GetSecs;