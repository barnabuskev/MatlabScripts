function getheartcount
% intialise...
% set vector of measurement times
meas_times = [25,35,45];
% set initial practice time
pract_time = 15;
% initialise directories
HRdir = '/home/projects/Desktop/Link to Students/HeartBeatCount';
wavdir = '/home/projects/Documents/UserFiles/utilities';
% navigate to data HeartBeatCount directory

dpth = uigetdir(HRdir,'Go to Data directory');
if dpth == 0
    %user has cancelled
    return
end
passdat.fastrate = 10;
% !!SPEED UP FOR TESTING!! set to 'true' to speed up
passdat.testing = false;
% passdat.testing = true;
if passdat.testing
    disp('High speed for testing')
else
    disp('Normal speed')
end
cd(dpth)
strtsnd = wavread([wavdir,filesep,'strtsnd.wav']);
strtsnd = strtsnd(1:round(length(strtsnd)/3));
endsnd = wavread([wavdir,filesep,'endsnd.wav']);
endsnd = endsnd(1:round(length(endsnd)/2));
% set first time flag
first_time = true;
% specify grey colour
grey = [0.5,0.5,0.5];
passdat.grey = grey;
% set exitflag to 'false'
exitflag = false;
% set abort subject flag to false
subjabrt = false;
% keep entering subject codes & data until user cancels/exits...
while ~exitflag
    % get next subject code
    getcodef = true;
    while getcodef
        %keep prompting for next subject code until correct format or user
        %cancels
        if first_time
            sprmt = 'Enter Subject ID or exit';
        else
            sprmt = 'Enter Next Subject ID or exit';
        end
        sans = inputdlg(sprmt);
        if isempty(sans)
            %user has cancelled - exit getheartcount
            exitflag = true;
            getcodef = false;
        else
            %check if input matches desired form (here 4 letters)
            tst = regexp(sans,'^[0-9]{3}[a-z,A-Z]$', 'once');
            if isempty(tst{1})
                wmsg = msgbox('subject ID must be 3 integers followed by a letter','Wrong subject code','warn');
                uiwait(wmsg)
            else
                %if yes, store ID, exit loop
                subjid = sans{1};
                getcodef = false;
                first_time = false;
            end
        end
    end
    if exitflag
        break
    end
    % create cell array for subject data
    subjdat = cell(length(meas_times)+1,4);
    % get subject data...
    % get random permutation of times (except 1st time)
    rprm = randperm(length(meas_times));
    HBtimes = [pract_time,meas_times(rprm)];
    if passdat.testing
        HBtimes = HBtimes / passdat.fastrate;
    end
    for ia = 1:length(HBtimes)
        % repeat series of times for heartbeat count
        % open dialogue
        counts_h = getcounts;
        % set properties of callbacks
        set(counts_h,'tag','getcounts_fig');
        set(counts_h,'busyaction','cancel');
        set(counts_h,'Interruptible','off');
        % setup callback functions
        set(counts_h,'CloseRequestFcn',@clsreq);
        set(counts_h,'KeyPressFcn',{@kpspcfcn,HBtimes(ia),strtsnd,endsnd});
        % grey-out text entry text
        enterhb_txt_h = findobj(counts_h,'tag','enterhb_txt');
        set(enterhb_txt_h,'ForegroundColor',grey);
        % disable text entry box & remove any entries in the text entry box
        enterhb_edit_h = findobj(counts_h,'tag','enterhb_edit');
        set(enterhb_edit_h,'enable','inactive');
        set(enterhb_edit_h,'string','')
        %un-grey out the start message
        start_txt_h = findobj(counts_h,'tag','start_txt');
        set(start_txt_h,'ForegroundColor','k');
        % store userdata
        passdat.subjabrt = subjabrt;
        set(counts_h,'UserData',passdat);
        % wait
        uiwait(counts_h);
        % recover userdata
        passdat = get(counts_h,'UserData');
        % if subject abort flag set, break from loop
        subjabrt = passdat.subjabrt;
        if subjabrt
            disp(['Subject ',subjid,' aborted']);
            delete(counts_h);
            break
        else
            %store row of data
            subjdat{ia,1} = passdat.start_t;
            subjdat{ia,2} = passdat.end_t;
            subjdat{ia,3} = getsecs(passdat.end_t - passdat.start_t);
            subjdat{ia,4} = passdat.count;
        end
    end %end of loop through HBtimes
    if ~subjabrt % if subject hasn't aborted
        %write data to file
        % open file for saving data, append date to file name
        tmp = clock;
        date = [num2str(tmp(3)),'_',num2str(tmp(2)),'_',num2str(tmp(1))];
        fname = [dpth,filesep,subjid,'_',date,'.csv'];
        [fid, message] = fopen(fname,'w');
        if fid == -1
            % file could not be saved
            errordlg(message)
            break
        end
        fprintf(fid,'start_time,end_time,difference,count\n');
        for ib=1:size(subjdat,1)
            strt = datestr(subjdat{ib,1},13);
            endt = datestr(subjdat{ib,2},13);
            fprintf(fid,[strt,',',endt,',','%.3f,%d\n'],[subjdat{ib,3},subjdat{ib,4}]);
        end
        fclose(fid);
        save([dpth,filesep,subjid,'_',date],'subjdat')
    end
    try
        delete(counts_h);
    catch %#ok<*CTCH>
        % do nothing - figure already closed
    end
end
end

function clsreq(src,evnt)
% executed when user tries to close the data input figure
if ~strcmp(get(src,'tag'),'getcounts_fig')
    delete(get(0,'CurrentFigure'))
    disp('closerec called')
end
% set exit flag
passdat = get(src,'UserData');
passdat.subjabrt = true;
set(src,'UserData',passdat);
% resume fig
uiresume(src);
end


function kpspcfcn(src,eventdata,varargin)
% executes when user presses a key
% return if not spacebar
if ~strcmp(eventdata.Key,'space')
    return
end
HBtime = varargin{1};
strtsnd = varargin{2};
endsnd = varargin{3};
%get userdata
passdat = get(src,'UserData');
% grey out the start message
start_txt_h = findobj(src,'tag','start_txt');
set(start_txt_h,'ForegroundColor',passdat.grey);
% pause for between 4 and 8 secs
offset_t = rand(1) * 4 + 4;
%go faster if testing
if passdat.testing
    offset_t = offset_t / passdat.fastrate;
end
pause(offset_t)
% start sound
sound(strtsnd,22050)
% record start time
passdat.start_t = clock;
% pause for random interval
pause(HBtime)
% record end time
passdat.end_t = clock;
% end sound
sound(endsnd,22050)
% un-grey-out text entry text
enterhb_txt_h = findobj(src,'tag','enterhb_txt');
set(enterhb_txt_h,'ForegroundColor','k')
% enable text entry box
enterhb_edit_h = findobj(src,'tag','enterhb_edit');
set(enterhb_edit_h,'enable','on')
% store times in user data
set(src,'UserData',passdat)
end

function out = getsecs(dtvec)
%function to convert a date vector into seconds
out = dtvec(4) * 60^2 + dtvec(5) * 60 + dtvec(6);
end







