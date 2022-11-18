function ind_vector = findTh_cons(v,threshold,cons_ind)
%find where the vector 'v' is higher than the 'threshold' for 'cons_ind'
%consecutive elements
va         = find((v>threshold));
ind_vector = va(find(diff(va)>cons_ind)+1);
end
