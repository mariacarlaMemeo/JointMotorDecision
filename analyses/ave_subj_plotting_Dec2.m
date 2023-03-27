%Script to plot random things noone will need

%%Temporal coordinates
%Velocity on y axis(4th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-1000 3500];
%blue
title_plot = ['ULNA - Velocity y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_vy_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_b,4,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['ULNA - Velocity y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_vy_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_y,4,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Acceleration on y axis(5th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-30000 20000];
%blue
title_plot = ['ULNA - Acceleration y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_ay_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_b,5,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['ULNA - Acceleration y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_ay_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_y,5,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Jerk on y axis(6th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-5*10^5 7*10^5];
%blue
title_plot = ['ULNA - Jerk y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_jy_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_b,6,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['ULNA - Jerk y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_jy_ULNA.png'];
ave_subj_plotting_fun(all_time_traj_ulna_y,6,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)



%%Temporal coordinates
%Velocity on y axis(4th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-1000 3500];
%blue
title_plot = ['INDEX - Velocity y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_vy_index.png'];
ave_subj_plotting_fun(all_time_traj_index_b,4,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Velocity y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_vy_index.png'];
ave_subj_plotting_fun(all_time_traj_index_y,4,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Acceleration on y axis(5th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-30000 20000];
%blue
title_plot = ['INDEX - Acceleration y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_ay_index.png'];
ave_subj_plotting_fun(all_time_traj_index_b,5,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Acceleration y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_ay_index.png'];
ave_subj_plotting_fun(all_time_traj_index_y,5,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Jerk on y axis(6th column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = [-5*10^5 7*10^5];
%blue
title_plot = ['INDEX - Jerk y-axis of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_jy_index.png'];
ave_subj_plotting_fun(all_time_traj_index_b,6,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Jerk y-axis of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_jy_index.png'];
ave_subj_plotting_fun(all_time_traj_index_y,6,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)




%Module of velocity(1st column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = 2500;
%blue
title_plot = ['INDEX - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_vm_index.png'];
ave_subj_plotting_fun(all_time_traj_index_b,1,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_vm_index.png'];
ave_subj_plotting_fun(all_time_traj_index_y,1,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Module of acceleration(2nd column in the of matrix 'all_time_traj_index') blue/yellow agent for index marker
threshold  = 20000;
%blue
title_plot = ['INDEX - Acceleration module of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_am_index.png'];
ave_subj_plotting_fun(all_time_traj_index_b,2,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Acceleration module of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_am_index.png'];
ave_subj_plotting_fun(all_time_traj_index_y,2,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)


%%Spatial coordinates
%Height coordinate (z) of blue/yellow agent for index marker
threshold = [-50 200];
%blue
title_plot = ['INDEX - Z coordinate of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_zcoord_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_b,3,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['INDEX - Z coordinate of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_zcoord_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_y,3,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)

%Height coordinate (z) of blue/yellow agent for ulna marker
%blue
threshold = -20;
title_plot = ['ULNA - Z coordinate of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_zcoord_ulna.png'];
ave_subj_plotting_fun(all_spa_traj_ulna_b,3,bConf,blue_Dec,title_plot,title_fig,path_temp,1,threshold)
%yellow
title_plot = ['ULNA - Z coordinate of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_zcoord_ulna.png'];
ave_subj_plotting_fun(all_spa_traj_ulna_y,3,yConf,yell_Dec,title_plot,title_fig,path_temp,1,threshold)


%XY plane blue/yellow agent for index marker
threshold  = [-1050 -750 50 550];%[xleft xright ylow yhigh]
%blue
title_plot = ['INDEX - XY index trajectory of BLUE agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'B_xy_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_b,[],bConf,blue_Dec,title_plot,title_fig,path_temp,2,threshold)
%yellow
threshold  = [700 1100 50 500];
title_plot = ['INDEX - XY index trajectory of YELLOW agent, pair' SUBJECTS{p}(2:end)];
title_fig  = [SUBJECTS{p}(2:end) 'Y_xy_index.png'];
ave_subj_plotting_fun(all_spa_traj_index_y,[],yConf,yell_Dec,title_plot,title_fig,path_temp,2,threshold)
