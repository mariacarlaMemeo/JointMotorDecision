
prompt = ('Subject number? (es. 1)\n--> ');
name = ['S' num2str(input(prompt), '%03i')];
[num, txt, raw] = xlsread(['\\geo.humanoids.iit.it\repository\groups\cmon_lab\MotorRegularities\Script\Subjects\' name '.xlsx'],'D2:F241');


for trial = 1:240   
    
    vstart = ['C:\Users\Cavallo\Documents\ViconStartStop\RemoteStartStop.exe --start --name trial_' num2str(trial, '%03i') ' --notes ' num2str(raw{trial,2}) ' --description ' raw{trial,1} ' --path C:/Temp'];
    vstop = ['C:\Users\Cavallo\Documents\ViconStartStop\RemoteStartStop.exe --stop --name trial_' num2str(trial, '%03i') ' --path "C:/Temp"'];
    
    if max(trial == 1:20:240)
        warning(['INIZIO PRATICA con ID ' num2str(raw{trial,3}) ', condizione ' num2str(raw{trial,1})]);
    end
    
    if max(trial == 6:20:240)
        warning(['FINE PRATICA con ID ' num2str(raw{trial,3}) ', condizione ' num2str(raw{trial,1})]);
    end
	
    if trial == 61
        fprintf(['*** - INIZIO BLOCCO 2 - cambio compito! - condizione ' num2str(raw{trial,1}) '***\n']); 
    end
	
	if trial == 121
        fprintf(['*** - INIZIO BLOCCO 3 - cambio compito! - condizione ' num2str(raw{trial,1}) '***\n']); 
		fprintf('*** - PAUSA 2 MINUTI! - ***\n'); 
    end
	
	if trial == 181
        fprintf(['*** - INIZIO BLOCCO 4 - cambio compito! - condizione ' num2str(raw{trial,1}) '***\n']); 
    end
    
    prompt = (['Premere per iniziare trial n ' num2str(trial, '%03i')]);
    x = input(prompt);
    startVicon = system(vstart);  
    startSound = system(' start C:\Users\Cavallo\Documents\ViconStartStop\"750hz.wav"');
    pause(0.5)
    system('taskkill /IM wmplayer.exe');
    
    prompt = (['Premere per terminare trial n ' num2str(trial, '%03i')]);
    x = input(prompt);
    stopVicon = system(vstop);
    
end

