function ave_all = plot_offline_fun_sd(ave_all,matrix_3d,marker,clm,pairS,...
    agents,title_plot,title_fig,save_path,n_var,threshold, ...
    which_Dec,flag_bin,str,dev)

% -------------------------------------------------------------------------
% -> We plot means +- variability for kin. variables, per agent.
% -------------------------------------------------------------------------
% This function is called from "plot_offline.m"

% Set some parameters first
wd            = 4; % line width
hConf_col     = [0.4667 0.6745 0.1882]; % GREEN
hConf_col_2   = [0.3922 0.8314 0.0745]; % variation of green to distinguish agents
lConf_col     = [0.4941 0.1843 0.5569]; % PURPLE
lConf_col_2   = [0.7176 0.2745 1.0000]; % variation of purple to distinguish agents
HiFill        = [0.7529 0.9412 0.5059];
LoFill        = [0.8235 0.4392 0.9020];
x_width       = 18;
y_width       = 12;
x = [1:100, fliplr(1:100)]; % sample length of x-axis
if which_Dec==3
    title_fig=title_fig(1:end-4);
end

%% Plotting trajectories (colored according to confidence - high/low)

% Plotting one variable (across time/frames)
if n_var==1

    % "squeeze" first to change format XXX
    matrix_sqz = squeeze(matrix_3d(:,clm,:)); % data named "ave_all" now

    % The following is done to remove weird trials, -----------------------
    % but we currently do NOT use this: "threshold" = []
    if length(threshold)==1
        if threshold>0
            [~,c]=find(matrix_sqz>threshold);
        else
            [~,c]=find(matrix_sqz<threshold);
        end
    elseif length(threshold)==2
        [~,c]=find(matrix_sqz<threshold(1) | matrix_sqz>threshold(2));
    elseif isempty(threshold)
        c=[];
    end
    % ---------------------------------------------------------------------

    matrix_3d(:,clm,unique(c)) = nan;
    matrix_sqz(:,unique(c))   = nan;

    biv = figure(); % create figure
    set(biv, 'WindowStyle', 'Docked');

    if which_Dec == 1 % plot only 1st decision
        % high confidence (mean +- variability)
        ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at1stDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
        semH    = sdH/sqrt(length(ave_all.(marker).meanH));
        semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
        plot(ave_all.(marker).meanH,'LineWidth',wd,'color',hConf_col); %mean
        hold on;
        if dev==1 % SD
            %plot(sdHPlus,'LineWidth',wd,'color',hConf_col, 'LineStyle',':'); %mean+SD
            %plot(sdHMin,'LineWidth',wd,'color',hConf_col, 'LineStyle',':'); %mean-SD
            inBetweenH = [sdHMin, fliplr(sdHPlus)];
        else % SEM
            %plot(semHPlus,'LineWidth',wd,'color',hConf_col, 'LineStyle',':'); %mean+SEM
            %plot(semHMin,'LineWidth',wd,'color',hConf_col, 'LineStyle',':'); %mean-SEM
            inBetweenH = [semHMin, fliplr(semHPlus)];
        end
        fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
        % low confidence (mean +- variability)
        ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at1stDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
        semL    = sdL/sqrt(length(ave_all.(marker).meanL));
        semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
        plot(ave_all.(marker).meanL,'LineWidth',wd,'color',lConf_col);
        hold on;
        if dev==1
            %plot(sdLPlus,'LineWidth',wd,'color',lConf_col, 'LineStyle',':'); %mean+SD
            %plot(sdLMin,'LineWidth',wd,'color',lConf_col, 'LineStyle',':'); %mean-SD
            inBetweenL = [sdLMin, fliplr(sdLPlus)];
        else
            %plot(semLPlus,'LineWidth',wd,'color',lConf_col, 'LineStyle',':'); %mean+SD
            %plot(semLMin,'LineWidth',wd,'color',lConf_col, 'LineStyle',':'); %mean-SD
            inBetweenL = [semLMin, fliplr(semLPlus)];
        end
        fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
        % add legend and confidence count
        legend({'high confidence', 'low confidence'}, 'Location','northwest');              
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');

    elseif which_Dec == 2 % only second decision
        % high confidence (mean +- variability)
        ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
        semH    = sdH/sqrt(length(ave_all.(marker).meanH));
        semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
        plot(ave_all.(marker).meanH,'LineWidth',wd,'color',hConf_col); %mean
        hold on;
        if dev==1 % SD
            inBetweenH = [sdHMin, fliplr(sdHPlus)];
        else % SEM
            inBetweenH = [semHMin, fliplr(semHPlus)];
        end
        fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
        % low confidence (mean +- variability)
        ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
        semL    = sdL/sqrt(length(ave_all.(marker).meanL));
        semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
        plot(ave_all.(marker).meanL,'LineWidth',wd,'color',lConf_col);
        hold on;
        if dev==1
            inBetweenL = [sdLMin, fliplr(sdLPlus)];
        else
            inBetweenL = [semLMin, fliplr(semLPlus)];
        end
        fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');  
        % add legend and confidence count
        legend({'high confidence', 'low confidence'}, 'Location','northwest');
        xL=xlim; yL=ylim;
        text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');

    elseif which_Dec == 3 % only collective decision
        agentsColl = {'B' 'Y'};
        styleColl  = {'-', '-'};
        colorH     = [hConf_col; hConf_col_2]; colorL = [lConf_col; lConf_col_2];
        for g = 1:length(agentsColl)
            % add a field to the output structure 
            ave_all.(marker).agent = agentsColl{g};

            % confidence count
            lo3=sum(pairS.curr_conf(pairS.curr_conf==1 & pairS.atCollDec==agentsColl{g}));
            hi3=sum(pairS.curr_conf(pairS.curr_conf==2 & pairS.atCollDec==agentsColl{g}))/2;
            str=['Hi: ' num2str(hi3) ', Lo: ' num2str(lo3)];
            if g==2
                biv = figure(); % create figure
                set(biv, 'WindowStyle', 'Docked');
            end
            % high confidence (mean +- variability)
            ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan');
            sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),0,3,'omitnan');
            sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
            semH    = sdH/sqrt(length(ave_all.(marker).meanH));
            semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
            plot(ave_all.(marker).meanH,'LineWidth',wd,'color',colorH(g,:)); %mean
            hold on;
            if dev==1 % SD
                inBetweenH = [sdHMin, fliplr(sdHPlus)];
            else % SEM
                inBetweenH = [semHMin, fliplr(semHPlus)];
            end
            fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
            % low confidence (mean +- variability)
            ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan');
            sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),0,3,'omitnan');
            sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
            semL    = sdL/sqrt(length(ave_all.(marker).meanL));
            semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
            plot(ave_all.(marker).meanL,'LineWidth',wd,'color',colorL(g,:));
            hold on;
            if dev==1
                inBetweenL = [sdLMin, fliplr(sdLPlus)];
            else
                inBetweenL = [semLMin, fliplr(semLPlus)];
            end
            fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
            if g==1
                legend({'high confidence B', 'low confidence B'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(title_plot);
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_fig '_' agentsColl{g} '.png']));
                hold off;
            elseif g==2
                legend({'high confidence Y', 'low confidence Y'}, 'Location','northwest');
                xL=xlim; yL=ylim;
                text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                title(title_plot);
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(save_path,'meanPlots',[title_fig '_' agentsColl{g} '.png']));
                hold off;
            end
        end

    elseif which_Dec == 4 % XXX 1st and 2nd decision NOT FUNCTIONAL
        % plot single trials
        plot(ave_all.(marker)(:,pairS.curr_conf==2),'color',hConf_col); % high confidence
        hold on;
        plot(ave_all.(marker)(:,pairS.curr_conf==1),'color',lConf_col); % low confidence
        % plot average trajectories only if data has been normalized (not feasible otherwise)
        if flag_bin
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==2),3,'omitnan'), ...
                'LineWidth',wd,'color',hConf_col); % average high confidence
            plot(mean(matrix_3d(:,clm,pairS.curr_conf==1),3,'omitnan'), ...
                'LineWidth',wd,'color',lConf_col); % average low confidence
        end

    end

    if which_Dec==1 || which_Dec==2
        title(title_plot);
        % save each figure with the specified dimensions
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,fullfile(save_path,'meanPlots',title_fig));
        hold off;
    end
    
end

% % Plotting two variables (i.e., spatial x-y plots, not across time/frames)
% elseif n_var==2 % CURRENTLY NOT USED, n_var is always passed as 1
% 
%     % "squeeze" to adjust data format
%     ave_x_all = squeeze(matrix_3d(:,1,:)); % 1st column is x
%     ave_y_all = squeeze(matrix_3d(:,2,:)); % 2nd column is y
% 
%     % remove outliers - CURRENTLY NOT USED --------------------------------
%     if length(threshold)>1
%         [~,cx] = find(ave_x_all<threshold(1) | ave_x_all>threshold(2));
%         [~,cy] = find(ave_y_all<threshold(3) | ave_y_all>threshold(4));
%         c_out  = unique([unique(cx); unique(cy)]);
%     elseif isempty(threshold)
%         c_out=[];
%     end
%     % ---------------------------------------------------------------------
% 
%     matrix_3d(:,1,c_out) = nan;
%     matrix_3d(:,2,c_out) = nan;
%     ave_x_all(:,c_out)   = nan;
%     ave_y_all(:,c_out)   = nan;
% 
%     yiz=figure(); % create figure
%     set(yiz, 'WindowStyle', 'Docked');
% 
%     if which_Dec == 1
%         % plot single trials
%         plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==2 & pairS.at1stDec==agents),'color',hConf_col);
%         hold on;
%         plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==1 & pairS.at1stDec==agents),'color',lConf_col);
%         % plot average trajectories only if data has been normalized (not feasible otherwise)
%         if flag_bin
%             % high confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             % low confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at1stDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%         end
% 
%     elseif which_Dec == 2 % only second decision
%         % plot single trials
%         plot(ave_x_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==2 & pairS.at2ndDec==agents),'color',hConf_col);
%         hold on;
%         plot(ave_x_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==1 & pairS.at2ndDec==agents),'color',lConf_col);
%         % plot average trajectories only if data has been normalized (not feasible otherwise)
%         if flag_bin
%             % high confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             % low confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%         end
% 
%     elseif which_Dec == 3 % only collective decision
%         % plot single trials
%         plot(ave_x_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==2 & pairS.atCollDec==agents),'color',hConf_col);
%         hold on;
%         plot(ave_x_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents), ...
%             ave_y_all(:,pairS.curr_conf==1 & pairS.atCollDec==agents),'color',lConf_col);
%         % plot average trajectories only if data has been normalized (not feasible otherwise)
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
% 
%     elseif which_Dec == 4 % XXX 1st and 2nd decision NOT FUNCTIONAL
%         % plot single trials
%         plot(ave_x_all(:,pairS.curr_conf==2),ave_y_all(:,pairS.curr_conf==2),'color',hConf_col);
%         hold on;
%         plot(ave_x_all(:,pairS.curr_conf==1),ave_y_all(:,pairS.curr_conf==1),'color',lConf_col);
%         % plot average trajectories only if data has been normalized (not feasible otherwise)
%         if flag_bin
%             % high confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==1),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==1),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==2 & pairS.curr_dec==2),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==2 & pairS.curr_dec==2),3,'omitnan'), ...
%                 'LineWidth',wd,'color',hConf_col);
%             % low confidence - target 1 (left) and target 2 (right)
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==1),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==1),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%             plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
%                 mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
%                 'LineWidth',wd,'color',lConf_col);
%         end
% 
%     end
% 
%     title(title_plot);
%     
%     % save each figure with the specified dimensions
%     set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
%     saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig)); % note: save_path=path_kin
%     hold off;
% 
% end % end of plotting
