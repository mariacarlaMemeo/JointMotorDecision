
% display both individuals' decision BEFORE asking for joint decision

% check whether Agent's response corresponds to actual target interval
if stimuli.firstSecond==1 % if target is in 1st interval
    % for AgentB observer
    stimuli.resp.AgentB.acc = stimuli.resp.AgentB.firstSec == 1;
    % for AgentY observer
    stimuli.resp.AgentY.acc = stimuli.resp.AgentY.firstSec == 1;
elseif stimuli.firstSecond==2 % if target is in 2nd interval
    % for AgentB observer
    stimuli.resp.AgentB.acc = stimuli.resp.AgentB.firstSec == 2;
    % for AgentY observer
    stimuli.resp.AgentY.acc = stimuli.resp.AgentY.firstSec == 2;
end

%----------------------------------------------------------------------
% PREPARE DECISIONS
%----------------------------------------------------------------------
if stimuli.firstSecond==1 % if target is in 1st interval
    if stimuli.resp.AgentY.acc
        AgentYDecision.text = '1° stimolo';
    else
        AgentYDecision.text = '2° stimolo';
    end
    
    if stimuli.resp.AgentB.acc
        AgentBDecision.text = '1° stimolo';
    else
        AgentBDecision.text = '2° stimolo';
    end
elseif stimuli.firstSecond==2 % if target is in 2nd interval
    if stimuli.resp.AgentY.acc
        AgentYDecision.text = '2° stimolo';
    else
        AgentYDecision.text = '1° stimolo';
    end
    
    if stimuli.resp.AgentB.acc
        AgentBDecision.text = '2° stimolo';
    else
        AgentBDecision.text = '1° stimolo';
    end
end
