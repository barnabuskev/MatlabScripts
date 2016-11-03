function expandaxis(h,fact)
%function to take axis pointed to by h & expand the axis by a factor of
%'fact'
xl = get(h,'xlim');
mxl = mean(xl);
set(h,'xlim',(xl - mxl) * fact + mxl);
yl = get(h,'ylim');
myl = mean(yl);
set(h,'ylim',(yl - myl) * fact + myl);