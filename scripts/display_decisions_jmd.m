
% display both individuals' decision BEFORE asking for joint decision

% check whether Agent's response corresponds to actual target interval
if stimuli.firstSecond==1 % if target is in 1st interval
    % for Agent1 observer
    stimuli.resp.Agent1.acc = stimuli.resp.Agent1.firstSec == 1;
    % for Agent2 observer
    stimuli.resp.Agent2.acc = stimuli.resp.Agent2.firstSec == 1;
elseif stimuli.firstSecond==2 % if target is in 2nd interval
    % for Agent1 observer
    stimuli.resp.Agent1.acc = stimuli.resp.Agent1.firstSec == 2;
    % for Agent2 observer
    stimuli.resp.Agent2.acc = stimuli.resp.Agent2.firstSec == 2;
end

%----------------------------------------------------------------------
% PREPARE DECISIONS
%----------------------------------------------------------------------
if stimuli.firstSecond==1 % if target is in 1st interval
    if stimuli.resp.Agent2.acc
        Agent2Feedback.text = '1° stimolo';
    else
        Agent2Feedback.text = '2° stimolo';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Feedback.text = '1° stimolo';
    else
        Agent1Feedback.text = '2° stimolo';
    end
elseif stimuli.firstSecond==2 % if target is in 2nd interval
    if stimuli.resp.Agent2.acc
        Agent2Feedback.text = '2° stimolo';
    else
        Agent2Feedback.text = '1° stimolo';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Feedback.text = '2° stimolo';
    else
        Agent1Feedback.text = '1° stimolo';
    end
end


% show feedback aligned horizontally (A1 - A2)
Agent1Feedback.y = 0; Agent2Feedback.y = 0; CollFeedback.y = 0;
cgpencol(0,0,1);
cgtext(Agent1Feedback.text,-mWidth-mWidth/2,Agent1Feedback.y);
cgtext(Agent1Feedback.text,mWidth/2,Agent1Feedback.y);
cgpencol(1,1,0);
cgtext(Agent2Feedback.text,-mWidth/2,Agent2Feedback.y);
cgtext(Agent2Feedback.text,mWidth+mWidth/2,Agent2Feedback.y);

cgflip(background(1),background(2),background(3));
wait(4000); % display for 2 seconds, then proceed automatically

cgpencol(0,0,0); % return to black font