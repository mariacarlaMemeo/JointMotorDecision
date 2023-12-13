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

% Do you want to plot the individual agents or just the grand average?
plot_indiv = 0;

% Check the computer running the script
[~, name] = system('hostname');

if strcmp(name(1:end-1),'DESKTOP-1C66RT')
    data_dir  = 'D:\DATA\Processed';
elseif strcmp(name(1:end-1),'IITCMONLAP008')
    data_dir  = 'D:\joint-motor-decision\kin_data\Processed';
end

% Which pair(s) to plot?
[file, path] = uigetfile(data_dir,'.mat','MultiSelect','on');
% If the user select only one file it just load .mat file. Otherwise it
% loads one .mat file in a for loop and keeps the info about the mean
% trajectories of each agent and each level of confidence (1-2)
ave_all.time   = [];
ave_all.space  = [];
meanHall.index = [];
meanLall.index = [];
meanHall.ulna  = [];
meanLall.ulna  = [];

if ischar(file)%only 1 input
    n_pr = 1;%number of pairs
elseif iscell(file)
    n_pr = length(file);
    flag_multiple = 1;
end

for sel_p=1:n_pr

    if ischar(file)%only 1 input
        load(fullfile(path,file));
    elseif iscell(file)
        ave_all.pairID = file{sel_p}(1:4);
        %in case of multiple inputs: load each pair at the beginning of the loop before setting the flags
        load(fullfile(path,file{sel_p}))
    end

    % Set flags ---------------------------------------------------------------
    % Which decision do you want to plot? (1=1st, 2=2nd, 3=collective)
    which_Dec      = 2;
    % Do you want to plot means +- variability (SD or SEM)
    plot_sd        = 1;
    % Do you want to apply a median split (yes=1, no=0)
    % If no median split, then assigment is the following: 1-3=lo, 4-6=high
    show_med_split = 1;
    % Which variability to plot?
    dev            = 1; % 1=SD, 2=SEM
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

            % time parameter loop: velocity, acceleration, jerk
            for param = 1:1%length(time_param)
                title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                % go into plotting function
                if plot_sd
                    ave_all.time = plot_offline_fun_sd(ave_all.time,eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),mrks{m},param,pairS,...
                        agents{g},title_plot,title_fig,data_dir,1,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                else
                    ave_all = plot_offline_fun(eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),mrks{m},param,pairS,...
                        agents{g},title_plot,title_fig,data_dir,1,[],which_Dec,flag_bin,strCount);
                end
            end

            % spatial parameter loop: x-dimension (left-right), z-dimension (height)
            for sparam = 1:2:length(spa_param)
                title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
                title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec' num2str(which_Dec) '.png'];
                % go into plotting function
                if plot_sd
                    for n=1:2
                        if n==2
                            title_plot = [title_plot '_Yaxis'];
                            title_fig  = [title_fig(1:end-4) '_Yaxis.png'];
                        end
                        ave_all.space = plot_offline_fun_sd(ave_all.space,eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),mrks{m},sparam,pairS,...
                            agents{g},title_plot,title_fig,data_dir,n,[],which_Dec,flag_bin,strCount,dev,plot_indiv);
                    end
                else
                    ave_all = plot_offline_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),mrks{m},sparam,pairS,...
                        agents{g},title_plot,title_fig,data_dir,1,[],which_Dec,flag_bin,strCount);
                end
            end


        end % end of marker loop

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

        %build a pragmatic matrix
        meanHall.index = [meanHall.index, ave_all.time.index.meanH];
        meanLall.index = [meanLall.index,ave_all.time.index.meanL];
        meanHall.ulna  = [meanHall.ulna,ave_all.time.ulna.meanH];
        meanLall.ulna  = [meanLall.ulna,ave_all.time.ulna.meanL];

        %store ave_all struct in a new variable updated per pair and agent
        name_struct = [(ave_all.pairID) 'mean' agents{g}];
        eval([(name_struct) '= ave_all;'])


    end % end of agent loop ---------------------------------------------------

    clearvars -except ave_all name data_dir sel_p n_pr file path meanHall meanLall flag_multiple mrks plot_indiv
end

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
if flag_multiple
    for m = 1:length(mrks)
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

        % Plot across pairs
        ap = figure(); % create figure
        set(ap, 'WindowStyle', 'Docked');

        plot(grandAveH, 'Color',hConf_col);
        hold on;
        fill(x, grandinBetweenH, HiFill, 'FaceAlpha',0.5,'HandleVisibility','off');
        plot(grandAveL,'Color',lConf_col);
        fill(x, grandinBetweenL, LoFill, 'FaceAlpha',0.5,'HandleVisibility','off');

    end
end

