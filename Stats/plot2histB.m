function plot2histB(a,b)
%another function to plot two histograms
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%plot first & change colour
hist(a)
hold on
hptch = findobj(gca,'Type','patch');
set(hptch,'FaceColor','r')
%plot next
hist(b)
hold off