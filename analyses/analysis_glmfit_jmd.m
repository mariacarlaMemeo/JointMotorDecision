% JMD - Analysis of perceptual sensitivity for oddball detection task
close all;
clear;

% Prepare variables
ptc       = [100,101,103];
slope     = zeros(length(ptc),5);
coll_ben  = zeros(length(ptc),3);%3=collective benefit; 1=coll A1(blue); 2=coll A2(yellow)
% Calculate collective benefit with 'max' or 'mean' function
fcalc     = input('Choose the function to calculate collective benefit:\n 1 = max\n 2 = mean\n');
if fcalc==1
    coll_calc = 'max';
elseif fcalc==2
    coll_calc = 'mean';
end

% Subselect target number for highest contrast (0.25, if you subtract the baseline the value in C2_C1_v var should be abs(0.15)), from 40(maximum) to 20
sub_con     = input('Choose to subselect highest contrast:\n 1 = yes\n 2 = no\n');
if sub_con==1
    subcon_calc = 1;
elseif sub_con==2
    subcon_calc = 0;
end

% Windowing (length: default.w_lgt)
default.step      = 4;
default.w_lgt     = 80;
default.w         = zeros(default.w_lgt/default.step,default.w_lgt);
default.slope_wnd = [];
default.slope_wcoll = [];

for p=ptc
    % Index of the participant
    pr = find(p==ptc);

    % Load each participant's data
    %     path_to_edit = ['Y:\Datasets\JointMotorDecision\Static\Raw\P',num2str(p),'\task\'];
    %     each = dir([path_to_edit,'*.mat']);
    path_to_edit = ['C:\Users\Laura\Sync\00_Research\UKE\JointMotorDecisions\04_Analysis\pilotData\',num2str(p),'\'];
    each = dir([path_to_edit,'*.mat']);
    load([path_to_edit,each.name])
    disp(['Loading ',each.name]);

    % Subselect or not
    if subcon_calc
        subcon_ind = find(data.output(:,4)==0.15);
        data.output(subcon_ind(21:end),:) = [];
    end

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

    cb=figure('Name',['CB_P' num2str(ptc(pr)) '_wnd']);set(cb, 'WindowStyle', 'Docked');
    % slope: [a1(blue), a2(yellow), sdyady(coll), sdyadA1(coll blue), sdyadA2(colle yellow)]
    % Each row is a pair
    full=1;
    slope(pr,:) = plot_psy(conSteps,y,plotSym,color,default,full,coll_calc);

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
    if not(subcon_calc)
        ws=figure('Name',['P' num2str(ptc(pr)) '_wnd']);set(ws, 'WindowStyle', 'Docked');

        % Each row is a pair - here the y is different!!!

        full=0;
        coll_prtc = [coll_fs_v C2_C1_v];
        slope_wcoll(pr,:) = plot_psy(conSteps,coll_prtc,plotSym,color,default,full,coll_calc);
        slope_wcoll(pr,:) = slope_wcoll(pr,:)/smax;

        plot(slope_wcoll(pr,:),['-' plotSym{3}],'Color',color(3,:)); title(['Coll benefit - ','P' num2str(ptc(pr)) ' wnd'])
    end
end

% Average across pairs
if not(subcon_calc)
    h4=figure();set(h4, 'WindowStyle', 'Docked');
    errorbar(1:default.w_lgt/default.step,mean(slope_wcoll),-std(slope_wcoll)/sqrt(length((slope_wcoll))),+std(slope_wcoll)/sqrt(length((slope_wcoll))),'Color', color(3,:),'LineWidth',1);hold on;
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:)); hold off
    axis([0 (default.w_lgt/default.step)+1 0.6 1.3]);title('Average values across pairs - coll. benefit');

    %
    h5=figure();set(h5, 'WindowStyle', 'Docked');
    colororder(color(end-2:end,:));
    plot(slope_wcoll',['-' plotSym{3}]); hold on;
    line((1:default.w_lgt/default.step),ones(1,default.w_lgt/default.step),'LineStyle','--','Color', color(6,:),'LineWidth',1); hold off
    axis([0 (default.w_lgt/default.step)+1 0.6 1.3]);legend({'P100','P101','P103','1'},'location','best');
    title('Coll. benefit - each pair');
end


