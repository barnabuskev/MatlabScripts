function p = plotnormal(mu,sd,rr)
%function to plot a normal distribution with mean mu and standard deviation
%sd and shade the rejection region rr where rr is the number of standard
%deviations away from the mean
x = -5:0.05:5;
x = x * sd + mu;
pd = npdf(x,mu,sd);
plot(x,pd)
tmp = find(x < mu - rr * sd);
rrx = [x(1),x(tmp),mu - rr * sd,mu - rr * sd];
yy = npdf([x(tmp),mu - rr * sd],mu,sd);
rry = [0,yy,0];
p = trapz([x(tmp),mu - rr * sd],yy) / sd;
patch(rrx,rry,'r')
tmp = find(x > mu + rr * sd);
rrx = [mu + rr * sd,mu + rr * sd,x(tmp),x(end)];
yy = npdf([mu + rr * sd,x(tmp)],mu,sd);
rry = [0,yy,0];
p = trapz([mu + rr * sd,x(tmp)],yy) / sd + p;
patch(rrx,rry,'r')
text(2 * sd + mu,0.35,['Red Area = ',num2str(p * 100,2),'%'],'fontsize',18)
maximize

%subfunction
function out = npdf(x,mu,sd)
out = 1 / (sqrt(2 * pi)) * exp(-(x - mu).^2 /( 2 * sd ^ 2));