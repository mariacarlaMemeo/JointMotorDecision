%Script to plot kinematic variables trial-by-trial, per agent
% 28.03.2023 (@@ -1,5 +1,41 @@)

%% Temporal coordinates
%Module of velocity(1st column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = 2500;
%blue
agent2ndDec = 1;
title_plot = ['INDEX - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'B_vm_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'B_vm_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_b,1,bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)
%yellow
agent2ndDec = 2;
title_plot = ['INDEX - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'Y_vm_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'Y_vm_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_y,1,yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)

%Acceleration (2nd column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-30000 20000];
%blue
agent2ndDec = 1;
title_plot = ['INDEX - Acceleration of BLUE agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'B_a_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'B_a_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_b,2,bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)
%yellow
agent2ndDec = 2;
title_plot = ['INDEX - Acceleration of YELLOW agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'Y_a_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'Y_a_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_y,2,yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)

%Jerk (3rd column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-5*10^5 7*10^5];
%blue
agent2ndDec = 1;
title_plot = ['INDEX - Jerk of BLUE agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'B_j_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'B_j_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_b,3,bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)
%yellow
agent2ndDec = 2;
title_plot = ['INDEX - Jerk of YELLOW agent, pair' SUBJECTS{p}(2:end)];
if flag_2nd
    title_fig  = [SUBJECTS{p}(2:end) 'Y_j_index_dec2.png'];
else
    title_fig  = [SUBJECTS{p}(2:end) 'Y_j_index.png'];
end
ave_subj_plotting_fun(all_time_traj_index_y,3,yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)


%% Spatial coordinates
%Height coordinate (z) of blue/yellow agent for index marker
threshold = [-50 200];
%blue
agent2ndDec = 1;
title_plot = ['INDEX - Z coordinate of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_zcoord_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_b,3,bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)
%yellow
agent2ndDec = 2;
title_plot = ['INDEX - Z coordinate of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_zcoord_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_y,3,yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)

% %Height coordinate (z) of blue/yellow agent for ulna marker
% threshold = -20;
% %blue
% agent2ndDec = 1;
% title_plot = ['ULNA - Z coordinate of BLUE agent, pair' SUBJECTS{p}(2:end)];
% title_fig  = [SUBJECTS{p}(2:end) 'B_zcoord_ulna.png'];
% ave_subj_plotting_fun(all_spa_traj_ulna_b,3,bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)
% %yellow
% agent2ndDec = 2;
% title_plot = ['ULNA - Z coordinate of YELLOW agent, pair' SUBJECTS{p}(2:end)];
% title_fig  = [SUBJECTS{p}(2:end) 'Y_zcoord_ulna.png'];
% ave_subj_plotting_fun(all_spa_traj_ulna_y,3,yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,1,[],flag_2nd)

%XY plane blue/yellow agent for index marker
%blue
threshold  = [-1050 -750 50 550];%[xleft xright ylow yhigh]
agent2ndDec = 1;
title_plot = ['INDEX - XY index trajectory of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_xy_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_b,[],bConf,blue_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,2,[],flag_2nd)
%yellow
threshold  = [700 1100 50 500];
agent2ndDec = 2;
title_plot = ['INDEX - XY index trajectory of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_xy_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_y,[],yConf,yell_Dec,SecondDec,agent2ndDec,title_plot,title_fig,path_temp,2,[],flag_2nd)


