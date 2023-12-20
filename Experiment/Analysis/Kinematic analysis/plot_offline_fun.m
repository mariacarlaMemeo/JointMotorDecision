function ave_all = plot_offline_fun(matrix_3d,~,clm,pairS,...
    agents,title_plot,title_fig,save_path,n_var,threshold, ...
    which_Dec,flag_bin,str)

% -------------------------------------------------------------------------
% -> Plot single trial trajectories + means, per agent and hi/lo confidence.
% -------------------------------------------------------------------------
% This function is called from "plot_offline.m"
% Note: "trials" actually means "decisions"

% TO DOs:
% 1. for n_var=2: adjust collective decision (not functional yet)
% 2. add axis labels everywhere
% 3. for n_var=1 and n_var=2: create two separate plots for collective


%% Preparatory steps
% Set some parameters first
wd            = 4; % line width for means
hConf_col     = [0.4667 0.6745 0.1882]; % GREEN
hConf_col_2   = [0.3922 0.8314 0.0745]; % variation of green to distinguish agents
lConf_col     = [0.4941 0.1843 0.5569]; % PURPLE
lConf_col_2   = [0.7176 0.2745 1.0000]; % variation of purple to distinguish agents
x_width       = 18; y_width = 12;
varlabx       = 'Normalized movement duration (%)';
fs            = 12; % fontsize for axis labels


%% Plot one variable (across normalized time (100 frames))
if n_var==1

    % "squeeze" first to change format
    % data for selected column (param) are named "ave_all" now
    ave_all = squeeze(matrix_3d(:,clm,:));

    % The following is done to remove weird trials, -----------------------
    % but we currently do NOT use this: "threshold" = []
    if length(threshold)==1
        if threshold>0
            [~,c]=find(ave_all>threshold);
        else
            [~,c]=find(ave_all<threshold);
        end
    elseif length(threshold)==2
        [~,c]=find(ave_all<threshold(1) | ave_all>threshold(2));
    elseif isempty(threshold)
        c=[];
    end

    matrix_3d(:,clm,unique(c)) = nan;
    ave_all(:,unique(c))       = nan;
    % ---------------------------------------------------------------------

    biv = figure(); % create figure
    set(biv, 'WindowStyle', 'Docked');

    % 1st DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if which_Dec == 1
        % plot all trials for high confidence
        plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==2 & pairS.at1stDec(1:size(ave_all,2))==agents),'color',hConf_col,'HandleVisibility','off');
        hold on;
        % plot all trials for low confidence
        plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==1 & pairS.at1stDec(1:size(ave_all,2))==agents),'color',lConf_col,'HandleVisibility','off');
        % plot averaged trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            % average high confidence
            meanH1 = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
            plot(meanH1,'LineWidth',wd,'color',hConf_col);
            hold on;
            % average low confidence
            meanL1 = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
            plot(meanL1,'LineWidth',wd,'color',lConf_col);
        end
        legend({'high confidence', 'low confidence'}, 'Location','northwest');
        % display count of high/lo confidence decisions
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');

    % 2nd DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif which_Dec == 2
        % plot all trials for high confidence
        plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==2 & pairS.at2ndDec(1:size(ave_all,2))==agents),'color',hConf_col,'HandleVisibility','off'); % high confidence
        % If you need to add trial number for each trajectory (to check)
        % indices = 1:length(ave_all); sel_lab = indices(pairS.at2ndDec==agents);
        % text(1:length(sel_lab),ave_all(1,pairS.at2ndDec==agents),string(sel_lab))
        hold on;
        % plot all trials for low confidence
        plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==1 & pairS.at2ndDec(1:size(ave_all,2))==agents),'color',lConf_col,'HandleVisibility','off'); % low confidence
        % plot average trajectories
        if flag_bin
            % average high confidence
            meanH2 = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
            plot(meanH2,'LineWidth',wd,'color',hConf_col);
            % average high confidence
            meanL2 = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
            plot(meanL2,'LineWidth',wd,'color',lConf_col);
        end
        legend({'high confidence', 'low confidence'}, 'Location','northwest');
        % display count of high/lo confidence decisions
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');

    % COLLECTIVE DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif which_Dec == 3
        agentsColl = {'B' 'Y'};
        styleColl = {'-', '-'};
        colorH = [hConf_col; hConf_col_2]; colorL = [lConf_col; lConf_col_2];
        % loop through agents (vary color by agent)
        % XXX change this and create one plot per agent!!! (see _fun_sd)
        for g = 1:length(agentsColl)
            % plot all trials for high confidence
            plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==2 & pairS.atCollDec(1:size(ave_all,2))==agentsColl{g}),'color',colorH(g,:),'HandleVisibility','off'); % high confidence
            hold on;
            % plot all trials for low confidence
            plot(ave_all(:,pairS.curr_conf(1:size(ave_all,2))==1 & pairS.atCollDec(1:size(ave_all,2))==agentsColl{g}),'color',colorL(g,:),'HandleVisibility','off'); % low confidence
            % plot average trajectories
            if flag_bin
                % average high confidence
                plot(mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan'), ...
                    'LineWidth',wd,'LineStyle',styleColl{g},'color',colorH(g,:));
                % average low confidence
                plot(mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan'), ...
                    'LineWidth',wd,'LineStyle',styleColl{g},'color',colorL(g,:));
            end
        end
        legend({'high confidence B', 'low confidence B','high confidence Y', 'low confidence Y'}, 'Location','northwest');

    end

    % add title and save figure
    title(title_plot);
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig));
    hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot two variables (spatial x-y [and y-z plots], not across time)
elseif n_var==2

    % "squeeze" to adjust data format and select params
    clm = 1; % set to 1 as a dummy (work on this, not optimal XXX)
    ave_all   = squeeze(matrix_3d(:,clm,:));
    ave_x_all = squeeze(matrix_3d(:,1,:)); % 1st column is x
    ave_y_all = squeeze(matrix_3d(:,2,:)); % 2nd column is y

    % remove outliers - CURRENTLY NOT USED --------------------------------
    if length(threshold)>1
        [~,cx] = find(ave_x_all<threshold(1) | ave_x_all>threshold(2));
        [~,cy] = find(ave_y_all<threshold(3) | ave_y_all>threshold(4));
        c_out  = unique([unique(cx); unique(cy)]);
    elseif isempty(threshold)
        c_out=[];
    end

    matrix_3d(:,1,c_out) = nan;
    matrix_3d(:,2,c_out) = nan;
    ave_x_all(:,c_out)   = nan;
    ave_y_all(:,c_out)   = nan;
    % ---------------------------------------------------------------------

    yiz=figure(); % create figure
    set(yiz, 'WindowStyle', 'Docked');

    % 1st DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if which_Dec == 1
        % plot all trials for high/low confidence
        plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents), ...
            ave_y_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents), ...
            ave_y_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents),'color',lConf_col);
        % plot average trajectories
        if flag_bin
            % high confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            % low confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col);
        end

    % 2nd DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif which_Dec == 2
        % plot all trials for high/low confidence
        plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents), ...
            ave_y_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents), ...
            ave_y_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents),'color',lConf_col);
        % plot average trajectories
        if flag_bin
            % high confidence - target 1 (left) and target 2 (right)
            % 2nd argument in matrix_3d is dimension (1=x,2=y,3=z)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            % low confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col);
        end

    % COLLECTIVE DECISION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     elseif which_Dec == 3
%         % plot all trials for high/low confidence
%         plot(ave_x_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents),'color',hConf_col);
%         hold on;
%         plot(ave_x_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents),'color',lConf_col);
%         % plot average trajectories
%         if flag_bin
%             % high confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             % low confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%         end

    end

    % add title and save figure
    title(title_plot);
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig));
    hold off;

end
