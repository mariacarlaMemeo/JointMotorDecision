% Plot the average trajectory per participant, for low/high confidence.
% variables: velocity, acceleration, z-coordinate
% Create one plot with 6 panels, for each variable-confidence combination
% -> this script can be run from within (or after) plot_offline

%% Preparatory steps

% participant list
sub_list = {'108B' '108Y' '111B' '111Y' '112B' '112Y' '113B' '113Y' ...
            '114B' '114Y' '115B' '115Y' '116B' '116Y' '117B' '117Y' ...
            '118B' '118Y' '120B' '120Y' '121B' '121Y' '122B' '122Y' ...
            '123B' '123Y' '124B' '124Y'};
% y-axis scale (might be needed for X-coordinate plots)
ydata = 1:100;
% mean values for each participant, for Hi/Lo confidence
% -> assign new names for convenience
Hi_means_V = meanHall_V.index;
Lo_means_V = meanLall_V.index;
Hi_means_A = meanHall_A.index;
Lo_means_A = meanLall_A.index;
Hi_means_Z = meanHall_Z.index;
Lo_means_Z = meanLall_Z.index;
Hi_means_X = meanHall_X.index;
Lo_means_X = meanLall_X.index; 
% store all variables in a cell array
var2plot       = [{Hi_means_V}; {Lo_means_V}; {Hi_means_A}; {Lo_means_A}; ...
                  {Hi_means_Z}; {Lo_means_Z}];
% corresponding variable names
var2plot_names = ["Velocity (mm/s)", "Acceleration (mm/s^2)", "Height (mm)"];
% create 28 plot colors (1 per participant)
colors = jet(28); %parula(28);

%% Create multipanel plot
means_fig = tiledlayout(3,2); % set tiled layout
var_count = 1; % variable counter

for var_num = 1:length(var2plot)/2 % loop through all variables

    for HiLo = 1:2 % for each variable: first high, then low confidence
        
        nexttile; % one tile per confidence level
        hold on
        for agent = 1:n_pr*2 % loop through all participants
            if HiLo == 1 % high conf
                plot(var2plot{var_count*2-1}(:,agent),'-','LineWidth',wd,'Color', colors(agent,:)); %hConf_col
                hold on;
            else % low conf
                plot(var2plot{var_count*2}(:,agent),'--','LineWidth',wd,'Color', colors(agent,:)); %hConf_col
                hold on;
            end
        end
        ylim([min(var2plot{var_count*2-1}, [], 'all'), max(var2plot{var_count*2-1}, [], 'all')]);
        if HiLo == 1
            title("high confidence");
        else
            title("low confidence");
        end
        ylabel(var2plot_names{var_count}); xlabel('% of movement duration');
        hold off;
        
    end % end of hi/low confidence loop

    var_count = var_count+1;

end % end of variable loop

% title and legend for the entire figure
title(means_fig,'Participant averages: high vs. low confidence', 'FontSize', 18, 'FontWeight', 'bold');
leg = legend(sub_list,'Orientation', 'Horizontal','NumColumns',14);
leg.Layout.Tile = 'south';
set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 35 40]);
saveas(gcf,'C:\Users\Laura\Desktop\jmd_modeling_inProgress\means_kin_HiLo.png');


% % plot x-coordinate means - NEEDS TO SPLIT INTO LEFT-RIGHT TARGET FIRST
% % (before averaging)
% means_xcoord = tiledlayout(2,1);
% for HiLo = 1:2
%     nexttile;
%     hold on
%     for agent = 1:n_pr*2
%         if HiLo == 1 % high conf
%             plot(Hi_means_X(:,agent),ydata,'-','LineWidth',wd,'Color', colors(agent,:));
%             hold on;
%         else % low conf
%             plot(Lo_means_X(:,agent),ydata,'--','LineWidth',wd,'Color', colors(agent,:));
%             hold on;
%         end
%     end
%     %ylim([min(var2plot{var_count*2-1}, [], 'all'), max(var2plot{var_count*2-1}, [], 'all')]);
%     if HiLo == 1
%         title("high confidence");
%     else
%         title("low confidence");
%     end
%     %ylabel(var2plot_names{var_count}); xlabel('% of movement duration');
%     hold off;
% end