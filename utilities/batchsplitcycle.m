function batchsplitcycle
%function to call 'splitdatcycles.m' on a batch of data matrices stored as
%matfiles and store results as matfiles containing 3D arrays in which each
%page is cycle data: rows samples in cycle, cols - variables.
[datpn,flist] = GetListFiles('Get matfiles containing data matrices','*.mat');
cd(datpn)
if isempty(flist)
    return
end
%get heel strike data
[fn,pn,fi] = uigetfile('*.mat','Get heelstrike data');
hsd = getvarfrommat([pn,filesep,fn]);
nfls = length(flist);
for ia = 1:nfls
    fl = [datpn,filesep,flist{ia}];
    %load data to workspace code
    dat = getvarfrommat(fl);
    spltsx = cell2mat(hsd(2:end,ia));
    cycdat = splitdatcycles(dat,spltsx);
    but = questdlg(['healstrike column = ',hsd(1,ia),'. File = ',flist{ia},'. OK?'],'batchsplitcycles','yes','no','yes');
    if strcmp(but,'no')
        return
    end
    if ia ~= nfls
        pause
    end
    [tmp,name,tmp,tmp] = fileparts(fl);
    save([datpn,filesep,name,'cycdat'],'cycdat')
end