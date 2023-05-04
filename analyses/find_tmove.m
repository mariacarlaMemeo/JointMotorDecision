function tmove = find_tmove(ulna)

[peak,peak_loc] = findpeaks(ulna);
min_loc = find(islocalmin(ulna));

[~,max_peak_loc] = max(peak);

diff_loc_min_peak = min_loc - peak_loc(max_peak_loc);
tmove = min_loc(max(find(diff_loc_min_peak<0)));
end