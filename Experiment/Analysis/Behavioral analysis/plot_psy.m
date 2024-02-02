function slope_pair=plot_psy(conSteps,y,plotSym,color,default,full,coll_calc,bType,mrkColor,ave)

if full % all trials (not windows)
    
    % slopes: [B, Y, coll, collB, collY, B1dec, Y1dec]
    slope_pair = zeros(1,width(y));
    
    for plt = 1:width(y)
        
        bhat = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit');
        % XXX modify this to get values on goodness of fit
        % [bhat, dev, stats] = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit')
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);
        
        % plot either B,Y,Coll (ave=0, per pair) or min,max,Coll (ave=1, averages)
        if bType == 2 && (ave == 0 || ave == 1)
            % plot the markers
            if plt<=3 
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,'Color',color(plt,:));
                hold on;
            end
            C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the lines
            if plt<=3
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:));
            end
        
        elseif bType == 1 && ave == 0 % plot BColl, YColl, B1dec, Y1dec (per pair)
            % plot the markers
            if plt>3 && plt<=5 %coll.: colors: blue, yellow; markers: empty
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,'Color',color(plt,:),'MarkerFaceColor',mrkColor(plt-3,:));
                hold on;
            elseif plt>5 && plt<=7 %ind.: colors: blue, yellow; markers: filled
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',2.5,'Color',color(plt-2,:),'MarkerFaceColor',mrkColor(plt-3,:));
                hold on;
            end
            C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the lines
            if plt>3 && plt<=5 %coll.: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:));
            elseif plt>5 && plt<=7 %ind.: dashed lines
                plot(C,ps,'--','LineWidth',3,'Color',color(plt-2,:));
            end
        
        elseif bType == 1 && ave == 1 % plot minColl, maxColl, min 1dec, max 1dec (averages)
            % plot the markers
            if plt>=1 && plt<=2
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,'Color',color(plt,:));
                hold on;
            elseif plt>2 && plt<=4
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',2.5,'Color',color(plt,:),'MarkerFaceColor',color(plt,:));
                hold on;
            end
            C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the lines
            if plt>=1 && plt<=2 %coll.: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:)); %coll.
            elseif plt>2 && plt<=4 %ind.: dashed lines
                plot(C,ps,'--','LineWidth',3,'Color',color(plt,:)); %ind.
            end
        
        end
        
        
        slope_pair(:,plt) = eval([coll_calc '(diff(ps)./diff(C))']);
        clear bhat d_mean d_sd C ps
        hold on;
    end

else % this is for the windows
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
        slope_pair(:,cnt) = eval([coll_calc '(diff(ps)./diff(C))']);
        clear bhat d_mean d_sd C ps
        cnt = cnt + 1;
    end
end
clear bhat d_mean d_sd C ps
end