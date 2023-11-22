function [npIndex, npUlna] = nPeaks(indexV, ulnaV)

[~,peak_loc_index] = findpeaks(indexV);
npIndex            = length(peak_loc_index);

[~,peak_loc_ulna] = findpeaks(ulnaV);
npUlna           = length(peak_loc_ulna);
