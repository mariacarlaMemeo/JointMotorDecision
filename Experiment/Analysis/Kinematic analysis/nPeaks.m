function [npIndex, npUlna] = nPeaks(indexV, ulnaV)

MPH = 50; % only those peaks greater than the minimum peak height, MPH
MPP = 20; % peaks guaranteed to have a vertical drop of more than MPP from the peak on both sides

[~,peak_loc_index] = findpeaks(indexV,'MinPeakHeight',MPH,'MinPeakProminence',MPP);
npIndex            = length(peak_loc_index);

[~,peak_loc_ulna]  = findpeaks(ulnaV,'MinPeakHeight',MPH,'MinPeakProminence',MPP);
npUlna             = length(peak_loc_ulna);
