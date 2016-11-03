function dat = genbivar(n,ang,fact,mux,muy,sigx,sigy)
%function to generate bivariate data. n is number of subjects, ang is the
%rotation. Use 45 to produce a pos correlation, -45 a neg correlation. fact
%is the ratio of the first principle component to the 2nd PC.sigx is the
%standard deviation of the x-axis variable, mux is the mean of the x-axis
%variable, same for y.
ang = -ang * pi / 180;
rot = [cos(ang),sin(ang);-sin(ang),cos(ang)];
dat(:,1) = randn(n,1);
dat(:,2) = randn(n,1) / fact;
m1 = mean(dat(:,1));
m2 = mean(dat(:,2));
dat(:,1) = dat(:,1) - m1;
dat(:,2) = dat(:,2) - m2;
dat = (rot * dat')';
%rescale * relocate data
m = mean(dat(:,1));
s = std(dat(:,1));
dat(:,1) = (dat(:,1) - m) / s;
dat(:,1) = dat(:,1) * sigx + mux;
m = mean(dat(:,2));
s = std(dat(:,2));
dat(:,2) = (dat(:,2) - m) / s;
dat(:,2) = dat(:,2) * sigy + muy;
plot(dat(:,1),dat(:,2),'ro')
