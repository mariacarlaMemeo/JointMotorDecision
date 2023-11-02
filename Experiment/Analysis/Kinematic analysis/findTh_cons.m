function ind_va = findTh_cons(v,threshold,cons_ind)

% -------------------------------------------------------------------------
% -> Here we find the moment(s) when the velocity threshold is passed.
% -------------------------------------------------------------------------
% This function is called from movement_onset.m
% Input arguments are: velocity vector (v), threshold (threshold), 
% no. of succesive samples that need to pass threshold (cons_ind)
cons_ind = cons_ind - 1; % to find 10 consecutive elements we need to give 9 as an input because it's used with a "diff" function
va       = find((v>threshold)); % find all elements that pass threshold
ind_va   = va(strfind(diff(va)',ones(1,cons_ind)));
% strfind(TEXT,PATTERN) returns the starting indices of any occurrences of PATTERN in TEXT.

if isempty(ind_va) % if none of the elements pass the test, ind_va is NaN
    ind_va = NaN;
end

end

% Explanation of procedure:
% We check, for each element in the vector v, if the velocity threshold
% (20 [mm/s]) is passed and if the consecutive 9 elements also pass the
% threshold (i.e., we check whether there are 10 consecutive elements above
% the threshold).
% If this is the case, then we include the index of the first element in
% the new vector "ind_va". Then we go on to check for the next element
% and so on, for all elements of the vector v.
% *Note*: ind_va contains indeces, not the actual values

% Example:
% a  = [2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2 2 2 2 2 2]
% va = [1 2 3 4 5 6 7 8 9 10 11 22 23 24 25 26 27 28 29 30 31 32]
% Check it with: va = find((a>=2))
% strfind(diff(va),ones(1,cons_ind)) = [1 2 12 13]
% ind_va = [1 2 22 23] -> this gives you the index of the elements (which pass
% the threshold test) in the original vector a.

% script version: 1 Nov 2023