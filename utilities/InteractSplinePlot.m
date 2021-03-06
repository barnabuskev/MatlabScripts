axis([0 10 0 10])
hold on
% Initially, the list of points is empty.
xy = [];
n = 0;
% Loop, picking up the points.
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    plot(xi,yi,'ro')
    n = n+1;
    xy(:,n) = [xi;yi];
end
% Interpolate with a spline curve and finer spacing.
t = 1:n;
ts = 1: 0.1: n;
xys = spline(t,xy,ts);

% Plot the interpolated curve.
plot(xys(1,:),xys(2,:),'b-');
hold off

%interpolate & plot the x & y separately
x = xy(1,:);
xs = spline(t,x,ts);
figure
plot(xs,ts,'-b');
set(gca,'xlim',[0,10])
hold on
plot(x,t,'ro')
hold off
y = xy(2,:);
ys = spline(t,y,ts);
figure
plot(ts,ys,'-b');
set(gca,'ylim',[0,10])
hold on
plot(t,y,'ro')
hold off