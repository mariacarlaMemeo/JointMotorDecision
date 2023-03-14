%Script to plot random things noone will need
wd = 3; ls =':';
b_dashed = [0.1176 0.2353 0.7451];
y_solid  = [0.8 0.4667 0.1333];
y_dashed = [0.9412 0.7843 0.1569]; 


%Module of velocity of blue/yellow agent for index marker
b_ave_Vm_index = mean(all_time_traj_index_b(:,1,:),3,'omitnan');
b_std_Vm_index = std(all_time_traj_index_b(:,1,:),0,3,'omitnan');
biv=figure();plot(squeeze(all_time_traj_index_b(:,1,:)),'color',[.7 .7 .7]);set(biv, 'WindowStyle', 'Docked');hold on;
plot(b_ave_Vm_index,'b','LineWidth',wd);title(['INDEX - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)]);
plot(b_ave_Vm_index+b_std_Vm_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
plot(b_ave_Vm_index-b_std_Vm_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);

y_ave_Vm_index = mean(all_time_traj_index_y(:,1,:),3,'omitnan');
y_std_Vm_index = std(all_time_traj_index_y(:,1,:),0,3,'omitnan');
yiv=figure();plot(squeeze(all_time_traj_index_y(:,1,:)),'color',[.7 .7 .7]);set(yiv, 'WindowStyle', 'Docked');hold on;
plot(y_ave_Vm_index,'color',y_solid,'LineWidth',wd);title(['INDEX - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
plot(y_ave_Vm_index+y_std_Vm_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
plot(y_ave_Vm_index-y_std_Vm_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);

%Module of velocity of blue/yellow agent for ulna marker
b_ave_Vm_ulna = mean(all_time_traj_ulna_b(:,1,:),3,'omitnan');
b_std_Vm_ulna = std(all_time_traj_ulna_b(:,1,:),0,3,'omitnan');
buv=figure();plot(squeeze(all_time_traj_ulna_b(:,1,:)),'color',[.7 .7 .7]);set(buv, 'WindowStyle', 'Docked');hold on;
plot(b_ave_Vm_ulna,'b','LineWidth',wd);title(['ULNA - Velocity module of BLUE agent, pair' SUBJECTS{p}(2:end)]);
plot(b_ave_Vm_ulna+b_std_Vm_ulna,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
plot(b_ave_Vm_ulna-b_std_Vm_ulna,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);

y_ave_Vm_ulna = mean(all_time_traj_ulna_y(:,1,:),3,'omitnan');
y_std_Vm_ulna = std(all_time_traj_ulna_y(:,1,:),0,3,'omitnan');
yuv=figure();plot(squeeze(all_time_traj_ulna_y(:,1,:)),'color',[.7 .7 .7]);set(yuv, 'WindowStyle', 'Docked');hold on;
plot(y_ave_Vm_ulna,'color',y_solid,'LineWidth',wd);title(['ULNA - Velocity module of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
plot(y_ave_Vm_ulna+y_std_Vm_ulna,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
plot(y_ave_Vm_ulna-y_std_Vm_ulna,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);

%Height coordinate (z) of blue/yellow agent for index marker
b_ave_z_index = mean(all_spa_traj_index_b(:,3,:),3,'omitnan');
b_std_z_index = std(all_spa_traj_index_b(:,3,:),0,3,'omitnan');
biz=figure();plot(squeeze(all_spa_traj_index_b(:,3,:)),'color',[.7 .7 .7]);set(biz, 'WindowStyle', 'Docked');hold on;
plot(b_ave_z_index,'b','LineWidth',wd);title(['INDEX - Zcoord of BLUE agent, pair' SUBJECTS{p}(2:end)]);
plot(b_ave_z_index+b_std_z_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);
plot(b_ave_z_index-b_std_z_index,'color',b_dashed,'LineWidth',wd,'LineStyle', ls);

y_ave_z_index = mean(all_spa_traj_index_y(:,3,:),3,'omitnan');
y_std_z_index = std(all_spa_traj_index_y(:,3,:),0,3,'omitnan');
yiz=figure();plot(squeeze(all_spa_traj_index_y(:,3,:)),'color',[.7 .7 .7]);set(yiz, 'WindowStyle', 'Docked');hold on;
plot(y_ave_z_index,'color',y_solid,'LineWidth',wd);title(['INDEX - Zcoord of YELLOW agent, pair' SUBJECTS{p}(2:end)]);
plot(y_ave_z_index+y_std_z_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);
plot(y_ave_z_index-y_std_z_index,'color',y_dashed,'LineWidth',wd,'LineStyle', ls);

