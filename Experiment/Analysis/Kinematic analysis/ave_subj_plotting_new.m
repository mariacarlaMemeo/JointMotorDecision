% -------------------------------------------------------------------------
% -> We plot kin. variables for all trials (only 2nd decision), per agent.
% -> The actual plotting is done in function ave_subj_plotting_fun.m
% -------------------------------------------------------------------------
% This is called from "calc_kin_rt_mt.m"

% Notes:
% Temporal variables in matrix 'all_time_traj_ulna/index_'
% Spatial variables in matrix 'all_spa_traj_ulna/index_'
% Temporal and spatial variables:
% Velocity      - 1st column of matrix
% Acceleration  - 2nd column of matrix
% Jerk          - 3rd column of matrix
% x-coordinate  - 1st column of matrix
% y-coordinate  - 2nd column of matrix -> currently not plotted
% z-coordinate  - 3rd column of matrix

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
            %title_plot = [upper(mrks{m}) ' - ' time_param{param} ' module of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
            title_plot = ['pair ' SUBJECTS{p}(2:end) ' - agent ' agents{g} ' - '...
                          time_param{param} ' - decision ' num2str(which_Dec) ' - ' upper(mrks{m})];            
            title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' time_param{param}(1) 'm_' mrks{m} '_dec' num2str(which_Dec) '.png'];
            % go into plotting function
            ave_all = ave_subj_plotting_fun(eval(['all_time_traj_' mrks{m} '_' lower(agents{g})]),param,pairS,...
                agents{g},title_plot,title_fig,path_kin,1,[],which_Dec,flag_bin);
        end
        
        % spatial parameter loop: x-dimension (left-right), z-dimension (height)
        for sparam = 1:2:length(spa_param)
            %title_plot = [upper(mrks{m}) ' - '  spa_param{sparam} ' coordinate of ' agents{g} ' agent, pair' SUBJECTS{p}(2:end) ', dec' num2str(which_Dec)];
            title_plot = ['pair ' SUBJECTS{p}(2:end) ' - agent ' agents{g} ' - '...
                          spa_param{sparam} '-coordinate - decision ' num2str(which_Dec) ' - ' upper(mrks{m})];                      
            title_fig  = [SUBJECTS{p}(2:end) agents{g} '_' spa_param{sparam} ' coord_' mrks{m} '_dec' num2str(which_Dec) '.png'];
            % go into plotting function
            ave_all = ave_subj_plotting_fun(eval(['all_spa_traj_'  mrks{m} '_' lower(agents{g})]),sparam,pairS,...
                agents{g},title_plot,title_fig,path_kin,1,[],which_Dec,flag_bin);
        end

    end % end of marker loop

    % Save number of plotted (i.e., clean!) trials in which either agent
    % blue or yellow took 2nd decision (in sum, this is the total number of
    % clean trials for this pair); trials_clean contains two values (b/y)
    if which_Dec == 1 || which_Dec ==2
        trials_clean(g) = length(ave_all(~isnan(ave_all(1,pairS.at2ndDec==agents{g}))));
    end

end % end of agent loop ---------------------------------------------------

% script version: Nov 2023