function ave_all = plot_offline_fun_sd(ave_all,matrix_3d,marker,clm,pairS,...
    agents,title_plot,title_fig,save_path,n_var,threshold, ...
    which_Dec,flag_bin,str,dev,plot_indiv)

% -------------------------------------------------------------------------
% -> We plot means +- variability for kin. variables, per agent.
% -------------------------------------------------------------------------
% This function is called from "plot_offline.m"

% Set some parameters first
wd            = 2; % line width
hConf_col     = [0.4667 0.6745 0.1882]; % GREEN
hConf_col_2   = [0.3922 0.8314 0.0745]; % variation of green to distinguish agents
lConf_col     = [0.4941 0.1843 0.5569]; % PURPLE
lConf_col_2   = [0.7176 0.2745 1.0000]; % variation of purple to distinguish agents
HiFill        = [0.7529 0.9412 0.5059];
LoFill        = [0.8235 0.4392 0.9020];
x_width       = 18; y_width = 12; % size of saved figure
varlabx       = 'Normalized movement duration (%)';
fs            = 12; % fontsize for axis labels
x = [1:100, fliplr(1:100)]; % sample length of x-axis
if which_Dec==3
    title_fig=title_fig(1:end-4);
end

% % Add labels for y-axis
% % !!! Note: labels need to passed to function, otherwise too complicated...
% if ~isempty(clm) % for n_var=2, we do not pass the param variable (it's [])
%     if clm==1
%         varlaby = 'Velocity (mm/s)';
%     elseif clm==2
%         varlaby = 'Acceleration (mm/s^2)';
%     elseif clm==3
%         varlaby = 'Jerk (mm/s^3)';
%     end
% end

%% Plotting trajectories (colored according to confidence - high/low)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting one variable (across time/frames)
if n_var==1

    % "squeeze" first to change format
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

    if plot_indiv
        biv = figure(); % create figure
        set(biv, 'WindowStyle', 'Docked');
    end

    if which_Dec == 1 % plot only 1st decision
        % high confidence (mean +- variability)
        ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at1stDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
        semH    = sdH/sqrt(length(ave_all.(marker).meanH));
        semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
        if plot_indiv
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
            fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off'); % shading between +- variability
        end
        % low confidence (mean +- variability)
        ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at1stDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at1stDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
        semL    = sdL/sqrt(length(ave_all.(marker).meanL));
        semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
        if plot_indiv
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
            fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            % add axes labels
            xlabel(varlabx, 'FontSize', fs, 'FontWeight','bold');
            % add legend and confidence count
            legend({'high confidence', 'low confidence'}, 'Location','northwest');
            xL=xlim; yL=ylim;
            text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
        end

    elseif which_Dec == 2 % only second decision
        % high confidence (mean +- variability)
        ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
        semH    = sdH/sqrt(length(ave_all.(marker).meanH));
        semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
        if plot_indiv
            plot(ave_all.(marker).meanH,'LineWidth',wd,'color',hConf_col); %mean
            hold on;
            if dev==1 % SD
                inBetweenH = [sdHMin, fliplr(sdHPlus)];
            else % SEM
                inBetweenH = [semHMin, fliplr(semHPlus)];
            end
            fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off'); % shading between +- variability
        end
        % low confidence (mean +- variability)
        ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.at2ndDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
        semL    = sdL/sqrt(length(ave_all.(marker).meanL));
        semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
        if plot_indiv
            plot(ave_all.(marker).meanL,'LineWidth',wd,'color',lConf_col);
            hold on;
            if dev==1
                inBetweenL = [sdLMin, fliplr(sdLPlus)];
            else
                inBetweenL = [semLMin, fliplr(semLPlus)];
            end
            fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off');
            % add axes labels
            xlabel(varlabx, 'FontSize', fs, 'FontWeight','bold');
            % add legend and confidence count
            legend({'high confidence', 'low confidence'}, 'Location','northwest');
            xL=xlim; yL=ylim;
            text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
        end

    elseif which_Dec == 3 % only collective decision
        agentsColl = {'B' 'Y'};
        %styleColl  = {'-', '-'};
        colorH     = [hConf_col; hConf_col_2]; colorL = [lConf_col; lConf_col_2];
        for a = 1:length(agentsColl)
            % confidence count
            lo3=sum(pairS.curr_conf(pairS.curr_conf==1 & pairS.atCollDec==agentsColl{a}));
            hi3=sum(pairS.curr_conf(pairS.curr_conf==2 & pairS.atCollDec==agentsColl{a}))/2;
            str=['Hi: ' num2str(hi3) ', Lo: ' num2str(lo3)];
            if a==2 && plot_indiv
                biv = figure(); % create figure
                set(biv, 'WindowStyle', 'Docked');
            end
            % high confidence (mean +- variability)
            ave_all.(marker).(agentsColl{a}).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{a}),3,'omitnan');
            sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{a}),0,3,'omitnan');
            sdHPlus = (ave_all.(marker).(agentsColl{a}).meanH+sdH)'; sdHMin=(ave_all.(marker).(agentsColl{a}).meanH-sdH)';
            semH    = sdH/sqrt(length(ave_all.(marker).(agentsColl{a}).meanH));
            semHPlus=(ave_all.(marker).(agentsColl{a}).meanH+semH)'; semHMin=(ave_all.(marker).(agentsColl{a}).meanH-semH)';
            if plot_indiv
                plot(ave_all.(marker).(agentsColl{a}).meanH,'LineWidth',wd,'color',colorH(a,:)); %mean
                hold on;
                if dev==1 % SD
                    inBetweenH = [sdHMin, fliplr(sdHPlus)];
                else % SEM
                    inBetweenH = [semHMin, fliplr(semHPlus)];
                end
                fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'LineStyle','none','HandleVisibility','off'); % shading between +- variability
            end
            % low confidence (mean +- variability)
            ave_all.(marker).(agentsColl{a}).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{a}),3,'omitnan');
            sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{a}),0,3,'omitnan');
            sdLPlus = (ave_all.(marker).(agentsColl{a}).meanL+sdL)'; sdLMin=(ave_all.(marker).(agentsColl{a}).meanL-sdL)';
            semL    = sdL/sqrt(length(ave_all.(marker).(agentsColl{a}).meanL));
            semLPlus= (ave_all.(marker).(agentsColl{a}).meanL+semL)'; semLMin=(ave_all.(marker).(agentsColl{a}).meanL-semL)';
            if plot_indiv
                plot(ave_all.(marker).(agentsColl{a}).meanL,'LineWidth',wd,'color',colorL(a,:));
                hold on;
                if dev==1
                    inBetweenL = [sdLMin, fliplr(sdLPlus)];
                else
                    inBetweenL = [semLMin, fliplr(semLPlus)];
                end
                fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                % add axes labels
                xlabel(varlabx, 'FontSize', fs, 'FontWeight','bold');
                if a==1
                    legend({'high confidence B', 'low confidence B'}, 'Location','northwest');
                    xL=xlim; yL=ylim;
                    text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                    title(title_plot);
                    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                    saveas(gcf,fullfile(save_path,'meanPlots',[title_fig '_' agentsColl{a} '.png']));
                    hold off;
                elseif a==2
                    legend({'high confidence Y', 'low confidence Y'}, 'Location','northwest');
                    xL=xlim; yL=ylim;
                    text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
                    title(title_plot);
                    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                    saveas(gcf,fullfile(save_path,'meanPlots',[title_fig '_' agentsColl{a} '.png']));
                    hold off;
                end
            end
        end
    end

    if (which_Dec==1 || which_Dec==2) && plot_indiv
        title(title_plot);
        % save each figure with the specified dimensions
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,fullfile(save_path,'meanPlots',title_fig));
        hold off;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting two variables (spatial x-y and y-z plots, not across time)
elseif n_var==2

    % titles
    title_plotX = [title_plot ', XYaxis'];
    title_figX  = [title_fig(1:end-4) '_XYaxis.png'];
    title_plotZ = [title_plot ', YZaxis'];
    title_figZ  = [title_fig(1:end-4) '_YZaxis.png'];

    % "squeeze" to adjust data format
    matrix_sqz_X = squeeze(matrix_3d(:,1,:)); % 1st column is x
    matrix_sqz_Y = squeeze(matrix_3d(:,2,:)); % 2nd column is y
    matrix_sqz_Z = squeeze(matrix_3d(:,3,:)); % 3rd column is z

    % remove outliers - CURRENTLY NOT USED --------------------------------
    if length(threshold)>1
        [~,cx] = find(matrix_sqz_X<threshold(1) | matrix_sqz_X>threshold(2));
        [~,cy] = find(matrix_sqz_Y<threshold(3) | matrix_sqz_Y>threshold(4));
        [~,cz] = find(matrix_sqz_Z<threshold(5) | matrix_sqz_Z>threshold(6));
        c_out  = unique([unique(cx); unique(cy); unique(cz)]);
    elseif isempty(threshold)
        c_out=[];
    end
    % ---------------------------------------------------------------------

    matrix_3d(:,1,c_out)  = nan; matrix_3d(:,2,c_out)  = nan; matrix_3d(:,3,c_out)  = nan;
    matrix_sqz_X(:,c_out) = nan; matrix_sqz_Y(:,c_out) = nan; matrix_sqz_Z(:,c_out) = nan;

    % plot 1st, 2nd decision or collective decision
    plot_offline_nvar2;

end
