function collateHB
% function to collate ECG and subject heartbeat counts data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% When ECG traces are displayed the QRS annotation can be edited:
% scroll trace right and left: right and left arrow keys
% zoom in: up arrow key
% zoom out: down arrow key
% remove an annotation: press minus key and then right-click and drag rubber box over annotation to remove it
% add an annotation: press + key and then click on annotation to add it
% accept annotations: Return key

% initialise directory pointers
subjdir = '/home/projects/Documents/UserFiles/Students/HeartBeatCount';
edfdir = '/home/projects/Documents/VirtualBoxShared';
cd(subjdir)
% get subject time data
[tmp,sbjpn,fi] = uigetfile('*.mat','Get batch of subject heart count data files','MultiSelect','on');
if fi == 0
    sprintf('%s','No files chosen! Quitting ''collateHB''')
    return
end
% initialisation
zoom = 2;
pans = 0.5;
meth = 1; %qrs detection method (see qrsdetect.m documentation)
ntints = 4;
% if only one file, put it into a cell array
if ~iscell(tmp)
	sfn{1} = tmp;
else
	sfn = tmp;
end
% get ECG data
cd(edfdir)
[efn,edfpn,fi] = uigetfile('*.edf','Get ECG data file');
if fi == 0
    sprintf('%s','No file chosen! Quitting ''collateHB''')
    return
end
% read EDF file
[hdr,rec] = edfread([edfpn,filesep,efn]);
% get file date from startdate
recdate = hdr.startdate;
disp(['Date of EDF file is ',recdate])
% get start time
rectime = hdr.starttime;
% convert edf date/time into matlab time vector
edfstime = datevec([recdate,'.',rectime],'dd.mm.yy.HH.MM.SS');
% read ECG signal
wchrec = strcmp('ECG0',hdr.label);
ecg = rec(wchrec,:);
% get sample rate
sr = hdr.samples(1);
% create cell array for results
collatedat = cell(length(sfn)*ntints,4);
for ia = 1:length(sfn)
    % for each subject hearbeat file...
    fname = sfn{ia};
    % get subject code
    tmp = regexp(fname,'^[0-9]{3}[a-z,A-Z]','match');
    code = tmp{1};
    % load time data 
    dat = load([sbjpn,fname]);
    dat = dat.subjdat;
    if size(dat,1) ~= ntints
    	error('Number of time intervals known to collateHB does not equal number of time intervals in file')
    end
    for ib = 1:size(dat,1)
    	% for each section of ECG...
    	strts = dat{ib,1};
    	% get difference in secs between edf start & subj time start
    	dffs = etime(strts,edfstime);
    	% estimate number of samples elapsed from edf start
    	strsmp = dffs*sr;
    	ends = dat{ib,2};
    	% get difference in secs between edf start & subj time end
    	dffe = etime(ends,edfstime);
    	% check if on same day
    	if dffe > 24*3600
    		error('Timing did not occur on the same day!')
    	end
    	% estimate number of samples elapsed from edf start
    	endsmp = dffe * sr;
    	% get section of ecg
    	datchk = ecg(floor(strsmp):ceil(endsmp));
    	nsmp = length(datchk);
    	% detect qrs'
    	qhdr = qrsdetect(datchk',sr,meth);
    	qrs = qhdr.EVENT.POS;
    	plot((0:(nsmp-1))./sr,datchk);
    	xlabel(['time in secs, starting at ',datestr(strts)]);
    	% set y position of QRS markers
    	qrsypos = max(datchk)/2;
    	lh = line(qrs./sr,ones(size(qrs))*qrsypos,'LineStyle','none','marker','d','color','r','MarkerSize',12);
    	axis tight;
    	title(['Subject ',code]);
    	maxfig(gcf,1);
    	% chose to edit QRS events or not...
    	while true
    		btn = waitforbuttonpress;
    		if btn == 0
    			% mouse pressed - skip rest of loop
    			continue
    		end
    		kpr = double(get(gcf,'CurrentCharacter'));
    		switch kpr
    			case 13 %return pressed
    				break
    			case 45 %_/- key pressed - remove QRS
    				while true
						btn = waitforbuttonpress;
						if btn == 1
							% key pressed - skip rest of loop
							continue
						end
						point1 = get(gca,'CurrentPoint');
						finalRect = rbbox;
						point2 = get(gca,'CurrentPoint');
						xmax = max(point1(1,1),point2(1,1));
						xmin = min(point1(1,1),point2(1,1));
						xdat = get(lh,'xdata');
						ydat = get(lh,'ydata');
						lessx = xdat < xmin;
						morex = xdat > xmax;
						tmp = [xdat(lessx),xdat(morex)];
						set(lh,'xdata',tmp);
						tmp = [ydat(lessx),ydat(morex)];
						set(lh,'ydata',tmp);
						break
    				end
    			case 61 %+/= key pressed add QRS
    				while true
						btn = waitforbuttonpress;
						if btn == 1
							% key pressed - skip rest of loop
							continue
						end
						point1 = get(gca,'CurrentPoint');
						xpnt = point1(1,1);
						xdat = get(lh,'xdata');
						ydat = get(lh,'ydata');
						lessx = xdat < xpnt;
						morex = xdat > xpnt;
						tmp = [xdat(lessx),xpnt,xdat(morex)];
						set(lh,'xdata',tmp);
						tmp = [ydat(lessx),qrsypos,ydat(morex)];
						set(lh,'ydata',tmp);
						break
    				end
    			case 28 %left arrow pressed
					oldlim = xlim;
					rng = oldlim(2) - oldlim(1);
					chnk = rng * pans;
					if oldlim(1)-chnk < min(get(lh,'xdata'))
						chnk = oldlim(1) - min(get(lh,'xdata'));
					end
					xlim(oldlim - chnk);
    			case 29 %right arrow pressed
					oldlim = xlim;
					rng = oldlim(2) - oldlim(1);
					chnk = rng * pans;
					if oldlim(2)+chnk > max(get(lh,'xdata'))
						chnk = max(get(lh,'xdata')) - oldlim(2);
					end
					xlim(oldlim + chnk);
    			case 30 %up arrow pressed
					oldlim = xlim;
					rng = oldlim(2) - oldlim(1);
					midpnt = oldlim(1) + rng / 2;
					newrng = rng / zoom;
					newxlimmax = midpnt + newrng / 2;
					newxlimmin = midpnt - newrng / 2;
					xlim([newxlimmin,newxlimmax]);
    			case 31 %down arrow pressed
					oldlim = xlim;
					rng = oldlim(2) - oldlim(1);
					midpnt = oldlim(1) + rng / 2;
					newrng = rng * zoom;
					newxlimmax = midpnt + newrng / 2;
					% if above max, make = max
					newxlimmax = min(max(get(lh,'xdata')),newxlimmax);
					newxlimmin = midpnt - newrng / 2;
					% if below min, make = min
					newxlimmin = max(min(get(lh,'xdata')),newxlimmin);
					xlim([newxlimmin,newxlimmax]);
    		end
    	end
    	% end of ecg trace edit - save row of data
    	collatedat{(ia-1)*ntints+ib,1} = ['"',code,'"'];
    	collatedat{(ia-1)*ntints+ib,2} = dat{ib,3};
    	collatedat{(ia-1)*ntints+ib,3} = dat{ib,4};
    	collatedat{(ia-1)*ntints+ib,4} = length(get(lh,'xdata'));
	end
	% end of a subject file
end
% end of all subject files
close(gcf)
% reformat data to one subject per line
collatedat = widedat(collatedat,1,ntints)
% add header row
hdrrw = {'subj','interval1','subj_est1','actual1','interval2','subj_est2','actual2','interval3','subj_est3','actual3','interval4','subj_est4','actual4'};
collatedat = [hdrrw;collatedat];
% save to CSV
writecsv(collatedat,[sbjpn,filesep,'Collatedat',recdate,'.csv'])


function out = widedat(in,widevari,nrow)
% function to take cell array 'in' and reformat so that all the data for each level of string variable is on one row...
% nrow is the number of rows per level of variable indexed by widevari
% subset according to widevari
levs = unique(in(:,widevari));
nlevs = length(levs);
% check sizes
if size(in,1) / nlevs ~= nrow
	error('Number of rows per level of widevar doesn''t match nrow')
end
% get other data (not indexed by widevari)
ncol = size(in,2);
odati = setdiff(1:ncol,widevari);
% create output cell
out = cell(nlevs,length(odati)*nrow+1);
for ia = 1:nlevs
	tmp = strcmp(levs{ia},in(:,widevari));
	subsi = find(tmp);
	subs = in(subsi,odati);
	% reformat into one row
	subs = subs';
	out(ia,2:end) = {subs{:}};
	out{ia,1} = levs{ia};
end


















