% analysis of perceptual sensitivity for oddball detection task
close all;
clear;
% load('C:\Users\Laura\Sync\00_Research\2022_UKE\Confidence from motion\04_Analysis\pilotData\gID103_run1_jomode.mat');
% load('Y:\Datasets\JointMotorDecision\Static\Raw\P100\task\gID100_run1_jomode.mat');

ptc = [100,101,103];

for p=ptc

    path_to_edit = ['Y:\Datasets\JointMotorDecision\Static\Raw\P',num2str(p),'\task\'];
    
    %loading each participant data
    each = dir([path_to_edit,'*.mat']);
    load([path_to_edit,each.name])
    disp(['Loading ',each.name]);

    % define variables
    asymp_limits    = [0 0.5];
    contrast_v      = data.output(:,4); % current contrast
    firstSecond_v   = data.output(:,6); % oddball in 1st or 2nd?
    C2_C1_v         = contrast_v .* (2.*firstSecond_v - 3);% gives the sign to the contrast
    conSteps        = unique(C2_C1_v);
    absConSteps     = unique(abs(conSteps));

    %-------------------------------------------------------------------------%
    % create vectors for accuracies (individual agents and collective)
    a1_acc_v        = data.output(:,9); % Agent 1 accuracy
    a2_acc_v        = data.output(:,15);% Agent 2 accuracy
    coll_acc_v      = data.output(:,21);% Collective accuracy

    %split collective accuracy depending on the agent
    agentExecColl_clmn = data.output(:,end);% agent taking collective decision
    coll_acc_vA1       = coll_acc_v(agentExecColl_clmn==1);
    coll_acc_vA2       = coll_acc_v(agentExecColl_clmn==2);

    for cIndex = 1 : size(absConSteps,1)
        c                           = absConSteps(cIndex);
        data.result.a1.acc(cIndex)  = mean(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.acc(cIndex)  = mean(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.acc(cIndex)= mean(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.acc(cIndex)= mean(coll_acc_vA1(abs(C2_C1_v(agentExecColl_clmn==1))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.acc(cIndex)= mean(coll_acc_vA2(abs(C2_C1_v(agentExecColl_clmn==2))==c & ~isnan(coll_acc_vA2)));

        data.result.a1.N(cIndex)    = length(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.N(cIndex)    = length(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.N(cIndex)  = length(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.N(cIndex)  = length(coll_acc_vA1(abs(C2_C1_v(agentExecColl_clmn==1))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.N(cIndex)  = length(coll_acc_vA2(abs(C2_C1_v(agentExecColl_clmn==2))==c & ~isnan(coll_acc_vA2)));
    end

    %-------------------------------------------------------------------------%
    % plot accuracies across contrasts for A1, A2, and Collective
    %  -> here we use the accuracy data (0 or 1)
    a=figure('Name',['P' ptc]); set(a, 'WindowStyle', 'Docked');
    subplot(1,2,1);
    semilogx(absConSteps,data.result.a1.acc,'bs-'); % A1 blue
    hold on
    semilogx(absConSteps,data.result.a2.acc,'yo-'); % A2 yellow
    semilogx(absConSteps,data.result.coll.acc,'gv-','LineWidth',1); % Coll green
    % semilogx(absConSteps,data.result.a1.acc,[0 0.4470 0.7410]); % A1 blue
    % hold on
    % semilogx(absConSteps,data.result.a2.acc,[0 0.4470 0.7410]); % A2 yellow
    % semilogx(absConSteps,data.result.coll.acc,[0 0.4470 0.7410],'LineWidth',1); % Coll green
    xlabel('LOG |C2 - C1|');
    xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
    ylabel('Accuracy');

    % CHECK THE BELOW LATER
    % h = figure(2);
    % fitTable = [absConSteps data.result.kb.acc' data.result.kb.N'];
    % data.result.kb.s = pfit(fitTable, 'shape', 'w', 'n_intervals', 2, 'runs', 10,'plot_opt','plot','lambda_limits',asymp_limits);
    % hold on
    % fitTable = [absConSteps data.result.ms.acc' data.result.ms.N'];
    % data.result.kb.s = pfit(fitTable, 'shape', 'w', 'n_intervals', 2, 'runs', 10,'plot_opt','plot','lambda_limits',asymp_limits);
    % hold on
    % fitTable = [absConSteps data.result.con.acc' data.result.con.N'];
    % data.result.kb.s = pfit(fitTable, 'shape', 'w', 'n_intervals', 2, 'runs', 10,'plot_opt','plot','lambda_limits',asymp_limits);
    % hold on
    % %saveas(h, ['g', int2str(data.group.id) '_r' int2str(data.runNumber) , '_baysCom02.mat' ], 'fig');

    %-------------------------------------------------------------------------%
    % plot P(Report 2nd) -> here we use the decision data (1 or 2)
    % fs = FirstSecond
    a1_fs_v     = data.output(:,8)-1;  % A1 decision:
    % if A1 said 1 (1st interval), the value is 0;
    % if A2 said 2 (2nd interval), the value is 1
    a2_fs_v     = data.output(:,14)-1; % A2 decision
    coll_fs_v   = data.output(:,20)-1; % collective decision
    %split collective decision depending on the agent
    coll_fs_vA1       = coll_fs_v(agentExecColl_clmn==1);
    coll_fs_vA2       = coll_fs_v(agentExecColl_clmn==2);

    for cIndex = 1 : size(conSteps,1)
        c                           = conSteps(cIndex);
        data.result.a1.fs(cIndex)   = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fs(cIndex)   = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fs(cIndex)  = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));

        data.result.collA1.fs(cIndex)= mean(coll_fs_vA1(C2_C1_v(agentExecColl_clmn==1)==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.fs(cIndex)= mean(coll_fs_vA2(C2_C1_v(agentExecColl_clmn==2)==c & ~isnan(coll_fs_vA2)));

        data.result.a1.fsN(cIndex)  = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fsN(cIndex)  = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fsN(cIndex) = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));

        data.result.collA1.N(cIndex)  = length(coll_fs_vA1(C2_C1_v(agentExecColl_clmn==1)==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.N(cIndex)  = length(coll_fs_vA2(C2_C1_v(agentExecColl_clmn==2)==c & ~isnan(coll_fs_vA2)));
    end

    
    subplot(1,2,2);
    plot(conSteps,data.result.a1.fs,'bs-');
    hold on
    plot(conSteps,data.result.a2.fs,'yo-');
    plot(conSteps,data.result.coll.fs,'gv-','LineWidth',1);
    xlabel('C2 - C1');
    ylabel('P(Report 2nd)');
    %-------------------------------------------------------------------------%
    % % plot psychometric curves to see collective benefit (for pair)
    % figure(2);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % plot A1 in blue
    % plotSym = 's';
    % y = data.result.a1.fs';
    % bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    % data.result.a1.mean = -bhat(1)/bhat(2);
    % data.result.a1.sd   = 1/bhat(2);
    % plot(conSteps, y,['b' plotSym],'LineWidth',2);
    % hold on
    % C_a1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    % ps_a1 = cdf('norm',C_a1,data.result.a1.mean,data.result.a1.sd);
    % plot(C_a1,ps_a1,'b-','LineWidth',3)
    % slope_a1 = max(diff(ps_a1)./diff(C_a1));
    % clear bhat;
    % hold on;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % plot A2 in yellow
    % plotSym = 'o';
    % y = data.result.a2.fs';
    % bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    % data.result.a2.mean = -bhat(1)/bhat(2);
    % data.result.a2.sd   = 1/bhat(2);
    % plot(conSteps, y,['y' plotSym],'LineWidth',2);
    % hold on;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % C_a2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    % ps_a2 = cdf('norm',C_a2,data.result.a2.mean,data.result.a2.sd);
    % plot(C_a2,ps_a2,'y-','LineWidth',3)
    % slope_a2 = max(diff(ps_a2)./diff(C_a2));
    % clear bhat;
    % hold on;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % plot Collective in green
    % plotSym = '*';
    % y = data.result.coll.fs';
    % bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    % data.result.coll.mean = -bhat(1)/bhat(2);
    % data.result.coll.sd   = 1/bhat(2);
    % plot(conSteps, y,['g' plotSym],'LineWidth',2);
    % hold on;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % C_coll = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    % ps_coll = cdf('norm',C_coll,data.result.coll.mean,data.result.coll.sd);
    % plot(C_coll,ps_coll,'g-','LineWidth',3)
    % sdyad = max(diff(ps_coll)./diff(C_coll));
    % clear bhat;
    % hold on;
    %
    % %%%%%Collective benefit
    % smax  = max(slope_a1,slope_a2);
    % smin  = min(slope_a1,slope_a2);
    % coll_ben = sdyad/smax;
    % coll_ben_rounded = round(coll_ben,2);
    % text(-0.15,0.6,['coll. benefit = ' num2str(coll_ben_rounded)]);
    % hold off;
    %
    % ratio = smin/smax;


    %-------------------------------------------------------------------------%
    % plot psychometric curves to see collective benefit (per agent)
    h3=figure(3);set(h3, 'WindowStyle', 'Docked');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot A1 in blue
    plotSym = 's';
    y = data.result.a1.fs';
    bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    data.result.a1.mean = -bhat(1)/bhat(2);
    data.result.a1.sd   = 1/bhat(2);
    plot(conSteps, y, plotSym,'Color',[30/255 60/255 190/255]);%blue
    hold on;
    C_a1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    ps_a1 = cdf('norm',C_a1,data.result.a1.mean,data.result.a1.sd);
    plot(C_a1,ps_a1,'-','LineWidth',2,'Color',[30/255 60/255 190/255]);
    slope_a1 = max(diff(ps_a1)./diff(C_a1));
    clear bhat;
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot A2 in yellow
    plotSym = 'o';
    y = data.result.a2.fs';
    bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    data.result.a2.mean = -bhat(1)/bhat(2);
    data.result.a2.sd   = 1/bhat(2);
    plot(conSteps, y, plotSym,'Color',[240/255 200/255 40/255]);%yellow
    hold on;
    C_a2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    ps_a2 = cdf('norm',C_a2,data.result.a2.mean,data.result.a2.sd);
    plot(C_a2,ps_a2,'-','LineWidth',2,'Color',[240/255 200/255 40/255])
    slope_a2 = max(diff(ps_a2)./diff(C_a2));
    clear bhat;
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot Collective in green
    plotSym = '*';
    y = data.result.coll.fs';
    bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    data.result.coll.mean = -bhat(1)/bhat(2);
    data.result.coll.sd   = 1/bhat(2);
    plot(conSteps, y, plotSym,'Color',[17/255 105/255 40/255]);%green
    hold on;
    C_coll = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    ps_coll = cdf('norm',C_coll,data.result.coll.mean,data.result.coll.sd);
    plot(C_coll,ps_coll,'-','LineWidth',2,'Color',[17/255 105/255 40/255])
    sdyad = max(diff(ps_coll)./diff(C_coll));
    clear bhat;
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot Collective A1 in blue
    plotSym = '+';
    y = data.result.collA1.fs';
    bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    data.result.collA1.mean = -bhat(1)/bhat(2);
    data.result.collA1.sd   = 1/bhat(2);
    plot(conSteps, y, plotSym,'Color',[30/255 60/255 190/255]);%blue
    hold on;
    C_collA1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    ps_collA1 = cdf('norm',C_collA1,data.result.collA1.mean,data.result.collA1.sd);
    plot(C_collA1,ps_collA1,'Color',[30/255 60/255 190/255],'LineWidth',2, 'LineStyle', '--')
    sdyadA1 = max(diff(ps_collA1)./diff(C_collA1));
    clear bhat;
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot Collective A2 in yellow
    plotSym = '+';
    y = data.result.collA2.fs'; % 8 values (per contrast): P(2nd interval)
    bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
    data.result.collA2.mean = -bhat(1)/bhat(2); %bias
    data.result.collA2.sd   = 1/bhat(2); %variance
    plot(conSteps, y, plotSym,'Color',[240/255 200/255 40/255]);%yellow
    hold on;
    C_collA2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    % ps = psychometric curve: x-axis steps, bias, variance
    ps_collA2 = cdf('norm',C_collA2,data.result.collA2.mean,data.result.collA2.sd);
    plot(C_collA2,ps_collA2,'Color',[240/255 200/255 40/255],'LineWidth',2, 'LineStyle', '--')
    sdyadA2 = max(diff(ps_collA2)./diff(C_collA2)); % compute slope / rate of change
    clear bhat;
    hold on;


    %%%%%Collective benefit
    smax  = max(slope_a1,slope_a2);
    smin  = min(slope_a1,slope_a2);
    coll_ben = sdyad/smax;
    
    collA1_ben = sdyadA1/slope_a1;
    collA2_ben = sdyadA2/slope_a2;
    coll_ben_rounded = round(coll_ben,2);
    disp(['Collective benefit ' num2str(p) ': ' num2str(coll_ben)]);

    collA1_ben_rounded = round(collA1_ben,2);
    collA2_ben_rounded = round(collA2_ben,2);
    disp(['A1 individual coll benefit ' num2str(p) ': ' num2str(collA1_ben_rounded)])
    disp(['A2 individual coll benefit ' num2str(p) ': ' num2str(collA2_ben_rounded)])

    text(-0.15,0.8,['coll. benefit = ' num2str(coll_ben_rounded)]);
    text(-0.15,0.7,['collA1 benefit = ' num2str(collA1_ben_rounded)]);
    text(-0.15,0.6,['collA2 benefit = ' num2str(collA2_ben_rounded)]);
    hold off;

    ratio = smin/smax;

end