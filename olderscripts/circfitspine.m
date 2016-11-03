function rslt = circfitspine
% function to fit a circle to set of points from a spinal region of spine
% (lumbar or thoracic) and calculate the Cobb angle between the top and
% bottom point
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get batch of files
[fn,pn,fi] = uigetfile('*.csv','Get coordinate files','/home/kevin/Documents/Work/BSO/Students/Bethan/bethanpilot','MultiSelect','on');
if ~fi
    return
end
cd(pn)
cllflg = true;
rslt = {};
for ia = 1:length(fn)
    %get points
    if iscell(fn)
        pts = csvread([pn,fn{ia}]);
    else
        pts = csvread([pn,fn]);
        cllflg = false;
    end
    %convert to Cartesian coords
    pts(:,2) = -pts(:,2);
    %fit circle
    prms = CircleFitByTaubin(pts);
    %calculate Cobb angle
    [tmp,mx] = max(pts(:,2));
    [tmp,mn] = min(pts(:,2));
    top = pts(mx,:);
    bot = pts(mn,:);
    %center to orig @ center circ
    topc = top - [prms(1),prms(2)];
    botc = bot - [prms(1),prms(2)];
    dtp = topc * botc';
    ang = acos(dtp / (norm(topc) * norm(botc))) * 180 / pi;
    %plot result
    plot(pts(:,1),pts(:,2),'r+','markersize',12);
    hold on
    plot(prms(1),prms(2),'g*','markersize',12);
    circle(prms(1:2),prms(3),100,'--');
    gon = [top;prms(1),prms(2);bot];
    plot(gon(:,1),gon(:,2),'r-')
    hold off
    axis equal
    text(prms(1)+20,prms(2)+20,num2str(ang))
    if ~cllflg
        rslt = {fn,ang};
        title(fn)
        break
    else
        rslt = [rslt;{fn{ia},ang}]; %#ok<AGROW>
        title(fn{ia})
    end
    pause
end
writecsv(rslt);
