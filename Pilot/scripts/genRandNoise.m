function f = genRandNoise(imSize,xOff,yOff,sigma,contrast)
noiseMat = 2.*rand(imSize,imSize)-1;
[X, Y]    = meshgrid(-.5:1/imSize:.5-1/imSize,-.5:1/imSize:.5-1/imSize);
s        = sigma/imSize;
gauss    = exp(-((((X-xOff).^2)+((Y-yOff).^2))./(2*s*s)));
f        = gauss .* noiseMat .* contrast;
%hist(f(:))
end