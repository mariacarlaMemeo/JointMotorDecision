%% PROSTHETICS: Phantom Limb Body Landmark Location
% Subject estimate the position of his phantom wrist and tip of index finger (than estimate also wrist e tip for the intact limb).
clear all
close all
Screen('CloseAll'); % or 'sca'

%% PATH
PathMatLabFiles = 'E:\PhantomLimb\DatiMatLab\PreTraining\';
path_excel_to_save = 'E:\PhantomLimb\Analisi\PreTraining\';

%% Load .mat with subjects data
prompt = ('Subject number? (es. 1)\n--> '); %Subject number
id = ['S' num2str(input(prompt), '%03i'), '_1'];

load ([PathMatLabFiles id])

%% Data Subject from T

name                = T.Subject; name = [name '_1'];
age                 = T.Age;
sex                 = T.Sex;
AmputationYears     = T.AmputationYears;
group               = T.Group;
DayExperiemnt       = T.DayExperiemnt;

%% Start Paradigm

n_trials   = 1;
n_training = 1;
% Conditions
limbs       = {'phantom limb'};
rand_limbs  = Shuffle(limbs);
all_cond_pha       = {'tip of little' 'tip of index' 'tip of thumb' 'ulna' 'tip of stump' 'elbow'};
all_cond_intact    = {'tip of little' 'tip of index' 'tip of thumb' 'ulna' 'elbow'};
% all_trial   = repmat(all_cond,1,n_trials);
% rand_trial  = Shuffle(all_trial); %randomize all the conditions
% all_training    = repmat(all_cond,1,n_training);
% rand_training      = Shuffle(all_training);
x = 1;

%Creo un dispay per mostrarmi la condizione
[window, rect]=Screen('OpenWindow',0, [], [10 40 960 1060]);
Screen('TextFont',window, 'Calibri');
Screen('TextSize',window, 100);
Screen('TextStyle', window, 0);

for limb_condition = 1:length(rand_limbs)
    
    arm = rand_limbs(limb_condition);
    
    input(arm{:});
    
    if strcmp(arm, 'phantom limb')
        all_trial   = repmat(all_cond_pha,1,n_trials);
        rand_trial  = Shuffle(all_trial); %randomize all the conditions
        all_training    = repmat(all_cond_pha,1,n_training);
        rand_training   = Shuffle(all_training);
    elseif strcmp(arm, 'intact limb')
        all_trial   = repmat(all_cond_intact,1,n_trials);
        rand_trial  = Shuffle(all_trial); %randomize all the conditions
        all_training    = repmat(all_cond_intact,1,n_training);
        rand_training   = Shuffle(all_training);
    end
    
    for training = 1:length(all_training)
        
        condition = rand_training(training);
        %MatLab says the condition
        %Speak(condition{:});
        
        %Mostro la condizione sullo screen
        DrawFormattedText(window,(condition{:}),'center','center',[255 0 255]);
        Screen('Flip',window)
        
        
        input(condition{:});
        
        %Matlab send a trigger to Nexus that start to record
        %create an instance of the io64 object
        ioObj = io64;
        % initialize the interface to the inpoutx64 system driver
        status = io64(ioObj);
        % if status = 0, you are now ready to write and read to a hardware port
        % let's try sending the value=1 to the parallel printer's output port (LPT1)
        address = hex2dec('DFF8');          %standard LPT1 output port address
        data_out = 1;                         %sample data value
        io64(ioObj,address,data_out);       %output command
        
        % now, let's read that value back into MATLAB
        data_in = io64(ioObj,address);
        WaitSecs(0.5);
        io64(ioObj,address,0);
        
        Speak('go'); %MatLab says go
        
        WaitSecs(0.5); %time of recording
        
        input('Stop');
        Speak('Stop');
        
        io64(ioObj,address,2);
        WaitSecs(0.5);
        io64(ioObj,address,0);
        
        WaitSecs(1);
        
        % Crate variable for T
        N(x,:)          = name;
        A(x,:)          = age;
        S(x,:)          = sex;
        AY(x,:)         = AmputationYears;
        G(x,:)          = group;
        DUP(x,:)        = DayExperiemnt;
        L(x,:)          = arm;
        C(x,:)          = condition;
        TP(x,:)          = {'P'};%'P' means 'pratica'
        
        x = x + 1;
    end
    
    fprintf('Training is finished. \n','s')
    
    for trial = 1:length(rand_trial)
        
        condition = rand_trial(trial);
        %MatLab says the condition
        %Speak(condition{:})
        fprintf('Trial: %1.0f\n', trial);
        %Mostro la condizione sullo screen
        DrawFormattedText(window,(condition{:}),'center','center',[255 0 255]);
        Screen('Flip',window)
        input(condition{:});
        
        
        %Matlab send a trigger to Nexus that start to record
        %create an instance of the io64 object
        ioObj = io64;
        % initialize the interface to the inpoutx64 system driver
        status = io64(ioObj);
        % if status = 0, you are now ready to write and read to a hardware port
        % let's try sending the value=1 to the parallel printer's output port (LPT1)
        address = hex2dec('DFF8');          %standard LPT1 output port address
        data_out = 1;                         %sample data value
        io64(ioObj,address,data_out);       %output command
        
        % now, let's read that value back into MATLAB
        data_in = io64(ioObj,address);
        WaitSecs(0.5);
        io64(ioObj,address,0);
        
        Speak('go'); %MatLab says go
        
        WaitSecs(1); %time of recording
        
        input('Stop');
        Speak('Stop');
        
        io64(ioObj,address,2);
        WaitSecs(0.5);
        io64(ioObj,address,0);
        
        WaitSecs(1);
        %
        % when finished with the io64 object it can be discarded via
        % 'clear all', 'clear mex', 'clear io64' or 'clear functions' command.
        
        % Crate variable for T
        N(x,:)          = name;
        A(x,:)          = age;
        S(x,:)          = sex;
        AY(x,:)         = AmputationYears;
        G(x,:)          = group;
        DUP(x,:)        = DayExperiemnt;
        L(x,:)          = arm;
        C(x,:)          = condition;
        TP(x,:)          = {'S'}; %'S' means 'sperimentale'
        
        x=x+1;
        
        input('go on');
    end
end

%% Create T table as empty (because is not possibile to update the data inside a table)

% N = T.Subject(2:trial,:);

T = cell2table({});


T.Subject           = N;
T.Age               = A;
T.Sex               = S;
T.AmputationYears   = AY;
T.Group             = G ;
T.DayExperiemnt     = DUP;
T.Limb              = L;
T.Condizione        = C;
T.TrainigExperiment = TP;
%% SAVE T DATA IN AN EXCEL FILES

% Save T data in the excel file of this paradigm in wich different sheets are different subjects
% xlsxFile = [path_excel_to_save '\Paradigmi\Temp_PEP.xlsx'];
xlsxFile = [path_excel_to_save '\Paradigmi\BodyLandmarkPhantom.xlsx'];%TAG=45

disp('writing file');
warning('off','MATLAB:xlswrite:AddSheet');

try
    writetable(T,xlsxFile,'Sheet',name)
    % erase the first 3 sheets created by default by excel
    RemoveSheet123(xlsxFile);
catch
    % The following function is to remove definitively the excel file
    system('taskkill /F /IM EXCEL.EXE');
    disp('failed to write xlsx for data');
    
end

fprintf(['\n the paradigm excel files for ' name  ' is done \n']);

% Save T data in the excel file of the subject in wich different sheets are
% different Paradigms
xlsxFile = [path_excel_to_save '\Soggetti\' name '.xlsx'];

disp('writing file');
warning('off','MATLAB:xlswrite:AddSheet');

try
    %     writetable(T,xlsxFile,'Sheet','PhaEstPas')
    writetable(T,xlsxFile,'Sheet','BodyLandmarkPhantom')%TAG=45
    % erase the first 3 sheets created by default by excel
    RemoveSheet123(xlsxFile);
catch
    % The following function is to remove definitively the excel file
    system('taskkill /F /IM EXCEL.EXE');
    disp('failed to write xlsx for data');
    
end

fprintf(['\n the Subject excel files for ' name  ' is done \n']);

%% Save T table
PathTableFiles = 'E:\PhantomLimb\DatiMatLab\PreTraining\Tables';
PathID = ([PathTableFiles '\' id]);
mkdir(PathID);
save([PathID '\' id '_BLPhantom.mat'],'T')
Screen('CloseAll'); % or 'sca'