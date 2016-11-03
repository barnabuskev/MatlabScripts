function collateEMG
% function to take mat files obtained from EMGtimer and EDF files from the
% Actiwave EMG and get specified EMG traces. Saves data as a CSV file
[fn,pn] = uigetfile('*.mat','Get mat files from EMGtimer','MultiSelect','on');
switch class(fn)
    case 'double'
        % no file selected
        disp('No file selected')
        return
    case 'char'
        fn = {fn};
        % single file selected
    case 'cell'
        % >1 file selected - do nothing
end
cd(pn)
% get log file file name
[logfn,logpn,fi] = uiputfile('*.txt','Select log file');
if fi == 0
    disp('No log file chosen')
end
datout = {'subject','muscle','breath','RMS'};
for ia = 1:length(fn)
    % for each mat file from EMGtimer
    tmp = load(fn{ia});
    fldnm = fieldnames(tmp);
    assert(length(fldnm) == 1,'fldnm should have length = 1')
    dat = tmp.(fldnm{1});
    % get corresdponding EDF file
    [efn,epn,fi] = uigetfile('*.edf',['Get EDF file for session ',dat.session]);
    if fi == 0
        disp('No EDF file chosen')
        continue
    end
    % load EDF file
    [hdr, record] = edfread([epn,filesep,efn]);
    % check that the mat file times are within the EDF file time limits
    % get mat file min and max times
    matstrt = datenum(dat.EMGtrace(1).start);
    nslice = length(dat.EMGtrace);
    matend = datenum(dat.EMGtrace(nslice).start);
    % get EDF file start and end
    edfstrt = datenum([hdr.startdate,' ',hdr.starttime],'dd.mm.yy HH.MM.SS');
    edftlength = hdr.records * hdr.duration;
    edfend = addtodate(edfstrt,edftlength,'second');
    % check if mat times correspond to edf times
    if (edfstrt-matstrt > 0 || edfend-matend < 0)
        beep
        disp('EMGtimer times are not within EDF file start and end times!')
        disp(['EDF file: ',efn])
        disp(['EMGtimer file: ',fn{ia}])
        disp('Press any key to continue')
        pause
        continue
    end
    % get & write stuff to log file
    logfpnt = fopen([logpn,filesep,logfn],'a');
    fprintf(logfpnt,'%s: %s\n','EDF file',efn);
    fprintf(logfpnt,'%s: %s\n','EMGtimer file',fn{ia});
    fprintf(logfpnt,'%s: %s\n','EDF start time',datestr(edfstrt));
    fprintf(logfpnt,'%s: %s\n','EDF end time',datestr(edfend));
    sr = hdr.samples(1)/hdr.duration;
    fprintf(logfpnt,'%s: %d\n','Sample rate',sr);
    fprintf(logfpnt,'%s: %s\n','Filters',hdr.prefilter{1});
    fprintf(logfpnt,'%s: [%d,%d] %s\n\n\n','Voltage range',hdr.physicalMin(1),hdr.physicalMax(1),hdr.units{1});
    fclose(logfpnt);
    % plot all data and start/stop times
    % plot difference if two channels, one otherwise
    edftsecs = etime(datevec(edfend),datevec(edfstrt));
    time = 0:1/sr:edftsecs;
    assert(hdr.ns == 2 || hdr.ns == 3,'Must be two or three channels')
    if hdr.ns == 2
        ts = timeseries(record(1,:),time(2:end));
        ts.Name = ['EMG trace for ',efn,' - single channel'];
    else
        ts = timeseries(record(1,:)- record(2,:),time(2:end));
        ts.Name = ['EMG trace for ',efn,' - difference between two channels'];
    end
    ts.DataInfo.Unit = 'seconds';
    % plot rectangles around intervals of interest
    plot(ts)
    ylabel('Muscle potential (uV)')
    ylims = get(gca,'ylim');
    h = abs(diff(ylims))*0.3;
    y = -h/2;
    for ib=1:nslice
        x = etime(dat.EMGtrace(ib).start,datevec(edfstrt));
        w = abs(etime(dat.EMGtrace(ib).start,dat.EMGtrace(ib).stop));
        rectangle('Position',[x,y,w,h]);
    end
    input('press Enter to continue')
    % calculate RMS of each segment and save data.
    for ib=1:nslice
        t1 = etime(dat.EMGtrace(ib).start,datevec(edfstrt));
        ind1 = find(ts.time<t1,1,'last');
        t2 = etime(dat.EMGtrace(ib).stop,datevec(edfstrt));
        ind2 = find(ts.time<t2,1,'last');
        datseg = squeeze(getdatasamples(ts,ind1-1000:ind2+1000));
        datout = [datout;{dat.EMGtrace(ib).subject,dat.EMGtrace(ib).muscle,dat.EMGtrace(ib).breath,sqrt(mean(datseg.^2))}]; %#ok<*AGROW>
    end
end
% fix level name for muscle to shorten and remove space
datout(:,2) = cellfun(@(x) strrep(x,'External oblique','int_oblq'),datout(:,2),'UniformOutput',false);
% get CSV output file name
[datfn,datpn,fi] = uiputfile('*.csv','Select file for data output');
if fi == 0
    disp('No data output file chosen')
    return
end
cell2csv([datpn,filesep,datfn],datout)
%varargout{1} = datout;























