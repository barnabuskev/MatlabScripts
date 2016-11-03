function [pcs,var] = PCsabovethresh(datmat,percent)
%function to estimate the number of PCs that are significant in PCA of
%datmat based on percentage of cummuative variance explained. It outputs
%that %age of variance 'var' below percentage 'percent' and the no. of PCs
%'pcs'
[vec,val] = eig(cov(datmat));
val = diag(val);
val = flipud(val);
%covert to %age explained var
val = val / sum(val);
%get cummulative fraction
tot = 0;
cum = [];
for ia = 1:length(val)
    tot = tot + val(ia);
    cum = [cum,tot];
end
pcs = sum(cum < percent / 100);
var = cum(pcs);