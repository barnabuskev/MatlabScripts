function data = proc_spiroCF
% function to process spiro data adapted for Claire Faragher project
% Specify variable names, types and levels (if applicable) here. 'type'
% is one of 'scale', 'ordinal', 'nominal' a la SPSS:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var(1).name = 'bra_type';
var(1).type = 'nominal';
var(1).levels = {'Fashion bra','T shirt','Sports bra'};
%
var(2).name = 'repetition';
var(2).type = 'nominal';
var(2).levels = {'no','yes'};
%
var(3).name = 'FIVC';
var(3).type = 'scale';
var(3).levels = {};
%
var(4).name = 'FIV1';
var(4).type = 'scale';
var(4).levels = {};
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% get bunch of files
[fn,pn] = uigetfile('*.mat','Get mat data files from spirometer','MultiSelect','on');
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
% create empty cell array to save data:
data = {'subject'};
for ia = 
nfiles = length(fn);
for ia = 1:nfiles
    % for each file...
    % get subject code
    fname = fn{ia}
    [tokens,matches] = regexp(fname,'data_(\d{3})','tokens','match');
    if isempty(matches)
        error('None match')
    end 
    tmp = tokens{1};
    sbj = tmp{1};
    % get treatment
    [tokens,matches] = regexp(fname,'\d{3}([BSM]{1})','tokens','match');
    if isempty(matches)
        error('None match')
    end
    tmp = tokens{1};
    switch tmp{1}
        case tttposs(1)
            ttt = 0;
        case tttposs(2)
            ttt = 1;
        case tttposs(3)
            ttt = 2;
        otherwise
            error('treatment doesn''t match available options')
    end
    % get repetition
    matches = regexp(fname,'_rep.mat','match');
    if isempty(matches)
        rep = 0;
    else
        rep = 1;
    end
    % get breath direction
    matches = regexp(fname,'(Vital_capacity|Forced_inspiration)','match');
    switch matches{1}
        case 'Vital_capacity'
            inout = 'out';
        case 'Forced_inspiration'
            inout = 'in';
        otherwise
            error('breath direction doesn''t match available options')
    end      
    % read raw data
    tmp = load(fname);
    fldnm = fieldnames(tmp);
    assert(length(fldnm) == 1,'fldnm should have length = 1')
    spirodat = tmp.(fldnm{1});
    % plot data
    plot(spirodat(:,2),spirodat(:,1))
    xlabel('Time (secs)')
    ylabel('Volume (litres)')
    title([num2str(ia),' out of ',num2str(nfiles)])
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    % get user to mark beginning of breath
    uiwait(msgbox('Mark begining of breath','Success','modal'));
    [begx,begy] = ginput(1);
    [pxf,pyf] = ds2nfu(begx,begy);
    X = [pxf,pxf];
    Y = [pyf+0.05,pyf];
    annot_h_beg = annotation('arrow',X,Y);
    % get user to mark end of breath
    uiwait(msgbox('Mark end of breath','Success','modal'));
    [endx,endy] = ginput(1);
    [pxf,pyf] = ds2nfu(endx,endy);
    X = [pxf,pxf];
    Y = [pyf-0.05,pyf];
    annot_h_end = annotation('arrow',X,Y);
    switch inout
        case 'in'
            % calculate FIC
            fic = abs(endy - begy);
            data = [data;{sbj,ttt,rep,fic,1}]; %#ok<*AGROW>
            % check to see if begx + 1 sec exceeds max value of time column
            if begx+1 > max(spirodat(:,2))
                h = msgbox(['FIV1 cannot be calculated for file ',fname,' as breath out lasted less than 1 second'],'modal');
                uiwait(h)
                continue
            end
            % calculate FIV1...
            volplus1 = interp1(spirodat(:,2),spirodat(:,1),begx+1);
            fiv1 = abs(volplus1 - begy);
            data = [data;{sbj,ttt,rep,fiv1,2}]; %#ok<*AGROW>
        case 'out'
            % calculate VC
            vc = endy - begy;
            data = [data;{sbj,ttt,rep,vc,0}]; %#ok<*AGROW>
        otherwise
            error('inout has wrong value?')
    end
    pause(0.5)
    delete(annot_h_beg)
    delete(annot_h_end)
end
delete(gcf)
[outfn,outpn,fi] = uiputfile('*.csv','Save data');
if fi == 0
    disp('file not saved')
else
    cell2csv([outpn,outfn],data)
end

