function sbjcd = jenproject
%function to support Jen Spark's project on laterality
%initialise
noreps = 5;
rest = 15;
thinktm = 4;
incrms = 30;
%get subject code
sbjcd = inputdlg('Enter subject code');
sbjcd = sbjcd{1};
%select directory containing foot images
wdir = '/home/projects/Documents/UserFiles/Students/jsparks/';
fdir = uigetdir(wdir,'Get directory of foot images');
if fdir == 0
	disp('No directory selected')
	return
end
cd(fdir)
cd('..')
lst = dir(fdir)
filecell = {lst(~[lst.isdir]).name}
nfs = length(filecell);
%check correct number of files
if nfs > 28
	disp('too many image files')
	return
end
if nfs < 28
	disp('too few image files')
	return
end
%replicate and randomly permute file names
inx = repmat(1:nfs,1,noreps);
ngos = length(inx);
% do practice run...
input('Practice run. Press return when ready...  ');
rpm = randperm(ngos);
fcell = filecell(inx(rpm));
for ia = 1:4
    imfp = [fdir,filesep,fcell{ia}];
    I = imread(imfp);
    image(I);
    ud.time = 0;
    ud.rl = 'neither';
    set(gcf,'UserData',ud);
    set(gca,'XTick',[],'YTick',[]);
    title(['Trial number ',num2str(ia)])
    maxfig(gcf,1)
    drawnow
    tstrt = tic;
    set(gcf,'KeyPressFcn',{@khandlr,tstrt})
    uiwait(gcf,thinktm)
end
close(gcf)
% re-shuffle image order
rpm = randperm(ngos);
fcell = filecell(inx(rpm));
% create empty cell for results
ntrials = length(fcell);
rslts = {};
if length(unique(fcell)) ~= 28
	error('wrong number of file replicates - tell Kevin!')
end
input('Real run. Press return when ready... ');
% for each image trial...
for ia = 1:ntrials
    if (ia==71)
        delete(gcf);
        wait_h = waitbar(0,'Rest time...');
        for ib=1:incrms
            pause(rest/incrms);
            waitbar(ib/incrms,wait_h);
        end
        close(wait_h);
    end
    imfp = [fdir,filesep,fcell{ia}];
    I = imread(imfp);
    image(I);
    ud.time = 0;
    ud.rl = 'neither';
    set(gcf,'UserData',ud);
    set(gca,'XTick',[],'YTick',[]);
    title(['Trial number ',num2str(ia)])
    maxfig(gcf,1)
    drawnow
    tstrt = tic;
    set(gcf,'KeyPressFcn',{@khandlr,tstrt})
    uiwait(gcf,thinktm)
    ud = get(gcf,'UserData');
    if strcmp(ud.rl,'esc')
    	break
    end
    [tmp,fnm,tmp] = fileparts(fcell{ia});
    rslts{ia,1} = fnm;
    rslts{ia,3} = ud.rl;
    if strcmp(ud.rl,'neither')
        rslts{ia,2} = thinktm;
    else
        rslts{ia,2} = ud.time;
    end
end
close(gcf)
% sort results and save
rslts = sortrows(rslts,1);
save([pwd,filesep,sbjcd,'-',datestr(now,1)],'rslts')


function khandlr(src,data,ts)
% executes when key pressed
% return if wrong key
dc = double(data.Character);
if ~ismember(dc,[47,92,27])
    return
end
ud = get(src,'UserData');
ud.time = toc(ts);
switch dc
    case 47
        ud.rl = 'right';
    case 92
        ud.rl = 'left';
    case 27
    	ud.rl = 'esc';
end
set(src,'UserData',ud);
uiresume(src)

