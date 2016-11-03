function outdat = PCreduce(inmat,pcs)
%function to take data matrix - rows objects, cols variables and compress
%it to principle components represented by vector pcs. E.g. pcs = [1,2,3]
%to compress inmat into 1st 3 principle components. 
[vec,val] = eig(cov(inmat));
vec = fliplr(vec);
eigspc = inmat * vec;
outdat = eigspc(:,pcs);
