function tstartTh = find_minstart(move_marker,startFrame)

% -------------------------------------------------------------------------
% -> Here we identify the minimum velocity preceding the passing of the
% 20mm/s threshold for either index or ulna.
% -------------------------------------------------------------------------
% This function is called from "movement_onset.m"

min_loc  = find(islocalmin(move_marker(1:startFrame))); % finds the indices of all minima
min_loc  = min_loc(min_loc>20); % only AFTER preAcqu

if isempty(min_loc)
    tstartTh = startFrame; % if the minimum cannot be found, use the previous startFrame
else
    % find minimum that is closest "to the left" (i.e., earlier in time) of the maximum
    diff_loc_min_start = min_loc - startFrame; % subtract startFrame from minima indices
    tstartTh = min_loc(max(find(diff_loc_min_start<0)));
end

end

% script version: Nov 2023