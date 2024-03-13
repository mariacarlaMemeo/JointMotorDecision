function slope_pair = plot_psy(conSteps,y,plotSym,color,default,full,...
                               coll_calc,bType,mrkColor,ave)

% Variables passed to function:
% conSteps:  -0.15 -0.07 -0.035 -0.015 0.015 0.035 0.07 0.15
% y[rows]:   8 contrast levels (conSteps)
% y[cols]:   averaged values per contrast level
%            -> y     = B,Y,Coll,BColl,YColl,Bdec1,Ydec1
%            -> y_ave = [min, max, Collective] (bType=2) or 
%                       [minColl, maxColl, minInd_dec1, maxInd_dec1] (bType=1)
% plotSym:   marker symbols; color: colors; NOTE: symbols and color differ
%            depending on whether individual or averaged data is shown
% mrkColor:  marker colors
% default:   structure that contains default values for window analysis
% full:      analyze all trials (1) or split into windows (0)
% coll_calc: compute maximum (1) or mean (2) slope of the curve (we use MAX)
% bType:     compute collective benefit (2) or individual benefits (1)
% ave:       aveFlag: pair data or averaged data?

% Note: can we evaluate goodness of fit for glmfit (with [bhat, dev, stats])!?

if full % all trials (not windows)

    % variable to save slopes for current pair for B, Y, coll, collB, collY, B1dec, Y1dec
    % -> this is the output of the function!
    slope_pair = zeros(1,width(y));

    for plt = 1:width(y) % fit slope for each column of y
        
        % compute parameters for fit
        bhat   = glmfit(conSteps,[y(:,plt) ones(size(y(:,plt)))],'binomial','link','probit');
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);

        % bType==2: plot Blue, Yellow, Collective (original Bahrami plots)
        % -> same structure for individual and collective data
        if bType == 2 && (ave == 0 || ave == 1)
            % plot the markers for y(:,1:3)
            if plt<=3 
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',10,'LineWidth',2.5,...
                    'Color',color(plt,:),'MarkerFaceColor',color(plt,:));
                hold on;
            end
            C  = 1.3 .* (min(conSteps) : 0.001 : max(conSteps)); % align conSteps
            ps = cdf('norm',C,d_mean,d_sd); % cumulative distribution function
            % plot the fitted curves
            if plt>=1 && plt<=2 % individual: dashed lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:)); %ind.
            elseif plt>2 && plt<=3 % collective: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:)); %coll.
            end
%             if plt<=3
%                 plot(C,ps,'-','LineWidth',3,'Color',color(plt,:));
%             end

        % bType==1, pair data: plot BColl, YColl, B1dec, Y1dec (per pair)
        elseif bType == 1 && ave == 0
            % plot the markers for y(:,4:7)
            if plt>3 && plt<=5 % collective markers: big empty (white)
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,...
                    'Color',color(plt-3,:),'MarkerFaceColor',mrkColor(plt-3,:));
                hold on;
            elseif plt>5 && plt<=7 % individual markers: small filled (blue/yellow)
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',2.5,...
                    'Color',color(plt-5,:),'MarkerFaceColor',mrkColor(plt-3,:));
                hold on;
            end
            C  = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the fitted curves
            if plt>3 && plt<=5 % collective: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt-3,:));
            elseif plt>5 && plt<=7 % individual: dashed lines
                plot(C,ps,'--','LineWidth',3,'Color',color(plt-5,:));
            end
        
        % bType==1, averaged data: plot minColl, maxColl, minInd_dec1, maxInd_dec1
        elseif bType == 1 && ave == 1
            % plot the markers for y(:,1:4)
            if plt>=1 && plt<=2 % collective markers: big empty (white)
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,...
                    'Color',color(plt,:));
                hold on;
            elseif plt>2 && plt<=4 % individual markers: small filled (blue/red)
                plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',2.5,...
                    'Color',color(plt,:),'MarkerFaceColor',color(plt,:));
                hold on;
            end
            C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the fitted curves
            if plt>=1 && plt<=2 % collective: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:)); %coll.
            elseif plt>2 && plt<=4 % individual: dashed lines
                plot(C,ps,'--','LineWidth',3,'Color',color(plt,:)); %ind.
            end
        
        % bType==3, averaged data: plot min, max, Collective, minColl, maxColl
        elseif bType == 3 && (ave == 0 || ave == 1)
            % plot the markers for y(:,1:4)
            if plt<=5
                plot(conSteps, y(:,plt), 'o','MarkerSize',8,'LineWidth',2.5,...
                    'Color',color(plt,:));
                hold on;
            end
%             if plt>=1 && plt<=2 % collective markers: big empty (white)
%                 plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',12,'LineWidth',2.5,...
%                     'Color',color(plt,:));
%                 hold on;
%             elseif plt>2 && plt<=4 % individual markers: small filled (blue/red)
%                 plot(conSteps, y(:,plt), plotSym{:,plt},'MarkerSize',6,'LineWidth',2.5,...
%                     'Color',color(plt,:),'MarkerFaceColor',color(plt,:));
%                 hold on;
%             end
            C = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
            ps = cdf('norm',C,d_mean,d_sd);
            % plot the fitted curves
            if plt>=1 && plt<=2 % individual: dashed lines
                plot(C,ps,'--','LineWidth',3,'Color',color(plt,:)); %ind.
            elseif plt>2 && plt<=5 % collective: continuous lines
                plot(C,ps,'-','LineWidth',3,'Color',color(plt,:)); %coll.
            end

        end
        
        % finally, compute either max or mean slope value (depending on coll_calc)
        slope_pair(:,plt) = eval([coll_calc '(diff(ps)./diff(C))']);

        clear bhat d_mean d_sd C ps
   
        hold on;
    end


else % split into windows
    
    % XXX no plots created here (just slope values computed); must be adjusted as above!
    
    cnt = 1; % set counter
    
    for i = 1:default.step:(160-(default.w_lgt-1)) % loop through windows (previous: 1:default.step:default.w_lgt)
        
        % create indices for the windows
        w(cnt,:) = i:i+default.w_lgt-1;
        selwn    = y(w(cnt,:)',:); % current selected window
        
        % compute parameters for fit
        bhat   = glmfit(selwn(:,2),[selwn(:,1) ones(size(selwn(:,1)))],'binomial','link','probit');
        d_mean = -bhat(1)/bhat(2);
        d_sd   = 1/bhat(2);

        %plot(selw(:,2), selw(:,1), plotSym{3},'Color',color(:,3));
        %hold on;
        C  = 1.3 .* (min(conSteps) : 0.001 : max(conSteps));
        ps = cdf('norm',C,d_mean,d_sd);
        %plot(C,ps,'-','LineWidth',2,'Color',color(:,3));
        
        % compute either max or mean slope value (depending on coll_calc)
        slope_pair(:,cnt) = eval([coll_calc '(diff(ps)./diff(C))']);
        
        clear bhat d_mean d_sd C ps
        cnt = cnt + 1;
    end
end

clear bhat d_mean d_sd C ps

end % end of function