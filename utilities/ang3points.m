function theta = ang3points(p3)
%function that given a 2X3 or 3X2 matrix returns the angle in degrees subtended
%by clockwise rotation between the 1st straight-line segment & the second
sz = size(p3);
if ~(min(sz) == 2 && max(sz) == 3)
    error('size of input must be 2X3 or 3X2')
end
if sz(1) == 2
    p3 = p3';
end
v1 = p3(1,:) - p3(2,:);
v2 = p3(3,:) - p3(2,:);
%get angle of v1 from (1,0)
v1a = atan2(v1(2),v1(1));
%rotate v2 back by this amount (i.e. clockwise)
rot = [cos(-v1a),-sin(-v1a);sin(-v1a),cos(-v1a)];
v2 = (rot * v2')';
%get angle of transformed v2 from (1,0)
v2a = atan2(v2(2),v2(1));
%convert to clockwise rotation angle
if v2a > 0
    v2a = 2 * pi - v2a;
else
    v2a = -v2a;
end
theta = v2a * 180 / pi;
