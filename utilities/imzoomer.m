function imzoomer(im_h,fact,x,y)
% function to take an image object handle and zoom into (or out) of the image centered
% at axis coordinates x,y by factor fact
ima = get(im_h,'parent');
xl = get(ima,'xlim');
yl = get(ima,'ylim');
%centre at x,y with axis ranges reduced by fact
set(ima,'xlim',(xl - mean(xl))/fact + x)
set(ima,'ylim',(yl - mean(yl))/fact + y)
end

