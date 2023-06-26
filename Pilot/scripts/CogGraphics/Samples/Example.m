function Example

cgloadlib
cgopen(1,0,0,1)

cgpenwid(10)
siz = 0;

kd(1) = 0;
while kd(1) == 0
 kd = cgkeymap;

 cgellipse(0,0,siz,siz,[1 1 1])
 cgflip(0,0,0)

 siz = siz + 2;
 if siz > 640
  siz = 0;
 end

end
cgshut
return