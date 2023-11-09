function ave_all = ave_subj_plotting_fun(matrix_3d,clm,pairS,...
    agents,title_plot,title_fig,save_path,n_var,threshold, ...
    which_Dec,flag_bin)

% -------------------------------------------------------------------------
% -> We plot kin. variables for all trials (only 2nd decision), per agent.
% -------------------------------------------------------------------------
% This function is called from "ave_subj_plotting_new.m"
% Note: "trials" actually means "decisions"

% Set some parameters first
wd            = 4;
hConf_col     = [.6 0 0];  % red
lConf_col     = [0.2 0.8 0.8]; % blueish
lConf_col_ave = [0 .6 .6]; % slightly different blueish for averages
x_width       = 16;
y_width       = 12;

%% Plotting trajectories (colored according to confidence - high/low)

% Plotting one variable (across time/frames)
if n_var==1

    % "squeeze" first to change format XXX
    ave_all = squeeze(matrix_3d(:,clm,:)); % data named "ave_all" now

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
    % ---------------------------------------------------------------------

    matrix_3d(:,clm,unique(c)) = nan;
    ave_all(:,unique(c))       = nan;

    biv = figure(); % create figure
    set(biv, 'WindowStyle', 'Docked');

    if which_Dec == 1
        % plot single trials
        plot(ave_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents),'color',hConf_col); % high confidence
        hold on;
        plot(ave_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents),'color',lConf_col); % low confidence
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col); % average high confidence
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==1 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave); % average low confidence
        end

    elseif which_Dec == 2 % only second decision

        % plot single trials
        plot(ave_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents),'color',hConf_col); % high confidence
        indeces = 1:length(ave_all);
        sel_lab = indeces(pairS.at2ndDec==agents);
        text(1:length(sel_lab),ave_all(1,pairS.at2ndDec==agents),string(sel_lab))
        hold on;
        plot(ave_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents),'color',lConf_col); % low confidence
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col); % average high confidence
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave); % average low confidence
        end

    elseif which_Dec == 3
        % plot single trials
        plot(ave_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents),'color',hConf_col); % high confidence
        hold on;
        plot(ave_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents),'color',lConf_col); % low confidence
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==2 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col); % average high confidence
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==1 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave); % average low confidence
        end

    elseif which_Dec == 4 % both first and second decision (collective is currently not included)
        % plot single trials
        plot(ave_all(:,pairS.curr_conf==2),'color',hConf_col); % high confidence
        hold on;
        plot(ave_all(:,pairS.curr_conf==1),'color',lConf_col); % low confidence
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==2),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col); % average high confidence
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==1),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave); % average low confidence
        end

    end

    title(title_plot);
    
    % save each figure with the specified dimensions
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig));
    hold off;

    % Plotting two variables (i.e., spatial x-y plots, not across time/frames)
elseif n_var==2

    % "squeeze" to adjust data format
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
    % ---------------------------------------------------------------------

    matrix_3d(:,1,c_out) = nan;
    matrix_3d(:,2,c_out) = nan;
    ave_x_all(:,c_out)   = nan;
    ave_y_all(:,c_out)   = nan;

    yiz=figure(); % create figure
    set(yiz, 'WindowStyle', 'Docked');

    if which_Dec == 1
        % plot single trials
        plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents), ...
            ave_y_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents), ...
            ave_y_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents),'color',lConf_col);
        % plot average trajectories only if data has been normalized (not feasible otherwise)
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
                'LineWidth',wd,'color',lConf_col_ave);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
        end

    elseif which_Dec == 2 % only second decision
        % plot single trials
        plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents), ...
            ave_y_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents), ...
            ave_y_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents),'color',lConf_col);
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            % high confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            % low confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
        end

    elseif which_Dec == 3
        % plot single trials
        plot(ave_x_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents), ...
            ave_y_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents), ...
            ave_y_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents),'color',lConf_col);
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            % high confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            % low confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
        end

    elseif which_Dec == 4 % both first and second decision (collective is currently not included)
        % plot single trials
        plot(ave_x_all(:,pairS.curr_conf==2),ave_y_all(:,pairS.curr_conf==2),'color',hConf_col);
        hold on;
        plot(ave_x_all(:,pairS.curr_conf==1),ave_y_all(:,pairS.curr_conf==1),'color',lConf_col);
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            % high confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col);
            % low confidence - target 1 (left) and target 2 (right)
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
            plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
                mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col_ave);
        end

    end

    title(title_plot);
    % save each figure with the specified dimensions
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig))
    hold off;

end % end of plotting
