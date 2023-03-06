function [tindex,tulna,sindex,sulna,sdindex]=movement_var(sMarkers,t,SUBJECTS,p,agentExec,startFrame,endFrame)

% CHECK index and wrist velocity threshold
frameRate  = sMarkers{t}.info.TRIAL.CAMERA_RATE{:};
model_name = [SUBJECTS{p} '_' agentExec(2) '_' agentExec];%name of the model in Nexus
samp       = 1:sMarkers{t}.info.nSamples;
index      = sMarkers{t}.markers.([model_name '_index']);
ulna       = sMarkers{t}.markers.([model_name '_ulna']);

const = 0;%%remove last 'const' frames for index values

%Calc kin vars - temporal variables
%average speed
va_index = mean(index.Vm(startFrame:endFrame-const));% 
va_ulna  = mean(ulna.Vm(startFrame:endFrame));% 
%average acceleration
aa_index = mean(index.Am(startFrame:endFrame-const));% 
aa_ulna  = mean(ulna.Am(startFrame:endFrame));% 
%average jerk
ja_index = index.Jmean;
ja_ulna  = ulna.Jmean;

%group time variables 
tindex = [va_index aa_index ja_index];
tulna  = [va_ulna aa_ulna ja_ulna];

%Calc kin vars - spatial variables
%peak hight (z coord)
pz_index = max(index.xyzf((startFrame:endFrame-const),3));
pz_ulna  = max(ulna.xyzf((startFrame:endFrame),3));
%minimum hight (z coord)
mz_index = min(index.xyzf((startFrame:endFrame-const),3));
mz_ulna  = min(ulna.xyzf((startFrame:endFrame),3));
%mean hight (z coord)
za_index = mean(index.xyzf((startFrame:endFrame-const),3));
za_ulna  = mean(ulna.xyzf((startFrame:endFrame),3));
%area of hight (z coord)
az_index = trapz(index.xyzf((startFrame:endFrame-const),3));
az_ulna  = trapz(ulna.xyzf((startFrame:endFrame),3));

%group spatial variables 
sindex = [pz_index mz_index za_index az_index];
sulna  = [pz_ulna mz_ulna za_ulna az_ulna];

%average deviation from straight line (queer spectrum)
%calculate coeffs of the straight line - only for index marker
x1    = index.xyzf(startFrame,1);
xend  = index.xyzf(endFrame-const,1);
y1    = index.xyzf(startFrame,2);
yend  = index.xyzf(endFrame-const,2);
coefs = polyfit([x1, xend], [y1, yend], 1);
sline = coefs(1).*index.xyzf((startFrame:endFrame-const),1) + coefs(2);
%calculate the area of the trajectory deviation (x,y) - neg values? 
xa    = abs(index.xyzf((startFrame:endFrame-const),1));
ya    = abs(index.xyzf((startFrame:endFrame-const),2));
y     = index.xyzf((startFrame:endFrame-const),2);
ard   = trapz(xa,abs(sline-y)); %trapz(abs(x),abs(y1-y2))

d     = sqrt(sum(([xa,ya]-[xa,abs(sline)]).^2,2));
mxd   = max(d);
mnd   = min(d);
ad    = mean(d);

%group spatial deviation variables 
sdindex = [ard mxd mnd ad];

