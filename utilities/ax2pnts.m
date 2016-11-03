function dvec = ax2pnts(ax_h,distax_x,distax_y)
% function to convert axis units to points
% distax_x,distax_y:    distance along x & y axis in axis units
% distp_x,distp_y:      distance along x & y axis in points
% ax_h:                 axis handle

assert(isvector(distax_x) || isscalar(distax_x),'distax_x must be a scalar or vector')
assert(isvector(distax_y) || isscalar(distax_y),'distax_y must be a scalar or vector')
assert(isequal(size(distax_x),size(distax_y)),'distax_x and distax_y must have equal size and orientation')
% get axis x & y lims
xl = get(ax_h,'xlim');
yl = get(ax_h,'ylim');
% get axis position in points
saveu = get(ax_h,'units');
set(ax_h,'units','points')
pos = get(ax_h,'position');
w = pos(3);
h = pos(4);
set(ax_h,'units',saveu)
xfact = w / (xl(2) - xl(1));
yfact = h / (yl(2) - yl(1));
distp_x = distax_x * xfact;
distp_y = distax_y * yfact;
% check shape of input vector & create matrix accordingly
if (size(distp_x,2) == 1)
    % column vector
    dvec = [distp_x,distp_y];
else
    % row vector
    dvec = [distp_x;distp_y];
end