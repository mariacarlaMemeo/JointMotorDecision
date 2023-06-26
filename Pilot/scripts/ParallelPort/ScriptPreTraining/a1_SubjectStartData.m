%% SUBJECT DATA
% Before start all the paradigm we record all the data of the subject and
% we save it on a 'T' table; than this table will be updated for record all
% the condition in the different paradimgs. After the last one paradigm 
% the table T will be saved in a general .xlsx file with one different 
% sheet for each subject.

clear all
close all
Screen('CloseAll'); % or 'sca'

%% PATH
PathMatLabFiles = 'E:\PhantomLimb\DatiMatLab\PreTraining\'; %da cambiare in base al path

%% Subject
% Subject data to insert 
prompt = ('Subject number? (es. 1)\n--> '); %Subject number
name = ['S' num2str(input(prompt), '%03i')];
prompt = ('Subject age? (es. 1)\n--> '); %Subject age
age = num2str(input(prompt));
prompt = ('Subject sex? (1 = M; 2 = F)\n--> '); %Subject sex
sex = num2str(input(prompt));
prompt = ('From how many years has been amputated? (es. 1)\n--> '); %Years after amputation
AmputationYears = num2str(input(prompt));
prompt = ('Is present the phantom limb (control means participants with no Phantom sensation)? (1 = Y; 2 = N)\n--> '); %
group = num2str(input(prompt));
prompt = ('Giorno sperimentazione (1 = Pre Training; 2 = Post Training)\n--> '); %Indicate whether the subject perfom the experiment with prosthesis the first or the second day
DayExperiment = num2str(input(prompt));
prompt = ('Quanto percepisce vivido e reale il movimento dell''arto gantasma? \n0 = Impossibile percepire alcun movimento; \n100 = il mvimento è percepito in modo vividamento uguale alla sensazione del movimento elicitato dalle dita della mano intatta\n--> '); 
VividnessPhaMovement = num2str(input(prompt));

prompt = ('Quanto è difficile muovere il pollice fantasma? (0 = facile; 100 = impossibile)\n--> '); 
DifficultyThumb = num2str(input(prompt));
prompt = ('Quanto è difficile muovere l''indice fantasma? (0 = facile; 100 = impossibile)\n--> '); 
DifficultyIndex = num2str(input(prompt));
prompt = ('Quanto è difficile muovere il medio fantasma? (0 = facile; 100 = impossibile)\n--> '); 
DifficultyMiddle = num2str(input(prompt));
prompt = ('Quanto è difficile muovere l''anulare fantasma? (0 = facile; 100 = impossibile)\n--> '); 
DifficultyRing = num2str(input(prompt));
prompt = ('Quanto è difficile muovere il mignolo fantasma? (0 = facile; 100 = impossibile)\n--> '); 
DifficultyLittle = num2str(input(prompt));

prompt = ('Qual''è la qualità e l''estensione di movimento per il pollice fantasma? (\n1 - posso fare tutti i movimenti esattamente come faccio con il dito intatto; \n2 - Quasi come per il dito intatto; \n3 - Molto meno rispetto al dito intatto (una flessione ed estensione solo parziale))\n--> '); 
QualityThumb = num2str(input(prompt));
prompt = ('Qual''è la qualità e l''estensione di movimento per l''indice fantasma? (\n1 - posso fare tutti i movimenti esattamente come faccio con il dito intatto; \n2 - Quasi come per il dito intatto; \n3 - Molto meno rispetto al dito intatto (una flessione ed estensione solo parziale))\n--> '); 
QualityIndex = num2str(input(prompt));
prompt = ('Qual''è la qualità e l''estensione di movimento per il medio fantasma? (\n1 - posso fare tutti i movimenti esattamente come faccio con il dito intatto; \n2 - Quasi come per il dito intatto; \n3 - Molto meno rispetto al dito intatto (una flessione ed estensione solo parziale))\n--> '); 
QualityMiddle = num2str(input(prompt));
prompt = ('Qual''è la qualità e l''estensione di movimento per l''anulare fantasma? (\n1 - posso fare tutti i movimenti esattamente come faccio con il dito intatto; \n2 - Quasi come per il dito intatto; \n3 - Molto meno rispetto al dito intatto (una flessione ed estensione solo parziale))\n--> '); 
QualityRing = num2str(input(prompt));
prompt = ('Qual''è la qualità e l''estensione di movimento per il mignolo fantasma? (\n1 - posso fare tutti i movimenti esattamente come faccio con il dito intatto; \n2 - Quasi come per il dito intatto; \n3 - Molto meno rispetto al dito intatto (una flessione ed estensione solo parziale))\n--> '); 
QualityLittle = num2str(input(prompt));



%% Create an empty table and put inside the data
T = cell2table({});

T.Subject               = name;
T.Age                   = age;
T.Sex                   = sex;
T.AmputationYears       = AmputationYears;
T.Group                 = group;
T.DayExperiemnt         = DayExperiment;
T.VividnessPhaMovement  = VividnessPhaMovement;
T.DifficultyThumb       = DifficultyThumb;
T.DifficultyIndex       = DifficultyIndex;
T.DifficultyMiddle      = DifficultyMiddle;
T.DifficultyRing        = DifficultyRing;
T.DifficultyLittle      = DifficultyLittle;
T.QualityThumb          = QualityThumb;
T.QualityIndex          = QualityIndex;
T.QualityMiddle         = QualityMiddle;
T.QualityRing           = QualityRing;
T.QualityLittle         = QualityLittle;


ifile = fullfile(PathMatLabFiles,[name '_' DayExperiment]);
save([ifile '.mat'],'T')


