function [indx,d] = findclosepnt(arry,pnt)
% function inputs:
%   arry: an Nx2 or 2xN array
%   pnt: a 2x1 or 1x2 vector
% function outputs:
%   indx: row or col index of closest point in arry
%   d: vector of distances to pnt
if numel(pnt) ~= 2
    error('pnt should be 2x1 or 1x2')
end
if size(arry,1)~=2 && size(arry,2)~=2
    error('arry must be Nx2 or 2xN')
end
if size(pnt,2) == 1
    % make pnt 1x2
    pnt = pnt';
end
if size(arry,1) == 2
    % make arry Nx2
    arry = arry';
end
tmp = bsxfun(@minus,arry,pnt);
tmp = tmp.^2;
tmp = tmp(:,1) + tmp(:,2);
d = sqrt(tmp);
[~,indx] = min(tmp);

