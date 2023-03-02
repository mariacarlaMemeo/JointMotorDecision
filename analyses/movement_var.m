function []=movement_var(sMarkers,t,SUBJECTS,p,agentExec,startFrame,endFrame)

% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:};
preAcq     = 20; %preacquisition of 200ms == 20 frames
model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']);
ulna       = sMarkers{t}.markers.([model_name '_ulna']);

%Calc kin vars - temporal variables
%average speed
va_index = mean(index.Vm(startFrame:endFrame));% 
va_ulna  = mean(ulna.Vm(startFrame:endFrame));% 
%average acceleration
aa_index = mean(index.Am(startFrame:endFrame));% 
aa_ulna  = mean(ulna.Am(startFrame:endFrame));% 
%average jerk
ja_index = index.Jmean;
ja_ulna  = ulna.Jmean;

%Calc kin vars - spatial variables
%peak hight (z coord)
pz_index = max(index.xyzf(:,3));
pz_ulna  = max(ulna.xyzf(:,3));
%mean hight (z coord)
za_index = mean(index.xyzf(:,3));
za_ulna  = mean(ulna.xyzf(:,3));
%area of hight (z coord)
az_index = trapz(index.xyzf(:,3));
az_ulna  = trapz(ulna.xyzf(:,3));
%average deviation from straight line (queer spectrum)
%calculate coeffs of the straight line - only for index marker
x1    = index.xyzf(1,1);
xend  = index.xyzf(end,1);
y1    = index.xyzf(1,2);
yend  = index.xyzf(end,2);
coefs = polyfit([x1, xend], [y1, yend], 1);
sline = coefs(1).*index.xyzf(startFrame:endFrame,1) + coefs(2);
%calculate the area of the trajectory deviation (x,y) - neg values? 
ad    = trapz(index.xyzf(startFrame:endFrame,2),index.xyzf(startFrame:endFrame,1)) - trapz(sline,index.xyzf(startFrame:endFrame,1));


