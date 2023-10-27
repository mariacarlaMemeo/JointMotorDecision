% Use "calc_kin_rt_mt.mc" first.
%Script to plot kinematic variables trial-by-trial, per agent
% 28.03.2023 (@@ -1,5 +1,41 @@)

% Temporal coordinates
%Module of velocity(1st column in the of matrix 'all_time_traj_ulna_') blue/yellow agent for index marker
%Acceleration (2nd column in the of matrix 'all_time_traj_ulna_') blue/yellow agent for index marker
%Jerk (3rd column in the of matrix 'all_time_traj_ulna_') blue/yellow agent for index marker

% Spatial coordinates
%Height coordinate (z) of blue/yellow agent for ulna marker

% For loop to plot both index and ulna trajectories
agent2ndDec = {'B' 'Y'};
mrks        = {'index' 'ulna'};
time_param  = {'velocity' 'acceleration' 'jerk'};
spa_param   = {'x' 'y' 'z'};

%loop on the agent:blue, yellow
for g = 1:length(agent2ndDec)
    if agent2ndDec{g}=='B'
        conf = bConf;
        dec  = blue_Dec;
    elseif agent2ndDec{g}=='Y'
        conf = yConf;
        dec  = yell_Dec;
    end
    %loop on the marker:index, ulna
    for m = 1:length(mrks)
        %loop on the time parameters
        for param = 1:length(time_param)
            title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agent2ndDec{g} ' agent, pair' SUBJECTS{p}(2:end)];
            if flag_2nd
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec2_pre_abs.png'];
            else
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' time_param{param}(1) 'm_' mrks{m} '.png'];
            end
            ave_subj_plotting_fun(eval(['all_time_traj_' mrks{m} '_' lower(agent2ndDec{g})]),param,conf,dec,SecondDec,agent2ndDec{g},title_plot,title_fig,path_kin,1,[],flag_2nd,flag_bin)

        end
        %loop on the spatial parameters
        for sparam = 1:2:length(spa_param)
            %change the title of the spatial param
            title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agent2ndDec{g} ' agent, pair' SUBJECTS{p}(2:end)];
            if flag_2nd
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec2_pre_abs.png'];
            else
                title_fig  = [SUBJECTS{p}(2:end) agent2ndDec{g} '_' spa_param{sparam} ' coord_' mrks{m} '.png'];
            end
            ave_subj_plotting_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agent2ndDec{g})]),sparam,conf,dec,SecondDec,agent2ndDec{g},title_plot,title_fig,path_kin,1,[],flag_2nd,flag_bin)
        end
    end
end

disp(eval(['size(all_spa_traj_'  mrks{m} '_' lower(agent2ndDec{g}) ',3)']))
