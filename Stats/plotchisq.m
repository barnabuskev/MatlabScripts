function plotchisq(dof)
%function to plot a chi-squared density function with dof degrees of
%freedom
upper = dof + 10*dof;
x = 0:upper/200:upper;
y = x.^(dof/2-1).*exp(-x/2)./(gamma(dof/2)*2^(dof/2));
plot(x,y)