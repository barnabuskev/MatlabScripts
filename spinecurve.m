function spinecurve
% function to take batch of images with hemispherical markers to obtain set
% of coordinates of the centre of the hemispheres, the cobb angle and the
% set of radii of the spheres.
% space:            finish present hemisphere, or start next hemisphere
% return (enter):   Go to next image
% alt:              hold to zoom, let go to resume marking hemisphere
% Esc:              abort current hemisphere

[fn,pn] = getfiles(pwd,'Get Images with hemispherical markers','*.*');
markdat = struct([]);
for ia = 1:length(fn)
    % get data for each subject
    tmpdat = markhemis([pn,fn{ia}]);
    % fit circle
    tmpdat.cent = tmpdat.cent';
    par = CircleFitByTaubin(tmpdat.cent);
    % obtain Cobb angle..
    % get x & y coords of centre of Tsp curve
    tspcent_x = par(1);
    tspcent_y = par(2);
    %tsp_rad = par(3);
    % get upper and lower hemisphere centre
    tmpdat.cent = sortrows(tmpdat.cent,2);
    top = tmpdat.cent(1,:);
    bot = tmpdat.cent(end,:);
    % get vectors from centre to top and bottom
    topv = top - [tspcent_x,tspcent_y];
    botv = bot - [tspcent_x,tspcent_y];
    % work out angle via dot product
    tmpdat.cobb = acos((topv * botv')/(norm(topv) * norm(botv)))*180/pi;
    % save data
    markdat = [markdat,tmpdat]; %#ok<*AGROW>
end
% save data to file..
[fn,pn,fi] = uiputfile('*.mat','Save raw Matlab data');
if fi == 0
    msgbox('Raw data not saved')
else
    save([pn,fn],'markdat')
end
% save spreadsheet data...
% create cell array
nimg = length(markdat);
csvdat = cell(nimg,2);
for ia = 1:nimg
    csvdat{ia,1} = markdat(ia).subjcode;
    csvdat{ia,2} = markdat(ia).cobb;
end
csvdat = [{'code','cobb'};csvdat];
% get file to save
[fn,pn,fi] = uiputfile('*.csv','Save spreadsheet data');
if fi == 0
    msgbox('spreadsheet data not saved')
else
    cell2csv([pn,fn],csvdat)
end
end




















