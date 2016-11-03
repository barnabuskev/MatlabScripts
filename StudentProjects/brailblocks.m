% script for Kate Dewhurst project
% * prompt for subject code and group
% * obtain a sequence of 10 brail blocks with a 50% chance that the next one
%    will be the same as the previous one
% * start timer when spacebar is pressed and enable reading of mouse clicks
% * left mouse button means same, right means different. Record right or wrong
% * record time of click and stop timer
% * if times out, then record as wrong answer
% * at the end of last block start next subject
% * save data in a CSV file with rows = subjects & colums: subj code,
% group, 9*3 columns for responses (true/false,right/wrong,time), mean
% response time, number of failed to clicks, number correct
function brailblocks
cd('C:\Users\Researcher\Documents\MATLAB\KateDewhurst\')
% block pairs
blknms = [char(65:73),char(75:90)];
% probability of next one being the same
p_same = 0.4;
% initialise random number generator
rng('shuffle')
% number of blocks
nblk = 20;
% timeout time (secs)
timeout = 10;
% cell array for results. pair is 'same' or 'diff'. response is 'correct'
% or 'incorrect'
results = {'subject','group','pair','response','time'};
% initialise gui
prompt = {'Subject Code:','Subject Group:'};
dlg_title = 'Get Subject Info';
num_lines = 1;
%create sound
fs = 44100; % Hz
%duration of sound
sounddur = 0.2;
t = 0:1/fs:sounddur;
frq = 512; % Hz
y = sin(2.*pi.*frq.*t);
% create timer object
t_h = timer('ExecutionMode','fixedRate','StopFcn',@timerfunct,'tag','timertag','TasksToExecute',timeout,...
    'TimerFcn',{@timerfunct,y,fs},'startfcn',@timerfunct,'startdelay',1);
while true
    subjans = inputdlg(prompt,dlg_title,num_lines);
    if isempty(subjans)
        disp('No more subjects')
        break
    end
    % Randomising algorithm: Get random sequence of same/differents. Choose the 1st block at random from 25 possibles.
    % depending on whether the first in the same/different sequence is 'same'
    % or 'different' choose the same block again or one from the remaining
    % pool.
    SDseq = rand(1,nblk-1) < p_same;
    % choose inital block
    blk = blknms(randperm(length(blknms),1));
    outseq = [blk];
    for ia = 1:length(SDseq)
        % select same or different block
        switch SDseq(ia)
            case false
                % different...
                % create a logical array of trues
                selind = true(1,length(blknms));
                % get index of last block
                blk_i = strfind(blknms,blk);
                % make that one false
                selind(blk_i) = false;
                % get subset to choose from
                blknms_sub = blknms(selind);
                % choose 1 at random
                blk = blknms_sub(randperm(length(blknms_sub),1));
                % add it to sequence
                outseq = [outseq,blk];
            case true
                % same - save the previous block in the sequence
                outseq = [outseq,blk];
        end
    end
    % initiate sequence of timings...
    % Open brailblock figure at position of cursor
    timerfh = brailblock;
    centrefigmouse(timerfh)
    timetxt = findobj(timerfh,'tag','timetag');
    instructtxt = findobj(timerfh,'tag','instructtag');
    % pass fig handle to timer
    ud.fig_h = timerfh;
    set(t_h,'userdata',ud)
    % display brail block sequence
    seqtxt = findobj(timerfh,'tag','seqtag');
    set(seqtxt,'string',outseq)
    for bbi = 2:nblk
        % for each pair of brail blocks...
        % set initial time
        set(timetxt,'string',timeout)
        % pass time remaining to timer
        ud.tleft = timeout;
        set(t_h,'userdata',ud)
        % set instructions
        set(instructtxt,'string',['Press spacebar to start timer for ',outseq(bbi)])
        % set keypress callback function
        set(timerfh,'keypressfcn',{@bbkeyp,t_h})
        % keypress callback: check if spacebar & if so create timer, set buttondown function
        % buttondown fucntion: checks which button pressed. If left save
        waitfor(timerfh,'userdata','timergo')
        % timer has started
        set(timerfh,'keypressfcn','')
        set(timerfh,'WindowButtonDownFcn',{@bbwinbutdwnfun,t_h})
        waitfor(timerfh,'userdata','timerstop')
        set(timerfh,'WindowButtonDownFcn','')
        centrefigmouse(timerfh)
        % write row of results...
        % get true pair same/diff
        if SDseq(bbi-1)
            pr = 'same';
        else
            pr = 'diff';
        end
        % compare with subject response
        ud = get(t_h,'userdata');
        if strcmp(ud.butprss,pr)
            sbjrsp = 'correct';
        else
            sbjrsp = 'incorrect';
        end
        results = [results;{subjans{1},subjans{2},pr,sbjrsp,toc}];
    end
    delete(timerfh)
end
% save data as CSV file
[fn,pn,fi] = uiputfile('*.csv','Save data');
if fi ~= 0
    cell2csv([pn,fn], results)
else
    disp('Data not saved.')
end
end

function bbkeyp(fig_h,keydat,tim)
% tim is handle to timer object
if isequal((keydat.Key),'space')
    % spacebar has been pressed
    tic
    start(tim)
    % change message on instructtxt
    instructtxt = findobj(fig_h,'tag','instructtag');
    set(instructtxt,'string','Waiting...')
    % centre figure to mouse position
    centrefigmouse(fig_h)
    set(fig_h,'userdata','timergo')
end
end

function bbwinbutdwnfun(fig_h,butdat,tim)
% tim is handle to timer object
stop(tim)
wbut = get(fig_h,'selectiontype');
ud = get(tim,'userdata');
switch wbut
    case 'normal'
        % left mouse button pressed
        ud.butprss = 'same';
    case 'alt'
        % right mouse button pressed
        ud.butprss = 'diff';
    otherwise
        beep
        disp('Wrong mouse button pressed!!')
        ud.butprss = 'wrong';
end
set(tim,'userdata',ud)
end

function centrefigmouse(fig_h)
% function to centre a figure at current mouse position
% get position of figure
save_u = get(fig_h,'units');
set(fig_h,'units','pixels')
outp = get(fig_h,'OuterPosition');
wdth = outp(3);
hght = outp(4);
% get cursor position on screen
ploc = get(0,'PointerLocation');
nposx = ploc(1) - wdth/2;
nposy = ploc(2) - hght/2;
set(fig_h,'OuterPosition',[nposx,nposy,wdth,hght])
set(fig_h,'units',save_u);
end

function timerfunct(myTimerObj,thisEvent,varargin)
% timer object to count down and stop mouse input if time has elapsed.
switch thisEvent.Type
    case 'StartFcn'
        % set default answer
        ud = get(myTimerObj,'userdata');
        ud.butprss = 'noanswer';
        set(myTimerObj,'userdata',ud)
    case 'TimerFcn'
        % update time left
        ud = get(myTimerObj,'userdata');
        timetxt = findobj(ud.fig_h,'tag','timetag');
        tl = ud.tleft-1;
        if tl == 3
            pause(0.1)
            sound(varargin{1},varargin{2},16);
        end
        set(timetxt,'string',tl)
        ud.tleft = tl;
        set(myTimerObj,'userdata',ud)
    case 'StopFcn'
        % flag timer stopped
        ud = get(myTimerObj,'userdata');
        set(ud.fig_h,'userdata','timerstop')
    otherwise
        disp('Timer Error function called')
end
end


