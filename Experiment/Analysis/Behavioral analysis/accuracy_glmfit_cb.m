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
% Blue agent (formerly A1) and Yellow agent (formerly A2).

close all; clear variables; clc;
%--------------------------------------------------------------------------
% Flags
save_plot   = 1;
benefitType = 1; % 1=individual benefit, 2=collective (original Bahrami)
if benefitType == 1
    ben_lab = '_collBen';
elseif benefitType == 2
    ben_lab = '_indiBen';
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Prepare path and variables
%--------------------------------------------------------------------------
path_data    = fullfile(pwd,'..\..\Data\Behavioral\original_files\'); % mat files
path_to_save = fullfile(pwd,'Behavioral plots\Accuracy_PsychCurves\'); % save here
each         = dir([path_data,'*.mat']); % list of mat files
% Retrieve participant number (take first 3 digits)
ptc          = cellfun(@(s) cell2mat(regexp(s,'\d{3}','Match')),{each.name},'uni',0);

% Initialize variable to save slope values for:
% B, Y, Collective, Collective taken by B, Collective taken by Y, B 1st dec, Y 1st dec
slope        = zeros(length(ptc),7);
% Initialize variable to save individual and collective benefit values:
% 1 = benefit for Blue; 2 = benefit for Yellow; 3 = collective benefit (cb)
coll_ben     = zeros(length(ptc),3);

% Figure labels (if not used below, then they should be empty)
lab  = ''; block_lab = ''; ind_lab = '';

% Preallocate variables to save specific values for all participants
sdyad_all   = []; smax_all   = []; smin_all   = [];
decDyad_all = []; decMax_all = []; decMin_all = [];
accDyad_all = []; accB_all   = []; accY_all   = [];
ratio_all   = []; cb_all     = []; ib_all_max = []; ib_all_min = [];
smax_coll   = []; smin_coll  = [];
smax_1dec   = []; smin_1dec  = [];
dmax_coll   = []; dmin_coll  = [];
dmax_1dec   = []; dmin_1dec  = [];

% Window analysis (length: default.w_lgt)
default.step        = 8;
default.w_lgt       = 80;
default.w           = zeros(default.w_lgt/default.step,default.w_lgt);
default.slope_wnd   = [];
default.slope_wcoll = [];

% Specify colors and markers for plots
plotSym    = {'o' 's' '*' 'o' 's' 'o' 's'}; %{'s' 'o' '*' '+' '+'};
mrkColor   = [[255 255 255]; [255 255 255]; ... % white, white
              [30 60 190]; [240 200 40]]./255;  % blue, yellow
color      = [[30 60 190]; [240 200 40]; [17 105 40];... % blue, yellow, dark green
              [30 60 190]; [240 200 40]; ... % blue, yellow
              % gray, emerald green, persian green, pine green
              [51 51 51]; [80 200 120]; [0 165 114]; [1 121 111]]./255;
% colors for average plots
if benefitType == 2 % blue (min), red (max), black (coll)
    colorAve = [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; [0 0 0]];
    plotSymAve = {'o' 's' 'diamond'};
elseif benefitType == 1
    colorAve = [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; ...
                [0 0.4470 0.7410]; [0.6350 0.0780 0.1840]];
     plotSymAve = {'o' 's' 'o' 's'};
end

%--------------------------------------------------------------------------
% Ask for user input
%--------------------------------------------------------------------------
disp('*ASK FOR USER INPUT*');  fprintf('\n');
% Calculate collective benefit with 'max' or 'mean' function?
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
% Select how to compute the individual collective benefit
% Use all individual trials or only those in which the agent acted first
% (and thus also took the respective joint decision)
ind_CB = input('Choose to select individual CB:\n 1 = all ind. trials\n 2 = only 1dec ind. trials\n');
if ind_CB==1
    ind_lab = '_indBenAll';
elseif ind_CB==2
    ind_lab = '_indBen1dec';
end
% Select only first or second block?
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
% START ANALYSIS
%--------------------------------------------------------------------------
for p=1:length(ptc) % start pair loop (p=number of pairs; ptc=pair numbers)

    % Load each pair's data
    load([path_data,each(p).name])
    disp(['Loading ',each(p).name]);

    % Remove header, save agent_order (e.g., B-Y-B) and convert cell to mat
    % Optionally: select 1st or 2nd block
    if sub_block==0 % all data
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
    % -> equivalent to: contrast at oddball location in 1st - 2nd intervall
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
    % (We need this value as a denominator for computing the indiv. coll.
    %  benefit (lines 209-210) when ind_CB=2.)
    a1_1dec_fs_v      = a1_fs_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))); % B 1st decision
    a2_1dec_fs_v      = a2_fs_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))); % Y 1st decision
    %----------------------------------------------------------------------

    % Collect ACCURACIES per contrast level (for B,Y,Coll,BColl,YColl)
    for cI = 1 : size(absConSteps,1)
        c                         = absConSteps(cI);
        % MEANS
        % Blue, Yellow, Collective
        data.result.a1.acc(cI)    = mean(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.acc(cI)    = mean(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.acc(cI)  = mean(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));
        % Collective decisions taken by Blue, Collective decisions taken by Yellow
        data.result.collA1.acc(cI)= mean(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.acc(cI)= mean(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));
        % LENGTH
        data.result.a1.N(cI)      = length(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.N(cI)      = length(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.N(cI)    = length(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));
        data.result.collA1.N(cI)  = length(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.N(cI)  = length(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));
    end

    % Save accuracies for all pairs
    accDyad_all  = [accDyad_all; data.result.coll.acc];
    accB_all     = [accB_all; data.result.a1.acc];
    accY_all     = [accY_all; data.result.a2.acc];
    
    %----------------------------------------------------------------------
    % PLOTTING accuracy
    %----------------------------------------------------------------------
    % Plot accuracies across abs., log-transformed contrast differences
    % -> Here we use the accuracy data (0 or 1)
    % -----------------------------------------
    acc_fig_contrasts=figure('Name',['S' ptc{p}]); set(acc_fig_contrasts, 'WindowStyle', 'Docked');
    semilogx(absConSteps,data.result.a1.acc,'-s','MarkerSize',6,'LineWidth',1.5,'Color',color(1,:)); % Blue
    hold on;
    semilogx(absConSteps,data.result.a2.acc,'-o','MarkerSize',6,'LineWidth',1.5,'Color',color(2,:)); % Yellow
    semilogx(absConSteps,data.result.coll.acc,'-*','MarkerSize',6,'LineWidth',1.5,'Color',color(3,:)); % Coll green
    xlabel('Contrast difference','FontSize',18); %xlabel('LOG |C2 - C1|');
    xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
    xticks([min(absConSteps)*.8 max(absConSteps)*1.2]); % remove ticks?
    ylabel('Accuracy','FontSize',18);
    ylim([0.3 1]);
    title(['Accuracy - ','S' ptc{p}],'FontSize',22);
    %if save_plot
        %saveas(gcf,[path_to_save,'S',ptc{p},'_Acc_',lab,block_lab,ind_lab,ben_lab],'png');
    %end
   
    % Collect DECISIONS per contrast level (for B,Y,Coll,B1dec,Y1dec,BColl,YColl)
    for cI = 1 : size(conSteps,1)
        c                           = conSteps(cI);
        % MEANS
        % Blue, Yellow, Collective
        data.result.a1.fs(cI)       = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fs(cI)       = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fs(cI)     = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        % Individual decisions where B/Y took the 1st and collective decision
        data.result.a1_1dec.fs(cI)  = mean(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fs(cI)  = mean(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));
        % Collective decisions taken by Blue, Collective decisions taken by Yellow
        data.result.collA1.fs(cI)   = mean(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.fs(cI)   = mean(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));
        % LENGTH
        data.result.a1.fsN(cI)      = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fsN(cI)      = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fsN(cI)    = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        data.result.a1_1dec.fsN(cI) = length(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fsN(cI) = length(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));
        data.result.collA1.N(cI)    = length(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.N(cI)    = length(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));
    end

    %----------------------------------------------------------------------
    % PLOTTING decision
    %----------------------------------------------------------------------
    % Plot P(Report 2nd) across contrast differences (non-logarithmic)
    % Note: This plot is like the psych. curve but without curve fitting!
    % -> Here we use the decision data (1 or 2)
    % -----------------------------------------
    acc_fig_psy=figure('Name',['S' ptc{p}]); set(acc_fig_psy, 'WindowStyle', 'Docked');
    plot(conSteps,data.result.a1.fs,'bs-');
    hold on;
    plot(conSteps,data.result.a2.fs,'yo-');
    plot(conSteps,data.result.coll.fs,'gv-','LineWidth',1);
    xlabel('C2 - C1','FontSize',18);
    ylabel('P(Report 2nd)','FontSize',18);
    ylim([0 1]);
    title(['Sensitivity - ','S' ptc{p}],'FontSize',22);
    %if save_plot
        %saveas(gcf,[path_to_save,'S',ptc{p},'_PerSens_',lab,block_lab,ind_lab],'png');
    %end

    
    %----------------------------------------------------------------------
    % FIT and PLOT PSYCHOMETRIC CURVES
    %----------------------------------------------------------------------
    full = 1; % 1 = compute cb for all trials, not for windows
    
    % *y* contains the DECISION data - for each of the 8 contrast levels  
    % 7 columns: [Blue, Yellow, Collective , BColl, YColl, Bdec1, Ydec1]
    % 15 rows (participant pairs)
    y    = [data.result.a1.fs' data.result.a2.fs' data.result.coll.fs'...
            data.result.collA1.fs' data.result.collA2.fs'...
            data.result.a1_1dec.fs' data.result.a2_1dec.fs'];

    % Prepare figure (per pair) to show psychometric curves
    cb=figure('Name',['CB_S' ptc{p}]); set(cb, 'WindowStyle', 'Docked');

    % *slope* contains the slope values (max or mean)
    % -> computed inside function plot_psy, see below
    % 7 columns: [Blue, Yellow, Collective , BColl, YColl, Bdec1, Ydec1]
    % 15 rows (participant pairs)
    % ---------------------------------------------------------------------
    % -> GO INTO FUNCTION PLOT_PSY to fit and plot psych. curves
    aveFlag=0;
    slope(p,:) = plot_psy(conSteps,y,plotSym,color,default,full,coll_calc,benefitType,mrkColor,aveFlag);
    % ---------------------------------------------------------------------

    % Set figure properties for psychometric function plots
    ylim([0 1]);
    xlabel("Contrast difference",'FontSize',18);
    ylabel("Proportion 2nd interval",'FontSize',18);

    %----------------------------------------------------------------------
    % COMPUTE COLLECTIVE BENEFIT
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
        if agent_max == 1
            text(-0.18,0.95,['ind. benefit B (max) = ' num2str(coll_ben(p,1),'%.2f')],'FontSize',18, 'Color', color(1,:));
            text(-0.18,0.9, ['ind. benefit Y (min) = ' num2str(coll_ben(p,2),'%.2f')],'FontSize',18, 'Color', color(2,:));
        elseif agent_max == 2
            text(-0.18,0.95,['ind. benefit B (min) = ' num2str(coll_ben(p,1),'%.2f')],'FontSize',18, 'Color', color(1,:));
            text(-0.18,0.9, ['ind. benefit Y (max) = ' num2str(coll_ben(p,2),'%.2f')],'FontSize',18, 'Color', color(2,:));
        end
        title(['Ind. benefit - ','S' ptc{p}],'FontSize',22);
    end

    % Save psychometric curve figure
    if save_plot
        saveas(gcf,[path_to_save,'S',ptc{p},'_PsyC',lab,block_lab,ind_lab],'png');
    end
    hold off;
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
        plot(slope_wcoll(p,:),['-' plotSym{3}],'Color',color(3,:));
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
    y_ave = [decMin_ave' decMax_ave' decDyad_ave']; % [smin, smax, Collective]
elseif benefitType == 1
    y_ave = [dmin_coll_ave' dmax_coll_ave' dmin_1dec_ave' dmax_1dec_ave'];
end

% Prepare figure
cb_ave=figure('Name','CB_Average'); set(cb_ave, 'WindowStyle', 'Docked');

% -------------------------------------------------------------------------
% -> GO INTO FUNCTION PLOT_PSY to fit and plot psych. curves
aveFlag=1;
sAverage = plot_psy(conSteps,y_ave,plotSymAve,colorAve,default,full,coll_calc,benefitType,mrkColor,aveFlag);
% -------------------------------------------------------------------------

% Set figure properties
ylim([0 1]);
xlabel('Contrast difference','FontSize',18);
ylabel('Proportion 2nd interval','FontSize',18);

% Display the computed values as text in plot
if benefitType == 2
    text(-0.18,0.95,['mean coll. benefit = ' num2str(mean(cb_all),'%.2f')],'FontSize',18);
    title('Grand averages: collective benefit','FontSize',22);
elseif benefitType == 1
    text(-0.18,0.95,['mean ind. benefit MAX = ' num2str(mean(ib_all_max),'%.2f')],'FontSize',18, 'Color', colorAve(2,:));
    text(-0.18,0.9,['mean ind. benefit MIN = ' num2str(mean(ib_all_min),'%.2f')],'FontSize',18, 'Color', colorAve(1,:));
    title('Grand averages: individual benefit','FontSize',22);
end

% Save figure
if save_plot
    saveas(gcf,[path_to_save,'Average_PsyC',lab,block_lab],'png');
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% AVERAGE PSYCHOMETRIC CURVES (dyad, min, max) per WINDOW
% ----------------------------------------------------------
% Compute collective benefit as average across pairs and for all pairs
if not(subcon_calc) && sub_block==0 && length(ptc)>1

    % Average across pairs
    h4=figure(); set(h4,'WindowStyle','Docked');
    errorbar(1:default.w_lgt/default.step,mean(slope_wcoll),-std(slope_wcoll)/sqrt(length((slope_wcoll))),+std(slope_wcoll)/sqrt(length((slope_wcoll))),'Color', color(3,:),'LineWidth',1);hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
    xlim([0 (default.w_lgt/default.step)+1]);
    xticks(0:1:10);
    ylim([0.95 1.25]);
    yticks(0.95:0.05:1.25);
    %     axis([0 (default.w_lgt/default.step)+1 0.8 1.2]);
    xlabel('Sliding window (80 trials each)','FontSize',18);
    ylabel('sdyad/smax','FontSize',18);
    title('Average values across pairs - coll. benefit','FontSize',22);
    % Save figure
    if save_plot
        saveas(gcf,[path_to_save,'Average_WindowCB_',lab,block_lab],'png');
    end

    % All pairs within one figure
    allColors = jet(16);
    h5=figure(); set(h5, 'WindowStyle', 'Docked');
    colororder(allColors(1:end,:));
    plot(slope_wcoll',['-' plotSym{3}]); hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:),'LineWidth',1.5);
    hold off;
    axis([0 (default.w_lgt/default.step)+1 0.5 2.2])
    legend({'S108','S110','S111','S112','S113','S114','S115','S116',...
        'S117','S118','S120','S121','S122','S123','S124','1'},'location','bestoutside');
    title('Coll. benefit - each pair','FontSize',22);
    % Save figure
    if save_plot
        saveas(gcf,[path_to_save,'AllPairs_WindowCB_',lab,block_lab],'png');
    end

end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% AVERAGE ACCURACIES (dyad, individual)
% --------------------------------------------------
% Compute average accuracy for sdyad and sindividual
accDyad_ave = mean(accDyad_all,1);
accB_ave   = mean(accB_all,1);
accY_ave   = mean(accY_all,1);
accInd_ave = mean([accB_ave; accY_ave],1);
acc_fig_contrasts_ave=figure('Name','AccAverage');
set(acc_fig_contrasts_ave, 'WindowStyle', 'Docked');
semilogx(absConSteps,accInd_ave,'--o','MarkerSize',6,'LineWidth',1.5,'Color',[1 0 1]); % Individual
hold on;
semilogx(absConSteps,accDyad_ave,'-*','MarkerSize',6,'LineWidth',1.5,'Color',colorAve(3,:)); % Collective
xlabel('Contrast difference','FontSize',18); %xlabel('LOG |C2 - C1|');
xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
xticks([min(absConSteps)*.8 max(absConSteps)*1.2]);
ylabel('Accuracy','FontSize',18);
ylim([0.3 1]);
title('Accuracy average across pairs','FontSize',22);
% save figure
if save_plot
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
cbcol=[0.7529  0.9412  0.5059];
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
yline(1, '-','Collective benefit','LineWidth',2, 'Color',cbcol, 'FontSize',12);
text(0.35,1.55,['R: ' num2str(R(2,1),'%.4f')],'Color','k','FontSize',18);
text(0.35,1.52,['p: ' num2str(P(2,1),'%.4f')],'Color','k','FontSize',18);
xlabel('smin/smax','FontSize',18);
ylabel('sdyad/smax','FontSize',18);
title('Coll. benefit as a function of similarity','FontSize',22);
% Save figure
if save_plot
    saveas(gcf,[path_to_save,'SimilarityCorr',lab,block_lab],'png');
end
% -------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATISTICAL TESTS
% test whether collective slope differs from max. slope
[h,p,ci,stats] = ttest(sdyad_all', smax_all', "Tail","right");
% % use non-parametric test (Wilcoxon signed rank test):
% [p,h,stats] = signrank(sdyad_all',smax_all');
disp('Is there a collective benefit?');
if p < 0.05
    disp('Collective is better than more sensitive individual!')
elseif p >= 0.05
    disp('No collective benefit!')
end
disp(['p-value (coll. slope vs. max. slope): ' num2str(p,'%.7f')]);
fprintf('\n');

% test if max/min individual differs from max/min collective slope
[h,p,ci,stats] = ttest(smax_coll', smax_1dec', "Tail","right");
disp('Did the more sensitive individual benefit?');
if p < 0.05
    disp('The more sensitive individual had a benefit!')
elseif p >= 0.05
    disp('The more sensitive individual did NOT benefit.')
end
disp(['p-value (max coll. vs. max indi.): ' num2str(p,'%.7f')]);
fprintf('\n');

[h,p,ci,stats] = ttest(smin_coll', smin_1dec', "Tail","right");
disp('Did the less sensitive individual benefit?');
if p < 0.05
    disp('The less sensitive individual had a benefit!')
elseif p >= 0.05
    disp('The less sensitive individual did NOT benefit.')
end
disp(['p-value (min coll. vs. min indi.): ' num2str(p,'%.7f')]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
