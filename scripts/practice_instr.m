% experiment instructions (during practice session)

fontsize_instr_big = 25;
fontsize_instr_small = 20;

% screen 1: welcome to the experiment
cgfont('Arial',fontsize_instr_big);
exp_instr_1_0     = 'Thank you for taking part in this experiment!';
exp_instr_1_1     = 'Please read the following instructions carefully.';
exp_instr_1_2     = 'If you have any questions, please ask the experimenter.';

cgtext(exp_instr_1_0,mWidth,100);
cgtext(exp_instr_1_0,-mWidth,100);
cgtext(exp_instr_1_1,mWidth,-100);
cgtext(exp_instr_1_1,-mWidth,-100);
cgtext(exp_instr_1_2,mWidth,-150);
cgtext(exp_instr_1_2,-mWidth,-150);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 2: perceptual task
exp_instr_2_0     = 'Your task:';
exp_instr_2_1     = 'This is a perceptual detection task.';
exp_instr_2_2     = 'You will see two images on the screen, one after the other.';
exp_instr_2_3     = 'Each image will appear only for a very short moment on the screen,';
exp_instr_2_4     = 'so you need to pay close attention.';

exp_instr_2_5     = 'Each image consists of 6 small gratings arranged in a circle.';
exp_instr_2_6     = 'One of the gratings differs from the others: it has a higher contrast.';
exp_instr_2_7     = 'This grating can appear either in the first or second image.';
exp_instr_2_8     = 'Your task is to decide when this grating appeared (first or second?).';

exp_instr_2_9     = 'You will see an example image on the next screen.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_2_0,mWidth,400);
cgtext(exp_instr_2_0,-mWidth,400);
cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_2_1,mWidth,300);
cgtext(exp_instr_2_1,-mWidth,300);
cgtext(exp_instr_2_2,mWidth,250);
cgtext(exp_instr_2_2,-mWidth,250);
cgtext(exp_instr_2_3,mWidth,200);
cgtext(exp_instr_2_3,-mWidth,200);
cgtext(exp_instr_2_4,mWidth,150);
cgtext(exp_instr_2_4,-mWidth,150);
cgtext(exp_instr_2_5,mWidth,-50);
cgtext(exp_instr_2_5,-mWidth,-50);
cgtext(exp_instr_2_6,mWidth,-100);
cgtext(exp_instr_2_6,-mWidth,-100);
cgtext(exp_instr_2_7,mWidth,-150);
cgtext(exp_instr_2_7,-mWidth,-150);
cgtext(exp_instr_2_8,mWidth,-200);
cgtext(exp_instr_2_8,-mWidth,-200);
cgtext(exp_instr_2_9,mWidth,-300);
cgtext(exp_instr_2_9,-mWidth,-300);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 3: stimulus example
loadpict('C:\Users\OTB\Documents\GitHub\joint-motor-decision\scripts\stimulus_2.png',1,0,0)
drawpict(1);

waitkeydown(inf,71);
% cgflip(background(1),background(2),background(3)); XXX

% screen 4: response
exp_instr_3_0     = 'If the different grating appears in the 1st image,';
exp_instr_3_01    = 'press the left button.';
exp_instr_3_1     = 'If the different grating appeared in the 2nd image,';
exp_instr_3_11    = 'press the right button.';
exp_instr_3_2     = 'Please use your index finger to press the buttons.';
exp_instr_3_3     = 'Important:';
exp_instr_3_4     = 'Keep the finger on the start until the decision prompt appears.';

cgtext(exp_instr_3_0,mWidth,300);
cgtext(exp_instr_3_0,-mWidth,300);
cgtext(exp_instr_3_01,mWidth,250);
cgtext(exp_instr_3_01,-mWidth,250);
cgtext(exp_instr_3_1,mWidth,200);
cgtext(exp_instr_3_1,-mWidth,200);
cgtext(exp_instr_3_11,mWidth,150);
cgtext(exp_instr_3_11,-mWidth,150);
cgtext(exp_instr_3_2,mWidth,0);
cgtext(exp_instr_3_2,-mWidth,0);
cgtext(exp_instr_3_3,mWidth,-200);
cgtext(exp_instr_3_3,-mWidth,-200);
cgtext(exp_instr_3_4,mWidth,-300);
cgtext(exp_instr_3_4,-mWidth,-300);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 5: confidence scale example
exp_instr_5_0     = 'After you take your decision, please rate your confidence';
exp_instr_5_1     = 'on a scale from 1-6 (see next screen).';

exp_instr_5_2     = '6 = maximum confidence level';
exp_instr_5_3     = '1 = minimum confidence level';
exp_instr_5_4     = 'Please use all levels of the confidence scale.';

cgtext(exp_instr_5_0,mWidth,300);
cgtext(exp_instr_5_0,-mWidth,300);
cgtext(exp_instr_5_1,mWidth,200);
cgtext(exp_instr_5_1,-mWidth,200);
cgtext(exp_instr_5_2,mWidth,-100);
cgtext(exp_instr_5_2,-mWidth,-100);
cgtext(exp_instr_5_3,mWidth,-150);
cgtext(exp_instr_5_3,-mWidth,-150);
cgtext(exp_instr_5_4,mWidth,-250);
cgtext(exp_instr_5_4,-mWidth,-250);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 5.2: confidence scale example
loadpict('C:\Users\OTB\Documents\GitHub\joint-motor-decision\scripts\confidence_2.png',2,0,0)
drawpict(2);

waitkeydown(inf,71); % stay on screen until space bar is pressed
% cgflip(background(1),background(2),background(3)); XXX


% screen 6: goal
exp_instr_6_0     = 'Your goal:';
exp_instr_6_1     = 'You solve this task in a team with another participant (“partner”).';
exp_instr_6_2     = 'Your goal is to maximize the TEAM SCORE.';
exp_instr_6_3     = 'In each trial, you and your partner will each first perform the task alone.';
exp_instr_6_4     = 'Afterwards, one of you takes the final decision for the team.';
exp_instr_6_5     = 'You will be informed about the team score.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_6_0,mWidth,400);
cgtext(exp_instr_6_0,-mWidth,400);
cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_6_1,mWidth,300);
cgtext(exp_instr_6_1,-mWidth,300);
cgtext(exp_instr_6_2,mWidth,200);
cgtext(exp_instr_6_2,-mWidth,200);
cgtext(exp_instr_6_3,mWidth,-100);
cgtext(exp_instr_6_3,-mWidth,-100);
cgtext(exp_instr_6_4,mWidth,-200);
cgtext(exp_instr_6_4,-mWidth,-200);
cgtext(exp_instr_6_5,mWidth,-400);
cgtext(exp_instr_6_5,-mWidth,-400);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed

% screen 7: information exchange
cgfont('Arial',fontsize_instr_big);
exp_instr_7_0     = 'During the experiment, you cannot talk to your partner.';
exp_instr_7_1     = 'However, you can learn about the decisions of your partner';
exp_instr_7_2     = 'by observing their movements.';

cgtext(exp_instr_7_0,mWidth,100);
cgtext(exp_instr_7_0,-mWidth,100);
cgtext(exp_instr_7_1,mWidth,0);
cgtext(exp_instr_7_1,-mWidth,0);
cgtext(exp_instr_7_2,mWidth,-100);
cgtext(exp_instr_7_2,-mWidth,-100);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 8: experiment structure
exp_instr_8_0     = 'Experiment structure:';
exp_instr_8_1     = 'The experiment is split into four parts.';
exp_instr_8_2     = 'You can take breaks inbetween parts and you will';
exp_instr_8_3     = 'be informed about your team score during each break.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_8_0,mWidth,200);
cgtext(exp_instr_8_0,-mWidth,200);
cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_8_1,mWidth,50);
cgtext(exp_instr_8_1,-mWidth,50);
cgtext(exp_instr_8_2,mWidth,0);
cgtext(exp_instr_8_2,-mWidth,0);
cgtext(exp_instr_8_3,mWidth,-50);
cgtext(exp_instr_8_3,-mWidth,-50);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed

% screen 9: ready for experiment?
exp_instr_9_0     = 'Before the experiment begins, there will be a short practice.';
exp_instr_9_1     = 'If you are ready, you can now start with the practice.';
exp_instr_9_2     = 'Remember that your goal is to maximize the team score.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_9_0,mWidth,200);
cgtext(exp_instr_9_0,-mWidth,200);
cgtext(exp_instr_9_1,mWidth,100);
cgtext(exp_instr_9_1,-mWidth,100);
cgtext(exp_instr_9_2,mWidth,-100);
cgtext(exp_instr_9_2,-mWidth,-100);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed
