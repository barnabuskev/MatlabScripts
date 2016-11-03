function varargout = splitdatcycles(dat,spltsx)
%function to input a data matrix 'dat' in which each row is time point and
%each col is a variable. Outputs a 3D array containing data matrices of
%data split into cycles. 'spltsx' is a vector of row indices indicating
%cycle boundaries. Resamples using splines to a user defined number of
%sample points. If no output specified, file save prompt
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get mean no of data points between boundaries, rounded
npts = round(mean(diff(spltsx)));
%get user to input samples per cycle giving npts as default
tmp = inputdlg('Enter samples per cycle','splitdatcycle',1,{num2str(npts)});
spc = str2double(tmp{1});
%fit spline to data...
%create resampling grid
rsmgrid = [];
nc = length(spltsx) - 1;
for i = 1:nc
    a = spltsx(i);
    b = spltsx(i+1);
    chunk = a:(b-a)/spc:b;
    rsmgrid = [rsmgrid(1:end-1),chunk];
end
ind = spltsx(1):spltsx(end);
%resample all coordinates at once producing matrix of resampled coordinates
yy = (spline(ind,dat(ind,:)',rsmgrid))';
%plot data and spline interpolation
plot(dat,'.g')
hold on
plot(rsmgrid,yy,'r+')
ylm = get(gca,'ylim');
for ia = 1:length(spltsx)
    line([spltsx(ia),spltsx(ia)],ylm)
end
hold off
nvar = size(dat,2);
out = zeros(spc,nvar,nc);
for ia = 1:nc
    %create vector of x-axis points that represent one cycle
    ind = ((ia - 1) * spc + 1):(ia * spc);
    out(:,:,ia) = yy(ind,:);
end
switch nargout
    case 0
        uisave(out)
    case 1
        varargout{1} = out;
    otherwise
        error('Too many output variables')
end





function delpeak(src,eventdata,pkh,ah)
%function to find nearest peak & delete it
%get position of mouse click
tmp = get(ah,'CurrentPoint');
cp = tmp(1,1:2);
%get peak data
pks = [get(pkh,'xdata')',get(pkh,'ydata')'];
%get vectors from click in data units
frmc = bsxfun(@minus,pks,cp);
%convert to pixels
asz = getpixelposition(ah);
xl = get(ah,'xlim');
yl = get(ah,'ylim');
xfct = asz(3) / (xl(2) - xl(1));
yfct = asz(4) / (yl(2) - yl(1));
frmc(:,1) = frmc(:,1) * xfct;
frmc(:,2) = frmc(:,2) * yfct;
%calculate distances
d = sqrt(sum(frmc.^2,2));
[md,mi] = min(d);
%delete if less than 5 pixels away
if md < 5
    kp = setxor(1:size(pks,1),mi);
    set(pkh,'xdata',pks(kp,1))
    set(pkh,'ydata',pks(kp,2))
end




function peaks = getpeaks(PC1,peakthresh)
%another algorithm to split cycles, this time based on a peakscore -
%distance in frames from the first frame with a higher eigenvalue
%get an array of peakscores for each frame
lf = length(PC1);
ff = 1;
peakscore = zeros((lf - ff + 1),2);
cnt = 1;
for f = ff:lf
    %initialise
    left = f;
    right = f;
    score = 0;
    while 1
        if left > ff
            left = left - 1;
        end
        if right < lf
            right = right + 1;
        end
        [m,i] = max([PC1(f),PC1(right),PC1(left)]);
        if i == 1
            score = max(right - f,f - left);
        else
            break
        end
        if left == ff && right == lf
            break
        end
    end
    peakscore(cnt,:) = [f,score];
    cnt = cnt + 1;
end
%record peaks
peaks = peakscore(find(peakscore(:,2) > peakthresh),1);

