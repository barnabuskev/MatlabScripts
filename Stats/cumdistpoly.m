function cumdistpoly(x)
%function to plot a cummulative distribution polygon from data x
n = length(x);
x = sort(x);
y = (1:n)/(n+1);
plot(x,y,'r+-')
grid on
set(gca,'ylim',[0,1])