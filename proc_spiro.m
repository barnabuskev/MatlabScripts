function data = proc_spiro
% function to process spiro data
% get bunch of files
[fn,pn] = uigetfile('*.mat','Get mat data files from spiro','MultiSelect','on');
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
% create empty cell array to save data
data = {'subject','heels','repetition','FVC','FEV1'};
nfiles = length(fn);
for ia = 1:nfiles
    % for each file...
    % get subject code
    fname = fn{ia};
    [tokens,matches] = regexp(fname,'_(\d{3})_','tokens','match');
    tmp = tokens{1};
    sbj = tmp{1};
    % get experimental condition
    [tokens,matches] = regexp(fname,'_([A-Z,a-z,\s]+)','tokens','match');
    tmp = tokens{1};
    cnd = tmp{1};
    % see if repeated
    switch length(tokens)
        case 2
            rpt = 1;
        case 1
            rpt = 0;
        otherwise
            error('tokens cell array must have length = 1 or 0')
    end
    % read file name and get subject code and experimental conditions
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
    % get user to mark point where trace starts to go up
    uiwait(msgbox('Mark begining of breath','Success','modal'));
    [botx,boty] = ginput(1);
    [pxf,pyf] = ds2nfu(botx,boty);
    X = [pxf,pxf];
    Y = [pyf+0.05,pyf];
    annot_h_beg = annotation('arrow',X,Y);
    uiwait(msgbox('Mark end of breath','Success','modal'));
    % and go down
    [topx,topy] = ginput(1);
    [pxf,pyf] = ds2nfu(topx,topy);
    X = [pxf,pxf];
    Y = [pyf-0.05,pyf];
    annot_h_end = annotation('arrow',X,Y);
    % calculate FVC
    fvc = topy - boty;
    % calculate FEV1...
    % check to see if botx exceeds max value of time column
    if botx+1 > max(spirodat(:,2))
        h = msgbox(['FEV1 cannot be calculated for subject ',fname,' as breath out lasted less than 1 second'],'modal');
        uiwait(h)
    end
    fevtop = interp1(spirodat(:,2),spirodat(:,1),botx+1);
    fev1 = fevtop - boty;
    % {'subject','heels','repetition','FVC','FEV1'}
    nxtline = {sbj,cnd,rpt,fvc,fev1};
    data = [data;nxtline];
    pause(0.5)
    delete(annot_h_beg)
    delete(annot_h_end)
    %TO DO
    %~~~~~
    % process file name to get sbj code and condition(s)
    % get save data file name and save data
end
delete(gcf)
[outfn,outpn,fi] = uiputfile('*.csv','Save data');
if fi == 0
    disp('file not saved')
else
    cell2csv([outpn,outfn],data)
end

