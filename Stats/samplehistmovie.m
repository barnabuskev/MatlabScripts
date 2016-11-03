function samplehistmovie(mu,sig)
%function to create a movie of sampling from a population with mean mu and
%standard deviation sig
data = (randn(25,50) * sig) + mu;
xlim = [mu-sig*4,mu+sig*4]
for i = 1:size(data,2)
    hist(data(:,i));
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','g')
    set(gca,'XLim',xlim)
    hold on
    text(mean(data(:,i)),0,'\downarrow','color','red','VerticalAlignment','bottom','FontSize',20);
    hold off
    frames(i) = getframe(gcf);
end
mean(mean(data))
[fn,pn,fi] = uiputfile('*.*','Save movie');
if fi
    movie2avi(frames,[pn,fn],'fps',1.5,'compression','none')
else
    return
end
    