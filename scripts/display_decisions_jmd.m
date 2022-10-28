
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
        Agent2Decision.text = '1° stimolo';
    else
        Agent2Decision.text = '2° stimolo';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Decision.text = '1° stimolo';
    else
        Agent1Decision.text = '2° stimolo';
    end
elseif stimuli.firstSecond==2 % if target is in 2nd interval
    if stimuli.resp.Agent2.acc
        Agent2Decision.text = '2° stimolo';
    else
        Agent2Decision.text = '1° stimolo';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Decision.text = '2° stimolo';
    else
        Agent1Decision.text = '1° stimolo';
    end
end
