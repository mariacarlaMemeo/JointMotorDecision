function [tindex,tulna,sindex,sulna,sdindex,...
    time_traj_index,time_traj_ulna,...
    spa_traj_index,spa_traj_ulna] = ...
    movement_var(sMarkers,t,SUBJECTS,p,agentExec,tstart,endFrame,flag_bin)

% CAN WE CHANGE "tstart" to "startFrame", please??! to avoid confusion

% -------------------------------------------------------------------------
% -> We compute the kin. variables and prepare 3d-matrices with all trials.
% -------------------------------------------------------------------------
% This function is called from "calc_kin_rt_mt.m" (after movement_onset.m)


% Retrieve and define some parameters
model_name = [SUBJECTS{p} '_' agentExec '_' agentExec]; % name of hand model in Nexus
index      = sMarkers{t}.markers.([model_name '_index']); % ALL DATA for index
ulna       = sMarkers{t}.markers.([model_name '_ulna']);  % ALL DATA for ulna

if endFrame > tstart

    % here we use the startFrame (passed as tstart) and endFrame identified
    % in movement_onset.m to define the trajectory range
    range_index = tstart:endFrame;
    range_ulna  = tstart:endFrame;

    if flag_bin % normalize and create 100 binned data points
        i_index = linspace(range_index(1),range_index(end));
        i_ulna  = linspace(range_ulna(1),range_ulna(end));
    end

    %% Compute average TEMPORAL variables and group them
    % average velocity (= magnitude/"module" of 3d-velocity)
    va_index = mean(index.Vm(range_index));
    va_ulna  = mean(ulna.Vm(range_ulna));
    % average acceleration
    aa_index = mean(index.A(range_index));
    aa_ulna  = mean(ulna.A(range_ulna));
    % average jerk
    ja_index = mean(index.J(range_index));
    ja_ulna  = mean(ulna.J(range_ulna));

    % Group temporal variables per marker
    tindex = [va_index aa_index ja_index];
    tulna  = [va_ulna aa_ulna ja_ulna];


    %% Create full (binned) temporal trajectories for vel., acc., and jerk
    if flag_bin % do interpolation to 100 samples
        time_traj_index = [interp1(range_index,index.Vm(range_index),i_index)'...
            interp1(range_index,index.A(range_index),i_index)'...
            interp1(range_index,index.J(range_index),i_index)'];
        time_traj_ulna  = [interp1(range_ulna,ulna.Vm(range_ulna),i_ulna)'...
            interp1(range_ulna,ulna.A(range_ulna),i_ulna)'...
            interp1(range_ulna,ulna.J(range_ulna),i_ulna)'];
    else % no interpolation
        time_traj_index = [index.Vm(range_index)...
            index.A(range_index)...
            index.J(range_index)];
        time_traj_ulna  = [ulna.Vm(range_ulna)...
            ulna.A(range_ulna)...
            ulna.J(range_ulna)];
    end


    %% Compute average SPATIAL variables and group them
    % peak hight (z coord)
    pz_index = max(index.xyzf((range_index),3));
    pz_ulna  = max(ulna.xyzf((range_ulna),3));
    % minimum hight (z coord)
    mz_index = min(index.xyzf((range_index),3));
    mz_ulna  = min(ulna.xyzf((range_ulna),3));
    % mean hight (z coord)
    za_index = mean(index.xyzf((range_index),3));
    za_ulna  = mean(ulna.xyzf((range_ulna),3));
    % area of hight (z coord)
    az_index = trapz(index.xyzf((range_index),3));
    az_ulna  = trapz(ulna.xyzf((range_ulna),3));

    % Group temporal variables per marker
    sindex = [pz_index mz_index za_index az_index];
    sulna  = [pz_ulna mz_ulna za_ulna az_ulna];


    %% Create full (binned) spatial trajectories for vel., acc., and jerk
    if flag_bin % do interpolation to 100 samples
        spa_traj_index = [interp1(range_index,index.xyzf((range_index),1),i_index)'...
            interp1(range_index,index.xyzf((range_index),2),i_index)'...
            interp1(range_index,index.xyzf((range_index),3),i_index)'];
        spa_traj_ulna  = [interp1(range_ulna,ulna.xyzf((range_ulna),1),i_ulna)'...
            interp1(range_ulna,ulna.xyzf((range_ulna),2),i_ulna)'...
            interp1(range_ulna,ulna.xyzf((range_ulna),3),i_ulna)'];
    else % no interpolation
        spa_traj_index = [index.xyzf((range_index),1)...
            index.xyzf((range_index),2)...
            index.xyzf((range_index),3)];
        spa_traj_ulna  = [ulna.xyzf((range_ulna),1)...
            ulna.xyzf((range_ulna),2)...
            ulna.xyzf((range_ulna),3)];
    end


    %% Compute further parameters: indicators for spatial deviation
    
    % Average deviation from straight line (for index marker only)    
    x1    = index.xyzf(tstart,1);
    xend  = index.xyzf(endFrame,1);
    y1    = index.xyzf(tstart,2);
    yend  = index.xyzf(endFrame,2);
    % calculate coefficients*
    coefs = polyfit([x1, xend], [y1, yend], 1);
    sline = coefs(1).*index.xyzf((range_index),1) + coefs(2);
    % * P = polyfit(X,Y,N) finds the coefficients of a polynomial P(X) of
    % degree N that fits the data Y best in a least-squares sense. P is a
    % row vector of length N+1 containing the polynomial coefficients in
    % descending powers, P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X + P(N+1).

    % Area of the trajectory deviation (x,y)
    % XXX CHECK IF CORRECT AND IF THERE ARE NEGATIVE VALUES IN ARD
    x    = index.xyzf((range_index),1);
    y    = index.xyzf((range_index),2);
    d    = sqrt(sum(([x,y]-[x,sline]).^2,2));
    mxd  = max(d);
    mnd  = min(d);
    ad   = mean(d);  % what exactly is contained in this value???
    ard  = trapz(d); % what exactly is contained in this value???
    % plot figure to check
%     figure();plot(x,sline,'r');hold on;plot(x,y,'b');hold off

    % Group spatial deviation variables
    sdindex = [ard mxd mnd ad];


else % if trial is empty, insert NaN values

    tindex          = [NaN NaN NaN];
    tulna           = [NaN NaN NaN];
    sindex          = [NaN NaN NaN];
    sulna           = [NaN NaN NaN];
    sdindex         = [NaN NaN NaN];
    time_traj_index = NaN*ones(100,3);
    time_traj_ulna  = NaN*ones(100,3);
    spa_traj_index  = NaN*ones(100,3);
    spa_traj_ulna   = NaN*ones(100,3);

end % end of function -> go back into calc_rt_mt.m

% script version: 1 Nov 2023