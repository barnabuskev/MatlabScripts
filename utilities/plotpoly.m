function plotpoly(coefs,intv)
%function to plot a polynomial over the interval 'intv'
xx = intv(1):(intv(2)-intv(1))/100:intv(2);
yy = coefs(1)*xx.^3 + coefs(2)*xx.^2 + coefs(3).*xx + coefs(4);
plot(xx,yy)