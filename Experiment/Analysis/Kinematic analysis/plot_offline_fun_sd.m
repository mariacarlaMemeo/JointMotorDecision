function ave_all = plot_offline_fun_sd(ave_all,matrix_3d,marker,clm,pairS,...
    agents,title_plot,title_fig,save_path,n_var,threshold, ...
    which_Dec,flag_bin,str,dev,plot_indiv)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
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
            fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
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
            fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
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
            fill(x, inBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
            % add legend and confidence count
            legend({'high confidence', 'low confidence'}, 'Location','northwest');
            xL=xlim; yL=ylim;
            text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
        end

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
            if g==2 && plot_indiv
                biv = figure(); % create figure
                set(biv, 'WindowStyle', 'Docked');
            end
            % high confidence (mean +- variability)
            ave_all.(marker).meanH   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan');
            sdH     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),0,3,'omitnan');
            sdHPlus = (ave_all.(marker).meanH+sdH)'; sdHMin=(ave_all.(marker).meanH-sdH)';
            semH    = sdH/sqrt(length(ave_all.(marker).meanH));
            semHPlus=(ave_all.(marker).meanH+semH)'; semHMin=(ave_all.(marker).meanH-semH)';
            if plot_indiv
                plot(ave_all.(marker).meanH,'LineWidth',wd,'color',colorH(g,:)); %mean
                hold on;
                if dev==1 % SD
                    inBetweenH = [sdHMin, fliplr(sdHPlus)];
                else % SEM
                    inBetweenH = [semHMin, fliplr(semHPlus)];
                end
                fill(x, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
            end
            % low confidence (mean +- variability)
            ave_all.(marker).meanL   = mean(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),3,'omitnan');
            sdL     = std(matrix_3d(:,clm,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.atCollDec(1:size(matrix_3d,3))==agentsColl{g}),0,3,'omitnan');
            sdLPlus = (ave_all.(marker).meanL+sdL)'; sdLMin=(ave_all.(marker).meanL-sdL)';
            semL    = sdL/sqrt(length(ave_all.(marker).meanL));
            semLPlus= (ave_all.(marker).meanL+semL)'; semLMin=(ave_all.(marker).meanL-semL)';
            if plot_indiv
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

    % plot 1st or 2nd decision
    if which_Dec == 1 || which_Dec == 2

        if which_Dec == 1
            atDec = pairS.at1stDec;
        elseif whic_Dec ==2
            atDec = pairS.at2ndDec;
        end
        
        %% X-Y plots
        % high confidence - target 1 (left) and target 2 (right)
        % mean
        ave_all.(marker).meanH_x1   = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_x2   = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_y1   = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_y2   = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_z1   = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_z2   = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        % mean for both decisions
        ave_all.(marker).meanH_y    = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanH_z    = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        % SD
        sdH_x1   = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_x2   = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_y1   = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_y2   = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_z1   = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_z2   = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        % SD for both decisions
        sdH_y    = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdH_z    = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        % +/- SD
        sdHPlus_x1 = (ave_all.(marker).meanH_x1+sdH_x1)'; sdHMin_x1=(ave_all.(marker).meanH_x1-sdH_x1)';
        sdHPlus_x2 = (ave_all.(marker).meanH_x2+sdH_x2)'; sdHMin_x2=(ave_all.(marker).meanH_x2-sdH_x2)';
        sdHPlus_y1 = (ave_all.(marker).meanH_y1+sdH_y1)'; sdHMin_y1=(ave_all.(marker).meanH_y1-sdH_y1)';
        sdHPlus_y2 = (ave_all.(marker).meanH_y2+sdH_y2)'; sdHMin_y2=(ave_all.(marker).meanH_y2-sdH_y2)';
        sdHPlus_z1 = (ave_all.(marker).meanH_z1+sdH_z1)'; sdHMin_z1=(ave_all.(marker).meanH_z1-sdH_z1)';
        sdHPlus_z2 = (ave_all.(marker).meanH_z2+sdH_z2)'; sdHMin_z2=(ave_all.(marker).meanH_z2-sdH_z2)';
        %for both decisions
        sdHPlus_y  = (ave_all.(marker).meanH_y+sdH_y)'; sdHMin_y=(ave_all.(marker).meanH_y-sdH_y)';
        sdHPlus_z  = (ave_all.(marker).meanH_z+sdH_z)'; sdHMin_z=(ave_all.(marker).meanH_z-sdH_z)';
        

        % low confidence (mean +- variability)
        ave_all.(marker).meanL_x1   = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_x2   = mean(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_y1   = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_y2   = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_z1   = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_z2   = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        %for both decisions
        ave_all.(marker).meanL_y    = mean(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');
        ave_all.(marker).meanL_z    = mean(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),3,'omitnan');

        sdL_x1   = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_x2   = std(matrix_3d(:,1,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_y1   = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_y2   = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_z1   = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_z2   = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & pairS.curr_dec(1:size(matrix_3d,3))==2 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        %for both decisions
        sdL_y    = std(matrix_3d(:,2,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        sdL_z    = std(matrix_3d(:,3,pairS.curr_conf(1:size(matrix_3d,3))==1 & atDec(1:size(matrix_3d,3))==agents),0,3,'omitnan');
        
        sdLPlus_x1 = (ave_all.(marker).meanL_x1+sdL_x1)'; sdLMin_x1=(ave_all.(marker).meanL_x1-sdL_x1)';
        sdLPlus_x2 = (ave_all.(marker).meanL_x2+sdL_x2)'; sdLMin_x2=(ave_all.(marker).meanL_x2-sdL_x2)';
        sdLPlus_y1 = (ave_all.(marker).meanL_y1+sdL_y1)'; sdLMin_y1=(ave_all.(marker).meanL_y1-sdL_y1)';
        sdLPlus_y2 = (ave_all.(marker).meanL_y2+sdL_y2)'; sdLMin_y2=(ave_all.(marker).meanL_y2-sdL_y2)';
        sdLPlus_z1 = (ave_all.(marker).meanL_z1+sdL_z1)'; sdLMin_z1=(ave_all.(marker).meanL_z1-sdL_z1)';
        sdLPlus_z2 = (ave_all.(marker).meanL_z2+sdL_z2)'; sdLMin_z2=(ave_all.(marker).meanL_z2-sdL_z2)';
        %for both decisions
        sdLPlus_y  = (ave_all.(marker).meanL_y+sdL_y)'; sdLMin_y=(ave_all.(marker).meanL_y-sdL_y)';
        sdLPlus_z  = (ave_all.(marker).meanL_z+sdL_z)'; sdLMin_z=(ave_all.(marker).meanL_z-sdL_z)';
        
        if plot_indiv
            % x_axis = 1:length(ave_all.(marker).meanH_y1);
            fxy=figure(); set(fxy, 'WindowStyle', 'Docked');
            plot(ave_all.(marker).meanH_x1,ave_all.(marker).meanH_y1,'LineWidth',wd,'color',hConf_col); %mean, decision 1
            hold on;
            plot(ave_all.(marker).meanH_x2,ave_all.(marker).meanH_y2,'LineWidth',wd,'color',hConf_col,'HandleVisibility','off'); %mean, decision 2
            % inBetweenH = [sdHMin_x1, fliplr(sdHPlus)];
            % fill(x_axis, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
            plot(ave_all.(marker).meanL_x1,ave_all.(marker).meanL_y1,'LineWidth',wd,'color',lConf_col); %mean, decision 1
            plot(ave_all.(marker).meanL_x2,ave_all.(marker).meanL_y2,'LineWidth',wd,'color',lConf_col,'HandleVisibility','off'); %mean, decision 2
            % inBetweenH = [sdHMin_x1, fliplr(sdHPlus)];
            % fill(x_axis, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability

            % add title, legend and confidence count, and save figure
            title(title_plotX);
            set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
            saveas(gcf,fullfile(save_path,'meanPlots',title_figX));
            legend({'high confidence', 'low confidence'}, 'Location','northwest');
            xL=xlim; yL=ylim;
            text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
            hold off;
            
        end

        %% Z-Y plots
        if plot_indiv
            % x_axis = 1:length(ave_all.(marker).meanH_y1);
            fyz=figure(); set(fyz, 'WindowStyle', 'Docked');
            plot(ave_all.(marker).meanH_y,ave_all.(marker).meanH_z,'LineWidth',wd,'color',hConf_col); %mean
            hold on;
            % inBetweenH = [sdHMin_x1, fliplr(sdHPlus)];
            % fill(x_axis, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability
            plot(ave_all.(marker).meanL_y,ave_all.(marker).meanL_z,'LineWidth',wd,'color',lConf_col); %mean
            % inBetweenH = [sdHMin_x1, fliplr(sdHPlus)];
            % fill(x_axis, inBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off'); % shading between +- variability

            % add title, legend and confidence count, and save figure
            title(title_plotZ);
            set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
            saveas(gcf,fullfile(save_path,'meanPlots',title_figZ));
            legend({'high confidence', 'low confidence'}, 'Location','northwest');
            xL=xlim; yL=ylim;
            text(0.99*xL(2),0.99*yL(2),str,'HorizontalAlignment','right','VerticalAlignment','top');
            hold off;
        end


    elseif which_Dec == 2 % only second decision

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
            'LineWidth',wd,'color',lConf_col);
        plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
            mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.at2ndDec==agents),3,'omitnan'), ...
            'LineWidth',wd,'color',lConf_col);

    elseif which_Dec == 3 % only collective decision

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
            'LineWidth',wd,'color',lConf_col);
        plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
            mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2 & pairS.atCollDec==agents),3,'omitnan'), ...
            'LineWidth',wd,'color',lConf_col);

    elseif which_Dec == 4 % XXX 1st and 2nd decision NOT FUNCTIONAL

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
            'LineWidth',wd,'color',lConf_col);
        plot(mean(matrix_3d(:,1,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
            mean(matrix_3d(:,2,pairS.curr_conf==1 & pairS.curr_dec==2),3,'omitnan'), ...
            'LineWidth',wd,'color',lConf_col);

    end


end
