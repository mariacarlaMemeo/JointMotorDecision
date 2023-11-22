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
%% ADD PATH where the Vicon SDK is installed
addpath('C:\Users\MMemeo\Desktop\RealTime\6. parallel_port\6. parallel_port')
sdk_path = 'C:\Users\MMemeo\Documents\Commonscript\realTime\MATLAB';
addpath(sdk_path)
startStop_path = '\\geo.humanoids.iit.it\repository\groups\cmon_lab\MotorRegularities\Script\ViconStartStop';
addpath(startStop_path)

addpath('C:\Program Files\Vicon\DataStream SDK\Win64\MATLAB') % SDK
%% FLAG set
FLAG.local_connection = true;
flag_vstart = true;

%% Connect to the client.
if FLAG.local_connection
    hostname = 'localhost:801';
else
    hostname = '192.168.1.4';
end
[MyClient, FLAG] = connectToClient(hostname);
FLAG.stampToScreen = false;
FLAG.showPlot = true;

% A dialog to stop the loop
MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );


%% INITIALIZING PARAMETERS
current_path = pwd;


%% SCREEN SETTINGS
% PsychDebugWindowConfiguration(0,0.6);
% SCREEN.screenNumbers              = Screen('Screens');    % Screen Number Identification
% SCREEN.screenID                   = max(SCREEN.screenNumbers);   % Select ID Screen
% Screen('Preference', 'SkipSyncTests', 0);%it disables synchronization at the beginning of the script
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID ,[0 0 0],[1026 0 2045 764]);
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[1368 0 3283 1196]);
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[1366 0 3283 1196]);
% [SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[-1907 129 -23 1185]);

% Screen('TextFont',SCREEN.windowPtr, 'Courier New');
% Screen('TextSize',SCREEN.windowPtr, 100);
% Screen('TextStyle', SCREEN.windowPtr, 1+2);

%new figure
f = figure();
f.OuterPosition = [-1919 121 1920 1080];%[-1927 -7 1936 1096];

%% DATASTREAM
Counter = 1;
average_th = 50;
t_switchCond = 15;
flag_incongruent = true;
error_stdAgent_C = [];
error_stdAgent_I = [];

%%
% Get initial time
t0 = GetSecs();

while ishandle( MessageBox )
    drawnow;
    
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
        
        % Get the marker name if it is not occluded
        %MarkerName = MyClient.GetMarkerName( SubjectName, MarkerIndex ).MarkerName;
        starting_frame(Counter) = MyClient.GetFrameNumber().FrameNumber;
        indexModel(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'TipIndexModel' );
        indexAgent(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'TipIndexAgent' );
        
        %Switch to the second subplot
        t1 = GetSecs() - t0;
        
        %CONGRUENT
        if not(indexAgent(Counter).Occluded)
            if t1 <= t_switchCond
                subplot(1,2,1);plot3(indexAgent(Counter).Translation(1),indexAgent(Counter).Translation(2),indexAgent(Counter).Translation(3),'bo');hold on;...
                    plot3(indexModel(Counter).Translation(1),indexModel(Counter).Translation(2),indexModel(Counter).Translation(3),'ro');tit=title('CONGRUENT ');tit.Color = [0 0 1];
                xlabel('x');ylabel('y');zlabel('z');axis([-1500 0 -2000 500 0 1800]);
                view(190,30);
                
                if Counter == average_th
                    listOfCoordinates = [indexAgent.Translation];
                    error_stdAgent_C = round(std(listOfCoordinates(3,:)),1);
                    indexModel = indexModel(Counter);
                    indexAgent = indexAgent(Counter);
                    Counter = 0;
                end
                if not(isempty(error_stdAgent_C))
                    t=title(['CONGRUENT ' num2str(error_stdAgent_C) ' mm']);t.Color = [0 0 1];
                end
            end
        end
        
        %INCONGRUENT
        if t1 > t_switchCond
            if flag_incongruent
                WaitSecs(1);
                k = input('Switch to the incongruent condition:');
                flag_incongruent = not(flag_incongruent);
            end
            
            subplot(1,2,2);plot3(indexAgent(Counter).Translation(1),indexAgent(Counter).Translation(2),indexAgent(Counter).Translation(3),'bo');hold on;...
                plot3(indexModel(Counter).Translation(1),indexModel(Counter).Translation(2),indexModel(Counter).Translation(3),'ro');tit1=title('INCONGRUENT ');tit1.Color = [0 0 1];
            xlabel('x');ylabel('y');zlabel('z');axis([-1500 0 -2000 500 0 1800]);
            view(190,30);
            
            if Counter == average_th
                listOfCoordinates = [indexAgent.Translation];
                error_stdAgent_I = round(std(listOfCoordinates(3,:)),1);
                indexModel = indexModel(Counter);
                indexAgent = indexAgent(Counter);
                Counter = 0;
            end
            if not(isempty(error_stdAgent_I))
                t=title(['INCONGRUENT ' num2str(error_stdAgent_I) ' mm']);t.Color = [0 0 1];
            end
        end
    end
    
    Counter = Counter + 1;
end
subplot(1,2,1);legend({'Agent','Model'});
subplot(1,2,2);legend({'Agent','Model'});

% Save the figure .fig
saveas(gcf,'DEMO_MotorContagion.fig');

% Disconnect and dispose
MyClient.Disconnect();

% Unload the SDK
fprintf( 'Unloading SDK...' );
Client.UnloadViconDataStreamSDK();
fprintf( 'done\n' );

