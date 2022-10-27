% Read device (e.g. force plates, eye trackers) status, information and output.   

% Count the number of devices
  DeviceCount = MyClient.GetDeviceCount().DeviceCount;
  if FLAG.stampToScreen
    fprintf( '  Devices (%d):\n', DeviceCount );
  end
  for DeviceIndex = 1:DeviceCount
    if FLAG.stampToScreen
        fprintf( '    Device #%d:\n', DeviceIndex - 1 );
    end
    % Get the device name and type
    Output_GetDeviceName = MyClient.GetDeviceName( DeviceIndex );
    if FLAG.stampToScreen
        fprintf( '      Name: %s\n', Output_GetDeviceName.DeviceName );
        fprintf( '      Type: %s\n', Output_GetDeviceName.DeviceType.ToString() );
    end
    % Count the number of device outputs
    DeviceOutputCount = MyClient.GetDeviceOutputCount( Output_GetDeviceName.DeviceName ).DeviceOutputCount;
    if FLAG.stampToScreen
        fprintf( '      Device Outputs (%d):\n', DeviceOutputCount );
    end
    for DeviceOutputIndex = 1:DeviceOutputCount
      % Get the device output name and unit
      Output_GetDeviceOutputName = MyClient.GetDeviceOutputName( Output_GetDeviceName.DeviceName, DeviceOutputIndex );

      % Get the number of subsamples associated with this device.
      Output_GetDeviceOutputSubsamples = MyClient.GetDeviceOutputSubsamples( Output_GetDeviceName.DeviceName, Output_GetDeviceOutputName.DeviceOutputName );
      if FLAG.stampToScreen        
        fprintf( '      Device Output #%d:\n', DeviceOutputIndex - 1 );

        fprintf( '      Samples (%d):\n', Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples );
      end

      for DeviceOutputSubsample = 1:Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples
        fprintf( '        Sample #%d:\n', DeviceOutputSubsample - 1 );
        % Get the device output value
        Output_GetDeviceOutputValue = MyClient.GetDeviceOutputValue( Output_GetDeviceName.DeviceName, Output_GetDeviceOutputName.DeviceOutputName, DeviceOutputSubsample );
        if FLAG.stampToScreen
            fprintf( '          ''%s'' %g %s %s\n',                                    ...
                               Output_GetDeviceOutputName.DeviceOutputName,            ...
                               Output_GetDeviceOutputValue.Value,                      ...
                               Output_GetDeviceOutputName.DeviceOutputUnit.ToString(), ...
                               AdaptBool( Output_GetDeviceOutputValue.Occluded ) );
        end
      end% DeviceOutputSubsample
    end% DeviceOutputIndex
    
  end% DeviceIndex
    % Count the number of force plates
  ForcePlateCount = MyClient.GetForcePlateCount().ForcePlateCount;
  if FLAG.stampToScreen
    fprintf( '  Force Plates: (%d)\n', ForcePlateCount );
  end
  for ForcePlateIndex = 1:ForcePlateCount
    if FLAG.stampToScreen
      fprintf( '    Force Plate #%d:\n', ForcePlateIndex - 1 );
    end
    % Get the number of subsamples associated with this device.
    Output_GetForcePlateSubsamples = MyClient.GetForcePlateSubsamples( ForcePlateIndex );
    if FLAG.stampToScreen
        fprintf( '    Samples (%d):\n', Output_GetForcePlateSubsamples.ForcePlateSubsamples );
    end
    for ForcePlateSubsample = 1:Output_GetForcePlateSubsamples.ForcePlateSubsamples
      % Output all the subsamples.
      if FLAG.stampToScreen
        fprintf( '      Sample #%d:\n', ForcePlateSubsample - 1 );
      end
      Output_GetGlobalForceVector = MyClient.GetGlobalForceVector( ForcePlateIndex, ForcePlateSubsample );
      if FLAG.stampToScreen
          fprintf( '      Force (%g, %g, %g)\n',                           ...
                             Output_GetGlobalForceVector.ForceVector( 1 ), ...
                             Output_GetGlobalForceVector.ForceVector( 2 ), ...
                             Output_GetGlobalForceVector.ForceVector( 3 ) );
      end
      Output_GetGlobalMomentVector = MyClient.GetGlobalMomentVector( ForcePlateIndex, ForcePlateSubsample );
      if FLAG.stampToScreen
          fprintf( '      Moment (%g, %g, %g)\n',                            ...
                             Output_GetGlobalMomentVector.MomentVector( 1 ), ...
                             Output_GetGlobalMomentVector.MomentVector( 2 ), ...
                             Output_GetGlobalMomentVector.MomentVector( 3 ) );
      end
      Output_GetGlobalCentreOfPressure = MyClient.GetGlobalCentreOfPressure( ForcePlateIndex, ForcePlateSubsample );
      if FLAG.stampToScreen
          fprintf( '      CoP (%g, %g, %g)\n',                                       ...
                             Output_GetGlobalCentreOfPressure.CentreOfPressure( 1 ), ...
                             Output_GetGlobalCentreOfPressure.CentreOfPressure( 2 ), ...
                             Output_GetGlobalCentreOfPressure.CentreOfPressure( 3 ) );    
      end
    end% ForcePlateSubsample                     
  end% ForcePlateIndex
  
  % Count the number of eye trackers
  EyeTrackerCount = MyClient.GetEyeTrackerCount().EyeTrackerCount;
  if FLAG.stampToScreen
    fprintf( '  Eye Trackers: (%d)\n', EyeTrackerCount );
  end
  for EyeTrackerIndex = 1:EyeTrackerCount
    if FLAG.stampToScreen
      fprintf( '    Eye Tracker #%d:\n', EyeTrackerIndex - 1 );
    end
    Output_GetEyeTrackerGlobalPosition = MyClient.GetEyeTrackerGlobalPosition( EyeTrackerIndex );
    if FLAG.stampToScreen
        fprintf( '      Position (%g, %g, %g) %s\n',                       ...
                     Output_GetEyeTrackerGlobalPosition.Position( 1 ), ...
                     Output_GetEyeTrackerGlobalPosition.Position( 2 ), ...
                     Output_GetEyeTrackerGlobalPosition.Position( 3 ), ...
                     AdaptBool( Output_GetEyeTrackerGlobalPosition.Occluded ) );
    end
    Output_GetEyeTrackerGlobalGazeVector = MyClient.GetEyeTrackerGlobalGazeVector( EyeTrackerIndex );
    if FLAG.stampToScreen
        fprintf( '      Gaze (%g, %g, %g) %s\n',                               ...
                         Output_GetEyeTrackerGlobalGazeVector.GazeVector( 1 ), ...
                         Output_GetEyeTrackerGlobalGazeVector.GazeVector( 2 ), ...
                         Output_GetEyeTrackerGlobalGazeVector.GazeVector( 3 ), ... 
                         AdaptBool( Output_GetEyeTrackerGlobalGazeVector.Occluded ) );
    end
  end% EyeTrackerIndex  
