% system('net use K: \\geo.humanoids.iit.it\repository');%map the repositoy

%PsychDebugWindowConfiguration(0,0.6);
SCREEN.screenNumbers              = Screen('Screens');    % Screen Number Identification
SCREEN.screenID                   = max(SCREEN.screenNumbers);   % Select ID Screen
Screen('Preference', 'SkipSyncTests', 1);%it disables synchronization at the beginning of the script

%[SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0]);

[SCREEN.windowPtr, SCREEN.rect]   = Screen('OpenWindow',SCREEN.screenID,[0 0 0],[1368 0 3283 1196]);

Screen('TextFont',SCREEN.windowPtr, 'Courier New');
Screen('TextSize',SCREEN.windowPtr, 50);
Screen('TextStyle', SCREEN.windowPtr, 1+2);

text = 'Piccolo';
[nx, ny, textbounds] = DrawFormattedText(SCREEN.windowPtr,text, 'center', 'center',[255 255 255]);
Screen('Flip',SCREEN.windowPtr,[],0); 
 
% [newX, newY, textHeight]=Screen('DrawText', SCREEN.windowPtr, 'Welcome',SCREEN.rect(3)/2,SCREEN.rect(4)/2,[255,255,255])
