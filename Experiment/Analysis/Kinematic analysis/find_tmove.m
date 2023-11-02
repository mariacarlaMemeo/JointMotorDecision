function tmove = find_tmove(ulna)

% -------------------------------------------------------------------------
% -> Here we identify the index of max. velocity and the preceding minimum.
% -------------------------------------------------------------------------
% This function is called from "movement_onset.m"

[peak,peak_loc]   = findpeaks(ulna); % finds all peaks and the corresponding indices
[~,max_peak_loc]  = max(peak); % finds the maximum peak and the corresponding indices
min_loc           = find(islocalmin(ulna)); % finds the indices of all minima
% XXX looking for local minima, we do not find the lowest point before
% the first maximum (because there is no maximum preceding it)...

diff_loc_min_peak = min_loc - peak_loc(max_peak_loc); % subtract max peak index from minima indices 
tmove             = min_loc(max(find(diff_loc_min_peak<0))); % ???

if isempty(tmove)
    tmove = NaN;
end

end

% script version: 1 Nov 2023