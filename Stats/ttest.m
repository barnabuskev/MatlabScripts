function [tstat,df] = ttest(dat1,dat2)
%function to return t statistic of unpaired data dat1 & dat2
if ~(isvector(dat1) && isvector(dat2))
    error('inputs must be vectors')
end
n1 = length(dat1);
n2 = length(dat2);
mu1 = mean(dat1);
mu2 = mean(dat2);
%sum of squares
SS1 = sum((dat1 - mu1).^2);
SS2 = sum((dat2 - mu2).^2);
df = n1 + n2 - 2;
%combined variance
comvar = (SS1 + SS2) / df;
se = sqrt(comvar * (1 / n1 + 1 / n2));
tstat = (mu1 - mu2) / se;
