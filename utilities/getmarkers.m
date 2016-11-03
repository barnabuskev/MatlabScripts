function getmarkers(conf_strct,workdir)
% function to take batch of images with mixture of anatomical landmarks and
% hemispherical markers and returns coordinates of landmarks and
% hemispherical marker's centre.
% features:
% *inputs 'workdir': string containing directory for getting images & getting results
% *inputs 'conf_strct': structure with the following fields:
%   'markers': cell array of marker name and whether it is a landmark ('point') or a hemi (in order of marking)
%   'factors': NX3 cell array of (per row): 1- factor name, 2- reg exp for extracting
%   factor levels, 3- cell array of level names.
%   'subj_reg': string with regex expression for extracting subject code - empty string
%   if entered manually
% *Extracts subject code from filename and allows user to edit it based on code displayed
%   in image, if it is wrong.
% *Extracts level of factors from filename and allows user to edit it based on code displayed
%   in image, if it is wrong.
% *Guides user to mark landmarks/hemispheres in set order
% *left click - add point
% *right click - remove point
% *alt left click - centre image at click point and zoom in
% *alt right click - centre image at click point and zoom out
% *space - finish marking currnet set of points
% *Esc - abort marking current set of points
% *Creates and writes to text file each time return is pressed
% Dependencies:
%   newid.m - replacement of inputdlg.m from Matlab (allows return key to enter OK
%   plotpoints.m
%   imzoomer.m
%   xml2struct.m
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set uicontrol font sizes to larger size
set(0, 'DefaultUIControlFontSize', 9);
% get batch of images
cd(workdir)
fspec = {'*.jpg;*.png;*.jpeg;*.tiff','Images files';'*.*','All files'};
[ifn,pn] = getfiles(pwd,'Get image files to mark',fspec);
if pn == 0
    return
end
n_ims = length(ifn);
% get file name to store data
[ofn, opn, fi] = uiputfile('*.csv', 'Get file to store data');
if fi == 0
    return
end
% specify column headers
fctnames = conf_strct.factors(:,1)';
headcell = [{'subject'},fctnames,{'markername'},{'x'},{'y'},{'radius'}];
% write to file
fpointer = fullfile(opn,ofn); 
cell2csvK(fpointer,headcell)
for ia = 1:n_ims
    % for each image...
    fpth = fullfile(pn,ifn{ia});
    % load and display image
    im = imread(fpth);
    im_h = image(im);
    % prepare figure
    set(gcf,'toolbar','none','menubar','none')
    axis equal tight
    set(gca,'xtick',[],'ytick',[],'Position',[.05 .05 .9 .9])
    set(gcf,'name',ifn{ia},'NumberTitle','off')
    % make figure full screen
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    % get subject code...
    subj = getsubjfact(ifn{ia},conf_strct.subj_reg,'subj');
    % code for getting factor levels...
    % check if field 'factors' exist
    if isfield(conf_strct,'factors')
        % if factors are specified...
        nfacts = size(conf_strct.factors,1);
        levs = cell(1,nfacts);
        for ib = 1:nfacts
            % for each factor...
            levs{ib} = getsubjfact(ifn{ia},conf_strct.factors(ib,:),'factor');
        end
    end
    % For each marker, get coordinate(s)
    mcell = conf_strct.markers;
    % create empty cell to store data for image
    nmarkers = size(mcell,1);
    imcell = cell(nmarkers,length(headcell));
    for imk = 1:nmarkers
        % for each marker...
        % display marker to get
        msg_fh = msgbox(['Get ',mcell{imk,1},': ',mcell{imk,2}],'modal');
        pb_h = findobj(msg_fh,'style','pushbutton');
        pb_pos = get(pb_h,'position');
        % locate centre of pushbutton
        pb_c = pb_pos(1) + pb_pos(1)/2;
        txt_h = findobj(msg_fh, 'Type', 'Text' );
        set(txt_h,'fontsize',12,'position',[pb_c,31,0],'HorizontalAlignment','center')
        % obtaining points.....
        switch mcell{imk,2}
            case 'point'
                butt = 'No';
                while strcmp( butt,'No')
                    line_h = plotpoints(im_h,1);
                    butt = questdlg('Point ok?','Message','Yes','No','Yes');
                    if strcmp(butt,'No')
                        delete(line_h)
                    end
                end
                xmrk = get(line_h,'xdata');
                ymrk = get(line_h,'ydata');
                % write data to cell
                %[{'subject'},fctnames,{'markername'},{'x'},{'y'},{'radius'}]
                imcell(imk,:) = [{subj},levs,mcell(imk,1),{xmrk},{ymrk},{''}];
            case 'hemi'
                line_h = plotpoints(im_h,5);
                % extract point coords
                xd = get(line_h,'xdata');
                yd = get(line_h,'ydata');
                % fit circle & get radius and centre
                par = CircleFitByTaubin([xd;yd]');
                xmrk = par(1);
                ymrk = par(2);
                radius = par(3);
                % plot centre
                line(xmrk,ymrk,'marker','x','MarkerEdgeColor','green',...
                        'linestyle','none','MarkerSize',20);
                % write data to cell
                imcell(imk,:) = [{subj},levs,mcell(imk,1),{xmrk},{ymrk},{radius}];
        end
    end
    % save marker data
    cell2csvK(fpointer,imcell)
end
end

function lev = getsubjfact(filenm,reginfo,mode)
% function to get factor level or subject code from file name or from
% dialogue. filenm is file name, reginfo is either a 1X3 cell array with
% factor name, regular expression & cell array of level names, or string
% with subject regular expression, mode is either 'subj' subject mode or
% 'factor' factor mode. If 'reginfo' is an empty string, user is promted to
% supply subject code or factor level manually.
switch mode
    case 'subj'
        rexp = reginfo;
    case 'factor'
        fctnm = reginfo{1};
        rexp = reginfo{2};
        levnm = reginfo{3};
    otherwise
        error('Unrecognised mode in function getsubjfact')
end
if ~isempty(rexp)
    % if regex specified, extract subject code/level from file name and allow editing
    tokens = regexp(filenm,rexp,'tokens');
    switch length(tokens)
        case 0
            error('Regex string matched no token!')
        case 1
            lev = tokens{1}{1};
        otherwise
            error('Regex string matched >1 token!')
    end
    switch mode
        case 'subj'
            butt = questdlg(['Subject code is ',lev,'?'],'Check subject code','Yes','No','Yes');
            if isequal(butt,'No')
                % get correct code
                lev = newid('Enter correct subject code');
            end
        case 'factor'
            butt = questdlg(['Factor level for ',fctnm,' is ',lev,'?'],'Check factor level','Yes','No','Yes');
            if isequal(butt,'No')
                % get correct code
                levi = listdlg('PromptString',['Enter correct level for ',fctnm],'SelectionMode','single',...
                    'ListString',levnm, 'ListSize', [160,100]);
                lev = levnm{levi};
            end
    end
else
    % get subject code/level from image
    switch mode
        case 'subj'
            lev = newid('Enter subject code');
        case 'factor'
            levi = listdlg('PromptString',['Enter level for ',fctnm],'SelectionMode','single',...
                'ListString',levnm, 'ListSize', [160,100]);
            lev = levnm{levi};
    end
end
end

















