% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (C) OMG Plc 2009.
% All rights reserved.  This software is protected by copyright
% law and international treaties.  No part of this software / document
% may be reproduced or distributed in any form or by any means,
% whether transiently or incidentally to some other use of this software,
% without the written permission of the copyright owner.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part of the Vicon DataStream SDK for MATLAB.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close all
Screen('CloseAll');

%% ADD PATH where the Vicon SDK is installed
addpath('C:\Users\MMemeo\Desktop\RealTime\6. parallel_port\6. parallel_port')
addpath('D:\ViconDB\Becchio\ComitatoScientifico\demos\Size_realTime\')
sdk_path = 'C:\Users\MMemeo\Documents\Commonscript\realTime\MATLAB';
addpath(sdk_path)
startStop_path = '\\geo.humanoids.iit.it\repository\groups\cmon_lab\MotorRegularities\Script\ViconStartStop';
addpath(startStop_path)

%% FLAG set
FLAG.local_connection = true;
flag_vstart = true;

%% INITIALIZE
%create an instance of the io64 object
ioObj = io64;
%
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
%
% if status = 0, you are now ready to write and read to a hardware port
% let's try sending the value=1 to the parallel printer's output port (LPT1)
address = hex2dec('D010');          %standard LPT1 output port address
data_out=1;                                 %sample data value
io64(ioObj,address,data_out);   %output command
%
% now, let's read that value back into MATLAB
data_in=io64(ioObj,address);

%% Connect to the client.
if FLAG.local_connection
    hostname = 'localhost:801';
else
    hostname = '192.168.1.4';
end
[MyClient, FLAG] = connectToClient(hostname);

% A dialog to stop the loop
MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );


%% INITIALIZING PARAMETERS
current_path = pwd;
x_high_threshold = 740;%650
x_low_threshold = 300;
aperture_threshold = 50;%65

% threshold for the start of the trial
x_start_high = 775;
x_start_low = 765;



%% SCREEN SETTINGS
% PsychDebugWindowConfiguration(0,0.6);
SCREEN.screenNumbers              = Screen('Screens');    % Screen Number Identification
SCREEN.screenID                   = max(SCREEN.screenNumbers);   % Select ID Screen
Screen('Preference', 'SkipSyncTests', 0);%it disables synchronization at the beginning of the script
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID ,[0 0 0],[1026 0 2045 764]);
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[1368 0 3283 1196]);
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[1366 0 3283 1196]);
[SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[-1907 129 -23 1185]);

Screen('TextFont',SCREEN.windowPtr, 'Courier New');
Screen('TextSize',SCREEN.windowPtr, 100);
Screen('TextStyle', SCREEN.windowPtr, 1+2);

text_piccolo = 'SMALL';
text_grande = 'LARGE';


%% DATASTREAM
Counter = 1;
t0 = [];


%%
try
    k = input('Enter enter');
    %Start the acquisition
    
    while ishandle( MessageBox )
        
        
        % Get a frame
        if FLAG.stampToScreen
            fprintf( 'Waiting for new frame...' );
        end
        while MyClient.GetFrame().Result.Value ~= Result.Success
            fprintf( '.' );
        end% while
        fprintf( '\n' );
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check the distance between index and thumb to trigger a audio file
        % Get the subject name
        SubjectIndex = 1;
        SubjectName = MyClient.GetSubjectName( SubjectIndex ).SubjectName;
        Output_GetFrameRate = MyClient.GetFrameRate().FrameRateHz;
        current = MyClient.GetFrameNumber().FrameNumber;
        
        if current > 0
            
            if flag_vstart
                io64(ioObj,address,0);
                flag_vstart = false;
            end
            % Get the marker name if it is not occluded
            %MarkerName = MyClient.GetMarkerName( SubjectName, MarkerIndex ).MarkerName;
            starting_frame(Counter) = MyClient.GetFrameNumber().FrameNumber;
            thumb_pos(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'thumb2' );
            index_pos(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'index2' );
            aperture(Counter) =  sqrt((thumb_pos(Counter).Translation(1) - index_pos(Counter).Translation(1))^2 +...
                (thumb_pos(Counter).Translation(2) - index_pos(Counter).Translation(2))^2 +...
                (thumb_pos(Counter).Translation(3) - index_pos(Counter).Translation(3))^2);
            
            if not(index_pos(Counter).Occluded)
                if index_pos(Counter).Translation(1)>=x_start_low && index_pos(Counter).Translation(1)<x_start_high
                    t0 = GetSecs();
                end
                if ~isempty(t0) && index_pos(Counter).Translation(1) <= x_high_threshold && index_pos(Counter).Translation(1)>= x_low_threshold && aperture(Counter) >= aperture_threshold
                    
                    t1 = GetSecs();
                    time_elapsed = 1000*(t1-t0);
                    
                    [nx, ny, textbounds] = DrawFormattedText(SCREEN.windowPtr,[text_grande '\n \n' num2str(time_elapsed) ' ms'], 'center', 'center',[255 255 255]);
                    Screen('Flip',SCREEN.windowPtr,[],0);
                    WaitSecs(0.005)
                    
                    % Stop the acquisition
                    io64(ioObj,address,0);
                    WaitSecs(0.005)
                    io64(ioObj,address,2);
                    WaitSecs(0.005)
                    io64(ioObj,address,1);
                    % Stop the acquisition
                    a = input('Press Enter to continue','s');
                    
                    Counter = Counter + 1;
                    flag_vstart = true;
                    
                elseif ~isempty(t0) && index_pos(Counter).Translation(1) <= x_high_threshold && index_pos(Counter).Translation(1)>= x_low_threshold && aperture(Counter) < aperture_threshold
                    
                    t1 = GetSecs();
                    time_elapsed = 1000*(t1-t0);
                    
                    [nx, ny, textbounds] = DrawFormattedText(SCREEN.windowPtr,[text_piccolo '\n \n' num2str(time_elapsed) ' ms'], 'center', 'center',[255 255 255]);
                    Screen('Flip',SCREEN.windowPtr,[],0);
                    WaitSecs(0.005)
                    
                    % Stop the acquisition
                    io64(ioObj,address,0);
                    WaitSecs(0.005)
                    io64(ioObj,address,2);
                    WaitSecs(0.005)
                    io64(ioObj,address,1);
                    % Stop the acquisition
                    a = input('Press Enter to continue','s');
                    Counter = Counter + 1;
                    flag_vstart = true;
                end
                %Empty screen
                DrawFormattedText(SCREEN.windowPtr,'', 'center', 'center',[255 255 255]);
                Screen('Flip',SCREEN.windowPtr,[],0);
            end
            
        end
    end
    
    % Disconnect and dispose
    Screen('CloseAll');
    MyClient.Disconnect();
    
    % Unload the SDK
    fprintf( 'Unloading SDK...' );
    Client.UnloadViconDataStreamSDK();
    fprintf( 'done\n' );
    
catch err
    Screen('CloseAll');
end

