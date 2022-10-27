% creates the locations for the Gabor patches
function [X, Y] = setStimXY(stimuli)
X = zeros(size(stimuli.setSize));
Y = zeros(size(stimuli.setSize));
initAngleInRad = rand * (pi./10);
angleStep = (2 .* pi) ./ stimuli.setSize;
angle = zeros(1,stimuli.setSize); % pre-allocate angle (row)vector
for i = 1 : stimuli.setSize
    angle(i) = initAngleInRad + ((i-1).* angleStep);
    X(i) = stimuli.R .* cos(angle(i));
    Y(i) = stimuli.R .* sin(angle(i));
end
