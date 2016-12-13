function data_out = proc_spiroCF
% function to process spiro data - Claire Faragher version

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
% parameters are grouped into 4 types, depending on method of acquisition:
% SI - slow inspiration, SE - slow expiration, FI - forced inspiration, FE
% - forced expiration

% slow expiration
% ~~~~~~~~~~~~~~~
% vital capacity
SE.name = 'VC';
SE.get = false;

% slow inspiration
% ~~~~~~~~~~~~~~~~
% inspiratory capacity
SI.name = 'IC';
SI.get = false;

% forced expiration
% ~~~~~~~~~~~~~~~~~
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
% ~~~~~~~~~~~~~~~~~~
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

% select bunch of files
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
for ia = 1:nfiles
    fname = fn{ia};
    stri = regexpi(fname,'.mat|_rep.mat');
    fname = [fname(1:stri-1),'_FI',fname(stri:end)];
    fn{ia} = fname;
end

% create empty cell array to save data:
row1 = {'subject'};
% add factor variable names
row1 = [row1,{var.name}];
% add chosen spirometer variable names
row1 = [row1,{SE([SE.get]).name},{SI([SI.get]).name},{FE([FE.get]).name},{FI([FI.get]).name}];
data_out = cell(nfiles+1,length(row1));
data_out(1,:) = row1;





for ia = 1:nfiles
    % for each file...
    fname = fn{ia};
    
    % categorise file according to how data was acquired
    [tokens,matches] = regexp(fname,'_(SE|SI|FE|FI)','tokens','match');
    if isempty(matches)
        error('File name does not contain acquisition type substring')
    end
    switch tokens{1}{1}
        % get measurement type structure for acquisition type
        case 'SE'
            param = SE;
        case 'SI'
            param = SI;
        case 'FE'
            param = FE;
        case 'FI'
            param = FI;
    end
    
    % THIS NEXT BIT IS A FUDGE FOR CLAIRE'S PROJECT
    % delete acquisition type substring from filename
    [C,matches] = strsplit(fname,'_(SE|SI|FE|FI)','DelimiterType','RegularExpression');
    fname = strjoin(C,'');
    
    % load data
    tmp = load(fname);
    fldnm = fieldnames(tmp);
    assert(length(fldnm) == 1,'fldnm should have length = 1')
    spirodat = tmp.(fldnm{1});
    
    % get subject code
    [tokens,matches] = regexp(fname,'data_(\d{3})','tokens','match');
    if isempty(matches)
        error('None match')
    end
    data_out(ia+1,1) = tokens{1};
    
    % get levels for each factor variable...
    [tokens,matches] = regexp(fname,'_([A-Za-z ]+)','tokens','match');
    if isempty(matches)
        error(['No factor levels found in file name ',fname])
    end
    % unnest tokens so cell array of strings (instead of cell array of cells)
    tokens = [tokens{:}];
    
    % get repetition level...
    rep_i = strcmp(tokens,'rep');
    % get column of repetition var
    rep_col = strcmp(row1,'repetition');
    if any(rep_i)
        data_out{ia+1,rep_col} = var(end).levels{2};
        tokens(rep_i) = [];
    else
        data_out{ia+1,rep_col} = var(end).levels{1};
    end
    
    % remove acquisition type
    [~,matches] = regexp(tokens,'(SE|SI|FE|FI)','tokens','match');
    acq_i = cellfun('isempty',matches);
    if any(~acq_i)
        % acquisition type present: delete token
        tokens(~acq_i) = [];
    end
    
    
    % get other factor levels (minus rep & acq. type)
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
                fct_dat{vi} = tokens{fcti};
                none_found = false;
            end
        end
        if none_found
            error(['No match for this factor level in file name: ',tokens{fcti},'. Check variable specs.'])
        end
    end
    % add user chosen factors
    data_out(ia+1,2:n_user_fct+1) = fct_dat;
    
    % plot data and get user to mark beginning and end of breath
    plot(spirodat(:,2),spirodat(:,1))
    xlabel('Time (secs)')
    ylabel('Volume (litres)')
    title([num2str(ia),' out of ',num2str(nfiles)])
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    
    % get user to mark beginning of breath
    uiwait(msgbox('Mark begining of breath','Success','modal'));
    [begt,begv] = ginput(1);
    [pxf,pyf] = ds2nfu(begt,begv);
    X = [pxf,pxf];
    Y = [pyf+0.05,pyf];
    annot_h_beg = annotation('arrow',X,Y);
    
    % get user to mark end of breath
    uiwait(msgbox('Mark end of breath','Success','modal'));
    [endt,endv] = ginput(1);
    [pxf,pyf] = ds2nfu(endt,endv);
    X = [pxf,pxf];
    Y = [pyf-0.05,pyf];
    annot_h_end = annotation('arrow',X,Y);
    
    % calculate desired spirometry parameters
    prms = param([param.get]);
    n_prms = length(prms);
    spr_dat = cell(1,n_prms);
    for prmi = 1:length(prms)
        % get col for this param
        prm_col = strcmp(prms(prmi).name,row1);
        switch prms(prmi).name
            case {'VC','FVC'}
                data_out{ia+1,prm_col} = endv - begv;
            case {'IC','FIVC'}
                data_out{ia+1,prm_col} = begv - endv;
            case 'FEV1'
                [near_i,~] = getnear(spirodat(:,2),begt+1);
                data_out{ia+1,prm_col} = spirodat(near_i,1) - begv;
            case 'FIV1'
                [near_i,~] = getnear(spirodat(:,2),begt+1);
                data_out{ia+1,prm_col} = begv - spirodat(near_i,1);
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
    cell2csv([outpn,outfn],data_out)
end
end

function [near_i,near_val] = getnear(vect,ind_val)
% function given ordered vector of doubles 'vect' and scalar 'ind_val'
% returns the nearest value to ind_val in vect 'near_val' and its index
% 'near_ind'
tmp = abs(vect - ind_val);
[near_val,near_i] = min(tmp);
end



