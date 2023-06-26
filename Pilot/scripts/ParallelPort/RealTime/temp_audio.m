gain = .5;

current_path = pwd;
small_path   = [current_path '\demo_realTime\small.wav'];
large_path   = [current_path '\demo_realTime\large.wav'];
[y_small,f_small]=audioread(small_path); 
[y_large,f_large]=audioread(large_path);

% f_small = gain*f_small;
f_large = gain*f_large;

sound(y_large,f_large)
% sound(y_small,f_small)