function out = mean0std1(in)
%function to take data matrix 'in' whose cols represent variables and rows
%represent objects, subtract the mean and normalise the standard deviation
%to 1
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%subtract mean
out = bsxfun(@minus,in,mean(in));
%divide by standard deviation
out = bsxfun(@rdivide,out,std(out));