function ind_va = findTh_cons(v,threshold,cons_ind)
% We define the velocity threshold (threshold=20 [mm/s]) and then check, for each
% element in the vector v, whether this element surpasses the threshold and
% whether the consecutive 9 elements also surpass the threshold (i.e., we
% check whether there are 10 consecutive elements above the threshold). If
% this is the case, then we include the index of the first element in the
% new vector ind_va. Then we go on to check for the next element and so on.
% Example:
% a=[2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2 2 2 2 2 2]
% va=[1 2 3 4 5 6 7 8 9 10 11 22 23 24 25 26 27 28 29 30 31 32]
% findstr(diff(va),ones(1,cons_ind)) = [1 12]
% ind_va=[1 22] -> this gives you the index of the elements (which pass the
% threshold test) in the original vector a
% Note: ind_va contains indeces, not the actual values

va     = find((v>threshold));
ind_va = va(findstr(diff(va)',ones(1,cons_ind)));
if isempty(ind_va) % if none of the elements pass the test, ind_va is NaN
    ind_va= NaN;
end
    
end

