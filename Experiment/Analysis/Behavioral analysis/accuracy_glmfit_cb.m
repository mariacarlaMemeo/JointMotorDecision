%--------------------------------------------------------------------------
% ANALYSIS JMD study (JMD = joint motor decision)
% Data: collected in June 2023 @IIT Genova
% Participants: N=32 (16 pairs), [108,110,111:124] -> remove 119 (15 pairs)
% Script: written by Mariacarla Memeo & Laura Schmitz
% Analyses: accuracy, perceptual sensitivity, collective benefit
%--------------------------------------------------------------------------

% Here we analyze the accuracy and the perceptual sensitivity
% (-> fit psychometric function) of two participants who perform a 2AFC
% detection task (oddball in 1st or 2nd interval?). Each participant
% first takes her individual decision; then one of the two participants
% takes the final, collective decision. The two participants are labelled
% Blue agent and Yellow agent.

close all; clear variables; clc;
%--------------------------------------------------------------------------
% Flags
save_plot         = 1; % save the plots (1) or not (0)?
plot_acc_sens_ind = 0; % plot accuracy and non-fitted sensitivity curves per pair (B,Y,Coll)?
subselect_similar = 0; % subselect only pairs whose members are similar (> ratio mean .0.68)
% which benefit to compute and plot? (1 or 2)
% 1=individual benefit (does the individual participant benefit from interaction?)
% 2=collective benefit (is collective better than better individual? Bahrami 2010)
benefitType = 2; 
if benefitType == 1
    ben_lab = '_indiBen';
elseif benefitType == 2
    ben_lab = '_collBen';
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% Prepare path and variables
%--------------------------------------------------------------------------
path_data    = fullfile(pwd,'..\..\Data\Behavioral\original_files\'); % mat files
path_to_save = fullfile(pwd,'Behavioral plots\Accuracy_PsychCurves\'); % save here
each         = dir([path_data,'*.mat']); % list of mat files
% Retrieve all participant numbers (take first 3 digits), as cell array
if subselect_similar % take only a subset
    ptc = {'110','113','115','116','117','122','123','124'};
else
    ptc = cellfun(@(s) cell2mat(regexp(s,'\d{3}','Match')),{each.name},'uni',0);
end

% Initialize variable to save slope (i.e., sensitivity) values for:
% B, Y, Collective, Collective taken by B, Collective taken by Y, B 1st dec, Y 1st dec
slope        = zeros(length(ptc),7); % one row per pair
slope_hdr    = {'sB','sY','sColl','sCollB','sCollY','dec1B','dec1Y'};
% Initialize variable to save individual and collective benefit values:
% 1 = benefit for Blue; 2 = benefit for Yellow; 3 = collective benefit (cb)
coll_ben     = zeros(length(ptc),3); % one row per pair
coll_ben_hdr = {'indiBenB','indiBenY','collBen'};

% Figure labels (if not filled below, then they should be empty)
lab  = ''; block_lab = ''; %ind_lab = '';
x_width  = 18; y_width = 18; % size of saved figure

% Preallocate variables to save average values for all participants
% [max/mean] SLOPE VALUES (15x1, row=pair,col=var)
sdyad_all   = []; smax_all   = []; smin_all   = []; % for coll, max ind., min ind.
smax_coll   = []; smin_coll  = [];                  % collective decisions split by max/min agent                  
smax_1dec   = []; smin_1dec  = [];                  % 1st individual decisions split by max/min agent 
% PROPORTION 2ND INTERVAL per contrast diff. (15x8, row=pair,col=contrast diff.)
decDyad_all = []; decMax_all = []; decMin_all = []; % for coll, max ind., min ind.
dmax_coll   = []; dmin_coll  = [];                  % collective decisions split by max/min agent 
dmax_1dec   = []; dmin_1dec  = [];                  % 1st decisions split by max/min agent
% ACCURACY per contrast (15x4, row=pair,col=contrast)
accDyad_all = []; accB_all   = []; accY_all   = []; % for coll, B, Y
% BENEFIT ratios (15x1, row=pair,col=var)
cb_all      = []; ib_all_max = []; ib_all_min = []; % for coll (sdyad/smax), max ind., min ind.
% SMIN/SMAX ratios to measure similarity between pair members (15x1, row=pair,col=var)
ratio_all   = [];

% Make table to save info on min/max agent per pair (then import this to R)
sz = [length(ptc) 3];
varTypes = ["double","string","string"]; varNames = ["Pair","maxAgent","minAgent"];
minmaxTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

% Window analysis (length: default.w_lgt)
default.step        = 8;
default.w_lgt       = 80;
default.w           = zeros(default.w_lgt/default.step,default.w_lgt);
default.slope_wnd   = [];
default.slope_wcoll = [];

% Specify colors and markers for plots
% for PAIR plots
color_B    = [0.1176 0.2353 0.7451]; color_Y = [0.9412 0.7843 0.1569];
color_coll = [0.0667 0.4118 0.1569];
color_min  = [0 0.4470 0.7410]; color_max = [0.6350 0.0780 0.1840];
plotSym    = {'o' 's' 'diamond' ...             % B,Y,Coll
              'o' 's' 'o' 's'};                 % min,max,min,max      
color      = [color_B; color_Y; color_coll; ... % blue, yellow, dark green
              color_min; color_max; ...         % blue(min), red(max)
              [0.2 0.2 0.2]];                   % dark gray (for horizontal line = 1)
% this is used to have different marker fillings in individual plots
mrkColor   = [[1 1 1]; [1 1 1]; ...             % white, white, 
              color_B; color_Y; ...             % blue, yellow, 
              color_min; color_max];            % blue(min), red(max)           

% for AVERAGE plots (pass colorAve and plotSymAve to plot_psy function)
if benefitType     == 2 % min, max, Coll (original Bahrami plots)
    colorAve       = [color_min; color_max; [0 0 0]]; % min,max,Coll (black)
    plotSymAve     = {'o' 's' 'diamond'};             % min,max,Coll
elseif benefitType == 1 % individual benefit: min (blue) vs. max (red) agent
    colorAve       = [color_min; color_max; color_min; color_max]; % mi,ma,mi,ma                           
    plotSymAve     = {'o' 's' 'o' 's'};                            % mi,ma,mi,ma  
end

%--------------------------------------------------------------------------
%% Ask for user input (current defaults: 1,2,2,0)
%--------------------------------------------------------------------------
disp('*ASK FOR USER INPUT*');  fprintf('\n');
% Calculate collective benefit with 'max' or 'mean' function? (we use MAX)
fcalc = input('Choose the function to calculate collective benefit:\n 1 = max\n 2 = mean\n');
if fcalc==1
    coll_calc = 'max';
elseif fcalc==2
    coll_calc = 'mean';
end
% Subselect target numbers for specific contrast levels?
% NOTE: probably not necessary anymore, as we have balanced contrast no.
sub_con = input('Choose to subselect trials:\n 1 = yes\n 2 = no\n');
if sub_con==1
    subcon_calc = 1;
    lab = '_balanced_';
elseif sub_con==2
    subcon_calc = 0;
end
% Select how to compute the individual benefit
% Use all individual trials or only those in which the agent acted first
% (and thus also took the respective joint decision)
ind_CB = input('How to compute individual benefit?:\n 1 = use all ind. trials\n 2 = use only 1dec ind. trials\n');
% if ind_CB==1
%     ind_lab = '_indBenAll';
% elseif ind_CB==2
%     ind_lab = '_indBen1dec';
% end
% Subselect block?
sub_block = input('Choose to select block:\n 0 = allBlocks\n 1 = 1stBlock\n 2 = 2ndBlock\n');
if sub_block==0 % all trials
elseif sub_block==1
    block_lab = '_block1_';
elseif sub_block==2
    block_lab = '_block2_';
end
fprintf('\n');
disp('*END OF USER INPUT*'); fprintf('\n');

%--------------------------------------------------------------------------
%% START ANALYSIS
%--------------------------------------------------------------------------
for p = 1:length(ptc) % start pair loop (p=current pair; ptc=cell array with all pair numbers)

    % Load each pair's data
    if subselect_similar % load only specific pairs
        select = [2 5 7 8 9 13 14 15];
        load([path_data,each(select(p)).name])
        disp(['Loading ',each(select(p)).name]);
    else
        load([path_data,each(p).name])
        disp(['Loading ',each(p).name]);
    end
    
    % Remove header, save agent_order (e.g., B-Y-B) separately, then
    % save data.output without agent order (col 28:30) and convert cell to mat
    % Optionally: select 1st or 2nd block
    if sub_block==0     % all data
        agent_order = data.output(2:end,28:30);
        data.output = cell2mat(data.output(2:end,1:27));
    elseif sub_block==1 % only 1st block
        agent_order = data.output(2:89,28:30);
        data.output = cell2mat(data.output(2:89,1:27));
    elseif sub_block==2 % only 2nd block
        agent_order = data.output(90:177,28:30);
        data.output = cell2mat(data.output(90:177,1:27));
    end

    % SKIP THIS -----------------------------------------------------------
    % The following is only useful if we have unequal numbers for the
    % different contrast levels. We chose to have equal numbers in Exp. 1.
    % Optionally subselect trials:
    % Here we subselect trials such that we have the same number of trials
    % for each contrast level (i.e., here: 32 per contrast)
    if subcon_calc
        subcon_ind1  = find(data.output(:,6)==0.015); % lowest contrast
        subcon_ind2  = find(data.output(:,6)==0.035); % 2nd lowest contrast
        % include only the first 32 trials per contrast
        subcon_ind12 = sort([subcon_ind1(33:end);subcon_ind2(33:end)]);
        data.output(subcon_ind12,:) = [];
        agent_order(subcon_ind12,:) = [];
    end
    %----------------------------------------------------------------------

    %----------------------------------------------------------------------
    % Define variables and structure data.output
    %----------------------------------------------------------------------
    asymp_limits    = [0 0.5];
    contrast_v      = data.output(:,6); % current contrast (-baseline 0.1)
    firstSecond_v   = data.output(:,8); % oddball in 1st or 2nd?
    % Give sign to the contrast (- if 1st interval, + if 2nd interval)
    % -> equivalent to: contrast at oddball location in 1st - 2nd interval
    C2_C1_v         = contrast_v .* (2.*firstSecond_v - 3);
    conSteps        = unique(C2_C1_v); % -.15,-.07,-.035,-.015,.015,.035,.07,.15
    absConSteps     = unique(abs(conSteps)); % .015,.035,.07,.15
    % Create vectors for accuracies and decisions (individual & collective)
    % Note that A1=Blue and A2=Yellow
    % ACCURACIES ----------------------------------------------------------
    a1_acc_v           = data.output(:,11); % B accuracy
    a2_acc_v           = data.output(:,17); % Y accuracy
    coll_acc_v         = data.output(:,23); % Collective accuracy
    % Split collective accuracy depending on the agent
    agentExecColl_clmn = agent_order(:,3); % agent taking collective decision
    coll_acc_vA1       = coll_acc_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)));
    coll_acc_vA2       = coll_acc_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)));
    % DECISIONS -----------------------------------------------------------
    % fs = FirstSecond
    % if A said 1 (1st interval), the value is 0
    % if A said 2 (2nd interval), the value is 1
    a1_fs_v           = data.output(:,10)-1; % B decision
    a2_fs_v           = data.output(:,16)-1; % Y decision
    coll_fs_v         = data.output(:,22)-1; % Collective decision
    % Split collective decision depending on the agent
    coll_fs_vA1       = coll_fs_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)));
    coll_fs_vA2       = coll_fs_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)));
    % Select only those *individual* decisions where agent acted 1st (and last).
    % We need this value as a denominator for computing the individual benefit (ind_CB==2)
    a1_1dec_fs_v      = a1_fs_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))); % B 1st decision
    a2_1dec_fs_v      = a2_fs_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))); % Y 1st decision
    %----------------------------------------------------------------------

    % Collect and average ACCURACIES per contrast level (for B,Y,Coll,BColl,YColl)
    for cI = 1 : size(absConSteps,1)
        c                         = absConSteps(cI);
        % MEANS
        % Blue, Yellow, Collective
        data.result.a1.acc(cI)    = mean(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.acc(cI)    = mean(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.acc(cI)  = mean(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));
        % Collective decisions taken by Blue, Collective decisions taken by Yellow
        data.result.collA1.acc(cI)= mean(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                         agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.acc(cI)= mean(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                         agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));
        % LENGTH
        data.result.a1.N(cI)      = length(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.N(cI)      = length(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.N(cI)    = length(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));
        data.result.collA1.N(cI)  = length(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                           agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.N(cI)  = length(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                           agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));
    end

    % Save accuracies for all pairs
    accDyad_all  = [accDyad_all; data.result.coll.acc];
    accB_all     = [accB_all;    data.result.a1.acc];
    accY_all     = [accY_all;    data.result.a2.acc];
    
    %----------------------------------------------------------------------
    % PLOTTING accuracy
    %----------------------------------------------------------------------
    % Plot accuracies across abs., log-transformed contrast differences
    % -> Here we use the accuracy data (0 or 1)
    % -----------------------------------------
    if plot_acc_sens_ind
        acc_fig_contrasts=figure('Name',['S' ptc{p}]); set(acc_fig_contrasts, 'WindowStyle', 'Docked');
        semilogx(absConSteps,data.result.a1.acc,'-s','MarkerSize',6,'LineWidth',1.5,'Color',color(1,:));   % Blue
        hold on;
        semilogx(absConSteps,data.result.a2.acc,'-o','MarkerSize',6,'LineWidth',1.5,'Color',color(2,:));   % Yellow
        semilogx(absConSteps,data.result.coll.acc,'-*','MarkerSize',6,'LineWidth',2.5,'Color',color(3,:)); % Green
        xlabel('Absolute contrast difference','FontSize',20); % ('LOG |C2 - C1|')
        xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
        xticks([min(absConSteps)*.8 max(absConSteps)*1.2]); % remove ticks?
        ylabel('Accuracy','FontSize',20);
        ylim([0.3 1]); ax = gca; ax.FontSize = 16; 
        title(['Accuracy - ','S' ptc{p}],'FontSize',22);
    end
%     if save_plot
%         set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
%         saveas(gcf,[path_to_save,'S',ptc{p},'_Acc_',lab,block_lab],'png');
%     end
   
    % Collect and average DECISIONS per contrast level (for B,Y,Coll,B1dec,Y1dec,BColl,YColl)
    for cI = 1 : size(conSteps,1)
        c                           = conSteps(cI);
        % MEANS
        % Blue, Yellow, Collective
        data.result.a1.fs(cI)       = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fs(cI)       = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fs(cI)     = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        % Individual decisions where B/Y took the 1st and collective decision
        data.result.a1_1dec.fs(cI)  = mean(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                           agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fs(cI)  = mean(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                           agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));
        % Collective decisions taken by Blue, Collective decisions taken by Yellow
        data.result.collA1.fs(cI)   = mean(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                           agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.fs(cI)   = mean(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                           agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));
        % LENGTH
        data.result.a1.fsN(cI)      = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fsN(cI)      = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fsN(cI)    = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        data.result.a1_1dec.fsN(cI) = length(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                             agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fsN(cI) = length(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                             agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));
        data.result.collA1.N(cI)    = length(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',...
                                             agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.N(cI)    = length(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',...
                                             agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));
    end

    %----------------------------------------------------------------------
    % PLOTTING sensitivity
    %----------------------------------------------------------------------
    % Plot P(Report 2nd) across contrast differences (non-logarithmic)
    % Note: This plot is like the psych. curve but without curve fitting!
    % -> Here we use the decision data (1 or 2)
    % -----------------------------------------
    if plot_acc_sens_ind
        acc_fig_psy=figure('Name',['S' ptc{p}]); set(acc_fig_psy, 'WindowStyle', 'Docked');
        plot(conSteps,data.result.a1.fs,'-s','MarkerSize',6,'LineWidth',1.5,'Color',color(1,:));   %'bs-'
        hold on;
        plot(conSteps,data.result.a2.fs,'-o','MarkerSize',6,'LineWidth',1.5,'Color',color(2,:));   %'yo-'
        plot(conSteps,data.result.coll.fs,'-*','MarkerSize',6,'LineWidth',2.5,'Color',color(3,:)); %'gv-'
        xlabel('Contrast difference','FontSize',20);
        ylabel('P(Report 2nd)','FontSize',20);
        ylim([0 1]); ax = gca; ax.FontSize = 16; 
        title(['Sensitivity - ','S' ptc{p}],'FontSize',22);
    end
%     if save_plot
%         set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
%         saveas(gcf,[path_to_save,'S',ptc{p},'_PerSens_',lab,block_lab],'png');
%     end

    
    %----------------------------------------------------------------------
    %% FIT and PLOT PSYCHOMETRIC CURVES
    %----------------------------------------------------------------------
    full = 1; % 1 = compute cb for all trials, not for windows
    
    % *y* contains the averaged DECISION data - for each of the 8 contrast levels  
    % 7 columns: [Blue, Yellow, Collective , BColl, YColl, Bdec1, Ydec1]
    % 15 rows  : pairs
    y    = [data.result.a1.fs'      data.result.a2.fs' data.result.coll.fs'...
            data.result.collA1.fs'  data.result.collA2.fs'...
            data.result.a1_1dec.fs' data.result.a2_1dec.fs'];

    % Prepare figure (per pair) to show psychometric curves
    cb=figure('Name',['CB_S' ptc{p}]); set(cb, 'WindowStyle', 'Docked');

    % *slope* contains the slope values (max or mean)
    % -> computed inside function plot_psy, see below
    % 7 columns: [Blue, Yellow, Collective , BColl, YColl, Bdec1, Ydec1]
    % 15 rows  : pairs
    % ---------------------------------------------------------------------
    % -> GO INTO FUNCTION PLOT_PSY to fit and plot psych. curves
    aveFlag=0;
    slope(p,:) = plot_psy(conSteps,y,plotSym,color,default,full,coll_calc,...
                          benefitType,mrkColor,aveFlag);
    % ---------------------------------------------------------------------

    % Set figure properties for psychometric curve plots (created in plot_psy)
    ylim([0 1]); ax = gca; ax.FontSize = 16; 
    xlabel("Contrast difference",'FontSize',20);
    ylabel("Proportion 2nd interval",'FontSize',20);

    %----------------------------------------------------------------------
    %% COMPUTE COLLECTIVE BENEFIT
    %----------------------------------------------------------------------
    % Which individual (B or Y) has larger slope (= higher sensitivity)?
    % agent_max/min = the agent names (1 = Blue, 2 = Yellow)
    % smax/smin     = the slope values
    [smax,agent_max]  = max(slope(p,1:2)); % more sensitive agent
    [smin,agent_min]  = min(slope(p,1:2)); % less sensitive agent
    if agent_max == 1
        amax = 'B';
        amin = 'Y';
    elseif agent_max == 2
        amax = 'Y';
        amin = 'B';
    end

    % save info on min/max agent in table
    minmaxTable(p,1)={str2double(each(p).name(2:4))};
    minmaxTable(p,2)={amax};
    minmaxTable(p,3)={amin};

    %%% Collective benefit
    % sdyad ([mean or max] dyad slope) / smax (slope of more sensitive agent)
    coll_ben(p,3) = round(slope(p,3)/smax,2);
    
    %%% Individual benefit (2 alternative versions)
    % ind_CB==1:
    % coll. decisions taken by respective agent (B or Y) / 
    % all ind. decisions of same agent
    if ind_CB==1
        coll_ben(p,1) = round(slope(p,4)/slope(p,1),2); %scollB/sindB
        coll_ben(p,2) = round(slope(p,5)/slope(p,2),2); %scollY/sindY
    % ind_CB==2:
    % coll. decisions taken by respective agent (B or Y) / 
    % *only* ind. decisions of those same trials (i.e., only trials in which
    % the same agent took 1st and collective decision; for better comparison
    elseif ind_CB==2
        coll_ben(p,1) = round(slope(p,4)/slope(p,6),2); %scollB/sindB_1dec
        coll_ben(p,2) = round(slope(p,5)/slope(p,7),2); %scollY/sindY_1dec
    end

    % based on ind. benefits for B/Y (above), assign ind. benefits min/max
    if agent_max == 1
        coll_ben_max = coll_ben(p,1);
        coll_ben_min = coll_ben(p,2);
    elseif agent_max == 2
        coll_ben_max = coll_ben(p,2);
        coll_ben_min = coll_ben(p,1);
    end

    % Display the computed values as text in plot
    if benefitType == 2
        text(-0.18,0.95,['coll. benefit = ' num2str(coll_ben(p,3),'%.2f')],'FontSize',18);
        title(['Coll. benefit - ','S' ptc{p}],'FontSize',22);
    elseif benefitType == 1
        if agent_max == 1 % if B is max agent
            text(-0.18,0.95,['ind. benefit B (max) = ' num2str(coll_ben_max,'%.2f')],...
                'FontSize',18, 'Color', color(1,:));
            text(-0.18,0.9, ['ind. benefit Y (min) = ' num2str(coll_ben_min,'%.2f')],...
                'FontSize',18, 'Color', color(2,:));
        elseif agent_max == 2 % if Y is max agent
            text(-0.18,0.95, ['ind. benefit Y (max) = ' num2str(coll_ben_max,'%.2f')],...
                'FontSize',18, 'Color', color(2,:));
            text(-0.18,0.9,['ind. benefit B (min) = ' num2str(coll_ben_min,'%.2f')],...
                'FontSize',18, 'Color', color(1,:));
        end
        title(['Ind. benefit - ','S' ptc{p}],'FontSize',22);
    end

    % Save psychometric curve figure
    if save_plot
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,[path_to_save,'S',ptc{p},'_PsyC',lab,block_lab,ben_lab],'png');
    end
    hold off; % end of psychometric function pair plot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot pair curves again, but this time colored according to min/max
    if full && benefitType == 1
        plot_minmax;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ---------------------------------------------------------------------

    % ---------------------------------------------------------------------
    % COMPUTE and SAVE variables
    % ---------------------------------------------------------------------
    % Compute ratio between the 2 individuals' slopes, as a measure for the
    % interindividual difference. If this difference is too large
    % (i.e., if ratio < ~0.4), then there should be no collective benefit.
    ratio = smin/smax;

    % Display info in command window
    disp(['Collective benefit ' ptc{p} ': ' num2str(coll_ben(p,3))]);
    disp(['B individual benefit ' ptc{p} ': ' num2str(coll_ben(p,1))])
    disp(['Y individual benefit ' ptc{p} ': ' num2str(coll_ben(p,2))])
    disp(['smax: ' num2str(smax,'%.2f') ' agent: ' amax]);
    disp(['smin: ' num2str(smin,'%.2f') ' agent: ' amin]);
    disp(['ratio: ' num2str(ratio,'%.2f')]);
    fprintf('\n');

    % Collect values for all pairs (for later computation of averages)
    sdyad_all    = [sdyad_all; slope(p,3)]; % collective slope
    smax_all     = [smax_all; smax]; % individual slope for better agent
    smin_all     = [smin_all; smin]; % individual slope for worse agent
    % slopes and dec for: coll. dec. and ind. 1dec for better and worse agent
    if agent_max == 1 % if B is better
        smax_coll = [smax_coll; slope(p,4)]; dmax_coll = [dmax_coll; y(:,4)']; 
        smin_coll = [smin_coll; slope(p,5)]; dmin_coll = [dmin_coll; y(:,5)']; 
        smax_1dec = [smax_1dec; slope(p,6)]; dmax_1dec = [dmax_1dec; y(:,6)'];
        smin_1dec = [smin_1dec; slope(p,7)]; dmin_1dec = [dmin_1dec; y(:,7)'];
    elseif agent_max == 2 % if Y is better
        smax_coll = [smax_coll; slope(p,5)]; dmax_coll = [dmax_coll; y(:,5)']; 
        smin_coll = [smin_coll; slope(p,4)]; dmin_coll = [dmin_coll; y(:,4)']; 
        smax_1dec = [smax_1dec; slope(p,7)]; dmax_1dec = [dmax_1dec; y(:,7)'];
        smin_1dec = [smin_1dec; slope(p,6)]; dmin_1dec = [dmin_1dec; y(:,6)'];
    end
    decDyad_all  = [decDyad_all; y(:,3)'];
    decMax_all   = [decMax_all; y(:,agent_max)'];
    decMin_all   = [decMin_all; y(:,agent_min)'];
    % benefits
    cb_all       = [cb_all; coll_ben(p,3)];
    ib_all_max   = [ib_all_max; coll_ben_max];
    ib_all_min   = [ib_all_min; coll_ben_min];
    ratio_all    = [ratio_all; ratio];


    % ---------------- WINDOW ANALYSIS -----------------------------------%
    % Calculate collective benefit in windows of 80 elements each 8 trials
    % -> use the same smax found before (no change across windows!)
    % -> collective decision and relative signed contrast
    if not(subcon_calc) && sub_block==0
        full=0; % compute cb separately for windows

        % Prepare figure: one per pair, show cb across windows
        ws=figure('Name',['S' ptc{p} '_wnd']);
        set(ws, 'WindowStyle', 'Docked');
        % coll_prtc:
        % Each row is a pair. Columns are XXX
        coll_prtc = [coll_fs_v C2_C1_v];
        % -> GO INTO FUNCTION PLOT_PSY to fit and plot psych. curves
        aveFlag=0;
        slope_wcoll(p,:) = plot_psy(conSteps,coll_prtc,plotSym,color,default,full,coll_calc,benefitType,mrkColor,aveFlag);
        % -----------------------------------------------------------------
        slope_wcoll(p,:) = slope_wcoll(p,:)/smax;
        plot(slope_wcoll(p,:),['-' plotSym{3}],'Color',color(3,:),'MarkerSize',8,'LineWidth',3);
        title(['Coll benefit - ','S' ptc{p},'- wnd'],'FontSize',22);
    end
end
% end of pair loop -------------------------------------------------------%



%--------------------------------------------------------------------------
% COMPUTE AND PLOT GROUP AVERAGES
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% AVERAGE PSYCHOMETRIC CURVES (dyad, min, max)
% -----------------------------------------------
full=1; % compute cb for all trials, not for windows
% Note: Use median instead of mean!
% -> median = middle value when data set is ordered from least to greatest.
decDyad_ave   = median(decDyad_all, 1);
decMax_ave    = median(decMax_all, 1);
decMin_ave    = median(decMin_all, 1);
% do averages for ind. coll. dec and ind. 1dec - compare min and max
dmax_coll_ave = median(dmax_coll, 1); 
dmin_coll_ave = median(dmin_coll, 1); 
dmax_1dec_ave = median(dmax_1dec, 1);
dmin_1dec_ave = median(dmin_1dec, 1);

% y_ave contains AVERAGE DECISION data for each of the 8 contrast levels
if benefitType == 2 % "traditional" collective benefit
    y_ave = [decMin_ave' decMax_ave' decDyad_ave']; % [min, max, Collective]
elseif benefitType == 1
    y_ave = [dmin_coll_ave' dmax_coll_ave' dmin_1dec_ave' dmax_1dec_ave'];
end

% Prepare figure
cb_ave=figure('Name','CB_Average'); set(cb_ave, 'WindowStyle', 'Docked');

% -------------------------------------------------------------------------
% -> GO INTO FUNCTION PLOT_PSY to fit and plot psych. curves
aveFlag=1;
sAverage = plot_psy(conSteps,y_ave,plotSymAve,colorAve,default,full,...
                    coll_calc,benefitType,mrkColor,aveFlag);
% -------------------------------------------------------------------------

% Set figure properties
ylim([0 1]); ax = gca; ax.FontSize = 16; 
xlabel('Contrast difference','FontSize',20);
ylabel('Proportion 2nd interval','FontSize',20);

% Display the computed values as text in plot
if benefitType == 2
    text(-0.18,0.95,['mean coll. benefit = ' num2str(mean(cb_all),'%.2f')],'FontSize',20);
    title('Grand averages: collective benefit','FontSize',22);
elseif benefitType == 1
    text(-0.18,0.95,['mean ind. benefit MAX = ' num2str(mean(ib_all_max),'%.2f')],'FontSize',20, 'Color', colorAve(2,:));
    text(-0.18,0.9,['mean ind. benefit MIN = ' num2str(mean(ib_all_min),'%.2f')],'FontSize',20, 'Color', colorAve(1,:));
    title('Grand averages: individual benefit','FontSize',22);
end

% Save figure
if save_plot
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,[path_to_save,'Average_PsyC',lab,block_lab,ben_lab],'png');
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% AVERAGE PSYCHOMETRIC CURVES (dyad, min, max) per WINDOW
% ----------------------------------------------------------
% Compute collective benefit as average across pairs and for all pairs
if not(subcon_calc) && sub_block==0 && length(ptc)>1

    % Average across pairs
    h4=figure(); set(h4,'WindowStyle','Docked');
    errorbar(1:default.w_lgt/default.step,...
             mean(slope_wcoll),-std(slope_wcoll)/sqrt(length((slope_wcoll))),+std(slope_wcoll)/sqrt(length((slope_wcoll))),...
             'Color', color(3,:),'LineWidth',3); hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
    xlim([0 (default.w_lgt/default.step)+1]); xticks(0:1:10);
    ylim([0.95 1.25]); yticks(0.95:0.05:1.25);
    ax = gca; ax.FontSize = 16; 
    %axis([0 (default.w_lgt/default.step)+1 0.8 1.2]);
    xlabel('Sliding window (80 trials each)','FontSize',20);
    ylabel('sdyad/smax','FontSize',20);
    title('Average values across pairs - coll. benefit','FontSize',22);
    % Save figure
    if save_plot
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,[path_to_save,'Average_WindowCB_',lab,block_lab],'png');
    end

    % All pairs within one figure
    allColors = jet(16);
    h5=figure(); set(h5, 'WindowStyle', 'Docked');
    colororder(allColors(1:end,:));
    plot(slope_wcoll',['-' plotSym{3}],'LineWidth',2, 'MarkerSize',6); hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:),'LineWidth',1.5);
    hold off;
    axis([0 (default.w_lgt/default.step)+1 0.5 2.2])
    legend({'S108','S110','S111','S112','S113','S114','S115','S116',...
        'S117','S118','S120','S121','S122','S123','S124','1'},'location','bestoutside');
    title('Coll. benefit - each pair','FontSize',22);
    % Save figure
    if save_plot
        set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,[path_to_save,'AllPairs_WindowCB_',lab,block_lab],'png');
    end

end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% AVERAGE ACCURACIES (dyad, individual)
% --------------------------------------------------
% Compute average accuracy for sdyad and sindividual
accDyad_ave = mean(accDyad_all,1);
accB_ave    = mean(accB_all,1);
accY_ave    = mean(accY_all,1);
accInd_ave  = mean([accB_ave; accY_ave],1);
acc_fig_contrasts_ave=figure('Name','AccAverage');
set(acc_fig_contrasts_ave, 'WindowStyle', 'Docked');
semilogx(absConSteps,accInd_ave,'o','LineStyle','--','MarkerSize',8,'LineWidth',2,'Color',[0.7804 0.3412 0.8706]); % Ind=purple
hold on;
semilogx(absConSteps,accDyad_ave,'diamond','LineStyle','-','MarkerSize',8,'LineWidth',2,'Color',[0 0 0]); % Coll=black
xlabel('Absolute contrast difference','FontSize',20); %xlabel('LOG |C2 - C1|');
xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
xticks([min(absConSteps)*.8 max(absConSteps)*1.2]);
ylabel('Accuracy','FontSize',20);
ylim([0.3 1]); ax = gca; ax.FontSize = 16; 
title('Accuracy average across pairs','FontSize',22);
% save figure
if save_plot
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,[path_to_save,'Average_Acc_',lab,block_lab],'png');
end
% -------------------------------------------------------------------------


% Correlation between similarity and collective benefit
% -------------------------------------------------------------------------
% Do interindividual differences predict collective benefit?
% Theoretical prediction:
% The larger the difference (i.e., smaller ratio), the smaller the cb.
% Threshold should be ~ 0.4: if ratio smaller, then no cb.

% Define x-y values (x: ratio, y: cb)
cb_ratio_combo = [cb_all ratio_all];
cb_ratio_combo_sorted = sortrows(cb_ratio_combo,2);
disp('What is the average similarity ratio across pairs?');
disp(['mean similarity ratio: ' num2str(mean(ratio_all),'%.2f')]);
fprintf('\n');

% Check correlation
[R,P] = corrcoef(cb_ratio_combo_sorted(:,2),cb_ratio_combo_sorted(:,1));
disp('Is there a correlation between similarity and coll. benefit?');
disp(['correlation coefficient: ' num2str(R(2,1),'%.4f')]);
disp(['p-value for correlation: ' num2str(P(2,1),'%.4f')]);
if P(2,1) < 0.05
    disp('YEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH!!!!!!!!!!!!!!!')
end
fprintf('\n');

% scatter plot properties:
mrksz=50; mrkedge=[0 0 0]; mrkfill=[1 1 1]; mrkw=1.5;
cbcol=[0.4667 0.6745 0.1882];
% Plot ratio on x-axis and collective benefit on y-axis
xdata=cb_ratio_combo_sorted(:,2); ydata=cb_ratio_combo_sorted(:,1);
ratio_fig=figure(); set(ratio_fig, 'WindowStyle', 'Docked');
scatter(xdata,ydata,mrksz,"MarkerEdgeColor",mrkedge,...
    "MarkerFaceColor",mrkfill,"LineWidth",mrkw);
ax = gca; ax.FontSize = 16; 
hold on; xlim([0.3 1]);
line = lsline(gca); line.LineWidth=2; hold on;
scatter(xdata(ydata(:,1)>=1, 1), ydata(ydata(:,1)>=1, 1),mrksz,"MarkerEdgeColor",mrkedge,...
    "MarkerFaceColor",cbcol,"LineWidth",mrkw); % color dots above 1 in green
hold on; 
yl = yline(1, '-','Collective benefit','LineWidth',2, 'Color',cbcol, 'FontSize',14);
yl.LabelHorizontalAlignment = 'left';
text(0.35,1.55,['R: ' num2str(R(2,1),'%.4f')],'Color','k','FontSize',18);
text(0.35,1.50,['p: ' num2str(P(2,1),'%.4f')],'Color','k','FontSize',18);
xlabel('smin/smax','FontSize',18);
ylabel('sdyad/smax','FontSize',18);
title('Coll. benefit as a function of similarity','FontSize',22);
% Save figure
if save_plot
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,[path_to_save,'SimilarityCorr',lab,block_lab],'png');
end
% -------------------------------------------------------------------------

% save min/max table as Excel file
writetable(minmaxTable,'minmaxTable.xlsx');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATISTICAL TESTS
% test whether collective slope differs from max. slope
[h,pval,ci,stats] = ttest(sdyad_all', smax_all', "Tail","right");
% % use non-parametric test (Wilcoxon signed rank test):
% [p,h,stats] = signrank(sdyad_all',smax_all');
disp('Is there a collective benefit?');
if pval < 0.05
    disp('Collective is better than more sensitive individual!')
elseif pval >= 0.05
    disp('No collective benefit!')
end
disp(['p-value (coll. slope vs. max. slope): ' num2str(pval,'%.7f')]);
fprintf('\n');

% test if max/min individual differs from max/min collective slope
[h,pval,ci,stats] = ttest(smax_coll', smax_1dec', "Tail","right");
disp('Did the more sensitive individual benefit?');
if pval < 0.05
    disp('The more sensitive individual had a benefit!')
elseif pval >= 0.05
    disp('The more sensitive individual did NOT benefit.')
end
disp(['p-value (max coll. vs. max indi.): ' num2str(pval,'%.7f')]);
fprintf('\n');

[h,pval,ci,stats] = ttest(smin_coll', smin_1dec', "Tail","right");
disp('Did the less sensitive individual benefit?');
if pval < 0.05
    disp('The less sensitive individual had a benefit!')
elseif pval >= 0.05
    disp('The less sensitive individual did NOT benefit.')
end
disp(['p-value (min coll. vs. min indi.): ' num2str(pval,'%.7f')]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
