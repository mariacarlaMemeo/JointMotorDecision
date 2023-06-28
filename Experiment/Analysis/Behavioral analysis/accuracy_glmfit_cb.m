%--------------------------------------------------------------------------
% ANALYSIS JMD study (JMD = joint motor decision)
% Data: collected in June 2023 @IIT Genova
% Participants: N=32 (16 pairs), [108,110,111:124]
% Script: written by Mariacarla Memeo & Laura Schmitz
% Analyses: accuracy, perceptual sensitivity, collective benefit
%--------------------------------------------------------------------------

% Here we analyze the accuracy and the perceptual sensitivity
% (-> fit psychometric function) of two participants who perform a 2AFC
% detection task (oddball in 1st or 2nd interval?). Each participant 
% first takes her individual decision; then one of the two participants 
% takes the final, collective decision. The two participants are labelled
% Blue agent (formerly A1) and Yellow agent (formerly A2).

close all;
clear;

%--------------------------------------------------------------------------
% Prepare path and variables
%--------------------------------------------------------------------------
path_to_edit = 'C:\Users\Laura\Desktop\check\exp_data_107+\'; % Matlab data
path_to_save = 'C:\Users\Laura\Desktop\check\'; % save figures here
ptc          = [108, 110, 111:124]; % participant numbers

% Initialize variable to save slope values for: Blue, Yellow, Collective,
% Coll. Blue, Coll. Yellow, Coll. Blue v2, Coll. Yellow v2,
slope        = zeros(length(ptc),7);
% Initialize variable to save collective benefit values:
% 3 = collective benefit (cb); 1 = cb A1/Blue; 2 = cb A2/Yellow
coll_ben     = zeros(length(ptc),3);

% Figures labels
lab        = ''; block_lab = ''; CB_lab = '';
% Preallocate variables to save specific values for all participants
sdyad_all  = []; smax_all    = []; decDyad_all = []; decMax_all = [];
decMin_all = []; accDyad_all = []; accB_all    = []; accY_all   = [];
ratio_all  = []; cb_all      = [];
   
% Window analysis (length: default.w_lgt)
default.step        = 8;
default.w_lgt       = 80;
default.w           = zeros(default.w_lgt/default.step,default.w_lgt);
default.slope_wnd   = [];
default.slope_wcoll = [];

% Specify colors and markers
plotSym    = {'s' 'o' '*' '+' '+'};
plotSymAve = {'o' 's' 'diamond'};
% Specify colors
color     = [[30 60 190]; [240 200 40]; [17 105 40];... % blue, yellow, dark green
    [30 60 190]; [240 200 40]; ... % blue, yellow
     % gray, emerald green, persian green, pine green:
    [51 51 51]; [80 200 120]; [0 165 114]; [1 121 111]]./255;
% Specify colors for average plots
colorAve = [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; [0 0 0]];


%--------------------------------------------------------------------------
% Ask for use input
%--------------------------------------------------------------------------
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
    lab = '_balanced';
elseif sub_con==2
    subcon_calc = 0;
end
% Select how to compute the individual collective benefit
% Use all individual trials or only those in which the individual acted
% first (and thus also took the respective joint decision)
ind_CB = input('Choose to select individual CB:\n 1 = all ind. trials\n 2 = only 1dec ind. trials\n');
if ind_CB==1
    CB_lab = '_indCBAll';
elseif ind_CB==2
    CB_lab = '_indCB1dec';
end
% Select only first or second block?
sub_block = input('Choose to select block:\n 0 = allBlocks\n 1 = 1stBlock\n 2 = 2ndBlock\n');
if sub_block==0
elseif sub_block==1
    block_lab = '_block1';
elseif sub_block==2
    block_lab = '_block2';
end

%--------------------------------------------------------------------------
% START ANALYSIS
%--------------------------------------------------------------------------
for p=1:length(ptc) % start pair loop (p=number of pairs; ptc=pair numbers)
    
    % Load each pair's data
    each = dir([path_to_edit,'*.mat']);
    load([path_to_edit,each(p).name])
    disp(['Loading ',each(p).name]);

    % remove header and convert cell to mat
    % optionally: select 1st or 2nd block
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
    % Optionally subselect trials
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
    contrast_v      = data.output(:,6); % current contrast
    firstSecond_v   = data.output(:,8); % oddball in 1st or 2nd?
    % Give the sign to the contrast (- if 1st interval, + if 2nd interval)
    C2_C1_v         = contrast_v .* (2.*firstSecond_v - 3);
    conSteps        = unique(C2_C1_v);
    absConSteps     = unique(abs(conSteps));
    % Create vectors for accuracies (individual agents and collective)
    a1_acc_v        = data.output(:,11); % A1/Blue accuracy
    a2_acc_v        = data.output(:,17); % A2/Yellow accuracy
    coll_acc_v      = data.output(:,23); % Collective accuracy
    % Split collective accuracy depending on the agent
    agentExecColl_clmn = agent_order(:,3); % agent taking collective decision
    coll_acc_vA1       = coll_acc_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)));
    coll_acc_vA2       = coll_acc_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)));

    % Collect ACCURACIES per contrast level (for B,Y,Coll,BColl,YColl)
    for cI = 1 : size(absConSteps,1)
        c                         = absConSteps(cI);
        data.result.a1.acc(cI)    = mean(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.acc(cI)    = mean(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.acc(cI)  = mean(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.acc(cI)= mean(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.acc(cI)= mean(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));

        data.result.a1.N(cI)      = length(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.N(cI)      = length(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.N(cI)    = length(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.N(cI)  = length(coll_acc_vA1(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.N(cI)  = length(coll_acc_vA2(abs(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))))==c & ~isnan(coll_acc_vA2)));
    end

    %----------------------------------------------------------------------
    % PLOTTING
    %----------------------------------------------------------------------
    % Plot accuracies across abs., log-transformed contrast differences
    %  -> Here we use the accuracy data (0 or 1)
    % -----------------------------------------
    acc_fig_contrasts=figure('Name',['S' num2str(ptc(p))]); set(acc_fig_contrasts, 'WindowStyle', 'Docked');
    semilogx(absConSteps,data.result.a1.acc,'-s','MarkerSize',6,'LineWidth',1.5,'Color',color(1,:)); % Blue
    hold on;
    semilogx(absConSteps,data.result.a2.acc,'-o','MarkerSize',6,'LineWidth',1.5,'Color',color(2,:)); % Yellow
    semilogx(absConSteps,data.result.coll.acc,'-*','MarkerSize',6,'LineWidth',1.5,'Color',color(3,:)); % Coll green
    xlabel('Contrast difference'); %xlabel('LOG |C2 - C1|');
    xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
    xticks([min(absConSteps)*.8 max(absConSteps)*1.2]); % remove ticks?
    ylabel('Accuracy');
    ylim([0.3 1]);
    title(['Accuracy - ','S' num2str(ptc(p))]);
    saveas(gcf,[path_to_save,'S',num2str(ptc(p)),'_accuracy',lab,block_lab,CB_lab],'png');
    
    % Save accuracies for all pairs
    accDyad_all  = [accDyad_all; data.result.coll.acc];
    accB_all     = [accB_all; data.result.a1.acc];
    accY_all     = [accY_all; data.result.a2.acc];
   
    %----------------------------------------------------------------------
    % Plot P(Report 2nd) across abs., log-transformed contrast differences
    % -> Here we use the decision data (1 or 2)
    % -----------------------------------------
    % fs = FirstSecond
    % if A said 1 (1st interval), the value is 0
    % if A said 2 (2nd interval), the value is 1
    a1_fs_v     = data.output(:,10)-1; % B decision
    a2_fs_v     = data.output(:,16)-1; % Y decision
    coll_fs_v   = data.output(:,22)-1; % Collective decision
    % Split collective decision depending on the agent
    coll_fs_vA1 = coll_fs_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)));
    coll_fs_vA2 = coll_fs_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)));
    % Save only those individual decisions where agent acted first & last
    % (We need this value as a denominator when computing the indiv. coll.
    % benefit (lines 209-210) in version 2).
    a1_1dec_fs_v   = a1_fs_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false))); % A1 1st and coll. decision
    a2_1dec_fs_v   = a2_fs_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false))); % A2 1st and coll. decision

    % Collect DECISIONS per contrast level (for B,Y,Coll,BColl,YColl)
    for cI = 1 : size(conSteps,1)
        c                        = conSteps(cI);
        data.result.a1.fs(cI)    = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fs(cI)    = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fs(cI)  = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        % The 2 following lines are for individual decisions where
        % Blue/Yellow took also the collective decision
        data.result.a1_1dec.fs(cI)   = mean(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fs(cI)   = mean(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));

        data.result.collA1.fs(cI)    = mean(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.fs(cI)    = mean(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));

        data.result.a1.fsN(cI)   = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fsN(cI)   = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fsN(cI) = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));
        % The 2 following lines are for individual decisions where
        % Blue/Yellow took also the collective decision
        data.result.a1_1dec.fsN(cI)   = length(a1_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a1_1dec_fs_v)));
        data.result.a2_1dec.fsN(cI)   = length(a2_1dec_fs_v(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(a2_1dec_fs_v)));

        data.result.collA1.N(cI) = length(coll_fs_vA1(C2_C1_v(cell2mat(cellfun(@(x) x=='B',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.N(cI) = length(coll_fs_vA2(C2_C1_v(cell2mat(cellfun(@(x) x=='Y',agentExecColl_clmn,'UniformOutput',false)))==c & ~isnan(coll_fs_vA2)));
    end

    %----------------------------------------------------------------------
    % Add the non-logarithmic plot (not necessary, so don't save it)
    acc_fig_psy=figure('Name',['S' num2str(ptc(p))]); set(acc_fig_psy, 'WindowStyle', 'Docked');
    plot(conSteps,data.result.a1.fs,'bs-');
    hold on;
    plot(conSteps,data.result.a2.fs,'yo-');
    plot(conSteps,data.result.coll.fs,'gv-','LineWidth',1);
    xlabel('C2 - C1');
    ylabel('P(Report 2nd)');
    ylim([0 1]);
    title(['Accuracy - ','S' num2str(ptc(p))]);
    % saveas(gcf,[path_to_save,'S',num2str(ptc(p)),'_psy',lab,block_lab,CB_lab],'png');
    
    
    %----------------------------------------------------------------------
    % FIT PSYCHOMETRIC CURVES
    %----------------------------------------------------------------------
    % In y, we save the decision data for each contrast level (i.e., signed 
    % contrast differences -> 8 values). There are 7 output values, for:
    % [Blue/A1, Yellow/A2, Collective , BColl, YColl, BCollv2, YCollv2]
    y       = [data.result.a1.fs' data.result.a2.fs' data.result.coll.fs'...
               data.result.collA1.fs' data.result.collA2.fs'...
               data.result.a1_1dec.fs' data.result.a2_1dec.fs'];
    % Figure per pair that shows the psychometric curves
    cb=figure('Name',['CB_S' num2str(ptc(p))]);set(cb, 'WindowStyle', 'Docked');
    % slope: [a1(blue), a2(yellow), sdyad(coll), sdyadA1(coll blue), sdyadA2(coll yellow)]
    % Each row is a pair; each column refers to coll/individual etc.
    full=1; % compute cb for all trials, not for windows
    slope(p,:) = plot_psy(conSteps,y,plotSym,color,default,full,coll_calc);
    ylim([0 1]);
    xlabel("Contrast difference");
    ylabel("Proportion 2nd interval");

    %%%%%Compute collective benefit
    [smax,agent_max]  = max(slope(p,1:2));
    [smin,agent_min]  = min(slope(p,1:2));
    % Note: the total collective benefit takes into account all trials
    % (from the coll. decision and from the max. individual decider)
    % whereas the indiv. collective benefits take into account only those
    % trials in which the respective individual (b/y) took the first and
    % last decision
    %%%
    coll_ben(p,3) = round(slope(p,3)/smax,2); % this is the coll. benefit
    %%%
    if ind_CB==1
        coll_ben(p,1) = round(slope(p,4)/slope(p,1),2);%sdyadA1/slope_a1;
        coll_ben(p,2) = round(slope(p,5)/slope(p,2),2);%sdyadA2/slope_a2;
    elseif ind_CB==2
        coll_ben(p,1) = round(slope(p,4)/slope(p,6),2);%sdyadA1/slope_a1 1st dec;
        coll_ben(p,2) = round(slope(p,5)/slope(p,7),2);%sdyadA2/slope_a2 1st dec;
    end
    
    % display info in command window
    disp(['Collective benefit ' num2str(ptc(p)) ': ' num2str(coll_ben(p,3))]);
    disp(['B individual coll benefit ' num2str(ptc(p)) ': ' num2str(coll_ben(p,1))])
    disp(['Y individual coll benefit ' num2str(ptc(p)) ': ' num2str(coll_ben(p,2))])
    disp(['smax: ' num2str(smax) ' agent: ' num2str(agent_max)]);
    disp(['smin: ' num2str(smin) ' agent: ' num2str(agent_min)]);
    disp(['sdiff: ' num2str(smax-smin)]);
    % include coll. benefit numbers in plot
    text(-0.15,0.8,['coll. benefit = ' num2str(coll_ben(p,3),'%.2f')]);
%     text(-0.15,0.7,['coll. blue benefit = ' num2str(coll_ben(p,1))]);
%     text(-0.15,0.6,['coll. yell benefit = ' num2str(coll_ben(p,2))]);
    
    title(['Coll. benefit - ','S' num2str(ptc(p))]);

    %save figure
    saveas(gcf,[path_to_save,'S',num2str(ptc(p)),'_cb',lab,block_lab,CB_lab],'png');
    hold off;

    ratio = smin/smax;

    % collect values for all pairs
    sdyad_all    = [sdyad_all; slope(p,3)];
    smax_all     = [smax_all; smax];
    cb_all       = [cb_all; coll_ben(p,3)];
    ratio_all = [ratio_all; ratio];
    decDyad_all  = [decDyad_all; y(:,3)'];
    decMax_all   = [decMax_all; y(:,agent_max)'];
    decMin_all   = [decMin_all; y(:,agent_min)'];
    
    
    
    % ---------------- WINDOW ANALYSIS -----------------------------------%
    % Calculate collective benefit in windows of 80 elements each 8(4) trials
    % -> use the same smax found before
    % -> collective decision and relative signed contrast
    if not(subcon_calc) && sub_block==0
        ws=figure('Name',['S' num2str(ptc(p)) '_wnd']);set(ws, 'WindowStyle', 'Docked');
        % XXX WHAT DOES THE FOLLOWING COMMENT MEAN?
        % Each row is a pair - here the y is different!!!
        full=0; % compute cb separately for windows
        coll_prtc = [coll_fs_v C2_C1_v];
        slope_wcoll(p,:) = plot_psy(conSteps,coll_prtc,plotSym,color,default,full,coll_calc);
        slope_wcoll(p,:) = slope_wcoll(p,:)/smax;
        plot(slope_wcoll(p,:),['-' plotSym{3}],'Color',color(3,:)); title(['Coll benefit - ','S' num2str(ptc(p)),'- wnd']);
    end
end % end of pair loop ---------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute average decisions for sdyad, smin, smax
% Use median instead of mean?!
% (The median is the middle value when a data set is ordered from least to
% greatest.)
decDyad_ave  = median(decDyad_all,1);
decMax_ave   = median(decMax_all,1);
decMin_ave   = median(decMin_all,1);
y = [decMin_ave' decMax_ave' decDyad_ave'];
cb_ave=figure('Name','CB_Average');
set(cb_ave, 'WindowStyle', 'Docked');
% slope: [a1(blue), a2(yellow), sdyad(coll)]
% Each row is a pair; each column refers to coll/individual etc.
full=1; % compute cb for all trials, not for windows
sAverage = plot_psy(conSteps,y,plotSymAve,colorAve,default,full,coll_calc);
ylim([0 1]);
xlabel("Contrast difference");
ylabel("Proportion 2nd interval");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Compute collective benefit as average across pairs and per pair, PER WINDOW
if not(subcon_calc) && sub_block==0 && length(ptc)>1
    
    % average across pairs
    h4=figure();set(h4,'WindowStyle','Docked');
    errorbar(1:default.w_lgt/default.step,mean(slope_wcoll),-std(slope_wcoll)/sqrt(length((slope_wcoll))),+std(slope_wcoll)/sqrt(length((slope_wcoll))),'Color', color(3,:),'LineWidth',1);hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
    xlim([0 (default.w_lgt/default.step)+1]);
    xticks(0:1:10);
    ylim([0.9 1.1]);
    yticks(0.9:0.05:1.1);
%     axis([0 (default.w_lgt/default.step)+1 0.8 1.2]);
    xlabel("Sliding window (80 trials each)");
    ylabel("sdyad/smax");
    title('Average values across pairs - coll. benefit');
    
    % all pairs within one figure
    h5=figure();set(h5, 'WindowStyle', 'Docked');
    colororder(color(end-2:end,:));
    plot(slope_wcoll',['-' plotSym{3}]); hold on;
    % plot a horizontal line at 1
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:),'LineWidth',1); hold off
    axis([0 (default.w_lgt/default.step)+1 0.6 1.3])
%     legend({'P101','P102','P103','P104','P105','P106','1'},'location','best');
    title('Coll. benefit - each pair');

end

% test whether collective slope differs from max. slope
% [h,p,ci,stats] = ttest(sdyad_all',smax_all', "Tail","right");
% use non-parametric test (Wilcoxon signed rank test)
[p,h,stats] = signrank(sdyad_all',smax_all');
disp(['p-value (coll. slope vs. max. slope): ' num2str(p,'%.7f')]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute average accuracy for sdyad, smin, smax
accDyad_ave = mean(accDyad_all,1);
accB_ave   = mean(accB_all,1);
accY_ave   = mean(accY_all,1);
accInd_ave = mean([accB_ave; accY_ave],1);
acc_fig_contrasts_ave=figure('Name','AccAverage');
set(acc_fig_contrasts_ave, 'WindowStyle', 'Docked');
semilogx(absConSteps,accInd_ave,'--o','MarkerSize',6,'LineWidth',1.5,'Color',[1 0 1]); % Individual
hold on;
semilogx(absConSteps,accDyad_ave,'-*','MarkerSize',6,'LineWidth',1.5,'Color',colorAve(3,:)); % Collective
%xlabel('LOG |C2 - C1|');
xlabel('Contrast difference');
xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
xticks([min(absConSteps)*.8 max(absConSteps)*1.2]);
ylabel('Accuracy');
ylim([0.3 1]);
title('Accuracy average across pairs');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if interindividual differences play a role
cb_ratio_combo = [cb_all ratio_all];
cb_ratio_combo_sorted = sortrows(cb_ratio_combo,2);
scatter(cb_ratio_combo_sorted(:,2),cb_ratio_combo_sorted(:,1)); hold on;
line = lsline; hold on;
yline(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%