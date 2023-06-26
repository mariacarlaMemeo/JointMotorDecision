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

%% FLAG set
FLAG.local_connection = true;

%% Connect to the client.
if FLAG.local_connection
    hostname = 'localhost:801';
else
    hostname = '192.168.1.4';
end
[MyClient, FLAG] = connectToClient(hostname);

% A dialog to stop the loop
MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );

%% ADD PATH where the Vicon SDK is installed
sdk_path = 'C:\Users\MMemeo\Documents\Commonscript\realTime\MATLAB';
addpath(sdk_path)

%% INITIALIZING PARAMETERS
current_path = pwd;
small_path   = [current_path '\demo_realTime\small_Marco.wav'];
large_path   = [current_path '\demo_realTime\large_Marco.wav'];
again_path   = [current_path '\demo_realTime\again.wav'];

[y_small,f_small]=audioread(small_path);
% f_small = 1.5
[y_large,f_large]=audioread(large_path);

[y_again,f_again]=audioread(again_path);


x_high_threshold = 650;
x_low_threshold = 620;

aperture_threshold = 65;

%% DATASTREAM
Counter = 1;
trial = 1;
% Loop until the message box is dismissed
while ishandle( MessageBox )
    drawnow;
    Counter = Counter + 1;
    
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
    % Get the marker name if it is not occluded
    %MarkerName = MyClient.GetMarkerName( SubjectName, MarkerIndex ).MarkerName;
    if Counter >= 3
        thumb_pos(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'thumb2' );
        index_pos(Counter) = MyClient.GetMarkerGlobalTranslation( SubjectName, 'index2' );
        aperture(Counter) =  sqrt((thumb_pos(Counter).Translation(1) - index_pos(Counter).Translation(1))^2 +...
            (thumb_pos(Counter).Translation(2) - index_pos(Counter).Translation(2))^2 +...
            (thumb_pos(Counter).Translation(3) - index_pos(Counter).Translation(3))^2);
        % fprintf( 'Aperture[mm]: %s\n', aperture );
        
        if not(index_pos(Counter).Occluded) && not(thumb_pos(Counter).Occluded)
            if index_pos(Counter).Translation(1) <= x_high_threshold && index_pos(Counter).Translation(1)>= x_low_threshold && aperture(Counter) >= aperture_threshold
                %                 audioplayer(y_large,f_large)
                sound(y_large,f_large)
                fprintf( 'Aperture[mm]: %s\n', aperture )
                a = input('Press Enter to continue');
                % The 'break' command was added in order to stop the while loop. We removed it to keep the acquisition continuous.
                % break
            elseif index_pos(Counter).Translation(1) <= x_high_threshold && index_pos(Counter).Translation(1)>= x_low_threshold && aperture(Counter) <= aperture_threshold
                trial = trial + 1;
                %                 audioplayer(y_small,f_small)
                sound(y_small,f_small)
                fprintf( 'Aperture[mm]: %s\n', aperture )
                a = input('Press Enter to continue');
                % The 'break' command was added in order to stop the while loop. We removed it to keep the acquisition continuous.
                % break
            elseif index_pos(Counter).Translation(1) < x_low_threshold
                trial = trial + 1;
                fprintf( 'Aperture[mm]: %s\n', aperture )
                                
                sound(y_again,f_again)
                a = input('Press Enter to continue');
            end
        end
    end
    
    if FLAG.showPlot
        figure(1)
        plot(aperture);
        hold on
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if FLAG.EnableHapticFeedbackTest
        if mod( Counter,2 ) == 0
            for i = 1:length( FLAG.HapticOnList )
                DeviceName = FLAG.HapticOnList{i};
                Output_GetApexFeedback = MyClient.SetApexDeviceFeedback( DeviceName, true );
                if Output_GetApexFeedback.Result.Value == Result.Success
                    fprintf( 'Turn haptic feedback on for device: %s\n', DeviceName );
                elseif Output_GetApexFeedback.Result.Value == Result.InvalidDeviceName
                    fprintf( 'Device doesn''t exist: %s\n', DeviceName );
                end
            end
        end
        if mod( Counter, 20 ) == 0
            for i = 1:length( FLAG.HapticOnList )
                DeviceName = FLAG.HapticOnList{i};
                Output_GetApexFeedback = MyClient.SetApexDeviceFeedback( DeviceName, false );
                if Output_GetApexFeedback.Result.Value == Result.Success
                    fprintf( 'Turn haptic feedback on for device: %s\n', DeviceName );
                end
            end
        end
    end
    
    
    % Get the frame number
    Output_GetFrameNumber = MyClient.GetFrameNumber();
    n_frame(Counter) = Output_GetFrameNumber.FrameNumber;
    % Get the frame rate
    Output_GetFrameRate = MyClient.GetFrameRate();
    for FrameRateIndex = 1:MyClient.GetFrameRateCount().Count
        FrameRateName  = MyClient.GetFrameRateName( FrameRateIndex ).Name;
        FrameRateValue = MyClient.GetFrameRateValue( FrameRateName ).Value;
        if FLAG.stampToScreen
            fprintf( '%s: %gHz\n', FrameRateName, FrameRateValue );
        end
    end% for
    
    % Get the timecode
    Output_GetTimecode = MyClient.GetTimecode();
    
    % Get the latency
    if FLAG.stampToScreen
        fprintf( 'Frame Number: %d\n', Output_GetFrameNumber.FrameNumber );
        fprintf( 'Frame rate: %g\n', Output_GetFrameRate.FrameRateHz );
        fprintf( '\n' );
        fprintf( 'Timecode: %dh %dm %ds %df %dsf %s %d %d %d\n\n',    ...
            Output_GetTimecode.Hours,                  ...
            Output_GetTimecode.Minutes,                ...
            Output_GetTimecode.Seconds,                ...
            Output_GetTimecode.Frames,                 ...
            Output_GetTimecode.SubFrame,               ...
            AdaptBool( Output_GetTimecode.FieldFlag ), ...
            Output_GetTimecode.Standard.Value,         ...
            Output_GetTimecode.SubFramesPerFrame,      ...
            Output_GetTimecode.UserBits );
        fprintf( 'Latency: %gs\n', MyClient.GetLatencyTotal().Total );
    end
    
    for LatencySampleIndex = 1:MyClient.GetLatencySampleCount().Count
        SampleName  = MyClient.GetLatencySampleName( LatencySampleIndex ).Name;
        SampleValue = MyClient.GetLatencySampleValue( SampleName ).Value;
        if FLAG.stampToScreen
            fprintf( '  %s %gs\n', SampleName, SampleValue );
        end
    end% for
    fprintf( '\n' );
    
    %% Details about all the subjects present in the Nexus session.
    % Count the number of subjects
    SubjectCount = MyClient.GetSubjectCount().SubjectCount;
    if FLAG.stampToScreen
        fprintf( 'Subjects (%d):\n', SubjectCount );
    end
    % For each subject it details the name, the name and number of segments, the classification in parent and child segment
    for SubjectIndex = 1:SubjectCount
        if FLAG.stampToScreen
            fprintf( '  Subject #%d\n', SubjectIndex - 1 );
        end
        % Get the subject name
        SubjectName = MyClient.GetSubjectName( SubjectIndex ).SubjectName;
        if FLAG.stampToScreen
            fprintf( '    Name: %s\n', SubjectName );
        end
        
        % Get the root segment
        RootSegment = MyClient.GetSubjectRootSegmentName( SubjectName ).SegmentName;
        if FLAG.stampToScreen
            fprintf( '    Root Segment: %s\n', RootSegment );
        end
        
        % Count the number of segments
        SegmentCount = MyClient.GetSegmentCount( SubjectName ).SegmentCount;
        if FLAG.stampToScreen
            fprintf( '    Segments (%d):\n', SegmentCount );
        end
        for SegmentIndex = 1:SegmentCount
            if FLAG.stampToScreen
                fprintf( '      Segment #%d\n', SegmentIndex - 1 );
            end
            
            % Get the segment name
            SegmentName = MyClient.GetSegmentName( SubjectName, SegmentIndex ).SegmentName;
            if FLAG.stampToScreen
                fprintf( '        Name: %s\n', SegmentName );
            end
            
            % Get the segment parent
            SegmentParentName = MyClient.GetSegmentParentName( SubjectName, SegmentName ).SegmentName;
            if ~isempty(SegmentParentName) && FLAG.stampToScreen
                fprintf( '        Parent: %s\n',  SegmentParentName );
            end
            % Get the segment's children
            ChildCount = MyClient.GetSegmentChildCount( SubjectName, SegmentName ).SegmentCount;
            if ChildCount && FLAG.stampToScreen
                fprintf( '     Children (%d):\n', ChildCount );
            end
            for ChildIndex = 1:ChildCount
                ChildName = MyClient.GetSegmentChildName( SubjectName, SegmentName, ChildIndex ).SegmentName;
                fprintf( '       %s\n', ChildName );
            end% for
            
            % Get the static segment translation
            Output_GetSegmentStaticTranslation = MyClient.GetSegmentStaticTranslation( SubjectName, SegmentName );
            % Get the static segment rotation in helical co-ordinates
            Output_GetSegmentStaticRotationHelical = MyClient.GetSegmentStaticRotationHelical( SubjectName, SegmentName );
            % Get the static segment rotation as a matrix
            Output_GetSegmentStaticRotationMatrix = MyClient.GetSegmentStaticRotationMatrix( SubjectName, SegmentName );
            % Get the static segment rotation in quaternion co-ordinates
            Output_GetSegmentStaticRotationQuaternion = MyClient.GetSegmentStaticRotationQuaternion( SubjectName, SegmentName );
            % Get the static segment rotation in EulerXYZ co-ordinates
            Output_GetSegmentStaticRotationEulerXYZ = MyClient.GetSegmentStaticRotationEulerXYZ( SubjectName, SegmentName );
            % Get the global segment translation
            Output_GetSegmentGlobalTranslation = MyClient.GetSegmentGlobalTranslation( SubjectName, SegmentName );
            % Get the global segment rotation in helical co-ordinates
            Output_GetSegmentGlobalRotationHelical = MyClient.GetSegmentGlobalRotationHelical( SubjectName, SegmentName );
            % Get the global segment rotation as a matrix
            Output_GetSegmentGlobalRotationMatrix = MyClient.GetSegmentGlobalRotationMatrix( SubjectName, SegmentName );
            % Get the global segment rotation in quaternion co-ordinates
            Output_GetSegmentGlobalRotationQuaternion = MyClient.GetSegmentGlobalRotationQuaternion( SubjectName, SegmentName );
            % Get the global segment rotation in EulerXYZ co-ordinates
            Output_GetSegmentGlobalRotationEulerXYZ = MyClient.GetSegmentGlobalRotationEulerXYZ( SubjectName, SegmentName );
            
            
            % Get the local segment translation
            Output_GetSegmentLocalTranslation = MyClient.GetSegmentLocalTranslation( SubjectName, SegmentName );
            % Get the local segment rotation in helical co-ordinates
            Output_GetSegmentLocalRotationHelical = MyClient.GetSegmentLocalRotationHelical( SubjectName, SegmentName );
            % Get the local segment rotation as a matrix
            Output_GetSegmentLocalRotationMatrix = MyClient.GetSegmentLocalRotationMatrix( SubjectName, SegmentName );
            % Get the local segment rotation in quaternion co-ordinates
            Output_GetSegmentLocalRotationQuaternion = MyClient.GetSegmentLocalRotationQuaternion( SubjectName, SegmentName );
            % Get the local segment rotation in EulerXYZ co-ordinates
            Output_GetSegmentLocalRotationEulerXYZ = MyClient.GetSegmentLocalRotationEulerXYZ( SubjectName, SegmentName );
            
            segm_x = Output_GetSegmentStaticTranslation.Translation(1);
            segm_y = Output_GetSegmentStaticTranslation.Translation(2);
            segm_z = Output_GetSegmentStaticTranslation.Translation(3);
            
            if FLAG.showPlot
                figure(1)
                plot3(segm_x, segm_y, segm_z,'ro','MarkerSize',5); title('trial')
                grid on; hold on;
            end
            
            if FLAG.stampToScreen
                fprintf( '        Static Translation: (%g, %g, %g)\n',                  ...
                    Output_GetSegmentStaticTranslation.Translation( 1 ), ...
                    Output_GetSegmentStaticTranslation.Translation( 2 ), ...
                    Output_GetSegmentStaticTranslation.Translation( 3 ) );
                fprintf( '        Static Rotation Helical: (%g, %g, %g)\n',              ...
                    Output_GetSegmentStaticRotationHelical.Rotation( 1 ), ...
                    Output_GetSegmentStaticRotationHelical.Rotation( 2 ), ...
                    Output_GetSegmentStaticRotationHelical.Rotation( 3 ) );
                fprintf( '        Static Rotation Matrix: (%g, %g, %g, %g, %g, %g, %g, %g, %g)\n', ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 1 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 2 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 3 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 4 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 5 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 6 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 7 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 8 ),            ...
                    Output_GetSegmentStaticRotationMatrix.Rotation( 9 ) );
                fprintf( '        Static Rotation Quaternion: (%g, %g, %g, %g)\n',          ...
                    Output_GetSegmentStaticRotationQuaternion.Rotation( 1 ), ...
                    Output_GetSegmentStaticRotationQuaternion.Rotation( 2 ), ...
                    Output_GetSegmentStaticRotationQuaternion.Rotation( 3 ), ...
                    Output_GetSegmentStaticRotationQuaternion.Rotation( 4 ) );
                fprintf( '        Static Rotation EulerXYZ: (%g, %g, %g)\n',               ...
                    Output_GetSegmentStaticRotationEulerXYZ.Rotation( 1 ),  ...
                    Output_GetSegmentStaticRotationEulerXYZ.Rotation( 2 ),  ...
                    Output_GetSegmentStaticRotationEulerXYZ.Rotation( 3 ) );
                fprintf( '        Global Translation: (%g, %g, %g) %s\n',               ...
                    Output_GetSegmentGlobalTranslation.Translation( 1 ), ...
                    Output_GetSegmentGlobalTranslation.Translation( 2 ), ...
                    Output_GetSegmentGlobalTranslation.Translation( 3 ), ...
                    AdaptBool( Output_GetSegmentGlobalTranslation.Occluded ) );
                fprintf( '        Global Rotation Helical: (%g, %g, %g) %s\n',           ...
                    Output_GetSegmentGlobalRotationHelical.Rotation( 1 ), ...
                    Output_GetSegmentGlobalRotationHelical.Rotation( 2 ), ...
                    Output_GetSegmentGlobalRotationHelical.Rotation( 3 ), ...
                    AdaptBool( Output_GetSegmentGlobalRotationHelical.Occluded ) );
                fprintf( '        Global Rotation Matrix: (%g, %g, %g, %g, %g, %g, %g, %g, %g) %s\n', ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 1 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 2 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 3 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 4 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 5 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 6 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 7 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 8 ),               ...
                    Output_GetSegmentGlobalRotationMatrix.Rotation( 9 ),               ...
                    AdaptBool( Output_GetSegmentGlobalRotationMatrix.Occluded ) );
                fprintf( '        Global Rotation Quaternion: (%g, %g, %g, %g) %s\n',             ...
                    Output_GetSegmentGlobalRotationQuaternion.Rotation( 1 ),       ...
                    Output_GetSegmentGlobalRotationQuaternion.Rotation( 2 ),       ...
                    Output_GetSegmentGlobalRotationQuaternion.Rotation( 3 ),       ...
                    Output_GetSegmentGlobalRotationQuaternion.Rotation( 4 ),       ...
                    AdaptBool( Output_GetSegmentGlobalRotationQuaternion.Occluded ) );
                fprintf( '        Global Rotation EulerXYZ: (%g, %g, %g) %s\n',                 ...
                    Output_GetSegmentGlobalRotationEulerXYZ.Rotation( 1 ),       ...
                    Output_GetSegmentGlobalRotationEulerXYZ.Rotation( 2 ),       ...
                    Output_GetSegmentGlobalRotationEulerXYZ.Rotation( 3 ),       ...
                    AdaptBool( Output_GetSegmentGlobalRotationEulerXYZ.Occluded ) );
                fprintf( '        Local Translation: (%g, %g, %g) %s\n',               ...
                    Output_GetSegmentLocalTranslation.Translation( 1 ), ...
                    Output_GetSegmentLocalTranslation.Translation( 2 ), ...
                    Output_GetSegmentLocalTranslation.Translation( 3 ), ...
                    AdaptBool( Output_GetSegmentLocalTranslation.Occluded ) );
                fprintf( '        Local Rotation Helical: (%g, %g, %g) %s\n',           ...
                    Output_GetSegmentLocalRotationHelical.Rotation( 1 ), ...
                    Output_GetSegmentLocalRotationHelical.Rotation( 2 ), ...
                    Output_GetSegmentLocalRotationHelical.Rotation( 3 ), ...
                    AdaptBool( Output_GetSegmentLocalRotationHelical.Occluded ) );
                fprintf( '        Local Rotation Matrix: (%g, %g, %g, %g, %g, %g, %g, %g, %g) %s\n', ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 1 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 2 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 3 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 4 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 5 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 6 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 7 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 8 ),               ...
                    Output_GetSegmentLocalRotationMatrix.Rotation( 9 ),               ...
                    AdaptBool( Output_GetSegmentLocalRotationMatrix.Occluded ) );
                fprintf( '        Local Rotation Quaternion: (%g, %g, %g, %g) %s\n',             ...
                    Output_GetSegmentLocalRotationQuaternion.Rotation( 1 ),       ...
                    Output_GetSegmentLocalRotationQuaternion.Rotation( 2 ),       ...
                    Output_GetSegmentLocalRotationQuaternion.Rotation( 3 ),       ...
                    Output_GetSegmentLocalRotationQuaternion.Rotation( 4 ),       ...
                    AdaptBool( Output_GetSegmentLocalRotationQuaternion.Occluded ) );
                fprintf( '        Local Rotation EulerXYZ: (%g, %g, %g) %s\n',                 ...
                    Output_GetSegmentLocalRotationEulerXYZ.Rotation( 1 ),       ...
                    Output_GetSegmentLocalRotationEulerXYZ.Rotation( 2 ),       ...
                    Output_GetSegmentLocalRotationEulerXYZ.Rotation( 3 ),       ...
                    AdaptBool( Output_GetSegmentLocalRotationEulerXYZ.Occluded ) );
            end
        end% SegmentIndex
        
        % Count the number of markers
        MarkerCount = MyClient.GetMarkerCount( SubjectName ).MarkerCount;
        if FLAG.stampToScreen
            fprintf( '    Markers (%d):\n', MarkerCount );
        end
        for MarkerIndex = 1:MarkerCount
            % Get the marker name
            MarkerName = MyClient.GetMarkerName( SubjectName, MarkerIndex ).MarkerName;
            % Get the marker parent
            MarkerParentName = MyClient.GetMarkerParentName( SubjectName, MarkerName ).SegmentName;
            % Get the global marker translation
            Output_GetMarkerGlobalTranslation = MyClient.GetMarkerGlobalTranslation( SubjectName, MarkerName );
            if FLAG.stampToScreen
                fprintf( '      Marker #%d: %s (%g, %g, %g) %s\n',                     ...
                    MarkerIndex - 1,                                    ...
                    MarkerName,                                         ...
                    Output_GetMarkerGlobalTranslation.Translation( 1 ), ...
                    Output_GetMarkerGlobalTranslation.Translation( 2 ), ...
                    Output_GetMarkerGlobalTranslation.Translation( 3 ), ...
                    AdaptBool( Output_GetMarkerGlobalTranslation.Occluded ) );
            end
            
            if FLAG.showPlot
                temp_x = Output_GetMarkerGlobalTranslation.Translation( 1 );
                temp_y = Output_GetMarkerGlobalTranslation.Translation( 2 );
                temp_z = Output_GetMarkerGlobalTranslation.Translation( 3 );
                
                figure(2)
                plot3(temp_x,temp_y,temp_z,'bo')
                grid on; axis square;
                hold on;
            end
            
            if FLAG.bReadRays
                % Get the ray contributions for this marker
                Output_GetMarkerRayContributionCount = MyClient.GetMarkerRayContributionCount( SubjectName, MarkerName );
                if( Output_GetMarkerRayContributionCount.Result.Value == Result.Success )
                    if FLAG.stampToScreen
                        fprintf('      Contributed to by: ');
                    end
                    MarkerRayContributionCount = Output_GetMarkerRayContributionCount.RayContributionsCount;
                    for ContributionIndex = 1: MarkerRayContributionCount
                        Output_GetMarkerRayContribution = MyClient.GetMarkerRayContribution(SubjectName, MarkerName, ContributionIndex);
                        if FLAG.stampToScreen
                            fprintf( '%d %d ', Output_GetMarkerRayContribution.CameraID, Output_GetMarkerRayContribution.CentroidIndex);
                        end
                    end
                    
                    fprintf('\n' );
                end
            end% bReadRays
        end% MarkerIndex
        
    end% SubjectIndex
    
    % Get the unlabeled markers
    UnlabeledMarkerCount = MyClient.GetUnlabeledMarkerCount().MarkerCount;
    if FLAG.stampToScreen
        fprintf( '    Unlabeled Markers (%d):\n', UnlabeledMarkerCount );
    end
    for UnlabeledMarkerIndex = 1:UnlabeledMarkerCount
        % Get the global marker translation
        Output_GetUnlabeledMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation( UnlabeledMarkerIndex );
        if FLAG.stampToScreen
            fprintf( '      Marker #%d: (%g, %g, %g)\n',                                    ...
                UnlabeledMarkerIndex - 1,                                    ...
                Output_GetUnlabeledMarkerGlobalTranslation.Translation( 1 ), ...
                Output_GetUnlabeledMarkerGlobalTranslation.Translation( 2 ), ...
                Output_GetUnlabeledMarkerGlobalTranslation.Translation( 3 ) );
        end
    end% UnlabeledMarkerIndex
    
    %% Device utility
    deviceUtility;
    
    %% Marker virtual representation through the cameras
    markerRepresentUtiliy;
    
end% while true

if FLAG.TransmitMulticast
    MyClient.StopTransmittingMulticast();
end

% Disconnect and dispose
MyClient.Disconnect();

% Unload the SDK
fprintf( 'Unloading SDK...' );
Client.UnloadViconDataStreamSDK();
fprintf( 'done\n' );
