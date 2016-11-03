function plotlogmapfixr(r,ign,plt,p)
%plot logistic map for a single value of reproduction rate
%p = initial population, ign = number of iterations to ignore, plt = number
%to plot, r = reproduction rate.
for ia = 1:ign
    p = iter(r,p);
end
Y = [];
wb = waitbar(0,'Please wait...');
for ia = 1:plt
    Y = [Y;p];
    p = iter(r,p);
    waitbar(ia/plt,wb)
end
delete(wb)
plot(Y,'ko','MarkerSize',2)
axis tight
set(gca,'ylim',[0,1],'color',[1,1,1])


function out = iter(r,p)
%function to output one iteration of the logistic map model of population growth
out = r .* p .* (1.-p);