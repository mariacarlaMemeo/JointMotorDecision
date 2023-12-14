% -------------------------------------------------------------------------
% Here we can plot our data "offline", using the _post (or _bkp) .mat file
% -------------------------------------------------------------------------

% Notes:
% Temporal variables in matrix 'all_time_traj_ulna/index/coll_'
% Spatial variables in matrix 'all_spa_traj_ulna/index/coll_'
% Temporal and spatial variables:
% Velocity      - 1st column of matrix
% Acceleration  - 2nd column of matrix
% Jerk          - 3rd column of matrix
% x-coordinate  - 1st column of matrix
% y-coordinate  - 2nd column of matrix -> currently not plotted
% z-coordinate  - 3rd column of matrix

clear; close all; clc;

% Check the computer running the script
[~, name] = system('hostname');

if strcmp(name(1:end-1),'DESKTOP-1C66RTI')
    data_dir  = 'D:\DATA\Processed';
elseif strcmp(name(1:end-1),'IITCMONLAP008')
    data_dir  = 'D:\joint-motor-decision\kin_data\Processed';
end

% Which pair(s) to plot?
[file, path] = uigetfile(data_dir,'.mat','MultiSelect','on');
% If the user select only one file it just load .mat file. Otherwise it
% loads one .mat file in a for loop and keeps the info about the mean
% trajectories of each agent and each level of confidence (1-2)
ave_all.V.time   = []; ave_all.A.time   = []; ave_all.J.time   = [];
ave_all.X.space  = []; ave_all.Y.space  = []; ave_all.Z.space  = [];
meanHall_V.index = []; meanLall_V.index = []; meanHall_V.ulna  = []; meanLall_V.ulna  = [];
meanHall_A.index = []; meanLall_A.index = []; meanHall_A.ulna  = []; meanLall_A.ulna  = [];
meanHall_Z.index = []; meanLall_Z.index = []; meanHall_Z.ulna  = []; meanLall_Z.ulna  = [];
meanHall_Y.index = []; meanLall_Y.index = []; meanHall_Y.ulna  = []; meanLall_Y.ulna  = [];

if ischar(file)%only 1 input
    n_pr = 1;%number of pairs
     flag_multiple = 0;
elseif iscell(file)
    n_pr = length(file);
    flag_multiple = 1;
end

list_ignore = {'session' 'c3d_config'}; % ignore those variable (do not load them)
list_ignore = strjoin(list_ignore','$|'); % join into string, separating vars by '|'

% for loop for the specific decision
list_Dec = [1 2 3];

for dec = 1%1:length(list_Dec)


    for sel_p=1:n_pr

        if ischar(file)%only 1 input
            %load(fullfile(path,file));
            load([fullfile(path,file)], '-regexp', ['^(?!' list_ignore ')\w']);
        elseif iscell(file)            
            ave_all.pairID = file{sel_p}(1:4);
            %in case of multiple inputs: load each pair at the beginning of the loop before setting the flags
            load([fullfile(path,file{sel_p})], '-regexp', ['^(?!' list_ignore ')\w']);
        end

        % Set flags ---------------------------------------------------------------
        which_Dec      = dec;%select the decision
        % Do you want to plot means +- variability (SD or SEM)
        plot_sd        = 1;
        % Do you want to apply a median split (yes=1, no=0)
        % If no median split, then assigment is the following: 1-3=lo, 4-6=high
        show_med_split = 1;
        % Which variability to plot?
        dev            = 1; % 1=SD, 2=SEM
        % Do you want to plot the individual agents or just the grand average?
        plot_indiv     = 1;
        %number of variables to plot
        n_var          = 2;
        % -------------------------------------------------------------------------

        % XXX adapt this for many pairs
        if show_med_split==0
            bConf = pairS.blue_Conf;
            yConf = pairS.yell_Conf;
            collConf = pairS.Coll_Conf;
            bConf(bConf<4)  = 1;
            bConf(bConf>=4) = 2;
            yConf(yConf<4)  = 1;
            yConf(yConf>=4) = 2;
            collConf(collConf<4)  = 1;
            collConf(collConf>=4) = 2;
            pairS.bConf = bConf;
            pairS.yConf = yConf;
            pairS.collConf = collConf;
        end

        % Prepare for loop structure below
        if which_Dec == 1 || which_Dec ==2
            agents = {'B' 'Y'};
        elseif which_Dec == 3
            agents = {'coll'};
        end
        mrks        = {'index' 'ulna'};
        time_param  = {'velocity' 'acceleration' 'jerk'};
        spa_param   = {'x' 'y' 'z'};

        %% Start looping through agents / markers / parameters
        % agent loop: blue, yellow
        for g = 1:length(agents) % -------------------------------------------

            if agents{g}=='B'
                pairS.curr_conf = pairS.bConf;
                pairS.curr_dec  = pairS.blue_Dec;
            elseif agents{g}=='Y'
                pairS.curr_conf = pairS.yConf;
                pairS.curr_dec  = pairS.yell_Dec;
            elseif strcmp(agents{g},'coll')
                pairS.curr_conf = pairS.collConf;
                pairS.curr_dec  = pairS.Coll_Dec;
            end

            lo1=sum(pairS.curr_conf(pairS.curr_conf==1 & pairS.at1stDec==agents{g}));
            hi1=sum(pairS.curr_conf(pairS.curr_conf==2 & pairS.at1stDec==agents{g}))/2;
            lo2=sum(pairS.curr_conf(pairS.curr_conf==1 & pairS.at2ndDec==agents{g}));
            hi2=sum(pairS.curr_conf(pairS.curr_conf==2 & pairS.at2ndDec==agents{g}))/2;
            if which_Dec==1
                strCount=['Hi: ' num2str(hi1) ', Lo: ' num2str(lo1)];
            elseif which_Dec==2
                strCount=['Hi: ' num2str(hi2) ', Lo: ' num2str(lo2)];
            elseif which_Dec==3
                strCount=[];
            end

            % marker loop: index, ulna
            for m = 1:length(mrks)

                if n_var == 1
                    % time parameter loop: velocity, acceleration, jerk
                    for param = 1:2%length(time_param)
                        if param == 1
                            lab_time = 'V';
                        elseif param == 2
                            lab_time = 'A';
                        elseif param == 3
                            lab_time = 'J';
                        end
                        title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                        title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                        %go into plotting function
                        if plot_sd
                            ave_all.(lab_time).time = plot_offline_fun_sd(ave_all.(lab_time).time,eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),mrks{m},param,pairS,...
                                agents{g},title_plot,title_fig,data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                        else
                            ave_all = plot_offline_fun(eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),mrks{m},param,pairS,...
                                agents{g},title_plot,title_fig,data_dir,n_var,[],which_Dec,flag_bin,strCount);
                        end
                    end

                    % spatial parameter loop: x-dimension (left-right), y-dimension (forward), z-dimension (height)
                    for sparam = 1:length(spa_param)
                        if sparam == 1
                            lab_space = 'X';
                        elseif sparam == 2
                            lab_space = 'Y';
                        elseif sparam == 3
                            lab_space = 'Z';
                        end
                        title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                        title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                        % go into plotting function
                        if plot_sd
                            ave_all.(lab_space).space = plot_offline_fun_sd(ave_all.(lab_space).space,eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),mrks{m},sparam,pairS,...
                                agents{g},title_plot,title_fig,data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                        else
                            ave_all = plot_offline_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),mrks{m},sparam,pairS,...
                                agents{g},title_plot,title_fig,data_dir,n_var,[],which_Dec,flag_bin,strCount);
                        end
                    end
                end

                % x-y and y-z plots
                if n_var == 2
                    title_plot = [upper(mrks{m}) ' - ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                    title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' mrks{m} '_dec' num2str(which_Dec) '.png'];

                    ave_all = plot_offline_fun_sd(ave_all,eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),mrks{m},[],pairS,...
                        agents{g},title_plot,title_fig,data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                end

            end % end of marker loop

            %% Build a pragmatic matrix
            if n_var ==1 && flag_multiple% collect temporal variables

                if dec == 3
                    if g == 1
                        ave_all.V.time.index = ave_all.V.time.index.B;
                        ave_all.A.time.index = ave_all.A.time.index.B;
                        ave_all.Z.space.index = ave_all.Z.space.index.B;
                        ave_all.V.time.ulna = ave_all.V.time.ulna.B;
                        ave_all.A.time.ulna = ave_all.A.time.ulna.B;
                        ave_all.Z.space.ulna = ave_all.Z.space.ulna.B;                        
                    elseif g == 2
                        ave_all.V.time.index = ave_all.V.time.index.Y;
                        ave_all.A.time.index = ave_all.A.time.index.Y;
                        ave_all.Z.space.index = ave_all.Z.space.index.Y;
                        ave_all.V.time.ulna = ave_all.V.time.ulna.Y;
                        ave_all.A.time.ulna = ave_all.A.time.ulna.Y;
                        ave_all.Z.space.ulna = ave_all.Z.space.ulna.Y;  
                    end
                end

                %ave_all.V represents the velocity
                meanHall_V.index = [meanHall_V.index, ave_all.V.time.index.meanH];
                meanLall_V.index = [meanLall_V.index,ave_all.V.time.index.meanL];
                meanHall_V.ulna  = [meanHall_V.ulna,ave_all.V.time.ulna.meanH];
                meanLall_V.ulna  = [meanLall_V.ulna,ave_all.V.time.ulna.meanL];
                %store ave_all struct in a new variable updated per pair and agent
                name_struct = [(ave_all.pairID) 'mean_V' agents{g}];
                eval([(name_struct) '= ave_all.V;'])

                %ave_all.A represents the acceleration
                meanHall_A.index = [meanHall_A.index, ave_all.A.time.index.meanH];
                meanLall_A.index = [meanLall_A.index,ave_all.A.time.index.meanL];
                meanHall_A.ulna  = [meanHall_A.ulna,ave_all.A.time.ulna.meanH];
                meanLall_A.ulna  = [meanLall_A.ulna,ave_all.A.time.ulna.meanL];
                name_struct = [(ave_all.pairID) 'mean_A' agents{g}];
                eval([(name_struct) '= ave_all.A;'])

                %ave_all.Z.space represents the z coordinate
                meanHall_Z.index = [meanHall_Z.index, ave_all.Z.space.index.meanH];
                meanLall_Z.index = [meanLall_Z.index,ave_all.Z.space.index.meanL];
                meanHall_Z.ulna  = [meanHall_Z.ulna,ave_all.Z.space.ulna.meanH];
                meanLall_Z.ulna  = [meanLall_Z.ulna,ave_all.Z.space.ulna.meanL];
                name_struct = [(ave_all.pairID) 'mean_Z' agents{g}];
                eval([(name_struct) '= ave_all.Z;'])

            end

            if n_var == 2 && flag_multiple % collect spatial variables

                if dec == 3
                    if g == 1
                        ave_all.index = ave_all.index.B;
                        ave_all.ulna  = ave_all.ulna.B;
                    elseif g == 2
                        ave_all.index = ave_all.index.Y;
                        ave_all.ulna  = ave_all.ulna.Y;
                    end
                end

                %ave_all.Z.space represents the z coordinate
                meanHall_Z.index = [meanHall_Z.index, ave_all.index.meanH_z];
                meanLall_Z.index = [meanLall_Z.index, ave_all.index.meanL_z];
                meanHall_Z.ulna  = [meanHall_Z.ulna, ave_all.ulna.meanH_z];
                meanLall_Z.ulna  = [meanLall_Z.ulna, ave_all.ulna.meanL_z];
                %ave_all.Y.space represents the Y coordinate
                meanHall_Y.index = [meanHall_Y.index, ave_all.index.meanH_y];
                meanLall_Y.index = [meanLall_Y.index, ave_all.index.meanL_y];
                meanHall_Y.ulna  = [meanHall_Y.ulna, ave_all.ulna.meanH_y];
                meanLall_Y.ulna  = [meanLall_Y.ulna, ave_all.ulna.meanL_y];

                name_struct = [(ave_all.pairID) 'mean_YZ' agents{g}];
                eval([(name_struct) '= ave_all;'])

            end

            % Save number of plotted (i.e., clean!) trials in which either agent
            % blue or yellow took 2nd decision (in sum, this is the total number of
            % clean trials for this pair); trials_clean contains two values (b/y)
            if (which_Dec == 1 || which_Dec ==2)
                %add the agent label to the 'ave_all' variable. the collective
                %variable already has that
                ave_all.agent   = agents{g};
                if plot_sd==0
                    trials_clean(g) = length(ave_all(~isnan(ave_all(1,pairS.at2ndDec(1:size(ave_all,2))==agents{g}))));
                end
            end
        end % end of agent loop -----------------------------------------------

        % clear variables, except those that are still needed!
        clearvars -except ave_all name data_dir sel_p n_pr file path flag_multiple...
            mrks plot_indiv dec which_Dec list_Dec data_dir n_var list_ignore...
            meanHall_V meanLall_V meanHall_A meanLall_A ...
            meanHall_Z meanLall_Z meanHall_Y meanLall_Y

    end % end of pair loop ---------------------------------------------------

    %% Plot the grand averages across pairs plus SEM
    % this is just temporary to do the plot
    wd            = 4; % line width
    hConf_col     = [0.4667 0.6745 0.1882]; % GREEN
    lConf_col     = [0.4941 0.1843 0.5569]; % PURPLE
    HiFill        = [0.7529 0.9412 0.5059];
    LoFill        = [0.8235 0.4392 0.9020];
    x_width       = 18;
    y_width       = 12;
    x = [1:100, fliplr(1:100)]; % sample length of x-axis

    % Calculate the average across multiple pairs
    var_list = {'V' 'A' 'Z'};

    if flag_multiple
        for m = 1:length(mrks)

            if n_var == 1 % velocity, acc, z-coordinate

                for v = 1:length(var_list)

                    if strcmp(var_list{v},'V')
                        meanHall = meanHall_V;
                        meanLall = meanLall_V;
                    elseif strcmp(var_list{v},'A')
                        meanHall = meanHall_A;
                        meanLall = meanLall_A;
                    elseif strcmp(var_list{v},'Z')
                        meanHall = meanHall_Z;
                        meanLall = meanLall_Z;
                    end

                    grandAveH = mean(meanHall.(mrks{m}),2);
                    grandAveL = mean(meanLall.(mrks{m}),2);
                    grandSdH  = std(meanHall.(mrks{m}),0,2);
                    grandSdL  = std(meanLall.(mrks{m}),0,2);

                    grandSemH = grandSdH/sqrt(length(grandAveH));
                    grandSemL = grandSdL/sqrt(length(grandAveH));

                    grandSemHPlus= (grandAveH+grandSemH)';
                    grandSemLPlus= (grandAveL+grandSemL)';
                    grandSemHMin= (grandAveH-grandSemH)';
                    grandSemLMin= (grandAveL-grandSemL)';

                    grandinBetweenH = [grandSemHMin, fliplr(grandSemHPlus)];
                    grandinBetweenL = [grandSemLMin, fliplr(grandSemLPlus)];

                    ap = figure(); % create figure
                    set(ap, 'WindowStyle', 'Docked');
                    plot(grandAveH, 'Color',hConf_col);
                    hold on;
                    plot(grandAveL,'Color',lConf_col);
                    fill(x, grandinBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                    fill(x, grandinBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                    title_plot = ['grandAverage ' upper(mrks{m}) ' - ' var_list{v} ', dec' num2str(which_Dec)];
                    title(title_plot);
                    title_fig = ['grandAve_' upper(mrks{m}) '_' var_list{v} '_dec' num2str(which_Dec) '.png'];

                    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                    saveas(gcf,fullfile(data_dir,'meanPlots',title_fig));
                    hold off;

                end

            elseif n_var == 2 % only Y-Z (can be adapted to Z-X)

                zmeanHall = meanHall_Z;
                zmeanLall = meanLall_Z;
                ymeanHall = meanHall_Y;
                ymeanLall = meanLall_Y;

                % z
                zgrandAveH = mean(zmeanHall.(mrks{m}),2);
                zgrandAveL = mean(zmeanLall.(mrks{m}),2);
                zgrandSdH  = std(zmeanHall.(mrks{m}),0,2);
                zgrandSdL  = std(zmeanLall.(mrks{m}),0,2);

                zgrandSemH = zgrandSdH/sqrt(length(zgrandAveH));
                zgrandSemL = zgrandSdL/sqrt(length(zgrandAveH));

                zgrandSemHPlus= (zgrandAveH+zgrandSemH)';
                zgrandSemLPlus= (zgrandAveL+zgrandSemL)';
                zgrandSemHMin= (zgrandAveH-zgrandSemH)';
                zgrandSemLMin= (zgrandAveL-zgrandSemL)';

                zgrandinBetweenH = [zgrandSemHMin, fliplr(zgrandSemHPlus)];
                zgrandinBetweenL = [zgrandSemLMin, fliplr(zgrandSemLPlus)];

                % y
                ygrandAveH = mean(ymeanHall.(mrks{m}),2);
                ygrandAveL = mean(ymeanLall.(mrks{m}),2);
                ygrandSdH  = std(ymeanHall.(mrks{m}),0,2);
                ygrandSdL  = std(ymeanLall.(mrks{m}),0,2);

                ygrandSemH = ygrandSdH/sqrt(length(ygrandAveH));
                ygrandSemL = ygrandSdL/sqrt(length(ygrandAveH));

                ygrandSemHPlus= (ygrandAveH+ygrandSemH)';
                ygrandSemLPlus= (ygrandAveL+ygrandSemL)';
                ygrandSemHMin= (ygrandAveH-ygrandSemH)';
                ygrandSemLMin= (ygrandAveL-ygrandSemL)';

                ygrandinBetweenH = [ygrandSemHMin, fliplr(ygrandSemHPlus)];
                ygrandinBetweenL = [ygrandSemLMin, fliplr(ygrandSemLPlus)];

                ap = figure(); % create figure
                set(ap, 'WindowStyle', 'Docked');
                plot(ygrandAveH, zgrandAveH,'Color',hConf_col);
                hold on;
                plot(ygrandAveL, zgrandAveL, 'Color',lConf_col);
                fill(ygrandinBetweenH, zgrandinBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                fill(ygrandinBetweenL, zgrandinBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');

                % save plot
                title_plot = ['grandAverage ' upper(mrks{m}) ' - Y-Z coordinates, dec' num2str(which_Dec)];
                title(title_plot);
                title_fig = ['grandAve_' upper(mrks{m}) '_YZ_dec' num2str(which_Dec) '.png'];
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(data_dir,'meanPlots',title_fig));
                hold off;

            end
        end
    end
end % decision loop
