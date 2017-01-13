function theta = ang3points(pts3)
% function that given a 2X3 or 3X2 matrix of x, y coordinates returns the
% angle in degrees between the vector made up of the first two coordinates
% and that made up of the last two coords (rotate first towards second clockwise)
% Assumes Cartesian coords

% CHECK INPUT
sz = size(pts3);
if ~(min(sz) == 2 && max(sz) == 3)
    error('size of input must be 2X3 or 3X2')
end
if sz(1) == 2
    pts3 = pts3';
end

% GET ANGLE
% translate points so that middle point is at the origin
pts3 = bsxfun(@minus,pts3,pts3(2,:));
% get anti-clockwise angles, in degrees, of vectors from (1,0)
angs = atan2d(pts3([1,3],2),pts3([1,3],1));
% return clockwise angle from first to second
theta = angs(1) - angs(2);

