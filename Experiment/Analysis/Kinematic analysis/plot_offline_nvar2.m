% Here we create the plots for n_var=2 (x-y and y-z plots)

% assign the column specifying the acting agent for the current decision
if which_Dec == 1
    atDec = pairS.at1stDec;
elseif which_Dec == 2
    atDec = pairS.at2ndDec;
elseif which_Dec == 3
    atDec = pairS.atCollDec;
end

% create specific titles for the two types of spatial plots
if which_Dec==3
    title_plotX = [title_plot '- XY-space'];
    title_figX  = [title_fig '_XYspace.png'];
    title_plotZ = [title_plot '- YZ-space'];
    title_figZ  = [title_fig '_YZspace.png'];
else
    title_plotX = [title_plot '- XY-space'];
    title_figX  = [title_fig(1:end-4) '_XYspace.png'];
    title_plotZ = [title_plot '- YZ-space'];
    title_figZ  = [title_fig(1:end-4) '_YZspace.png'];
end


%% 1st or 2nd DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if which_Dec == 1 || which_Dec == 2

    % HIGH confidence
    % mean per decision: target 1 (left) and target 2 (right)
    ave_all.(marker).meanH_x1 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_x2 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_y1 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_y2 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_z1 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_z2 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    % mean across decisions
    ave_all.(marker).meanH_y  = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanH_z  = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    % SD per decision
    sdH_x1 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_x2 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_y1 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_y2 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_z1 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_z2 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    % SD across decisions
    sdH_y  = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdH_z  = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    % mean +/- SD per decision
    sdHPlus_x1 = (ave_all.(marker).meanH_x1+sdH_x1)'; sdHMin_x1=(ave_all.(marker).meanH_x1-sdH_x1)';
    sdHPlus_x2 = (ave_all.(marker).meanH_x2+sdH_x2)'; sdHMin_x2=(ave_all.(marker).meanH_x2-sdH_x2)';
    sdHPlus_y1 = (ave_all.(marker).meanH_y1+sdH_y1)'; sdHMin_y1=(ave_all.(marker).meanH_y1-sdH_y1)';
    sdHPlus_y2 = (ave_all.(marker).meanH_y2+sdH_y2)'; sdHMin_y2=(ave_all.(marker).meanH_y2-sdH_y2)';
    sdHPlus_z1 = (ave_all.(marker).meanH_z1+sdH_z1)'; sdHMin_z1=(ave_all.(marker).meanH_z1-sdH_z1)';
    sdHPlus_z2 = (ave_all.(marker).meanH_z2+sdH_z2)'; sdHMin_z2=(ave_all.(marker).meanH_z2-sdH_z2)';
    % mean +/- SD across decisions
    sdHPlus_y  = (ave_all.(marker).meanH_y+sdH_y)'; sdHMin_y=(ave_all.(marker).meanH_y-sdH_y)';
    sdHPlus_z  = (ave_all.(marker).meanH_z+sdH_z)'; sdHMin_z=(ave_all.(marker).meanH_z-sdH_z)';


    % LOW confidence
    % mean per decision: target 1 (left) and target 2 (right)
    ave_all.(marker).meanL_x1 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_x2 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_y1 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_y2 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_z1 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_z2 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    % mean across decisions
    ave_all.(marker).meanL_y  = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    ave_all.(marker).meanL_z  = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
    % SD per decision
    sdL_x1 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_x2 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_y1 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_y2 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_z1 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_z2 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    % SD across decisions
    sdL_y  = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    sdL_z  = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
    % mean +/- SD per decision
    sdLPlus_x1 = (ave_all.(marker).meanL_x1+sdL_x1)'; sdLMin_x1=(ave_all.(marker).meanL_x1-sdL_x1)';
    sdLPlus_x2 = (ave_all.(marker).meanL_x2+sdL_x2)'; sdLMin_x2=(ave_all.(marker).meanL_x2-sdL_x2)';
    sdLPlus_y1 = (ave_all.(marker).meanL_y1+sdL_y1)'; sdLMin_y1=(ave_all.(marker).meanL_y1-sdL_y1)';
    sdLPlus_y2 = (ave_all.(marker).meanL_y2+sdL_y2)'; sdLMin_y2=(ave_all.(marker).meanL_y2-sdL_y2)';
    sdLPlus_z1 = (ave_all.(marker).meanL_z1+sdL_z1)'; sdLMin_z1=(ave_all.(marker).meanL_z1-sdL_z1)';
    sdLPlus_z2 = (ave_all.(marker).meanL_z2+sdL_z2)'; sdLMin_z2=(ave_all.(marker).meanL_z2-sdL_z2)';
    % mean +/- SD across decisions
    sdLPlus_y  = (ave_all.(marker).meanL_y+sdL_y)'; sdLMin_y=(ave_all.(marker).meanL_y-sdL_y)';
    sdLPlus_z  = (ave_all.(marker).meanL_z+sdL_z)'; sdLMin_z=(ave_all.(marker).meanL_z-sdL_z)';


    if plot_indiv

        %% X-Y plots (left-right target choice)
        fxy=figure(); set(fxy, 'WindowStyle', 'Docked');
        % HIGH CONFIDENCE
        % mean decision 1 (left target)
        plot(ave_all.(marker).meanH_x1,ave_all.(marker).meanH_y1,'LineWidth',wd,'color',hConf_col);
        hold on;
        % mean decision 2 (right target)
        plot(ave_all.(marker).meanH_x2,ave_all.(marker).meanH_y2,'LineWidth',wd,'color',hConf_col,'HandleVisibility','off');
        % SD shading
        inBetweenH_x1 = [sdHMin_x1, fliplr(sdHPlus_x1)];
        inBetweenH_x2 = [sdHMin_x2, fliplr(sdHPlus_x2)];
        inBetweenH_y1 = [sdHMin_y1, fliplr(sdHPlus_y1)];
        inBetweenH_y2 = [sdHMin_y2, fliplr(sdHPlus_y2)];
        fill(inBetweenH_x1, inBetweenH_y1, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
        fill(inBetweenH_x2, inBetweenH_y2, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
        % LOW CONFIDENCE
        % mean decision 1 (left target)
        plot(ave_all.(marker).meanL_x1,ave_all.(marker).meanL_y1,'LineWidth',wd,'color',lConf_col);
        % mean decision 2 (right target)
        plot(ave_all.(marker).meanL_x2,ave_all.(marker).meanL_y2,'LineWidth',wd,'color',lConf_col,'HandleVisibility','off');
        % SD shading
        inBetweenL_x1 = [sdLMin_x1, fliplr(sdLPlus_x1)];
        inBetweenL_x2 = [sdLMin_x2, fliplr(sdLPlus_x2)];
        inBetweenL_y1 = [sdLMin_y1, fliplr(sdLPlus_y1)];
        inBetweenL_y2 = [sdLMin_y2, fliplr(sdLPlus_y2)];
        fill(inBetweenL_x1, inBetweenL_y1, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
        fill(inBetweenL_x2, inBetweenL_y2, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');

        % axes labels
        xlabel('Left-right (mm)', 'FontSize', fs, 'FontWeight','bold');
        ylabel('Distance (mm)', 'FontSize', fs, 'FontWeight','bold');
        
        % add title, legend and confidence count, and save figure
        title(title_plotX);
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,fullfile(save_path,'meanPlots',title_figX));
        legend({'high confidence', 'low confidence'}, 'Location','northwest');
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
        hold off;

        %% Y-Z plots (height across distance)
        fyz=figure(); set(fyz, 'WindowStyle', 'Docked');
        % HIGH CONFIDENCE
        plot(ave_all.(marker).meanH_y,ave_all.(marker).meanH_z,'LineWidth',wd,'color',hConf_col);
        hold on;
        inBetweenH_y = [sdHMin_y, fliplr(sdHPlus_y)];
        inBetweenH_z = [sdHMin_z, fliplr(sdHPlus_z)];
        fill(inBetweenH_y, inBetweenH_z, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
        % LOW CONFIDENCE
        plot(ave_all.(marker).meanL_y,ave_all.(marker).meanL_z,'LineWidth',wd,'color',lConf_col);
        inBetweenL_y = [sdLMin_y, fliplr(sdLPlus_y)];
        inBetweenL_z = [sdLMin_z, fliplr(sdLPlus_z)];
        fill(inBetweenL_y, inBetweenL_z, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');

        % axes labels
        xlabel('Distance (mm)', 'FontSize', fs, 'FontWeight','bold');
        ylabel('Height (mm)', 'FontSize', fs, 'FontWeight','bold');

        % add title, legend and confidence count, and save figure
        title(title_plotZ);
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,fullfile(save_path,'meanPlots',title_figZ));
        legend({'high confidence', 'low confidence'}, 'Location','northwest');
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
        hold off;
    end

%% COLLECTIVE DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif which_Dec == 3

    agentsColl = {'B' 'Y'};
    colorH     = [hConf_col; hConf_col_2]; colorL = [lConf_col; lConf_col_2];

    for ag = 1:length(agentsColl)

        % needed for agent-specific labels
        title_plotX_2 = title_plotX;
        title_figX_2  = title_figX;
        title_plotZ_2 = title_plotZ;
        title_figZ_2  = title_figZ;

        % confidence count for current agent
        lo3=sum(pairS.curr_conf(pairS.curr_conf==1 & pairS.atCollDec==agentsColl{ag}));
        hi3=sum(pairS.curr_conf(pairS.curr_conf==2 & pairS.atCollDec==agentsColl{ag}))/2;
        str=['Hi: ' num2str(hi3) ', Lo: ' num2str(lo3)];
        
        % HIGH confidence
        % mean per decision: target 1 (left) and target 2 (right)
        ave_all.(marker).(agentsColl{ag}).meanH_x1 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_x2 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_y1 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_y2 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_z1 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_z2 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        % mean across decisions
        ave_all.(marker).(agentsColl{ag}).meanH_y  = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanH_z  = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        % SD per decision
        sdH_x1 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_x2 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_y1 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_y2 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_z1 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_z2 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        % SD across decisions
        sdH_y  = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdH_z  = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        % mean +/- SD per decision
        sdHPlus_x1 = (ave_all.(marker).(agentsColl{ag}).meanH_x1+sdH_x1)'; sdHMin_x1=(ave_all.(marker).(agentsColl{ag}).meanH_x1-sdH_x1)';
        sdHPlus_x2 = (ave_all.(marker).(agentsColl{ag}).meanH_x2+sdH_x2)'; sdHMin_x2=(ave_all.(marker).(agentsColl{ag}).meanH_x2-sdH_x2)';
        sdHPlus_y1 = (ave_all.(marker).(agentsColl{ag}).meanH_y1+sdH_y1)'; sdHMin_y1=(ave_all.(marker).(agentsColl{ag}).meanH_y1-sdH_y1)';
        sdHPlus_y2 = (ave_all.(marker).(agentsColl{ag}).meanH_y2+sdH_y2)'; sdHMin_y2=(ave_all.(marker).(agentsColl{ag}).meanH_y2-sdH_y2)';
        sdHPlus_z1 = (ave_all.(marker).(agentsColl{ag}).meanH_z1+sdH_z1)'; sdHMin_z1=(ave_all.(marker).(agentsColl{ag}).meanH_z1-sdH_z1)';
        sdHPlus_z2 = (ave_all.(marker).(agentsColl{ag}).meanH_z2+sdH_z2)'; sdHMin_z2=(ave_all.(marker).(agentsColl{ag}).meanH_z2-sdH_z2)';
        % mean +/- SD across decisions
        sdHPlus_y  = (ave_all.(marker).(agentsColl{ag}).meanH_y+sdH_y)'; sdHMin_y=(ave_all.(marker).(agentsColl{ag}).meanH_y-sdH_y)';
        sdHPlus_z  = (ave_all.(marker).(agentsColl{ag}).meanH_z+sdH_z)'; sdHMin_z=(ave_all.(marker).(agentsColl{ag}).meanH_z-sdH_z)';


        % LOW confidence
        % mean per decision: target 1 (left) and target 2 (right)
        ave_all.(marker).(agentsColl{ag}).meanL_x1 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_x2 = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_y1 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_y2 = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_z1 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_z2 = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        % mean across decisions
        ave_all.(marker).(agentsColl{ag}).meanL_y  = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        ave_all.(marker).(agentsColl{ag}).meanL_z  = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),3,'omitnan');
        % SD per decision
        sdL_x1 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_x2 = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_y1 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_y2 = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_z1 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_z2 = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        % SD across decisions
        sdL_y  = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        sdL_z  = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agentsColl{ag}),0,3,'omitnan');
        % mean +/- SD per decision
        sdLPlus_x1 = (ave_all.(marker).(agentsColl{ag}).meanL_x1+sdL_x1)'; sdLMin_x1=(ave_all.(marker).(agentsColl{ag}).meanL_x1-sdL_x1)';
        sdLPlus_x2 = (ave_all.(marker).(agentsColl{ag}).meanL_x2+sdL_x2)'; sdLMin_x2=(ave_all.(marker).(agentsColl{ag}).meanL_x2-sdL_x2)';
        sdLPlus_y1 = (ave_all.(marker).(agentsColl{ag}).meanL_y1+sdL_y1)'; sdLMin_y1=(ave_all.(marker).(agentsColl{ag}).meanL_y1-sdL_y1)';
        sdLPlus_y2 = (ave_all.(marker).(agentsColl{ag}).meanL_y2+sdL_y2)'; sdLMin_y2=(ave_all.(marker).(agentsColl{ag}).meanL_y2-sdL_y2)';
        sdLPlus_z1 = (ave_all.(marker).(agentsColl{ag}).meanL_z1+sdL_z1)'; sdLMin_z1=(ave_all.(marker).(agentsColl{ag}).meanL_z1-sdL_z1)';
        sdLPlus_z2 = (ave_all.(marker).(agentsColl{ag}).meanL_z2+sdL_z2)'; sdLMin_z2=(ave_all.(marker).(agentsColl{ag}).meanL_z2-sdL_z2)';
        % mean +/- SD across decisions
        sdLPlus_y  = (ave_all.(marker).(agentsColl{ag}).meanL_y+sdL_y)'; sdLMin_y=(ave_all.(marker).(agentsColl{ag}).meanL_y-sdL_y)';
        sdLPlus_z  = (ave_all.(marker).(agentsColl{ag}).meanL_z+sdL_z)'; sdLMin_z=(ave_all.(marker).(agentsColl{ag}).meanL_z-sdL_z)';


        if plot_indiv

            %% X-Y plots (left-right target choice)
            fxy=figure(); set(fxy, 'WindowStyle', 'Docked');
            % HIGH CONFIDENCE
            plot(ave_all.(marker).(agentsColl{ag}).meanH_x1,ave_all.(marker).(agentsColl{ag}).meanH_y1,'LineWidth',wd,'color',hConf_col);
            hold on;
            plot(ave_all.(marker).(agentsColl{ag}).meanH_x2,ave_all.(marker).(agentsColl{ag}).meanH_y2,'LineWidth',wd,'color',hConf_col,'HandleVisibility','off');
            inBetweenH_x1 = [sdHMin_x1, fliplr(sdHPlus_x1)];
            inBetweenH_x2 = [sdHMin_x2, fliplr(sdHPlus_x2)];
            inBetweenH_y1 = [sdHMin_y1, fliplr(sdHPlus_y1)];
            inBetweenH_y2 = [sdHMin_y2, fliplr(sdHPlus_y2)];
            fill(inBetweenH_x1, inBetweenH_y1, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            fill(inBetweenH_x2, inBetweenH_y2, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            % LOW CONFIDENCE
            plot(ave_all.(marker).(agentsColl{ag}).meanL_x1,ave_all.(marker).(agentsColl{ag}).meanL_y1,'LineWidth',wd,'color',lConf_col);
            plot(ave_all.(marker).(agentsColl{ag}).meanL_x2,ave_all.(marker).(agentsColl{ag}).meanL_y2,'LineWidth',wd,'color',lConf_col,'HandleVisibility','off');
            inBetweenL_x1 = [sdLMin_x1, fliplr(sdLPlus_x1)];
            inBetweenL_x2 = [sdLMin_x2, fliplr(sdLPlus_x2)];
            inBetweenL_y1 = [sdLMin_y1, fliplr(sdLPlus_y1)];
            inBetweenL_y2 = [sdLMin_y2, fliplr(sdLPlus_y2)];
            fill(inBetweenL_x1, inBetweenL_y1, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            fill(inBetweenL_x2, inBetweenL_y2, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');

            % axes labels
            xlabel('Left-right (mm)', 'FontSize', fs, 'FontWeight','bold');
            ylabel('Distance (mm)', 'FontSize', fs, 'FontWeight','bold');

            % add title, legend and confidence count, and save figure
            if ag==1
                legend({'high confidence B', 'low confidence B'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(fullfile([title_plotX,' - B']));
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_figX(1:end-4) '_' agentsColl{ag} '.png']));
                hold off;
            elseif ag==2
                legend({'high confidence Y', 'low confidence Y'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(fullfile([title_plotX_2,' - Y']));
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_figX_2(1:end-4) '_' agentsColl{ag} '.png']));
                hold off;
            end
            
            %% Y-Z plots (height across distance)
            fyz=figure(); set(fyz, 'WindowStyle', 'Docked');
            % HIGH CONFIDENCE
            plot(ave_all.(marker).(agentsColl{ag}).meanH_y,ave_all.(marker).(agentsColl{ag}).meanH_z,'LineWidth',wd,'color',hConf_col);
            hold on;
            inBetweenH_y = [sdHMin_y, fliplr(sdHPlus_y)];
            inBetweenH_z = [sdHMin_z, fliplr(sdHPlus_z)];
            fill(inBetweenH_y, inBetweenH_z, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            % LOW CONFIDENCE
            plot(ave_all.(marker).(agentsColl{ag}).meanL_y,ave_all.(marker).(agentsColl{ag}).meanL_z,'LineWidth',wd,'color',lConf_col);
            inBetweenL_y = [sdLMin_y, fliplr(sdLPlus_y)];
            inBetweenL_z = [sdLMin_z, fliplr(sdLPlus_z)];
            fill(inBetweenL_y, inBetweenL_z, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');

            % axes labels
            xlabel('Distance (mm)', 'FontSize', fs, 'FontWeight','bold');
            ylabel('Height (mm)', 'FontSize', fs, 'FontWeight','bold');
            
            % add title, legend and confidence count, and save figure
            if ag==1
                legend({'high confidence B', 'low confidence B'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(fullfile([title_plotZ,' - B']));
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_figZ(1:end-4) '_' agentsColl{ag} '.png']));
                hold off;
            elseif ag==2
                legend({'high confidence Y', 'low confidence Y'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(fullfile([title_plotZ_2,' - Y']));
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_figZ_2(1:end-4) '_' agentsColl{ag} '.png']));
                hold off;
            end
        end

    end

end
