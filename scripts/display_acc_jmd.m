%Seconds to wait
w = 2;

if show_acc==3 % show A1,A2, joint
    if stimuli.resp.Agent2.acc
        Agent2Feedback.text = 'correct';
    else
        Agent2Feedback.text = 'wrong';
    end
    
    if stimuli.resp.Agent1.acc
        Agent1Feedback.text = 'correct';
    else
        Agent1Feedback.text = 'wrong';
    end
    
    if stimuli.resp.Coll.acc
        CollFeedback.text = 'correct';
    else
        CollFeedback.text = 'wrong';
    end
    % show feedback aligned horizontally (A1 - joint - A2)
    Agent1Feedback.y = 0; Agent2Feedback.y = 0; CollFeedback.y = -150;
    cgpencol(0,0,1); % blue
    cgtext(Agent1Feedback.text,-mWidth-mWidth/2,Agent1Feedback.y);
    cgtext(Agent1Feedback.text,mWidth/2,Agent1Feedback.y);
    cgpencol(1,1,0); % yellow
    cgtext(Agent2Feedback.text,-mWidth/2,Agent2Feedback.y);
    cgtext(Agent2Feedback.text,mWidth+mWidth/2,Agent2Feedback.y);
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

