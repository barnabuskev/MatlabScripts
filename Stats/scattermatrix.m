function varargout = scattermatrix(datmat,labs,tit)
%function to plot a scatter matrix of input data matrix datmat. Plots a
%histogram on the diagonal. labs is a cell array of variable names & tit is
%the title of the scatter matrix. labs must have same length as data
%dimension
p = size(datmat,2);
if length(labs) ~= p
    error('labels must have same length as data dimension')
end
for ia = 1:p
    %rows
    for ib = 1:p
        %cols
        subplot(p,p,(ia - 1) * p + ib)
        if ia == ib
            hist(datmat(:,ia))
        else
            plot(datmat(:,ib),datmat(:,ia),'k.')
        end
        set(gca,'xtick',[],'ytick',[])
        if ib == 1
            ylabel(labs{ia},'FontSize',12,'fontweight','bold')
        end
        if ia == 1
            title(labs{ib},'FontSize',12,'fontweight','bold')
        end
    end
end
axes('Position',[0 0 1 1],'Visible','off');
text(0.5,0.97,tit,'FontSize',14,'fontweight','bold')
switch nargout
    case 0
        %do nowt
    case 1
        varargout{1} = gcf;
    otherwise
        error('wrong number of output args')
end
