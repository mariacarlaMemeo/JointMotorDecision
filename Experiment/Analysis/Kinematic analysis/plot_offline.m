% -------------------------------------------------------------------------
% Here we can plot our data "offline", using the _post (or _bkp) .mat file
% -------------------------------------------------------------------------

% Notes on temporal and spatial variables:
% Temporal variables in matrix 'all_time_traj_ulna/index/coll_'
% Spatial variables in matrix 'all_spa_traj_ulna/index/coll_'
% Velocity      - 1st column of matrix
% Acceleration  - 2nd column of matrix
% Jerk          - 3rd column of matrix
% x-coordinate  - 1st column of matrix
% y-coordinate  - 2nd column of matrix
% z-coordinate  - 3rd column of matrix

clear; close all; clc;

%% Load data and do preparatory steps

% Check automatically which computer is running the script ----------------
% and adjust directory path accordingly
[~, name] = system('hostname');
if strcmp(name(1:end-1),'DESKTOP-1C66RTI')
    data_dir  = 'D:\DATA\Processed';
elseif strcmp(name(1:end-1),'IITCMONLAP008')
    data_dir  = 'D:\joint-motor-decision\kin_data\Processed';
end

% User input: select which pair(s) to plot
[file, path] = uigetfile(data_dir,'.mat','MultiSelect','on');
% Set number of pairs (n_pr) and flag_multiple according to user input
if ischar(file)          % only 1 input
    n_pr = 1;            % number of pairs
    flag_multiple = 0;
elseif iscell(file)      % several inputs
    n_pr = length(file); % number of pairs
    flag_multiple = 1;
end

% Do not load full kinematic session to save time
list_ignore = {'session' 'c3d_config'}; % define which variable NOT to load
list_ignore = strjoin(list_ignore','$|'); % create string, separate vars by '|'
%--------------------------------------------------------------------------

% Pre-allocate structures to store variables for multiple pairs
ave_all.V.time   = []; ave_all.A.time   = []; ave_all.J.time   = [];
ave_all.X.space  = []; ave_all.Y.space  = []; ave_all.Z.space  = [];
meanHall_V.index = []; meanLall_V.index = []; meanHall_V.ulna  = []; meanLall_V.ulna  = [];
meanHall_A.index = []; meanLall_A.index = []; meanHall_A.ulna  = []; meanLall_A.ulna  = [];
meanHall_Z.index = []; meanLall_Z.index = []; meanHall_Z.ulna  = []; meanLall_Z.ulna  = [];
meanHall_Y.index = []; meanLall_Y.index = []; meanHall_Y.ulna  = []; meanLall_Y.ulna  = [];

% Set some more parameters
list_Dec    = [1 2 3];
mrks        = {'index' 'ulna'};
time_param  = {'velocity' 'acceleration' 'jerk'};
spa_param   = {'x' 'y' 'z'};


%% START DECISION LOOP: run through all three decisions
for dec = 1%1:length(list_Dec)

    % pair loop: run through this for all selected pairs (n_pr = number of pairs)
    for sel_p = 1:n_pr

        % load pairs *before* setting the flags (to avoid overwriting)
        if ischar(file) % load only 1 pair
            load([fullfile(path,file)], '-regexp', ['^(?!' list_ignore ')\w']);
        elseif iscell(file) % load several pairs            
            ave_all.pairID = file{sel_p}(1:4);
            load([fullfile(path,file{sel_p})], '-regexp', ['^(?!' list_ignore ')\w']);
        end

        % set flags -------------------------------------------------------
        which_Dec      = dec; % which_Dec is equivalent to dec (loop var)
        plot_indiv     = 0; % Plots for individual agents? (1=yes, 0=no)
        n_var          = 2; % Plot which variables? (1=V,A,Z,X; 2=XY,YZ)
        plot_sd        = 1; % Plot variability? (1=yes, 0=no)
        dev            = 1; % Which variability? (1=SD, 2=SEM)
        show_med_split = 1; % Apply a median split? (1=yes, 0=no)      
        % -----------------------------------------------------------------

        % if no median split: define confidence as low (1-3) and high (4-6)
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

        % prepare for loop structure below
        if which_Dec == 1 || which_Dec ==2
            agents = {'B' 'Y'};
        elseif which_Dec == 3
            agents = {'coll'};
        end


        %% Start looping through agents / markers / parameters
        % AGENT LOOP: B,Y OR coll %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for g = 1:length(agents)

            % select variables according to agent
            if agents{g}=='B'
                pairS.curr_conf = pairS.bConf; % confidence (1-6)
                pairS.curr_dec  = pairS.blue_Dec; % decision (1 or 2)
            elseif agents{g}=='Y'
                pairS.curr_conf = pairS.yConf;
                pairS.curr_dec  = pairS.yell_Dec;
            elseif strcmp(agents{g},'coll')
                pairS.curr_conf = pairS.collConf;
                pairS.curr_dec  = pairS.Coll_Dec;
            end

            % compute percentage of high/low confidence for 1st and 2nd dec
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

            % MARKER LOOP: index, ulna %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for m = 1:length(mrks)

                % n_var=1: plot variables across normalized time
                if n_var == 1
                    % time param loop: velocity, acceleration, jerk
                    for param = 1:2%length(time_param)
                        if param == 1
                            lab_time = 'V';
                        elseif param == 2
                            lab_time = 'A';
                        elseif param == 3
                            lab_time = 'J';
                        end
                        title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' ...
                                      agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                        title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' time_param{param}(1) ...
                                      'm_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                        % CALL PLOTTING FUNCTION plot_offline_fun(_sd)
                        if plot_sd
                            ave_all.(lab_time).time = plot_offline_fun_sd(ave_all.(lab_time).time, ...
                                                      eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]), ...
                                                      mrks{m},param,pairS,agents{g},title_plot,title_fig, ...
                                                      data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                        else
                            ave_all = plot_offline_fun(eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]), ...
                                      mrks{m},param,pairS,agents{g},title_plot,title_fig, ...
                                      data_dir,n_var,[],which_Dec,flag_bin,strCount);
                        end
                    end

                    % spatial param loop: x-dimension (left-right), y-dimension (forward), z-dimension (height)
                    for sparam = 1:length(spa_param)
                        if sparam == 1
                            lab_space = 'X';
                        elseif sparam == 2
                            lab_space = 'Y';
                        elseif sparam == 3
                            lab_space = 'Z';
                        end
                        title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' ...
                                      agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                        title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' spa_param{sparam} ...
                                      ' coord_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                        % CALL PLOTTING FUNCTION plot_offline_fun(_sd)
                        if plot_sd
                            ave_all.(lab_space).space = plot_offline_fun_sd(ave_all.(lab_space).space, ...
                                                        eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]), ...
                                                        mrks{m},sparam,pairS,agents{g},title_plot,title_fig, ...
                                                        data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                        else
                            ave_all = plot_offline_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]), ...
                                      mrks{m},sparam,pairS,agents{g},title_plot,title_fig, ...
                                      data_dir,n_var,[],which_Dec,flag_bin,strCount);
                        end
                    end
                end

                % n_var=2: plot two spatial varibles x-y and y-z 
                % Note: spatial variables are time-normalized in movement_var.m
                if n_var == 2
                    title_plot = [upper(mrks{m}) ' - ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                    title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                    % CALL PLOTTING FUNCTION plot_offline_fun_sd
                    ave_all = plot_offline_fun_sd(ave_all,eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]), ...
                              mrks{m},[],pairS,agents{g},title_plot,title_fig, ...
                              data_dir,n_var,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                end

            end % end of marker loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            %% Build pragmatic matrix to collect variables for all pairs
            % This is done to later plot the GRAND AVERAGE across pairs.
            % Note: do this only if multiple pairs have been selected
            if n_var ==1 && flag_multiple % one variable across norm. time

                if dec == 3 % use a trick for collective decision
                    if g == 1 % assign according to g which specifies agent
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

                % Velocity (ave_all.V.time)
                meanHall_V.index = [meanHall_V.index, ave_all.V.time.index.meanH];
                meanLall_V.index = [meanLall_V.index,ave_all.V.time.index.meanL];
                meanHall_V.ulna  = [meanHall_V.ulna,ave_all.V.time.ulna.meanH];
                meanLall_V.ulna  = [meanLall_V.ulna,ave_all.V.time.ulna.meanL];
                % store ave_all struct in a new variable per pair and agent
                name_struct = [(ave_all.pairID) 'mean_V' agents{g}];
                eval([(name_struct) '= ave_all.V;'])

                % Acceleration (ave_all.A.time)
                meanHall_A.index = [meanHall_A.index, ave_all.A.time.index.meanH];
                meanLall_A.index = [meanLall_A.index,ave_all.A.time.index.meanL];
                meanHall_A.ulna  = [meanHall_A.ulna,ave_all.A.time.ulna.meanH];
                meanLall_A.ulna  = [meanLall_A.ulna,ave_all.A.time.ulna.meanL];
                name_struct = [(ave_all.pairID) 'mean_A' agents{g}];
                eval([(name_struct) '= ave_all.A;'])

                % Height/z-coordinate (ave_all.Z.space)
                meanHall_Z.index = [meanHall_Z.index, ave_all.Z.space.index.meanH];
                meanLall_Z.index = [meanLall_Z.index,ave_all.Z.space.index.meanL];
                meanHall_Z.ulna  = [meanHall_Z.ulna,ave_all.Z.space.ulna.meanH];
                meanLall_Z.ulna  = [meanLall_Z.ulna,ave_all.Z.space.ulna.meanL];
                name_struct = [(ave_all.pairID) 'mean_Z' agents{g}];
                eval([(name_struct) '= ave_all.Z;'])

            end

            if n_var == 2 && flag_multiple % two spatial variables

                if dec == 3 % use a trick for collective decision
                    if g == 1 % assign according to g which specifies agent
                        ave_all.index = ave_all.index.B;
                        ave_all.ulna  = ave_all.ulna.B;
                    elseif g == 2
                        ave_all.index = ave_all.index.Y;
                        ave_all.ulna  = ave_all.ulna.Y;
                    end
                end

                % Height/z-coordinate (ave_all.Z)
                meanHall_Z.index = [meanHall_Z.index, ave_all.index.meanH_z];
                meanLall_Z.index = [meanLall_Z.index, ave_all.index.meanL_z];
                meanHall_Z.ulna  = [meanHall_Z.ulna, ave_all.ulna.meanH_z];
                meanLall_Z.ulna  = [meanLall_Z.ulna, ave_all.ulna.meanL_z];
                % Distance/y-coordinate (ave_all.Y)
                meanHall_Y.index = [meanHall_Y.index, ave_all.index.meanH_y];
                meanLall_Y.index = [meanLall_Y.index, ave_all.index.meanL_y];
                meanHall_Y.ulna  = [meanHall_Y.ulna, ave_all.ulna.meanH_y];
                meanLall_Y.ulna  = [meanLall_Y.ulna, ave_all.ulna.meanL_y];
                name_struct = [(ave_all.pairID) 'mean_YZ' agents{g}];
                eval([(name_struct) '= ave_all;'])

            end

            % THIS IS NOT STRICLTY NECESSARY (already done in main script)
            % Save number of plotted (i.e., clean!) trials in which either 
            % agent B or Y took 2nd decision (in sum, this is the total
            % number of clean trials for the pair).
            % trials_clean contains two values (b/y)
            if (which_Dec == 1 || which_Dec ==2)
                % Add the agent label to the 'ave_all' variable.
                % (this label is already there for the collective ave_all)
                ave_all.agent = agents{g};
                if plot_sd==0
                    trials_clean(g) = ...
                    length(ave_all(~isnan(ave_all(1,pairS.at2ndDec(1:size(ave_all,2))==agents{g}))));
                end
            end
        
        end % end of agent loop -------------------------------------------

        % clear variables, except those that are still needed!
        clearvars -except ave_all name data_dir sel_p n_pr file path flag_multiple...
            mrks plot_indiv dec which_Dec list_Dec data_dir n_var list_ignore...
            meanHall_V meanLall_V meanHall_A meanLall_A ...
            meanHall_Z meanLall_Z meanHall_Y meanLall_Y

    end % end of pair loop ------------------------------------------------

    
    %% Plot the grand averages across pairs plus SEM (for current dec)
    
    % set plotting parameters
    wd            = 4; % line width
    hConf_col     = [0.4667 0.6745 0.1882]; % GREEN
    lConf_col     = [0.4941 0.1843 0.5569]; % PURPLE
    HiFill        = [0.7529 0.9412 0.5059];
    LoFill        = [0.8235 0.4392 0.9020];
    x_width       = 18; y_width = 12; % size of saved figure
    var_list      = {'V' 'A' 'Z'};
    fs            = 12; % fontsize for axis labels
    x = [1:100, fliplr(1:100)]; % normalized sample length of x-axis   
   
    % start plotting (if multiple pairs have been selected)
    % note: plots are created either for n_var=1 OR n_var=2
    if flag_multiple
        
        for m = 1:length(mrks)

            if n_var == 1 % velocity, acceleration, z-coordinate

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

                    % mean and std
                    grandAveH = mean(meanHall.(mrks{m}),2);
                    grandAveL = mean(meanLall.(mrks{m}),2);
                    grandSdH  = std(meanHall.(mrks{m}),0,2);
                    grandSdL  = std(meanLall.(mrks{m}),0,2);
                    % sem
                    grandSemH = grandSdH/sqrt(length(grandAveH));
                    grandSemL = grandSdL/sqrt(length(grandAveH));
                    % mean +/- sem
                    grandSemHPlus= (grandAveH+grandSemH)';
                    grandSemLPlus= (grandAveL+grandSemL)';
                    grandSemHMin= (grandAveH-grandSemH)';
                    grandSemLMin= (grandAveL-grandSemL)';
                    % prepare shaded filling
                    grandinBetweenH = [grandSemHMin, fliplr(grandSemHPlus)];
                    grandinBetweenL = [grandSemLMin, fliplr(grandSemLPlus)];

                    % create figure and plot means +/- sem
                    ap = figure();
                    set(ap, 'WindowStyle', 'Docked');
                    plot(grandAveH, 'Color',hConf_col);
                    hold on;
                    plot(grandAveL,'Color',lConf_col);
                    fill(x, grandinBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                    fill(x, grandinBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                    title_plot = ['grandAverage ' upper(mrks{m}) ' - ' var_list{v} ', dec' num2str(which_Dec)];
                    title(title_plot);
                    title_fig = ['grandAve_' upper(mrks{m}) '_' var_list{v} '_dec' num2str(which_Dec) '.png'];
                    % save figure
                    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                    saveas(gcf,fullfile(data_dir,'meanPlots',title_fig));
                    hold off;

                end

            elseif n_var == 2 % only Y-Z (can be adapted to Z-X)

                % adjust names for easier spelling
                zmeanHall = meanHall_Z;
                zmeanLall = meanLall_Z;
                ymeanHall = meanHall_Y;
                ymeanLall = meanLall_Y;

                % Z-coordinate
                % mean and std
                zgrandAveH = mean(zmeanHall.(mrks{m}),2);
                zgrandAveL = mean(zmeanLall.(mrks{m}),2);
                zgrandSdH  = std(zmeanHall.(mrks{m}),0,2);
                zgrandSdL  = std(zmeanLall.(mrks{m}),0,2);
                % sem
                zgrandSemH = zgrandSdH/sqrt(length(zgrandAveH));
                zgrandSemL = zgrandSdL/sqrt(length(zgrandAveH));
                % mean +/- sem
                zgrandSemHPlus= (zgrandAveH+zgrandSemH)';
                zgrandSemLPlus= (zgrandAveL+zgrandSemL)';
                zgrandSemHMin= (zgrandAveH-zgrandSemH)';
                zgrandSemLMin= (zgrandAveL-zgrandSemL)';
                % prepare shaded filling
                zgrandinBetweenH = [zgrandSemHMin, fliplr(zgrandSemHPlus)];
                zgrandinBetweenL = [zgrandSemLMin, fliplr(zgrandSemLPlus)];

                % Y-coordinate
                % mean and std
                ygrandAveH = mean(ymeanHall.(mrks{m}),2);
                ygrandAveL = mean(ymeanLall.(mrks{m}),2);
                ygrandSdH  = std(ymeanHall.(mrks{m}),0,2);
                ygrandSdL  = std(ymeanLall.(mrks{m}),0,2);
                % sem
                ygrandSemH = ygrandSdH/sqrt(length(ygrandAveH));
                ygrandSemL = ygrandSdL/sqrt(length(ygrandAveH));
                % mean +/- sem
                ygrandSemHPlus= (ygrandAveH+ygrandSemH)';
                ygrandSemLPlus= (ygrandAveL+ygrandSemL)';
                ygrandSemHMin= (ygrandAveH-ygrandSemH)';
                ygrandSemLMin= (ygrandAveL-ygrandSemL)';
                % prepare shaded filling
                ygrandinBetweenH = [ygrandSemHMin, fliplr(ygrandSemHPlus)];
                ygrandinBetweenL = [ygrandSemLMin, fliplr(ygrandSemLPlus)];

                % create figure and plot means +/- sem
                ap = figure(); % create figure
                set(ap, 'WindowStyle', 'Docked');
                plot(ygrandAveH, zgrandAveH,'Color',hConf_col, 'Marker','*');
                hold on;
                plot(ygrandAveL, zgrandAveL, 'Color',lConf_col, 'Marker','*');
                fill(ygrandinBetweenH, zgrandinBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off');
                fill(ygrandinBetweenL, zgrandinBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');

                % axes labels
                xlabel('Distance [mm]', 'FontSize', fs, 'FontWeight','bold');
                ylabel('Height [mm]', 'FontSize', fs, 'FontWeight','bold');
                                
                % save plot
                title_plot = ['grandAverage ' upper(mrks{m}) ' - Y-Z coordinates, dec' num2str(which_Dec)];
                title(title_plot);
                title_fig = ['grandAve_' upper(mrks{m}) '_YZ_dec' num2str(which_Dec) '.png'];
                set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
                saveas(gcf,fullfile(data_dir,'meanPlots',title_fig));
                hold off;

            end         
        end    
    end % end of plotting grand averages (for n_var=1 OR n_var=2, for current dec)

end % end of decision loop
