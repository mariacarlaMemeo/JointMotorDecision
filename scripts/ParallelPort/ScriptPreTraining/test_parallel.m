%test parallel port

% addpath('C:\Users\memeo_vicon\Desktop\Script_Paradigms\ScriptFinale')

for a = 1:10
ioObj = io64;
    % initialize the interface to the inpoutx64 system driver
    status = io64(ioObj);
    % if status = 0, you are now ready to write and read to a hardware port
    % let's try sending the value=1 to the parallel printer's output port (LPT1)
    address = hex2dec('DFF8');          %standard LPT1 output port address
    data_out = 2;                         %sample data value
    io64(ioObj,address,data_out);       %output command
    
    % now, let's read that value back into MATLAB
    data_in = io64(ioObj,address);
    WaitSecs(0.5);
    
    io64(ioObj,address,16);
    WaitSecs(1);
    io64(ioObj,address,0);
    
    
    Speak('go'); %MatLab says go
    
    WaitSecs(1); %time of recording
    
    Speak('Stop');
    
    io64(ioObj,address,2);
    WaitSecs(0.5);
    io64(ioObj,address,0);
    
    WaitSecs(1);
end