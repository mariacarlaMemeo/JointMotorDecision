%Seconds to wait
w = 2;

if show_acc==3 % show B,Y, joint
    if stimuli.resp.AgentY.acc
        AgentYFeedback.text = 'correct';
    else
        AgentYFeedback.text = 'wrong';
    end
    
    if stimuli.resp.AgentB.acc
        AgentBFeedback.text = 'correct';
    else
        AgentBFeedback.text = 'wrong';
    end
    
    if stimuli.resp.Coll.acc
        CollFeedback.text = 'correct';
    else
        CollFeedback.text = 'wrong';
    end
    % show feedback aligned horizontally (B - joint - Y)
    AgentBFeedback.y = 0; AgentYFeedback.y = 0; CollFeedback.y = -150;
    cgpencol(0,0,1); % blue
    cgtext(AgentBFeedback.text,-mWidth-mWidth/2,AgentBFeedback.y);
    cgtext(AgentBFeedback.text,mWidth/2,AgentBFeedback.y);
    cgpencol(1,1,0); % yellow
    cgtext(AgentYFeedback.text,-mWidth/2,AgentYFeedback.y);
    cgtext(AgentYFeedback.text,mWidth+mWidth/2,AgentYFeedback.y);
    cgpencol(1,1,1); % white
    cgfont('Arial',40);
    cgtext(CollFeedback.text,-mWidth,CollFeedback.y);
    cgtext(CollFeedback.text,mWidth,CollFeedback.y);
    cgflip(background(1),background(2),background(3));
    
    WaitSecs(w); % display for 2 seconds, then proceed automatically
    
elseif show_acc==2 % show only joint
    if stimuli.resp.Coll.acc
        CollFeedback.text = 'correct';
    else
        CollFeedback.text = 'wrong';
    end
    CollFeedback.y = 0;
    cgpencol(1,1,1); % white
    cgfont('Arial',40);
    cgtext(CollFeedback.text,-mWidth,CollFeedback.y);
    cgtext(CollFeedback.text,mWidth,CollFeedback.y);
    cgflip(background(1),background(2),background(3));
    
    WaitSecs(w);
    
elseif show_acc==1 %nothing happens
    
end

