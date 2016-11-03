function cobb = estcobb(points,ref)
%Function to take a set of points (e.g. along the thoracic spine) and fit a
%circle through the points. The Cobb angle is calculated as the angle
%between the line going from one end of the set of points to the centre and
%the line between the centre and the other end of the set of points. This
%is done by minimising an error function. The error function is
%'centrecircerror'. This calculates the sum of squares of errors for each
%point. This error is obtained by calculating the distance between each
%point and an estimate of the location of the centre of the circle, and
%finding the difference between this distance and the mean distance for all
%the points. Points on a circle should have an error = zero for a correctly
%estimated centre. 'points' are points on the curve, and ref is a set of
%points to plot at same time (e.g. for reference)
%
%Get initial estimate (average of all points)
plot(points(:,1),points(:,2));
axis equal
hold on;
plot(ref(:,1),ref(:,2),'g-')
est = ginput(1);
%obtain centre
centre = fminsearch(@centrecircerror,est,[],points);
%Calculate average distance from estimated centre
no_points = size(points,1);
r = [];
for i = 1:no_points
    r = [r,norm(points(i,:) - centre)];
end
rmean = mean(r);
%plot results
plot(points(:,1),points(:,2),'b.');
plot(centre(1),centre(2),'rx');
for theta = 0:pi/50:2*pi
    [X,Y] = pol2cart(theta,rmean);
    plot(X+centre(1),Y+centre(2));
end
axis equal;
hold off;
pause
%Calculate cobb angle by law of cosines
a = norm(points(1,:) - points(end,:));
b = norm(points(1,:) - centre);
c = norm(points(end,:) - centre);
cobb = acos((b^2+c^2-a^2)/(2*b*c))*180/pi;