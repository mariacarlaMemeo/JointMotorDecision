FLAG.Analyses = true;

WaitSecs(10);

for trial = 1:5

%Matlab send a trigger to Nexus that start to record
        %create an instance of the io64 object
        ioObj = io64;
        % initialize the interface to the inpoutx64 system driver
        status = io64(ioObj);
        % if status = 0, you are now ready to write and read to a hardware port
        % let's try sending the value=1 to the parallel printer's output port (LPT1)
        address = hex2dec('C010');          %standard LPT1 output port address
        data_out = 1;                         %sample data value
        
        io64(ioObj,address,data_out);       %output command

        % now, let's read that value back into MATLAB
        Speak(['trial,' num2str(trial) ', go']);
        WaitSecs(0.1);
        io64(ioObj,address,0);
        WaitSecs(0.1);
        io64(ioObj,address,1);

        WaitSecs(2);
        
        io64(ioObj,address,2);
        WaitSecs(0.1);
        io64(ioObj,address,0);
        WaitSecs(2);
        %
        Speak('Stop');
        
end

if FLAG.Analyses
    addpath('X:\Prosthetic_Hands\Script\Script_Analisi\paradigms')
   load('X:\Prosthetic_Hands\ViconData\Piloti\Pilots\Pilots\processed\P001\proveMic.mat');
   
   for trial = 1:length(session)

                sound       = session{trial}.analogs;
                sound_names = fieldnames(sound);
                
            occhio_name = char(sound_names(not(cellfun(@isempty,strfind(sound_names,'Voltage')))));
            sound = struct2mat(getfield(session{trial}.analogs,occhio_name(1,:)));
            soundALL(:,trial) = sound(1:44000);
            
   end
            
            for trial = 1:5
                figure
            subplot(4,1,1);plot(soundALL(:,trial));title('5cm');ylim([-0.5 0.5])
            subplot(4,1,2);plot(soundALL(:,trial+5));title('10cm');ylim([-0.5 0.5])
            subplot(4,1,3);plot(soundALL(:,trial+10));title('15cm');ylim([-0.5 0.5])
            subplot(4,1,4);plot(soundALL(:,trial+15));title('20cm');ylim([-0.5 0.5])
            end
        