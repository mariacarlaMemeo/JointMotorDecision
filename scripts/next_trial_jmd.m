%----------------------------------------------------------------------
% ANNOUNCE NEXT TRIAL (and wait for keypress)
cgfont('Arial',fontsizebig);

nextTrialStart  = 'Trial about to begin.';
nextA1          = 'Blue participant starts.';
nextA2          = 'Yellow participant starts.';

if stimuli.trial < stimuli.trialsInBlock
    % announce which agent will start next trial
    if mod(trial,2) == 1 % if curr. trial is odd, blue p (A1) starts
        cgpencol(0,0,1);
        cgtext(nextTrialStart,-mWidth,50);
        cgtext(nextTrialStart,mWidth,50);
        cgtext(nextA1,-mWidth,-50);
        cgtext(nextA1,mWidth,-50);
    elseif mod(trial,2) == 0 % if curr. trial is even, yellow p (A2) starts
        cgpencol(1,1,0);
        cgtext(nextTrialStart,-mWidth,50);
        cgtext(nextTrialStart,mWidth,50);
        cgtext(nextA2,-mWidth,-50);
        cgtext(nextA2,mWidth,-50);
    end
    cgflip(background(1),background(2),background(3));
    waitkeydown(inf,71); % start new trial with spacebar press
end
cgflip(background(1),background(2),background(3));
cgpencol(0,0,0)