function tmove = find_tmove(move_marker)

% -------------------------------------------------------------------------
% -> Here we identify the index of max. velocity and the preceding minimum.
% -------------------------------------------------------------------------
% This function is called from "movement_onset.m"

[peak,peak_loc]   = findpeaks(move_marker); % finds all peaks and the corresponding indices
[~,max_peak_loc]  = max(peak); % finds the maximum peak and the corresponding indices
min_loc           = find(islocalmin(move_marker)); % finds the indices of all minima
min_loc           = min_loc(min_loc>20); % only AFTER preAcqu

diff_loc_min_peak = min_loc - peak_loc(max_peak_loc); % subtract max peak index from minima indices
% find minimum that is closest "to the left" (i.e., earlier in time) of the maximum
tmove             = min_loc(max(find(diff_loc_min_peak<0)));

if isempty(tmove)
    tmove = NaN;
end

end

% script version: Nov 2023