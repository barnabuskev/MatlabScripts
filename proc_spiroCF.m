function data = proc_spiroCF
% function to process spiro data

% Data must have the following file name format:
% data_sbjcode_lev1[_lev2_lev3...]_(SE|SI|FE|FI)[_rep].mat
% sbjcode must be 3 digits e.g. 007
% levX is the name of a factor level used in the experiment (must be at
% least 1), _rep is appended if the data is a repeat. Level names must
% consist of letters and spaces only.

% Specify factor variable names, types and levels here. 'type' is one of
% 'ordinal' or 'nominal'. If ordinal, must be in descending order:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var(1).name = 'bra_type';
var(1).type = 'nominal';
var(1).levels = {'Fashion bra','T shirt','Sports bra'};
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% add repetition as a factor - this is compulsory
n = length(var) + 1;
var(n).name = 'repetition';
var(n).type = 'nominal';
var(n).levels = {'1','2'};

% Specify which spirometer measurements required here:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%#ok<*NASGU> - suppress unused variable warning
% parameters are grouped into 4 types: SI - slow inspiration, SE - slow
% expiration, FI - forced inspiration, FE - forced expiration

% slow expiration
% vital capacity
SE.name = 'VC';
SE.get = false;

% slow inspiration
% inspiratory capacity
SI.name = 'IC';
SI.get = false;

% forced expiration
% forced vital capacity
FE(1).name = 'FVC';
FE(1).get = false;
% forced expiratory volume in one second
FE(2).name = 'FEV1';
FE(2).get = false;
% Peak expiratory flow
FE(3).name = 'PEF';
FE(3).get = false;

% forced inspiration
% forced inspiratory capacity
FI(1).name = 'FIVC';
FI(1).get = true;
% forced inspiratory volume in one second
FI(2).name = 'FIV1';
FI(2).get = true;
% Peak inspiratory flow
FI(3).name = 'PIF';
FI(3).get = false;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% % create empty cell array to save data:
% data = {'subject'};
% data = [data,{var.name}];
% data = [data,{param([param.get]).name}];
% 

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
nfiles = length(fn);

% THIS NEXT BIT IS A FUDGE FOR CLAIRE'S PROJECT AS CATEGORISING INTO 4 TYPES OF
% ACQUISITION HAD NOT BEEN IMPLEMENTED
fn_copy = fn;
for ia = 1:nfiles
    fname = fn{ia};
    stri = regexpi(fname,'.mat|_rep.mat');
    fname = [fname(1:stri-1),'_FI',fname(stri:end)];
    fn_copy{ia} = fname;
end


for ia = 1:nfiles
    % for each file...
    fname = fn{ia};
    % NEXT BIT FUDGE TOO
    fname_fudge = fn_copy{ia};
    % categorise file according to how data was acquired
    [tokens,matches] = regexp(fname_fudge,'_(SE|SI|FE|FI)','tokens','match');
    if isempty(matches)
        error('File name does not contain acquisition type substring')
    end
    switch tokens{1}{1}
        case 'SE'
            param = SE;
        case 'SI'
            param = SI;
        case 'FE'
            param = FE;
        case 'FI'
            param = FI;
    end
    
    % empty data row
    datrow = cell(1,length(var)+length(param([param.get]))+1);
    
    % get subject code
    fname = fn{ia};
    [tokens,matches] = regexp(fname,'data_(\d{3})','tokens','match');
    if isempty(matches)
        error('None match')
    end 
    datrow(1) = tokens{1};
    
    % get levels for each factor variable...    
    [tokens,matches] = regexp(fname,'_([A-Za-z ]+)','tokens','match');
    if isempty(matches)
        error(['No factor levels found in file name ',fname])
    end
    
    %get factor levels
    for fcti = 1:length(tokens)
        % get repetition level and delete from tokens if there
        if strcmp(tokens{fcti},'rep')
            rep = var(end).levels{2};
            tokens(fcti) = [];
        else
            rep = var(end).levels{1};
        end
    end
    % get other factor levels (minus rep)
    var_red = var(1:end-1);
    n_user_fct = length(var_red);
    fct_dat = cell(1,n_user_fct);
    none_found = true;
    for fcti = 1:length(tokens)
        % search through levels of each user spec. factor
        for vi = 1:length(var_red)
            mtchs = strcmp(tokens{fcti},var_red(vi).levels);
            if any(mtchs)
                % save factor level
                fct_dat(vi) = tokens{fcti};
                none_found = false;
            end
        end
        if none_found
            error(['No match for this factor level in file name: ',tokens{fcti},'. Check variable specs.'])
        end
    end
    % add user chosen factors
    datrow(2:n_user_fct+1) = fct_dat;
    % add repetition
    datrow(n_user_fct+2) = {rep};
    
    
    % Display data and get user to mark beginning and end of breath
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
    
    % calculate desired spirometry parameters
    prms = param([param.get]);
    n_prms = length(prms);
    spr_dat = cell(1,n_prms);
    for prmi = 1:length(prms)
       switch prms(prmi).name
           case {'VC','FVC'}
               p = endy - begy;
           case {'IC','FIVC'}
               p = begy - endy;
           case 'FEV1'
           case 'FIV1'
           case 'PEF'
           case 'PIF'
       end
    end
    
    % short pause before next
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

