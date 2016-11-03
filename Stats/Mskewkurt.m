function [skw,krt] = Mskewkurt(X)
%function to calculate multivariate skewness & kurtosis as defined by Mardia K.V.
%("Measures of multivariate skewness and kurtosis with applications",
%Biometrika, 57, 519-530). datmat is a data matrix whose rows correspond to
%objects and columns represent the variables
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%data dimension
[n,p] = size(X);
mu = mean(X);
%get covariance matrix
S = cov(X,1);
%subtract mean
Xc = bsxfun(@minus,X,mu);
%calculate function g for all pairs of variables
g = Xc * inv(S) * Xc';
%calculate skewness
skw = 1 / n^2 * sum(sum(g.^3));
%calculate kurtosis
krt = 1 / n * sum(diag(g).^2);

