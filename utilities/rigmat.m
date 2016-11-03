function trnsmat = rigmat(rot,x,y)
%function to take rigid transformation parameters, rotation 'rot' in
%degrees x & y displacements & produce a 3X3 transformation matrix of the
%form [r,r,x;r,r,y;0,0,1] where 'r' are the rotation elements & x & y are
%the displacements. This produces anticlockwise rotation for positive
%values, by convention...
%
%convert to radians
rot = rot * pi / 180;
trnsmat = [cos(rot),-sin(rot),x;sin(rot),cos(rot),y;0,0,1];