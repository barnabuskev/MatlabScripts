function plotlogmap3(range,ign,plt,init,divs)
%function to plot bifurcation plot of logistic map
%range = range of values of reproduction rate
%ign = ignore the first ign values
%plt = plot the next plt values
%init = initial size of population (between 0 & 1)
%divs = number of subdivisions of range
inc = (range(2) - range(1))/divs;
r = range(1):inc:range(2);
p = ones(1,length(r)) * init;
for ia = 1:ign
    p = iter(r,p);
end
Y = [];
for ia = 1:plt
    Y = [Y;p];
    p = iter(r,p);
end

fs = 12;
plot(r,Y,'k.','MarkerSize',1)
xlabel('Reproduction Rate','FontSize',fs,'fontname','ariel','fontweight','bold')
ylabel('%age Maximum Population','FontSize',fs,'fontname','ariel','fontweight','bold')
%title('Bifurcation Diagram','FontSize',fs,'fontname','ariel','fontweight','bold')
axis tight
set(gca,'ylim',[0,1],'color',[1,1,1])
yl = str2num(get(gca,'YTickLabel'));
set(gca,'YTickLabel',yl*100,'FontSize',fs,'fontname','ariel');

function out = iter(r,p)
%function to output one iteration of the logistic map model of population growth
out = r .* p .* (1.-p);