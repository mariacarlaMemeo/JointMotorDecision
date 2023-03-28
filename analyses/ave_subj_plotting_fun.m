function ave_subj_plotting_fun(matrix_3d,clm,ag_Conf,ag_Dec,SecondDec,agent2ndDec,title_plot,title_fig,save_path,n_var,threshold,flag_2nd)
% 28.03.23
%settings
wd = 4; ls =':';
b_dashed = [0.1176 0.2353 0.7451];
y_solid  = [0.8 0.4667 0.1333];
y_dashed = [0.9412 0.7843 0.1569];
hConf_col = [.6 0 0];
lConf_col = [0 .6 .6];

%plot 1 var
if n_var==1
    %remove outliers
    ave_all = squeeze(matrix_3d(:,clm,:));
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
    ave_all(:,unique(c)) = nan;

    biv=figure();set(biv, 'WindowStyle', 'Docked');
    title(title_plot);
    if flag_2nd
        % plot single trials
        plot(ave_all(:,ag_Conf==2 & SecondDec==agent2ndDec),'color',hConf_col);hold on;%plot all trials high confidence
        plot(ave_all(:,ag_Conf==1 & SecondDec==agent2ndDec),'color',lConf_col+.2);%plot all trials low confidence
        % plot averages
        plot(mean(matrix_3d(:,clm,ag_Conf==2 & SecondDec==agent2ndDec),3,'omitnan'),'LineWidth',wd,'color',hConf_col);%plot average value of high confidence
        plot(mean(matrix_3d(:,clm,ag_Conf==1 & SecondDec==agent2ndDec),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
    else
        % plot single trials
        plot(ave_all(:,ag_Conf==2),'color',hConf_col);hold on;%plot all trials high confidence
        plot(ave_all(:,ag_Conf==1),'color',lConf_col+.2);%plot all trials low confidence
        % plot averages
        plot(mean(matrix_3d(:,clm,ag_Conf==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);%plot average value of high confidence
        plot(mean(matrix_3d(:,clm,ag_Conf==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
    end
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig))
    hold off;

elseif n_var==2 %only for xy plots
    ave_x_all = squeeze(matrix_3d(:,1,:));%here I want always the FIRST COLUMN because it represents x
    ave_y_all = squeeze(matrix_3d(:,2,:));%here I want always the SECOND COLUMN because it represents y

    %remove outliers
    [~,cx] = find(ave_x_all<threshold(1) | ave_x_all>threshold(2));
    [~,cy] = find(ave_y_all<threshold(3) | ave_y_all>threshold(4));
    c_out  = unique([unique(cx); unique(cy)]);
    matrix_3d(:,1,c_out) = nan;
    matrix_3d(:,2,c_out) = nan;
    ave_x_all(:,c_out) = nan;
    ave_y_all(:,c_out) = nan;

    yiz=figure();set(yiz, 'WindowStyle', 'Docked');
    title(title_plot);
    if flag_2nd
        % plot single trials
        plot(ave_x_all(:,ag_Conf==2 & SecondDec==agent2ndDec),ave_y_all(:,ag_Conf==2),'color',hConf_col);hold on;
        plot(ave_x_all(:,ag_Conf==1 & SecondDec==agent2ndDec),ave_y_all(:,ag_Conf==1),'color',lConf_col+.2);
        % plot averages
        %high conf (left and right targets)
        plot(mean(matrix_3d(:,1,ag_Conf==2 & ag_Dec==1 & SecondDec==agent2ndDec),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==2 & ag_Dec==1),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
        plot(mean(matrix_3d(:,1,ag_Conf==2 & ag_Dec==2 & SecondDec==agent2ndDec),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==2 & ag_Dec==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
        %low conf (left and right targets)
        plot(mean(matrix_3d(:,1,ag_Conf==1 & ag_Dec==1 & SecondDec==agent2ndDec),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==1 & ag_Dec==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
        plot(mean(matrix_3d(:,1,ag_Conf==1 & ag_Dec==2 & SecondDec==agent2ndDec),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==1 & ag_Dec==2),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
    else
        % plot single trials
        plot(ave_x_all(:,ag_Conf==2),ave_y_all(:,ag_Conf==2),'color',hConf_col);hold on;
        plot(ave_x_all(:,ag_Conf==1),ave_y_all(:,ag_Conf==1),'color',lConf_col+.2);
        % plot averages
        %high conf (left and right targets)
        plot(mean(matrix_3d(:,1,ag_Conf==2 & ag_Dec==1),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==2 & ag_Dec==1),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
        plot(mean(matrix_3d(:,1,ag_Conf==2 & ag_Dec==2),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==2 & ag_Dec==2),3,'omitnan'),'LineWidth',wd,'color',hConf_col);
        %low conf (left and right targets)
        plot(mean(matrix_3d(:,1,ag_Conf==1 & ag_Dec==1),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==1 & ag_Dec==1),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
        plot(mean(matrix_3d(:,1,ag_Conf==1 & ag_Dec==2),3,'omitnan'),mean(matrix_3d(:,2,ag_Conf==1 & ag_Dec==2),3,'omitnan'),'LineWidth',wd,'color',lConf_col);
    end
    saveas(gcf,fullfile(save_path,'exploratoryPlots',title_fig))
    hold off;
end