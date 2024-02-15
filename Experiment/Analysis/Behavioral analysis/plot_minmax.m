% PAIR PLOTS WITH COLOR ADJUSTED TO MIN/MAX AGENT
% Typical psychometric curves with x=contrast difference and y=P(2nd interval)
% We plot 4 fitted curves, one plot for each pair.
% 1. collective decisions taken by B agent (continuous line)
% 2. collective decisions taken by Y agent (continuous line)
% 3. first individual decisions taken by B agent (dashed line)
% 4. first individual decisions taken by Y agent (dashed line)
% -> compare ONLY IND. DEC1 against COLLECTIVE - both taken by same agent
% -> the individual benefit is the ratio between agentColl/agentIndDec1

% COLOR-CODING
% light blue = less sensitive agent (min) - markers are circles
% dark red = more sensitive agent (max)   - markers are squares
% in-plot-text: 1st row is max agent, 2nd row is min agent

plt_mima=figure('Name',['mima_S' ptc{p}]); set(plt_mima, 'WindowStyle', 'Docked');

% adjust the color order because, by default (due to how y is structured),
% B is always plotted before Y. so the color order needs to be consistent.
if agent_max == 1 % B is more sensitive agent
    col_mima = [color_max; color_min]; % max(red),mix(blue)
    mrk_mima = {'s' 'o' 's' 'o'};      % max, min, max, min
elseif agent_max == 2 % Y is more sensitive agent
    col_mima = [color_min; color_max]; % min(blue),max(red)
    mrk_mima = {'o' 's' 'o' 's'};      % min, max, min, max
end

for plt = 4:width(y) % only plot BColl, YColl, B1dec, Y1dec (per pair)

    % compute parameters for fit
    bhat   = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit');
    d_mean = -bhat(1)/bhat(2);
    d_sd   = 1/bhat(2);

    % plot the markers for y(:,4:7)
    if plt>3 && plt<=5 % collective markers: big empty (white)
        plot(conSteps, y(:,plt), mrk_mima{:,plt-3},'MarkerSize',12,'LineWidth',2.5,...
            'Color',col_mima(plt-3,:),'MarkerFaceColor',mrkColor(plt-3,:));
        hold on;
    elseif plt>5 && plt<=7 % individual markers: small filled (blue/red)
        plot(conSteps, y(:,plt), mrk_mima{:,plt-3},'MarkerSize',6,'LineWidth',2.5,...
            'Color',col_mima(plt-5,:),'MarkerFaceColor',col_mima(plt-5,:));
        hold on;
    end
    C  = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
    ps = cdf('norm',C,d_mean,d_sd);
    % plot the fitted curves
    if plt>3 && plt<=5 % collective: continuous lines
        plot(C,ps,'-','LineWidth',3,'Color',col_mima(plt-3,:));
    elseif plt>5 && plt<=7 % individual: dashed lines
        plot(C,ps,'--','LineWidth',3,'Color',col_mima(plt-5,:));
    end
    clear bhat d_mean d_sd C ps
    hold on;
end

ylim([0 1]);  ax = gca; ax.FontSize = 16; 
xlabel("Contrast difference",'FontSize',20);
ylabel("Proportion 2nd interval",'FontSize',20);
title(['Ind. benefit - ','S' ptc{p}],'FontSize',22);

if agent_max == 1 % if B is max agent
    text(-0.18,0.95,['ind. benefit B (max) = ' num2str(coll_ben_max,'%.2f')],...
        'FontSize',18, 'Color', col_mima(1,:));
    text(-0.18,0.9, ['ind. benefit Y (min) = ' num2str(coll_ben_min,'%.2f')],...
        'FontSize',18, 'Color', col_mima(2,:));
elseif agent_max == 2 % if Y is max agent
    text(-0.18,0.95, ['ind. benefit Y (max) = ' num2str(coll_ben_max,'%.2f')],...
        'FontSize',18, 'Color', col_mima(2,:));
    text(-0.18,0.9,['ind. benefit B (min) = ' num2str(coll_ben_min,'%.2f')],...
        'FontSize',18, 'Color', col_mima(1,:));
end



% Save psychometric curve figure
if save_plot
    set(gcf,'PaperUnits','centimeters','PaperPosition', [0 0 x_width y_width]);
    saveas(gcf,[path_to_save,'S',ptc{p},'_PsyC',lab,block_lab,ben_lab,'_mima'],'png');
end
hold off;