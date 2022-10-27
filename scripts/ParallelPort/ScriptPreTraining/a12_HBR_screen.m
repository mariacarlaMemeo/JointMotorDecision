%% PROSTHETICS: HAND BLINK REFLEX Script
%Per questo esperimento bisogna connettere i BNC in questo modo:
% BNC 1: Rec start Vicon
% BNC 2: Rec Stop Vicon
% BNC 3: Trigger in Digitimer
% BNC 8: connettore BNC a porta vicon per vedere il trigger su nexus
clear all
close all
%set figure
set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultFigureWindowStyle','docked');
%% PATH
PathMatLabFiles = 'E:\PhantomLimb\DatiMatLab\PreTraining\';
path_excel_to_save = 'E:\PhantomLimb\Analisi\PreTraining\';
addpath('E:\PhantomLimb\Script_Paradigms\CommonScript')
addpath('E:\PhantomLimb\Script_Paradigms\CommonScript\RealTime')
addpath('C:\Program Files\Vicon\DataStream SDK\Win64\MATLAB')
%%  Load .mat with subjects data
prompt = ('Subject number? (es. 1)\n--> '); %Subject number
id = ['S' num2str(input(prompt), '%03i'), '_1'];

load ([PathMatLabFiles id])

%% initialize variable
counterStimuli = 0;
cutoffFrequency = 7;
%% Data Subject from T

name                = T.Subject; name = [name '_1'];
age                 = T.Age;
sex                 = T.Sex;
AmputationYears     = T.AmputationYears;
group               = T.Group;
DayExperiemnt       = T.DayExperiemnt;

%% FLAG
FLAG.debug = true;
FLAG.RealTime = true;
FLAG.thresholdCheck = true;

%% Find blink threshold

if FLAG.thresholdCheck
    
    % FLAG set
    FLAG.local_connection = true;
    flag_vstart = true;
    
    % Connect to the client.
    if FLAG.local_connection
        hostname = 'localhost:801';
    else
        hostname = '192.168.1.4';
    end
    [MyClient] = connectToClient(hostname);
    
    % Find blink threshold
    
    [threshold_RT_baseline, eye_baseline, trigger] = FYT(2, MyClient);
    eye_baseline = abs(eye_baseline);
    %eye_baseline_filtered = filter_lowpass(eye_baseline, cutoffFrequency);
    input(['soglia di baseline trovata: ', num2str(threshold_RT_baseline), ' proseguire!'])
    
    %Matlab send a trigger to Nexus that start to record
    %create an instance of the io64 object
    ioObj = io64;
    % initialize the interface to the inpoutx64 system driver
    status = io64(ioObj);
    % if status = 0, you are now ready to write and read to a hardware port
    % let's try sending the value=1 to the parallel printer's output port (LPT1)
    address = hex2dec('DFF8');          %standard LPT1 output port address
    data_out = 1;                         %sample data value
    
    io64(ioObj,address,0);       %output command
    
    % now, let's read that value back into MATLAB
    %         data_in = io64(ioObj,address);
    %         WaitSecs(0.5);
    %         io64(ioObj,address,0); %Trigger Go to Vicon
    trial_threshold = 0;
    
    while FLAG.thresholdCheck
        trial_threshold = trial_threshold + 1;
        
        %io64(ioObj,address,136); %Trigger to Digitimer (electric pulse)
        [threshold_RT, eye, trigger] = FYT_pulse(3, MyClient);
        
        threshold.eye_raw{trial_threshold} = eye';
        threshold.eye_abs{trial_threshold} = abs(eye)';
        trigger = trigger./2;
        threshold.trigger{trial_threshold} = trigger;
        WaitSecs(0.5);
        io64(ioObj,address,0);
        
        plot(abs(eye)); hold on; plot(abs(eye_baseline),'r'); plot(repmat(0.05, 1, length(eye_baseline)),'k')
        hold on; plot(trigger,'k'); xlim([0 300]); ylim([0 0.1])
        check = input('The threshold is right? [Enter] if Yes \n','s');
        hold off;
        
        if isempty(check)
            counterStimuli = counterStimuli + 1;
            input(['soglia corretta n= ', num2str(counterStimuli)])
            if counterStimuli == 3
                FLAG.thresholdCheck = false;
            end
        else
            input('Aumentare la soglia')
            counterStimuli = 0;
            hold off
        end
    end
    
    prompt = ('Insert threshould found (es. 1)\n--> '); %Subject number
    threshold_found = input(prompt);
    
end
%% Start Paradigm
n_trials   = 10;

% Conditions
limbs       = {'screen'};%{'intact' 'phantom'};
rand_limbs  = Shuffle(limbs);
all_cond    = {'screen_stump' 'screen_face'};
if length(all_cond) == 2
    all_trial   = repmat(all_cond,1,n_trials);
elseif length(all_cond) == 3
    all_trial   = [repmat(all_cond(1),1,n_trials) repmat(all_cond(2),1,n_trials) repmat(all_cond(3),1,n_trials)];
end

x = 1;

%Creo un dispay per mostrarmi la condizione
[window, rect]=Screen('OpenWindow',0, [], [10 40 960 1060]);
Screen('TextFont',window, 'Calibri');
Screen('TextSize',window, 100);
Screen('TextStyle', window, 0);

for limb = 1:length(limbs)
    
    arm = rand_limbs(limb);
    input(arm{:});
    
    for trial = 1:length(all_trial)
        
        fprintf('Trial: %1.0f\n', trial);
        condition = cell2mat(all_trial(trial));
        %Mostro la condizione sullo screen
        DrawFormattedText(window,(condition{:}),'center','center',[255 0 255]);
        Screen('Flip',window)
        input(condition);
        
        REC_HBR
        
        % Crate variable for T
        N(x,:)          = name;
        A(x,:)          = age;
        S(x,:)          = sex;
        AY(x,:)         = AmputationYears;
        G(x,:)          = group;
        DUP(x,:)        = DayExperiemnt;
        C(x,:)          = string(condition);
        TP(x,:)         = {'S'}; %'S' means 'sperimentale'
        if FLAG.thresholdCheck
            TF(x,:)         = threshold_found;
        end
        
        x = x + 1;
        WaitSecs(25)%time required to avoid any habituation effect
        if trial == n_trials
            fprintf([condition ' is finished start next condition \n','s'])
            change = ['\n change arm/head position to ' condition];
            input(change);
        end
    end
end


%% Create T table as empty (because is not possibile to update the data inside a table)

T = cell2table({});


T.Subject           = N;
T.Age               = A;
T.Sex               = S;
T.AmputationYears   = AY;
T.Group             = G ;
T.DayExperiemnt     = DUP;
T.Condizione        = C;
T.TrainigExperiment = TP;
if FLAG.thresholdCheck
    T.ThresholdFound    = TF;
end

%% SAVE T DATA IN AN EXCEL FILES

% Save T data in the excel file of this paradigm in wich different sheets are different subjects
% xlsxFile = [path_excel_to_save '\Paradigmi\Temp_TC.xlsx'];
xlsxFile = [path_excel_to_save '\Paradigmi\HandBlinkReflex_Screen.xlsx'];

disp('writing file')
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

disp('writing file')
warning('off','MATLAB:xlswrite:AddSheet');

try
    %     writetable(T,xlsxFile,'Sheet','TemporalCoupling')
    writetable(T,xlsxFile,'Sheet','HandBlinkReflex_Screen');
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
save([PathID '\' id '_HBR_Screen.mat'],'T', 'threshold')
Screen('CloseAll'); % or 'sca'

%% Disconnect SDK Real Time
if FLAG.thresholdCheck
    % Disconnect and dispose
    MyClient.Disconnect();
    
    % Unload the SDK
    fprintf( 'Unloading SDK...' );
    Client.UnloadViconDataStreamSDK();
    fprintf( 'done\n' );
end