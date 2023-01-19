% analysis of perceptual sensitivity for oddball detection task
close all;
% load('C:\Users\Laura\Sync\00_Research\2022_UKE\Confidence from motion\04_Analysis\pilotData\gID103_run1_jomode.mat');
load('Y:\Datasets\JointMotorDecision\Static\Raw\P100\task\gID100_run1_jomode.mat');

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
figure(1);
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
% plot P(Report 2nd)
a1_fs_v     = data.output(:,8)-1;
a2_fs_v     = data.output(:,14)-1;
coll_fs_v   = data.output(:,20)-1;

for cIndex = 1 : size(conSteps,1)
    c                           = conSteps(cIndex);
    data.result.a1.fs(cIndex)   = mean(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
    data.result.a2.fs(cIndex)   = mean(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
    data.result.coll.fs(cIndex)  = mean(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v))); 
    
    data.result.a1.fsN(cIndex)  = length(a1_fs_v(C2_C1_v==c & ~isnan(a1_fs_v)));
    data.result.a2.fsN(cIndex)  = length(a2_fs_v(C2_C1_v==c & ~isnan(a2_fs_v)));
    data.result.coll.fsN(cIndex) = length(coll_fs_v(C2_C1_v==c & ~isnan(coll_fs_v)));     
end

figure(1);
subplot(1,2,2);
plot(conSteps,data.result.a1.fs,'bs-');
hold on
plot(conSteps,data.result.a2.fs,'yo-');
plot(conSteps,data.result.coll.fs,'gv-','LineWidth',1);
xlabel('C2 - C1');
ylabel('P(Report 2nd)');
%-------------------------------------------------------------------------%
% data analysis
figure(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot A1 in blue
plotSym = 's';
y = data.result.a1.fs';
bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
data.result.a1.mean = -bhat(1)/bhat(2);
data.result.a1.sd   = 1/bhat(2);
plot(conSteps, y,['b' plotSym],'LineWidth',2);
hold on
C_a1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_a1 = cdf('norm',C_a1,data.result.a1.mean,data.result.a1.sd);
plot(C_a1,ps_a1,'b-','LineWidth',3)
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
plot(conSteps, y,['y' plotSym],'LineWidth',2);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_a2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_a2 = cdf('norm',C_a2,data.result.a2.mean,data.result.a2.sd);
plot(C_a2,ps_a2,'y-','LineWidth',3)
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
plot(conSteps, y,['g' plotSym],'LineWidth',2);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_coll = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_coll = cdf('norm',C_coll,data.result.coll.mean,data.result.coll.sd);
plot(C_coll,ps_coll,'g-','LineWidth',3)
sdyad = max(diff(ps_coll)./diff(C_coll));
clear bhat;
hold on;




%%%%%Collective benefit
smax  = max(slope_a1,slope_a2);
smin  = min(slope_a1,slope_a2);
coll_ben = sdyad/smax;
coll_ben_rounded = round(coll_ben,2);
text(-0.15,0.6,['coll. benefit = ' num2str(coll_ben_rounded)]);
hold off;

ratio = smin/smax;


%-------------------------------------------------------------------------%
% data analysis - split collective in 2 agents
h3=figure(3);set(h3, 'WindowStyle', 'Docked');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot A1 in blue
plotSym = 's';
y = data.result.a1.fs';
bhat = glmfit(conSteps,[y ones(size(y))],'binomial','link','probit');
data.result.a1.mean = -bhat(1)/bhat(2);
data.result.a1.sd   = 1/bhat(2);
plot(conSteps, y,['b' plotSym],'LineWidth',2);
hold on
C_a1 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_a1 = cdf('norm',C_a1,data.result.a1.mean,data.result.a1.sd);
plot(C_a1,ps_a1,'b-','LineWidth',3)
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
plot(conSteps, y,['y' plotSym],'LineWidth',2);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_a2 = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_a2 = cdf('norm',C_a2,data.result.a2.mean,data.result.a2.sd);
plot(C_a2,ps_a2,'y-','LineWidth',3)
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
plot(conSteps, y,['g' plotSym],'LineWidth',2);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_coll = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
ps_coll = cdf('norm',C_coll,data.result.coll.mean,data.result.coll.sd);
plot(C_coll,ps_coll,'g-','LineWidth',3)
sdyad = max(diff(ps_coll)./diff(C_coll));
clear bhat;
hold on;




%%%%%Collective benefit
smax  = max(slope_a1,slope_a2);
smin  = min(slope_a1,slope_a2);
coll_ben = sdyad/smax;
coll_ben_rounded = round(coll_ben,2);
text(-0.15,0.6,['coll. benefit = ' num2str(coll_ben_rounded)]);
hold off;

ratio = smin/smax;