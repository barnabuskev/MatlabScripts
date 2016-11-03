function out = headneck
%function to take a cell array of data from digitisespheres.m and return
%another cell array with 4 columns. 1st col = file name, 2nd = nod: the
%angle of the line joining the nasion to the inion , 3rd = distance: the
%distance between the centre of the line joining the nasion and the inion,
%and the CT, 4th = protraction: the angle between the vertical and the line
%joining the CT and he centre of the line between the inion and nasion.
%Uses 'circfit.m' by Izhak bucher
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%BALL DIAMETER (cm)
bdiam = 4;
%get file of digitisesheres data
[fn,pn,fi] = uigetfile('*.mat',...
    'Select digitisespheres data','');
if fi == 0
    return
end
cd(pn)
%load data and extract first variable in file
tmp = load([pn,fn]);
fnms = fieldnames(tmp);
nfl = length(fnms);
if length(fnms) == 1
    in = tmp.(fnms{1});
else
    dnms = '';
    for ia = 1:nfl
        dnms = [dnms,' ',fnms{ia}];
    end
    error(['mat file contains more than one variable: ',dnms])
end
%number of rows (1 per image)
nrws = size(in,1);
out = cell(nrws,4);
for ia = 1:nrws
    %check that 2nd col is valid data
    circs = in{ia,2};
    if ~isa(circs,'double')
        msgbox(['Row ',num2str(ia),', 2nd column of input cell is not an array of doubles!'])
        pause(3)
        continue
    end
    [r,c] = size(circs);
    if r ~= 3 || c ~= 2
        msgbox(['Row ',num2str(ia),', 2nd column of input cell is the wrong size! [',num2str(r),' ',num2str(c),']'])
        pause(3)
        continue
    end
    %store file name
    out{ia,1} = in{ia,1};
    %determine order of circle centres
    [x,nasi] = min(circs(:,1));
    [x,cti] = max(circs(:,2));
    ini = setxor([1,2,3],[nasi,cti]);
    %get scaling factor to convert data to centimeters
    %get diameter of each ball
    pts_c = in{ia,3};
    d_obs = [];
    for ib = 1:length(pts_c)
        pts = pts_c{ib};
        [xc,yc,R,a] = circfit(pts(:,1),pts(:,2));
        d_obs = [d_obs,R * 2];
    end
    %mean diameter
    mdm = mean(d_obs);
    %scaling factor
    scl = bdiam / mdm;
    %calculate nod
    invec = circs(nasi,:) - circs(ini,:);
    out{ia,2} = 180 - atan2(-invec(2),invec(1)) * 180 / pi;
    %calculate distance
    midp = circs(ini,:) + invec / 2;
    out{ia,3} = norm(circs(ini,:)-midp) * scl;
    %calculate protraction
    civec = circs(ini,:) - circs(cti,:);
    out{ia,4} = atan2(-civec(2),civec(1)) * 180 / pi - 90; 
end
