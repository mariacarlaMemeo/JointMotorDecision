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





% % bvm_all = squeeze(all_time_traj_index_b(:,1,:));
% % b_ave_Vm_index = mean(all_time_traj_index_b(:,1,:),3,'omitnan');
% % b_std_Vm_index = std(all_time_traj_index_b(:,1,:),0,3,'omitnan');
% % biv=figure();set(biv, 'WindowStyle', 'Docked');
% % plot(bvm_all(:,bConf==2),'color',hConf_col);hold on;
% % plot(bvm_all(:,bConf==1),'color',lConf_col+.2);
% % title(['INDEX - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)]);
% % plot(mean(all_time_traj_index_b(:,1,bConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% % plot(mean(all_time_traj_index_b(:,1,bConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% % saveas(gcf,fullfile(path_temp,'exploratoryPlots',['b' SUBJECTS{p}(2:end) '_vm_index.png']))
% % hold off;
% % plot(b_ave_Vm_index,'b','LineWidth',wd);
% % plot(b_ave_Vm_index+b_std_Vm_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
% % plot(b_ave_Vm_index-b_std_Vm_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
% 
% %remove outlier
% yvm_all = squeeze(all_time_traj_index_y(:,1,:));
% [~,c]=find(yvm_all>2500);
% all_time_traj_index_y(:,1,unique(c)) = nan;
% yvm_all(:,unique(c)) = nan;
% 
% yiv=figure();set(yiv, 'WindowStyle', 'Docked');
% plot(yvm_all(:,yConf==2),'color',hConf_col);hold on;
% plot(yvm_all(:,yConf==1),'color',lConf_col+.2);
% title(['INDEX - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
% plot(mean(all_time_traj_index_y(:,1,yConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_time_traj_index_y(:,1,yConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['y' SUBJECTS{p}(2:end) '_vm_index.png']))
% hold off;
% % plot(squeeze(all_time_traj_index_y(:,1,:)),'color',[.7 .7 .7]);
% % plot(y_ave_Vm_index,'color',y_solid,'LineWidth',wd);
% % plot(y_ave_Vm_index+y_std_Vm_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
% % plot(y_ave_Vm_index-y_std_Vm_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
% 
% 
% % %Module of velocity of blue/yellow agent for ulna marker
% % b_ave_Vm_ulna = mean(all_time_traj_ulna_b(:,1,:),3,'omitnan');
% % b_std_Vm_ulna = std(all_time_traj_ulna_b(:,1,:),0,3,'omitnan');
% % buv=figure();plot(squeeze(all_time_traj_ulna_b(:,1,:)),'color',[.7 .7 .7]);set(buv, 'WindowStyle', 'Docked');hold on;
% % plot(b_ave_Vm_ulna,'b','LineWidth',wd);title(['ULNA - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)]);
% % plot(b_ave_Vm_ulna+b_std_Vm_ulna,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
% % plot(b_ave_Vm_ulna-b_std_Vm_ulna,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
% % 
% % y_ave_Vm_ulna = mean(all_time_traj_ulna_y(:,1,:),3,'omitnan');
% % y_std_Vm_ulna = std(all_time_traj_ulna_y(:,1,:),0,3,'omitnan');
% % yuv=figure();plot(squeeze(all_time_traj_ulna_y(:,1,:)),'color',[.7 .7 .7]);set(yuv, 'WindowStyle', 'Docked');hold on;
% % plot(y_ave_Vm_ulna,'color',y_solid,'LineWidth',wd);title(['ULNA - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
% % plot(y_ave_Vm_ulna+y_std_Vm_ulna,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
% % plot(y_ave_Vm_ulna-y_std_Vm_ulna,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
% 
% %Height coordinate (z) of blue/yellow agent for index marker
% %blue
% bz_all = squeeze(all_spa_traj_index_b(:,3,:));
% biz=figure();set(biz, 'WindowStyle', 'Docked');
% plot(bz_all(:,bConf==2),'color',hConf_col);hold on;
% plot(bz_all(:,bConf==1),'color',lConf_col+.2);
% title(['INDEX - Height of BLUE agent, pair' SUBJECTS{p}(2:end)]);
% plot(mean(all_spa_traj_index_b(:,3,bConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_index_b(:,3,bConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['b' SUBJECTS{p}(2:end) '_z_index.png']))
% hold off;
% %yellow
% clear c
% yz_all = squeeze(all_spa_traj_index_y(:,3,:));
% [~,c]=find(yz_all>120 | yz_all<-20);
% all_spa_traj_index_y(:,3,unique(c)) = nan;
% yz_all(:,unique(c)) = nan;
% 
% yiz=figure();set(yiz, 'WindowStyle', 'Docked');
% plot(yz_all(:,yConf==2),'color',hConf_col);hold on;
% plot(yz_all(:,yConf==1),'color',lConf_col+.2);
% title(['INDEX - Height of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
% plot(mean(all_spa_traj_index_y(:,3,yConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_index_y(:,3,yConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['y' SUBJECTS{p}(2:end) '_z_index.png']))
% hold off;
% 
% 
% 
% %Height coordinate (z) of blue/yellow agent for ulna marker
% %blue
% clear bz_all yz_all biz yiz
% bz_all = squeeze(all_spa_traj_ulna_b(:,3,:));
% biz=figure();set(biz, 'WindowStyle', 'Docked');
% plot(bz_all(:,bConf==2),'color',hConf_col);hold on;
% plot(bz_all(:,bConf==1),'color',lConf_col+.2);
% title(['ulna - Height of BLUE agent, pair' SUBJECTS{p}(2:end)]);
% plot(mean(all_spa_traj_ulna_b(:,3,bConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_ulna_b(:,3,bConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['b' SUBJECTS{p}(2:end) '_z_ulna.png']))
% hold off;
% 
% %yellow
% yz_all = squeeze(all_spa_traj_ulna_y(:,3,:));
% yiz=figure();set(yiz, 'WindowStyle', 'Docked');
% plot(yz_all(:,yConf==2),'color',hConf_col);hold on;
% plot(yz_all(:,yConf==1),'color',lConf_col+.2);
% title(['ulna - Height of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
% plot(mean(all_spa_traj_ulna_y(:,3,yConf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_ulna_y(:,3,yConf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['y' SUBJECTS{p}(2:end) '_z_ulna.png']))
% hold off;

% %XY index trajectory of blue/yellow agent 
% clear biz yiz
% bx_all = squeeze(all_spa_traj_index_b(:,1,:));
% by_all = squeeze(all_spa_traj_index_b(:,2,:));
% biz=figure();set(biz, 'WindowStyle', 'Docked');
% plot(bx_all(:,bConf==2),by_all(:,bConf==2),'color',hConf_col);hold on;
% plot(bx_all(:,bConf==1),by_all(:,bConf==1),'color',lConf_col+.2);
% title(['INDEX - XY index trajectory of BLUE agent, pair' SUBJECTS{p}(2:end)]);
% %high conf (left and right targets)
% plot(mean(all_spa_traj_index_b(:,1,bConf==2 & blue_Dec==1),3,'omitnan'),mean(all_spa_traj_index_b(:,2,bConf==2 & blue_Dec==1),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_index_b(:,1,bConf==2 & blue_Dec==2),3,'omitnan'),mean(all_spa_traj_index_b(:,2,bConf==2 & blue_Dec==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% %low conf (left and right targets)
% plot(mean(all_spa_traj_index_b(:,1,bConf==1 & blue_Dec==1),3,'omitnan'),mean(all_spa_traj_index_b(:,2,bConf==1 & blue_Dec==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% plot(mean(all_spa_traj_index_b(:,1,bConf==1 & blue_Dec==2),3,'omitnan'),mean(all_spa_traj_index_b(:,2,bConf==1 & blue_Dec==2),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['b' SUBJECTS{p}(2:end) '_xy_index.png']))
% hold off;
% 
% %yellow
% clear biz yiz c
% yx_all = squeeze(all_spa_traj_index_y(:,1,:));
% [~,cx]=find(yx_all>1000 | yx_all<700);
% yx_all(:,unique(cx)) = nan;
% 
% yy_all = squeeze(all_spa_traj_index_y(:,2,:));
% [~,cy]=find(yy_all>500 | yy_all<50);
% all_spa_traj_index_y(:,1,unique(cx)) = nan;
% all_spa_traj_index_y(:,2,unique(cy)) = nan;
% yy_all(:,unique(cy)) = nan;
% 
% yiz=figure();set(yiz, 'WindowStyle', 'Docked');
% plot(yx_all(:,yConf==2),yy_all(:,yConf==2),'color',hConf_col);hold on;
% plot(yx_all(:,yConf==1),yy_all(:,yConf==1),'color',lConf_col+.2);
% title(['INDEX - XY index trajectory of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
% %high conf (left and right targets)
% plot(mean(all_spa_traj_index_y(:,1,yConf==2 & yell_Dec==1),3,'omitnan'),mean(all_spa_traj_index_y(:,2,yConf==2 & yell_Dec==1),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% plot(mean(all_spa_traj_index_y(:,1,yConf==2 & yell_Dec==2),3,'omitnan'),mean(all_spa_traj_index_y(:,2,yConf==2 & yell_Dec==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
% %low conf (left and right targets)
% plot(mean(all_spa_traj_index_y(:,1,yConf==1 & yell_Dec==1),3,'omitnan'),mean(all_spa_traj_index_y(:,2,yConf==1 & yell_Dec==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% plot(mean(all_spa_traj_index_y(:,1,yConf==1 & yell_Dec==2),3,'omitnan'),mean(all_spa_traj_index_y(:,2,yConf==1 & yell_Dec==2),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
% saveas(gcf,fullfile(path_temp,'exploratoryPlots',['y' SUBJECTS{p}(2:end) '_xy_index.png']))
% hold off;
% 
% clear bvm_all yvm_all biv yiv bz_all yz_all bx_all by_all yx_all yy_all biz yiz bConf yConf