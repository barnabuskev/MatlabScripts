function tsampdist
%function to show sampling dist of t
tdat = [];
for ia = 1:1000
    a = randn(30,1);
    b = randn(30,1);
    [tstat,df] = ttest(a,b);
    tdat = [tdat,tstat];
    [n,xout] = hist(tdat,round(sqrt(length(tdat))));
    bh = bar(xout,n,'barwidth',1);
    hold on
    plot(tstat,0,'ro','markerfacecolor','r','markersize',12);
    hold off
    set(gca,'xlim',[-5,5])
    title('t statistic when two populations are the same- sample of 30 each','fontsize',12,'fontweight','bold')
    xlabel('t statistic','fontsize',10,'fontweight','bold')
    ylabel('frequency','fontsize',10,'fontweight','bold')
    if ia == 1
        maximize
    end
    if ia < 5
        pause(2)
    elseif ia >= 5 && ia < 50
        pause(0.3)
    else
        pause(0.01)
    end
end
