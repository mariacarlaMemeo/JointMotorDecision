% Marker virtual representation through the cameras
if FLAG.bReadCentroids
    CameraCount = MyClient.GetCameraCount().CameraCount;
    if FLAG.stampToScreen
        fprintf( 'Cameras(%d):\n', CameraCount);
    end
    for CameraIndex = 1:CameraCount
      if FLAG.stampToScreen
        fprintf('  Camera #%d:\n', CameraIndex - 1 );
      end
      CameraName = MyClient.GetCameraName( CameraIndex ).CameraName;
      if FLAG.stampToScreen
        fprintf ( '    Name: %s\n', CameraName );
      end
      CentroidCount = MyClient.GetCentroidCount( CameraName ).CentroidCount;
      if FLAG.stampToScreen
        fprintf ( '    Centroids(%d):\n', CentroidCount );
      end
      for CentroidIndex = 1:CentroidCount
        if FLAG.stampToScreen
          fprintf( '      Centroid #%d:\n', CentroidIndex - 1 );
        end
        Output_GetCentroidPosition = MyClient.GetCentroidPosition( CameraName, CentroidIndex );
        
        if FLAG.stampToScreen
            fprintf( '        Position: (%g, %g)\n', Output_GetCentroidPosition.CentroidPosition( 1 ), ...
                                                     Output_GetCentroidPosition.CentroidPosition( 2 ) );
            fprintf( '        Radius: (%g)\n', Output_GetCentroidPosition.Radius );
            %fprintf( '        Accuracy: (%g)\n', Output_GetCentroidPosition.Accuracy );
        end
      end% CentroidIndex
    end% CameraIndex
  end% bReadCentroids