function pts = rot2D(pts,theta,varargin)
%function to do counterclockwise rotation in degs 'theta' of points 'pts' about
%center of rotation 'cnt'. if cnt is ommited then rotation occurs about the
%origin: out = rot2D(pts,theta,cnt). pts must be NX2 or 2XN. if it is 2X2
%make sure that the 1st row are x coords & 2nd row are y coords
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%handle input
switch nargin
    case 2
        cnt = [0,0]';
    case 3
        cnt = varargin{1};
        sc = size(cnt);
        if ~(isequal(sc,[1,2]) || isequal(sc,[2,1]))
            error('center of rotation must be point in plane')
        end
        if sc(2) == 2
            cnt = cnt';
        end
    otherwise
        error('Wrong number of input arguments')
end
%check pts argument
ind = find(size(pts) == 2);
tpse = false;
switch length(ind)
    case 0
        error('points must be 2D')
    case 1
        if ind == 2
            %transpose
            pts = pts';
            tpse = true;
        end
    case 2
        %do nothing
    otherwise
        error('Only 2D arrays can be used')
end
%get rotation matrix
theta = theta * pi / 180;
ct = cos(theta);
st = sin(theta);
rotmat = [ct,-st;st,ct];
% move points to origin, rotate & move back
pts = bsxfun(@minus,pts,cnt);
pts = rotmat * pts;
pts = bsxfun(@plus,pts,cnt);
%transpose if transposed
if tpse
    pts = pts';
end

