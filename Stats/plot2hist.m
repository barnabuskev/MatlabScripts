function plot2hist(a,b)
%function to plot 2 histograms
ha = subplot(2,1,1);
hist(a)
hold on
plot(mean(a),0,'g+','MarkerSize',14)
hold off
hb = subplot(2,1,2);
hist(b)
hold on
plot(mean(b),0,'g+','MarkerSize',14)
hold off
hptch = findobj(gca,'Type','patch');
set(hptch,'FaceColor','r')
xlima = get(ha,'xlim');
xlimb = get(hb,'xlim');
newlim = [min([xlima(1),xlimb(1)]),max([xlima(2),xlimb(2)])];
set(ha,'xlim',newlim)
set(hb,'xlim',newlim)
ylima = get(ha,'ylim');
ylimb = get(hb,'ylim');
newlim = [0,max([ylima(2),ylimb(2)])];
set(ha,'ylim',newlim)
set(hb,'ylim',newlim)