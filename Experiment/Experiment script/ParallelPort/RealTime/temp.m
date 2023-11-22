for i=2:length(index_pos)
   index_x(i) = index_pos(i).Translation(1);
   index_y(i) = index_pos(i).Translation(2);
   index_z(i) = index_pos(i).Translation(3);
if index_pos(i).Translation(1)<=650 
    disp(aperture(i))
end
end