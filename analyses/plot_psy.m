function slope_pair=plot_psy(conSteps,y,plotSym,color,default,full)
if full
    %collect the slopes: [blue, yellow, coll, coll blue, colle yellow]
    slope_pair = zeros(1,width(y));
    for plt=1:width(y)
        bhat = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit');
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);
        plot(conSteps, y(:,plt), plotSym{:,plt},'Color',color(plt,:));
        hold on;
        C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
        ps = cdf('norm',C,d_mean,d_sd);
        plot(C,ps,'-','LineWidth',2,'Color',color(plt,:));
        slope_pair(:,plt) = max(diff(ps)./diff(C));
        clear bhat d_mean d_sd C ps
        hold on;
    end
else
    cnt = 1;
    for i=1:default.step:default.w_lgt
        % Create indeces for the windows
        w(cnt,:) = i:i+default.w_lgt-1;
        selwn = y(w(cnt,:)',:);

        bhat = glmfit(selwn(:,2),[selwn(:,1) ones(size(selwn(:,1)))],'binomial','link','probit');
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);
        %         plot(selw(:,2), selw(:,1), plotSym{3},'Color',color(:,3));
        %         hold on;
        C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
        ps = cdf('norm',C,d_mean,d_sd);
        %         plot(C,ps,'-','LineWidth',2,'Color',color(:,3));
        slope_pair(:,cnt) = max(diff(ps)./diff(C));
        clear bhat d_mean d_sd C ps
        cnt = cnt + 1;
    end
end
clear bhat d_mean d_sd C ps
end