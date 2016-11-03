function data = plotscatter(n,x_mean,x_sd,scale,offset,r_squared)
%function to plot a scattergram of x against y with mean of x = x_mean,
%standard deviation of x = x_sd, systematic scale difference of y from x (y
%= scale * x) offset = what's added x to make y, r_squared = the relative
%proportion of y that is made up of x, the rest being random with mean_x &
%sd_x, n= number of data points. OK?
data(:,1) = (randn(n,1) * x_sd) + x_mean;
temp = (data(:,1) * scale) + offset;
data(:,2) = temp * r_squared + ((randn(n,1) * x_sd) + x_mean) * (1 - r_squared);
plot(data(:,1),data(:,2),'or')
set(gca,'fontsize',14)
