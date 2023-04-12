% analysis of perceptual sensitivity for oddball detection task
close all;
clear;
% load('C:\Users\Laura\Sync\00_Research\2022_UKE\Confidence from motion\04_Analysis\pilotData\gID103_run1_jomode.mat');
% load('Y:\Datasets\JointMotorDecision\Static\Raw\P100\task\gID100_run1_jomode.mat');

%Prepare variables
ptc       = [100,101,103];
slope     = zeros(length(ptc),5); 
coll_ben  = zeros(length(ptc),3);%3=collective benefit; 1=coll A1(blue); 2=coll A2(yellow)
%windowing
default.step      = 4;
default.w_lgt     = 80;
default.w         = zeros(default.w_lgt/default.step,default.w_lgt);
default.slope_wnd = [];
default.slope_wcoll = [];

for p=ptc
    % Index of the participant
    pr = find(p==ptc);
    
    % Load each participant's data
    path_to_edit = ['Y:\Datasets\JointMotorDecision\Static\Raw\P',num2str(p),'\task\'];
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


    for cI = 1 : size(absConSteps,1)
        c                           = absConSteps(cI);
        data.result.a1.acc(cI)  = mean(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.acc(cI)  = mean(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.acc(cI)= mean(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.acc(cI)= mean(coll_acc_vA1(abs(C2_C1_v(agentExecColl_clmn==1))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.acc(cI)= mean(coll_acc_vA2(abs(C2_C1_v(agentExecColl_clmn==2))==c & ~isnan(coll_acc_vA2)));

        data.result.a1.N(cI)    = length(a1_acc_v(abs(C2_C1_v)==c & ~isnan(a1_acc_v)));
        data.result.a2.N(cI)    = length(a2_acc_v(abs(C2_C1_v)==c & ~isnan(a2_acc_v)));
        data.result.coll.N(cI)  = length(coll_acc_v(abs(C2_C1_v)==c & ~isnan(coll_acc_v)));

        data.result.collA1.N(cI)  = length(coll_acc_vA1(abs(C2_C1_v(agentExecColl_clmn==1))==c & ~isnan(coll_acc_vA1)));
        data.result.collA2.N(cI)  = length(coll_acc_vA2(abs(C2_C1_v(agentExecColl_clmn==2))==c & ~isnan(coll_acc_vA2)));
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
    xlabel('LOG |C2 - C1|');
    xlim([min(absConSteps)*.8 max(absConSteps)*1.2]);
    ylabel('Accuracy');

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

    for cI = 1 : size(conSteps,1)
        c                           = conSteps(cI);
        data.result.a1.fs(cI)   = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fs(cI)   = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fs(cI)  = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));

        data.result.collA1.fs(cI)= mean(coll_fs_vA1(C2_C1_v(agentExecColl_clmn==1)==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.fs(cI)= mean(coll_fs_vA2(C2_C1_v(agentExecColl_clmn==2)==c & ~isnan(coll_fs_vA2)));

        data.result.a1.fsN(cI)  = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
        data.result.a2.fsN(cI)  = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
        data.result.coll.fsN(cI) = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));

        data.result.collA1.N(cI)  = length(coll_fs_vA1(C2_C1_v(agentExecColl_clmn==1)==c & ~isnan(coll_fs_vA1)));
        data.result.collA2.N(cI)  = length(coll_fs_vA2(C2_C1_v(agentExecColl_clmn==2)==c & ~isnan(coll_fs_vA2)));
    end

    % Add the non logaritmic plot
    subplot(1,2,2);
    plot(conSteps,data.result.a1.fs,'bs-');
    hold on
    plot(conSteps,data.result.a2.fs,'yo-');
    plot(conSteps,data.result.coll.fs,'gv-','LineWidth',1);
    xlabel('C2 - C1');
    ylabel('P(Report 2nd)');

    %-------------------------------------------------------------------------%
    % Condense in a function the psychometric plots:
    % psychometric curves to see collective benefit (per agent)
    % 5 output values: [blue agent(here a1), yellow agent(here a2),
    % collective global, collective only blue, collective only yellow]
    y       = [data.result.a1.fs' data.result.a2.fs' data.result.coll.fs'...
                data.result.collA1.fs' data.result.collA2.fs'];
    plotSym = {'s' 'o' '*' '+' '+'};
    color   = [[30 60 190]; [240 200 40]; [17 105 40];...
                [30 60 190]; [240 200 40]; [51 51 51];...
                [80 200 120]; [0 165 114]; [1 121 111]]./255;%blue, yellow, dark green, blue, yellow,gray, emerald green, persian green, pine green
    
    h3=figure(3);set(h3, 'WindowStyle', 'Docked');
    % slope: [a1(blue), a2(yellow), sdyady(coll), sdyadA1(coll blue), sdyadA2(colle yellow)]
    % Each row is a pair
    full=1;
    slope(pr,:) = plot_psy(conSteps,y,plotSym,color,default,full);

    %%%%%Collective benefit
    smax  = max(slope(pr,1:2));
    smin  = min(slope(pr,1:2));
    coll_ben(pr,3) = round(slope(pr,3)/smax,2);

    coll_ben(pr,1) = round(slope(pr,4)/slope(pr,1),2);%sdyadA1/slope_a1;
    coll_ben(pr,2) = round(slope(pr,5)/slope(pr,2),2);%sdyadA2/slope_a2;
    disp(['Collective benefit ' num2str(p) ': ' num2str(coll_ben(pr,3))]);

    disp(['A1 individual coll benefit ' num2str(p) ': ' num2str(coll_ben(pr,1))])
    disp(['A2 individual coll benefit ' num2str(p) ': ' num2str(coll_ben(pr,2))])

    text(-0.15,0.8,['coll. benefit = ' num2str(coll_ben(pr,3))]);
    text(-0.15,0.7,['collA1 benefit = ' num2str(coll_ben(pr,1))]);
    text(-0.15,0.6,['collA2 benefit = ' num2str(coll_ben(pr,2))]);
    hold off;

    ratio = smin/smax;

    % Calculate collective benefit in windows of 80 elements each 4 trials
    % use the same smax found before. 
    % collective decision and relative signed contrast
    ws=figure('Name',['P' num2str(ptc(pr)) '_wnd']);set(ws, 'WindowStyle', 'Docked');

    % Each row is a pair - here the y is different!!!
    full=0;
    coll_prtc = [coll_fs_v C2_C1_v];
    slope_wcoll(pr,:) = plot_psy(conSteps,coll_prtc,plotSym,color,default,full);
    slope_wcoll(pr,:) = slope_wcoll(pr,:)/smax;
    
    plot(slope_wcoll(pr,:),['-' plotSym{3}],'Color',color(3,:)); title(['Coll benefit - ','P' num2str(ptc(pr)) ' wnd'])
end

% Average across pairs
h4=figure();set(h4, 'WindowStyle', 'Docked');
errorbar(1:default.w_lgt/default.step,mean(slope_wcoll),-std(slope_wcoll)/sqrt(length((slope_wcoll))),+std(slope_wcoll)/sqrt(length((slope_wcoll))),'Color', color(3,:),'LineWidth',1);hold on;
line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
axis([0 (default.w_lgt/default.step)+1 0.6 1.3]);title('Average values across pairs - coll. benefit');

% coll ben for each pair
h5=figure();set(h5, 'WindowStyle', 'Docked');
colororder(color(end-2:end,:));
plot(slope_wcoll',['-' plotSym{3}],'LineWidth',1); 
line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
axis([0 (default.w_lgt/default.step)+1 0.6 1.3]);legend({'P100','P101','P103','1'},'Location','best'); hold on;
title('Coll. benefit - each pair');



%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % plot A1 in blue
%     plotSym = 's';
%     y = data.result.a1.fs';
%     bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
%     data.result.a1.mean = -bhat(1)/bhat(2);
%     data.result.a1.sd   = 1/bhat(2);
%     plot(conSteps, y, plotSym,'Color',[30/255 60/255 190/255]);%blue
%     hold on;
%     C_a1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
%     ps_a1 = cdf('norm',C_a1,data.result.a1.mean,data.result.a1.sd);
%     plot(C_a1,ps_a1,'-','LineWidth',2,'Color',[30/255 60/255 190/255]);
%     slope_a1 = max(diff(ps_a1)./diff(C_a1));
%     clear bhat;
%     hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % plot A2 in yellow
%     plotSym = 'o';
%     y = data.result.a2.fs';
%     bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
%     data.result.a2.mean = -bhat(1)/bhat(2);
%     data.result.a2.sd   = 1/bhat(2);
%     plot(conSteps, y, plotSym,'Color',[240/255 200/255 40/255]);%yellow
%     hold on;
%     C_a2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
%     ps_a2 = cdf('norm',C_a2,data.result.a2.mean,data.result.a2.sd);
%     plot(C_a2,ps_a2,'-','LineWidth',2,'Color',[240/255 200/255 40/255])
%     slope_a2 = max(diff(ps_a2)./diff(C_a2));
%     clear bhat;
%     hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % plot Collective in green
%     plotSym = '*';
%     y = data.result.coll.fs';
%     bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
%     data.result.coll.mean = -bhat(1)/bhat(2);
%     data.result.coll.sd   = 1/bhat(2);
%     plot(conSteps, y, plotSym,'Color',[17/255 105/255 40/255]);%green
%     hold on;
%     C_coll = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
%     ps_coll = cdf('norm',C_coll,data.result.coll.mean,data.result.coll.sd);
%     plot(C_coll,ps_coll,'-','LineWidth',2,'Color',[17/255 105/255 40/255])
%     sdyad = max(diff(ps_coll)./diff(C_coll));
%     clear bhat;
%     hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % plot Collective A1 in blue
%     plotSym = '+';
%     y = data.result.collA1.fs';
%     bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
%     data.result.collA1.mean = -bhat(1)/bhat(2);
%     data.result.collA1.sd   = 1/bhat(2);
%     plot(conSteps, y, plotSym,'Color',[30/255 60/255 190/255]);%blue
%     hold on;
%     C_collA1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
%     ps_collA1 = cdf('norm',C_collA1,data.result.collA1.mean,data.result.collA1.sd);
%     plot(C_collA1,ps_collA1,'Color',[30/255 60/255 190/255],'LineWidth',2, 'LineStyle', '--')
%     sdyadA1 = max(diff(ps_collA1)./diff(C_collA1));
%     clear bhat;
%     hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % plot Collective A2 in yellow
%     plotSym = '+';
%     y = data.result.collA2.fs'; % 8 values (per contrast): P(2nd interval)
%     bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
%     data.result.collA2.mean = -bhat(1)/bhat(2); %bias
%     data.result.collA2.sd   = 1/bhat(2); %variance
%     plot(conSteps, y, plotSym,'Color',[240/255 200/255 40/255]);%yellow
%     hold on;
%     C_collA2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
%     % ps = psychometric curve: x-axis steps, bias, variance
%     ps_collA2 = cdf('norm',C_collA2,data.result.collA2.mean,data.result.collA2.sd);
%     plot(C_collA2,ps_collA2,'Color',[240/255 200/255 40/255],'LineWidth',2, 'LineStyle', '--')
%     sdyadA2 = max(diff(ps_collA2)./diff(C_collA2)); % compute slope / rate of change
%     clear bhat;
%     hold on;


   