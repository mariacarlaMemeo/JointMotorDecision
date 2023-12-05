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

pair ='S108_post';

% load .mat file
data_dir = 'D:\DATA\Processed';
file_dir  = fullfile(data_dir,[pair,'.mat']);
load(file_dir);

% Which decision do you want to plot? (1=1st,2=2nd,3=collective)
which_Dec = 1;
% set other flags
flag_bin = 1;

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

      
    % marker loop: index, ulna
    for m = 1:length(mrks)
        
        % time parameter loop: velocity, acceleration, jerk
        for param = 1:length(time_param)
            title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
            title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec' num2str(which_Dec) '.png'];
            % go into plotting function
            ave_all = plot_offline_fun(eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),param,pairS,...
                agents{g},title_plot,title_fig,path_kin,1,[],which_Dec,flag_bin);
        end
        
        % spatial parameter loop: x-dimension (left-right), z-dimension (height)
        for sparam = 1:2:length(spa_param)
            title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
            title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec' num2str(which_Dec) '.png'];
            % go into plotting function
            ave_all = plot_offline_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),sparam,pairS,...
                agents{g},title_plot,title_fig,path_kin,1,[],which_Dec,flag_bin);
        end

    end % end of marker loop

    % Save number of plotted (i.e., clean!) trials in which either agent
    % blue or yellow took 2nd decision (in sum, this is the total number of
    % clean trials for this pair); trials_clean contains two values (b/y)
    if which_Dec == 1 || which_Dec ==2
        trials_clean(g) = length(ave_all(~isnan(ave_all(1,pairS.at2ndDec(1:size(ave_all,2))==agents{g}))));
    end

end % end of agent loop ---------------------------------------------------

% script version: 1 Nov 2023