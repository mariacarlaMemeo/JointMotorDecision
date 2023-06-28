function slope_pair=plot_psy(conSteps,y,plotSym,color,default,full,coll_calc)
if full
    %collect the slopes: [blue, yellow, coll, coll blue, coll yellow,blue indiv. 1st dec, yellow indiv. 1st dec]
    slope_pair = zeros(1,width(y));
    for plt=1:width(y)
        bhat = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit');
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);
        % plot the markers
        if plt<=3 % if also indiv. coll. benefit should be plotted: plt<=5
            plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',1.5,'Color',color(plt,:));
            hold on;
        end
        C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
        ps = cdf('norm',C,d_mean,d_sd);
        % plot the lines
        if plt<=3
            plot(C,ps,'-','LineWidth',1.5,'Color',color(plt,:));
%         elseif plt>3 && plt<=5
%             plot(C,ps,'--','LineWidth',2,'Color',color(plt,:));
        end
        slope_pair(:,plt) = eval([coll_calc '(diff(ps)./diff(C))']);%%EDIT mean instead of max
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
        slope_pair(:,cnt) = eval([coll_calc '(diff(ps)./diff(C))']); %%EDIT mean instead of max
        clear bhat d_mean d_sd C ps
        cnt = cnt + 1;
    end
end
clear bhat d_mean d_sd C ps
end