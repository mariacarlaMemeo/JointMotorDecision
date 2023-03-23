function [tindex,tulna,sindex,sulna,sdindex,...
          time_traj_index,time_traj_ulna,...
          spa_traj_index,spa_traj_ulna]=movement_var(sMarkers,t,SUBJECTS,p,agentExec,startFrame,endFrame)

% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:};
model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']);
ulna       = sMarkers{t}.markers.([model_name '_ulna']);

const = 0;%%remove last 'const' frames for index values
range_index = startFrame:endFrame-const;
i_index     = linspace(range_index(1),range_index(end));
range_ulna  = startFrame:endFrame;
i_ulna      = linspace(range_ulna(1),range_ulna(end));

%Calc kin vars - temporal variables
%average speed
va_index = mean(index.Vm(range_index));% 
va_ulna  = mean(ulna.Vm(range_ulna));% 
%average acceleration (magnitude - xyz)
aa_index = mean(index.Am(range_index));% 
aa_ulna  = mean(ulna.Am(range_ulna));% 
%average jerk
ja_index = index.Jmean;
ja_ulna  = ulna.Jmean;

%average speed (y)
vay_index = mean(index.Vxyzf(range_index,2));% 
vay_ulna  = mean(ulna.Vxyzf(range_ulna,2));% 
%average acceleration (y)
aay_index = mean(index.Axyzf(range_index,2));
aay_ulna  = mean(ulna.Axyzf(range_ulna,2));
%average jerk(y)
jay_index = mean(index.Jxyzf(range_index,2));
jay_ulna  = mean(ulna.Jxyzf(range_ulna,2));

%group time variables 
tindex = [va_index aa_index ja_index vay_index aay_index jay_index];
tulna  = [va_ulna aa_ulna ja_ulna vay_ulna aay_ulna jay_ulna];
% group time variables - all the trajectory
time_traj_index = [interp1(range_index,index.Vm(range_index),i_index)'...
                    interp1(range_index,index.Am(range_index),i_index)'...
                    interp1(range_index,index.Jm(range_index),i_index)'...
                    interp1(range_index,index.Vxyzf(range_index,2),i_index)'...
                    interp1(range_index,index.Axyzf(range_index,2),i_index)'...
                    interp1(range_index,index.Jxyzf(range_index,2),i_index)'];
time_traj_ulna  = [interp1(range_ulna,ulna.Vm(range_ulna),i_ulna)'...
                    interp1(range_ulna,ulna.Am(range_ulna),i_ulna)'...
                    interp1(range_ulna,ulna.Jm(range_ulna),i_ulna)'...
                    interp1(range_ulna,ulna.Vxyzf(range_ulna,2),i_ulna)'...
                    interp1(range_ulna,ulna.Axyzf(range_ulna,2),i_ulna)'...
                    interp1(range_ulna,ulna.Jxyzf(range_ulna,2),i_ulna)'];

%Calc kin vars - spatial variables
%peak hight (z coord)
pz_index = max(index.xyzf((range_index),3));
pz_ulna  = max(ulna.xyzf((range_ulna),3));
%minimum hight (z coord)
mz_index = min(index.xyzf((range_index),3));
mz_ulna  = min(ulna.xyzf((range_ulna),3));
%mean hight (z coord)
za_index = mean(index.xyzf((range_index),3));
za_ulna  = mean(ulna.xyzf((range_ulna),3));
%area of hight (z coord)
az_index = trapz(index.xyzf((range_index),3));
az_ulna  = trapz(ulna.xyzf((range_ulna),3));

%group spatial variables 
sindex = [pz_index mz_index za_index az_index];
sulna  = [pz_ulna mz_ulna za_ulna az_ulna];

% group spatial variables - all the trajectory
spa_traj_index = [interp1(range_index,index.xyzf((range_index),1),i_index)'...
                    interp1(range_index,index.xyzf((range_index),2),i_index)'...
                    interp1(range_index,index.xyzf((range_index),3),i_index)'];
spa_traj_ulna  = [interp1(range_ulna,ulna.xyzf((range_ulna),1),i_ulna)'...
                    interp1(range_ulna,ulna.xyzf((range_ulna),2),i_ulna)'...
                    interp1(range_ulna,ulna.xyzf((range_ulna),3),i_ulna)'];

%average deviation from straight line (queer spectrum)
%calculate coeffs of the straight line - only for index marker
x1    = index.xyzf(startFrame,1);
xend  = index.xyzf(endFrame-const,1);
y1    = index.xyzf(startFrame,2);
yend  = index.xyzf(endFrame-const,2);
coefs = polyfit([x1, xend], [y1, yend], 1);
sline = coefs(1).*index.xyzf((range_index),1) + coefs(2);

%calculate the area of the trajectory deviation (x,y) - neg values? 
x     = index.xyzf((range_index),1);
y     = index.xyzf((range_index),2);
% ard   = trapz(xa,abs(sline-y)); % or trapz(abs(x),abs(y1-y2))

d     = sqrt(sum(([x,y]-[x,sline]).^2,2));
mxd   = max(d);
mnd   = min(d);
ad    = mean(d);
ard   = trapz(d);

% figure();plot(x,sline,'r');hold on;plot(x,y,'b');hold off

%group spatial deviation variables 
sdindex = [ard mxd mnd ad];

