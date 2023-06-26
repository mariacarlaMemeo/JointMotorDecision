function [clientObj, FLAG] = connectToClient(hostname,verbose)
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
% 
% It connects to the Client, Load the SDK, Set the streaming mode, Set the
% global axes, discover the Version number.
% INPUTS : It accepts as input the 'hostname' (string) and the 'verbose' flag
% (true/false). 
% OUTPUTS: The 'clientObj' is the object with all the parameters for the
% connection with the client. 'connectionStatus' is a flag (true/false) indicating if the connection has been established or not. 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Default program options
% Default program options
FLAG.connectionStatus = false;
FLAG.TransmitMulticast = false;
FLAG.EnableHapticFeedbackTest = false;
FLAG.HapticOnList = {'ViconAP_001';'ViconAP_002'};
FLAG.bReadCentroids = false;
FLAG.bReadRays = false;

if nargin == 0
    %Set default host name
    hostname = '192.168.1.4';
    verbose = false;
    FLAG.stampToScreen = false;
    FLAG.showPlot = false;
    
elseif nargin == 1
    %Set default plotting options
    FLAG.stampToScreen = false;
    FLAG.showPlot = false;
    verbose = true;
end

%EDIT 
FLAG.stampToScreen = false;
FLAG.showPlot = false;
%

%% Load the SDK
fprintf( 'Loading SDK...' );
Client.LoadViconDataStreamSDK();
fprintf( 'done\n' );

% Make a new client
clientObj = Client();

% Connect to a server
fprintf( 'Connecting to %s ...', hostname );
while ~clientObj.IsConnected().Connected
  % Direct connection
  clientObj.Connect( hostname );
  fprintf( '.' );
end
FLAG.connectionStatus = ~FLAG.connectionStatus;
fprintf( '\n' );


% Enable some different data types
clientObj.EnableSegmentData();
clientObj.EnableMarkerData();
clientObj.EnableUnlabeledMarkerData();
clientObj.EnableDeviceData();
if FLAG.bReadCentroids
  clientObj.EnableCentroidData();
end
if FLAG.bReadRays
  clientObj.EnableMarkerRayData();
end

if verbose
    fprintf( 'Segment Data Enabled: %s\n',          AdaptBool( clientObj.IsSegmentDataEnabled().Enabled ) );
    fprintf( 'Marker Data Enabled: %s\n',           AdaptBool( clientObj.IsMarkerDataEnabled().Enabled ) );
    fprintf( 'Unlabeled Marker Data Enabled: %s\n', AdaptBool( clientObj.IsUnlabeledMarkerDataEnabled().Enabled ) );
    fprintf( 'Device Data Enabled: %s\n',           AdaptBool( clientObj.IsDeviceDataEnabled().Enabled ) );
    fprintf( 'Centroid Data Enabled: %s\n',         AdaptBool( clientObj.IsCentroidDataEnabled().Enabled ) );
    fprintf( 'Marker Ray Data Enabled: %s\n',       AdaptBool( clientObj.IsMarkerRayDataEnabled().Enabled ) );
end

% Set the streaming mode
% There are three modes that the SDK can operate in. Each mode has a different impact on the Client, Server, and network resources used.
% - In "ServerPush" mode, the Server pushes every new frame of data over the network to the Client. The Server will try not to drop any frames. This results in the lowest latency we can achieve. If the Client is unable to read data at the rate it is being sent, then it is buffered, firstly in the Client, then on the TCP/IP connection, and then at the Server. Once all buffers have filled up then frames may be dropped at the Server and the performance of the Server may be affected. The GetFrame() method will return the most recently received frame if available, or block the calling thread if the most recently received frame has already been processed.
% - In "ClientPull" mode, the Client waits for a call to GetFrame(), and then request the latest frame of data from the Server. This increases latency, because we need to send a request over the network to the Server, the Server has to prepare the frame of data for the Client, and then we need to send the data back over the network. Network bandwidth is kept to a minimum, because the Server only sends what you need. We are very unlikely to fill up our buffers, and Server performance is unlikely to be affected. The GetFrame() method blocks the calling thread until the frame has been received.
% - "ClientPullPreFetch" is an enhancement to "ClientPull" mode. A thread in the SDK continuously and preemptively does a "ClientPull" on your behalf, storing the latest requested frame in memory. When you next call GetFrame(), the SDK returns the last requested frame which we had cached in memory. GetFrame() does not need to block the calling thread. As with normal "ClientPull", buffers are unlikely to fill up, Server performance is unlikely to be affected. Latency is slightly reduced, but network traffic may increase if we request frames on behalf of the Client which are never used.
% The stream defaults to "ClientPull" mode as this is considered the safest option. If performance is a problem, then try "ClientPullPreFetch" followed by "ServerPush".
clientObj.SetStreamMode( StreamMode.ClientPullPreFetch );

% Set the global up axis
clientObj.SetAxisMapping( Direction.Forward, ...
                         Direction.Left,    ...
                         Direction.Up );    % Z-up

Output_GetAxisMapping = clientObj.GetAxisMapping();
if verbose
    fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
                                               Output_GetAxisMapping.YAxis.ToString(), ...
                                               Output_GetAxisMapping.ZAxis.ToString() );
end

% Discover the version number
Output_GetVersion = clientObj.GetVersion();
if verbose
    fprintf( 'Version: %d.%d.%d\n', Output_GetVersion.Major, ...
                                    Output_GetVersion.Minor, ...
                                    Output_GetVersion.Point );
end

if FLAG.TransmitMulticast
  clientObj.StartTransmittingMulticast( 'localhost', '224.0.0.0' );
end  


