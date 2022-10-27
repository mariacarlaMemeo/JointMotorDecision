%% PROSTHETICS: TEMPORAL COUPLING Experiments Script
% Temporal coupling experiment in which subject interacts with cubes at different distances.

clear all
close all

%% PATH
PathMatLabFiles = 'E:\PhantomLimb\DatiMatLab\PreTraining\';
path_excel_to_save = 'E:\PhantomLimb\Analisi\PreTraining\';

%%  Load .mat with subjects data
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

%% FLAG
FLAG.debug = true;

%% Start Paradigm

%stimuli
n_blocks    = 3;
n_trials    = 10;
n_training  = 0;


x = 1;

for blocks = 1:n_blocks
    
    for training = 1:n_training
        
        condition = 'NoObstacle';
        
        input(condition)
        
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
        C(x,:)          = condition;
        TP(x,:)         = {'P'};%'P' means 'practice'
        
        x = x + 1;
        
    end
    
    
    fprintf('Training is finished. \n','s')
    
    for trial = 1:n_trials
        condition = 'NoObstacle';
        
        fprintf('Trial: %1.0f\n', trial);
        input(condition);
      
        
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
        C(x,:)          = condition;
        TP(x,:)         = {'S'}; %'S' means 'sperimentale'
        x = x + 1;
        
    end
    
    for training = 1:n_training
        
        condition = 'YeObstacle';
        
        input(condition)
        
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
        C(x,:)          = condition;
        TP(x,:)         = {'P'};%'P' means 'practice'
        
        x = x + 1;
        
        input('change figure');
    end
    
    
    fprintf('Training is finished. \n','s')
    
    for trial = 1:n_trials
        condition = 'YeObstacle';
        
        fprintf('Trial: %1.0f\n', trial);
        input(condition);
      
        
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
        C(x,:)          = condition;
        TP(x,:)         = {'S'}; %'S' means 'sperimentale'
        x = x + 1;
        
    end
    
        fprintf([condition ' is finished start next condition \n','s'])
    
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

%% SAVE T DATA IN AN EXCEL FILES

% Save T data in the excel file of this paradigm in wich different sheets are different subjects
% xlsxFile = [path_excel_to_save '\Paradigmi\Temp_TC.xlsx'];
xlsxFile = [path_excel_to_save '\Paradigmi\NewTemporalCoupling.xlsx'];

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
    writetable(T,xlsxFile,'Sheet','TemporalCoupling');
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
save([PathID '\' id '_TC.mat'],'T')