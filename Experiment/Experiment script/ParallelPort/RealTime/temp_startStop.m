
path_startStop = '\\geo.humanoids.iit.it\repository\groups\cmon_lab\MotorRegularities\Script\ViconStartStop';
trial = 2;

% vstart = [path_startStop '\RemoteStartStop.exe --start --name trial_' num2str(trial, '%03i') ' --notes ' num2str(raw{trial,2}) ' --description ' raw{trial,1} ' --path C:/Temp'];
% vstop = [path_startStop '\RemoteStartStop.exe --stop --name trial_' num2str(trial, '%03i') ' --path "C:/Temp"'];


vstart = [path_startStop '\RemoteStartStop.exe --start --name trial_' num2str(trial, '%03i') ' --notes ' 'bla' ' --description ' 'blabla' ' --path C:/Temp'];
vstop = [path_startStop '\RemoteStartStop.exe --stop --name trial_' num2str(trial, '%03i') ' --path "C:/Temp"'];


startVicon = system(vstart);

% stopVicon = system(vstop);

