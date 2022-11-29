function ind_va = findTh_cons(v,threshold,cons_ind)
%find where the vector 'v' is higher than the 'threshold' for 'cons_ind'
%consecutive elements
va     = find((v>threshold));
ind_va = va(findstr(diff(va)',ones(1,cons_ind)));%find all the indeces in which the numbers are repeated 'cons_ind' times
if isempty(ind_va)
    ind_va= NaN;
end
    
end
