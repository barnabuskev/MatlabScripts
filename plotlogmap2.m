function plotlogmap2(range,ign,plt,init,r)
%function to plot bifurcation plot of logistic map
%range = range of values of reproduction rate
%ign = ignore the first ign values
%plt = plot the next plt values
%init = initial size of population (between 0 & 1)
%r =  input reproduction rates
if max(r) > range(2) || min(r) < range(1)
    error('input r values outside range')
end
p = ones(1,length(r)) * init;
for ia = 1:ign
    p = iter(r,p);
end
%Y = [];
fs = 12;
for ia = 1:plt
    %Y = [Y;p];
    if exist('h1','var')
        delete(h1)
    end
    h1 = plot(r,p,'ro','MarkerSize',6,'MarkerFaceColor','r');
    title(['Population at Generation ',num2str(ia)],'FontSize',fs)
    if ia == 1
        xlabel('Reproduction Rate','FontSize',fs)
        ylabel('%age Maximum Population','FontSize',fs)
        axis tight
        set(gca,'ylim',[0,1])
        yl = str2num(get(gca,'YTickLabel'));
        set(gca,'YTickLabel',yl*100,'FontSize',fs);
        hold on
    end
    M(ia) = getframe(gcf);
    p = iter(r,p);
end
hold off
delete(gcf)
[fn,pn,fi] = uiputfile('*.avi','save movie');
if ~fi
    return
end
movie2avi([M(1),M],[pn,fn],'compression','none','fps',1.5)
%plot(r,Y,'k.','MarkerSize',0.5)

function out = iter(r,p)
%function to output one iteration of the logistic map model of population growth
out = r .* p .* (1.-p);