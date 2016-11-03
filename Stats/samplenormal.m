function samplenormal(data,mu,sig)
%function to take some univariate data and draw a dot diagram and a
%histogram of the data starting from just the first data point &
%progressively including more data points & create a movie from it. mu and
%sig are the mean and standard deviation of the population
if ~isequal(min(size(data)),1)
    error('data must be vector or scalar')
end
xlim = [mu-sig*4,mu+sig*4];
len = length(data);
for n = 1:len
    if n<20
        plot(data(1:n),zeros(size(data(1:n))),'ro','MarkerFaceColor','r','MarkerSize',10);
        hold on
        plotnormal(mu,sig)
        hold off
    else
        [freq,binloc] = hist(data(1:n),15);
        intv=mean(abs(binloc(1:end-1)-binloc(2:end)));
        area = sum(freq)*intv;
        bar(binloc,freq/area,1);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','g');
        hold on
        plotnormal(mu,sig)
        hold off
    end
    set(gca,'XLim',xlim,'YLim',[0,0.4]);
    frames(n) = getframe(gcf);
end
[fn,pn,fi] = uiputfile('*.*','Save movie');
if fi
    movie2avi(frames,[pn,fn],'fps',5,'compression','none')
else
    return
end

