%----------------------------------------------------------------------
% ANNOUNCE NEXT TRIAL (and wait for keypress)
cgfont('Arial',fontsizebig);

nextTrialStart = 'NUOVO TRIAL';%'Trial about to begin.';
nextB          = 'Blu inizia';%'Blue participant starts.';
nextY          = 'Giallo inizia';%'Yellow participant starts.';

buttonWarning1 = 'Questa volta uno di voi ha rilasciato ';
buttonWarning2 = 'il pulsante di start troppo presto.';
buttonWarning3 = 'Aspettate di vedere il ? prima di rispondere!';

% Warning message in case, at least in one decision, an agent released the
% start button before the decision prompt.
if stimuli.trial > 1 && any(stimuli.release_flag)
    cgpencol(0,0,0);
    cgtext(buttonWarning1,-mWidth,100);
    cgtext(buttonWarning1,mWidth,100);
    cgtext(buttonWarning2,-mWidth,50);
    cgtext(buttonWarning2,mWidth,50);
    cgtext(buttonWarning3,-mWidth,-150);
    cgtext(buttonWarning3,mWidth,-150);    
    cgflip(background(1),background(2),background(3));
    waitkeydown(inf,71);
end

if stimuli.trial < 2*stimuli.trialsInBlock
    % announce which agent will start next trial
    if mod(trial,2) == 1 % if curr. trial is odd, blue p (B) starts
        cgpencol(0,0,1);
        cgtext(nextTrialStart,-mWidth,50);
        cgtext(nextTrialStart,mWidth,50);
        cgtext(nextB,-mWidth,-50);
        cgtext(nextB,mWidth,-50);
    elseif mod(trial,2) == 0 % if curr. trial is even, yellow p (Y) starts
        cgpencol(1,1,0);
        cgtext(nextTrialStart,-mWidth,50);
        cgtext(nextTrialStart,mWidth,50);
        cgtext(nextY,-mWidth,-50);
        cgtext(nextY,mWidth,-50);
    end
    cgflip(background(1),background(2),background(3));
    waitkeydown(inf,71); % start new trial with spacebar press
end
cgflip(background(1),background(2),background(3));
cgpencol(0,0,0);