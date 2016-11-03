function [totcurv,curvvec] = getcurvature(in)
% function to take a NX2 matrix of pixel coordinates 'in' and calculate the
% curvature of the curve total curvature - 'totcurv' - and the curvature values
% along the length of the curve - 'curvvec' -
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% fit spline...
% initialise
divn = 500;
npts = size(in,2);
% calculate parametric parameter t
t = [0];
for ia = 2:npts
	t = [t,t(ia-1) + sqrt((in(1,ia-1) - in(1,ia))^2 + (in(2,ia-1) - in(2,ia))^2)];
end
divs = max(t)/divn;
pp = spline(t,in);
% get interpolated points
ti = min(t):divs:max(t);
Yi = ppval(pp,ti);
% get curvature & arc for values of t
[curvvec,arcf] = gettanj(pp,ti);
curvint = linint(arcf,curvvec);
totcurv = sum(curvint);

function [curv,arcf] = gettanj(pp,ti)
% function to take poly params for x & y and values of t & calculate angle of 
% tangent of curve at values of t in degrees
curv = zeros(1,length(ti));
arcf = zeros(1,length(ti));
prms = pp.coefs;
for ia = 1:pp.pieces
	indx = ti >= pp.breaks(ia) & ti <= pp.breaks(ia+1);
	tsec = ti(indx) - pp.breaks(ia);
	ax = prms(ia*2-1,1);
	ay = prms(ia*2,1);
	bx = prms(ia*2-1,2);
	by = prms(ia*2,2);
	cx = prms(ia*2-1,3);
	cy = prms(ia*2,3);
	curv(indx) = getcurv(tsec,ax,ay,bx,by,cx,cy);
	indx = find(indx);
	if ~(max(ti(indx)) == pp.breaks(ia+1))
		indx = [indx,max(indx)+1];
	end
	arcf(indx(2:end)) = getarclen(ti(indx) - pp.breaks(ia),ax,ay,bx,by,cx,cy);
end
arcf = cumsum(arcf);


function out = getcurv(t,ax,ay,bx,by,cx,cy)
%calculate curvature of parametric poly
out = abs((6*(bx*ay - ax*by)*t.^2 + 6*(cx*ay - ax*cy)*t + 2*(cx*by - bx*cy))...
    ./ ((3*ax*t.^2 + 2*bx*t+cx).^2 + (3*ay*t.^2 + 2*by*t + cy).^2).^1.5);

function out = getarclen(tsec,ax,ay,bx,by,cx,cy)
%function to calculate arc length at each subsample interval
ns = length(tsec);
tmp = zeros(1,ns);
for ia = 1:(ns-1)
	out(ia) = quad(@(t) getarclenf(t,ax,ay,bx,by,cx,cy),tsec(ia),tsec(ia+1));
end

function out = getarclenf(t,ax,ay,bx,by,cx,cy)
%function to calculate the function to integrate to get arc length
out = sqrt((3*ax*t.^2 + 2*bx*t + cx).^2 + (3*ay*t.^2 + 2*by*t + cy).^2);


function out = linint(x,y)
% function to integrate sampled function with linear interpolation
if ~all(size(x) == size(y))
	error('x & y must be same size')
end
out = zeros(size(x));
for ia = 2:length(x)
	out(ia) = (y(ia-1) + y(ia)) / 2 * (x(ia) - x(ia-1));
end
