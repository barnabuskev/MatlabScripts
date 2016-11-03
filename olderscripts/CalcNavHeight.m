function CalcNavHeight(datin,reflngth)
%function to calculate navicular height from datin. datin should be a NX2
%cell with file names in first col, coords in second. reflngth is the
%length in desired units of reference line
if ~iscell(datin)
    error('Input must be a cell array')
end
[r,c] = size(datin);
if c ~= 2
    error('Input cell array must have 2 columns')
end
%output cell array
out = cell(r,c);
%coord conversion matrix
flp = [1,0;0,-1];
for ia = 1:r
    tmp = datin{ia,2};
    if ~isequal(size(tmp),[3,2])
        out(ia,2) = {'corrupt data'};
        continue
    end
    %convert from image to cartesian coords
    tmp = (flp * tmp')';
    %centre data to first point
    tmp = bsxfun(@minus, tmp, tmp(1,:));
%     %plot points
%     plot(tmp(:,1),tmp(:,2),'-+r')
%     text(tmp(1,1),tmp(1,2),'first')
%     axis equal
%     pause
    %get angle of ref line from horizontal
    thet = atan2(tmp(2,2),tmp(2,1)) * 180 / pi;
    %rotate points
    tmp = rot2D(tmp,-thet);
    %get & check angle of reference line
    chqh = acosd(tmp(2,:) * [tmp(2,1);0] / sum(tmp(2,:).^2));
    if chqh ~= 0
        disp(['reference line is not horizontal in file ',datin{ia,1},' (',num2str(chqh),')'])
        continue
    end
    %get length of ref line
    lngth = abs(tmp(2,1));
    %get height of navicular
    hgt = abs(tmp(3,2));
    %get length conversion factor
    cf = reflngth / lngth;
    %save nav height
    out(ia,2) = {hgt * cf};
end
%add file names
out(:,1) = datin(:,1);
writecsv(out)