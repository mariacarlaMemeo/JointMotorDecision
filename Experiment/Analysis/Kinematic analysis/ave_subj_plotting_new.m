% -------------------------------------------------------------------------
% -> We plot kin. variables for all trials (only 2nd decision), per agent.
% -> The actual plotting is done in function ave_subj_plotting_fun.m
% -------------------------------------------------------------------------
% This is called from "calc_kin_rt_mt.m"

% XXX CHECK FIGURE NAMES (pre, abs, etc.)

% Notes:
% Temporal variables in matrix 'all_time_traj_ulna/index_'
% Spatial variables in matrix 'all_spa_traj_ulna/index_'
% Temporal and spatial variables:
% Velocity      - 1st column of matrix
% Acceleration  - 2nd column of matrix
% Jerk          - 3rd column of matrix
% x-coordinate  - 1st column of matrix
% y-coordinate  - 2nd column of matrix -> currently not plotted
% z-coordinate  - 3rd column of matrix

% Prepare for loop structure below
agent2ndDec = {'B' 'Y'};
mrks        = {'index' 'ulna'};
time_param  = {'velocity' 'acceleration' 'jerk'};
spa_param   = {'x' 'y' 'z'};

%% Start looping through agents / markers / parameters
% agent loop: blue, yellow
for g = 1:length(agent2ndDec) % -------------------------------------------
    
    if agent2ndDec{g}=='B'
        conf = bConf;
        dec  = blue_Dec;
    elseif agent2ndDec{g}=='Y'
        conf = yConf;
        dec  = yell_Dec;
    end
    
    % marker loop: index, ulna
    for m = 1:length(mrks)
        
        % time parameter loop: velocity, acceleration, jerk
        for param = 1:length(time_param)
            title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agent2ndDec{g} ' agent, pair' SUBJECTS{p}(2:end)];
            if flag_2nd
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec2_pre_abs.png'];
            else
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' time_param{param}(1) 'm_' mrks{m} '.png'];
            end
            % go into plotting function
            ave_subj_plotting_fun(eval(['all_time_traj_' mrks{m} '_' lower(agent2ndDec{g})]),param,conf, ...
                dec,SecondDec,agent2ndDec{g},title_plot,title_fig,path_kin,1,[],flag_2nd,flag_bin)
        end
        
        % spatial parameter loop: x-dimension (left-right), z-dimension (height)
        for sparam = 1:2:length(spa_param)
            %change the title of the spatial param
            title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agent2ndDec{g} ' agent, pair' SUBJECTS{p}(2:end)];
            if flag_2nd
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec2_pre_abs.png'];
            else
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' spa_param{sparam} ' coord_' mrks{m} '.png'];
            end
            % go into plotting function
            ave_subj_plotting_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agent2ndDec{g})]),sparam,conf, ...
                dec,SecondDec,agent2ndDec{g},title_plot,title_fig,path_kin,1,[],flag_2nd,flag_bin)
        end

    end % end of marker loop
end % end of agent loop ---------------------------------------------------


% XXX what do we want to display here?
disp(eval(['size(all_spa_traj_'  mrks{m} '_' lower(agent2ndDec{g}) ',3)']));

% script version: 1 Nov 2023