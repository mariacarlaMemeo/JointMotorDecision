function [pksInd, pksUlna] = nPeaks(indexV, ulnaV)

% we have two structures pks.Index/Ulna to save
% 1. the values of the velocity peaks
% 2. the locations of the velocity peaks
% 3. the number of velocity peaks

MPH = 50; % only those peaks greater than the minimum peak height, MPH
MPP = 20; % peaks guaranteed to have a vertical drop of more than MPP from the peak on both sides

[pksInd.peaks_index,pksInd.peak_loc_index] = findpeaks(indexV,'MinPeakHeight',MPH,'MinPeakProminence',MPP);
pksInd.npIndex            = length(pksInd.peak_loc_index);

[pksUlna.peaks_ulna,pksUlna.peak_loc_ulna]  = findpeaks(ulnaV,'MinPeakHeight',MPH,'MinPeakProminence',MPP);
pksUlna.npUlna             = length(pksUlna.peak_loc_ulna);
