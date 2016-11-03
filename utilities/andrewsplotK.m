function varargout = andrewsplotK(datmat,varargin)
%function to plot Andrews curve for data matrix datmat. If 2nd input is
%present, it must be a cell array of labels & it is assumed that the 1st
%col consists of integers indexing these labels
switch nargin
    case 1
        %do nowt
    case 2
        lcol = datmat(:,1);
        datmat = datmat(:,2:end);
    otherwise
        error('Wrong number of input arguments')
end
nobj = size(datmat,1);
nvar = size(datmat,2);
%time
N = 100;
t = linspace(-pi,pi,N)';
Adat = zeros(nobj,N);
%create harmonic matrix...
hrm = zeros(nvar,N);
%multiples of t
nm = ceil((nvar - 1) / 2);
mt = 1:nm;
tmat = (t * mt)';
%sin & cos parts
tmp = sin(tmat);
hrm(2:2:nm * 2,:) = tmp;
if rem(nvar,2)
    %if odd
    tmp = cos(tmat);
    nc = nm * 2;
else
    %if even
    tmp = cos(tmat(1:end - 1,:));
    nc = nm * 2 - 1;
end
hrm(3:2:nc,:) = tmp;

%first row
hrm(1,:) = ones(1,N) / sqrt(2);
Adat = datmat * hrm;
newplot
switch nargin
    case 1
        set(gca,'colororder',colormap(hot(nobj)),'nextplot','replacechildren','color','b')
        plot(t,Adat')
    case 2
        lbls = varargin{1};
        nl = length(lbls);
        cm = colormap(lines(nl));
        lns = {'-',':'};
        hndls = [];
        for ia = 1:nl
            lnsi = rem(ia,length(lns)) + 1;
            h = plot(t,Adat(lcol == ia,:)','color',cm(ia,:),'LineStyle',lns{lnsi});
            hndls = [hndls,h(1)];
            hold on
        end
        hold off
        legend(hndls,lbls)
end
axis tight
%output
switch nargout
    case 0
        %do nowt
    case 1
        varargout{1} = Adat;
    otherwise
        error('too many output arguments')
end