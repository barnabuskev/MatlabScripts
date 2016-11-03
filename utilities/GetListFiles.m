function [seldir,filelist] = GetListFiles(prompt,varargin)
%Generic function to obtain a list of files.
%Returns cell array of strings of file names (filelist), & name of
%directory (seldir). 2nd argument is file selection eg '*.mat'
seldir = uigetdir('',prompt);
if seldir == 0
    seldir = '';
    filelist = {};
    return
end
switch nargin
    case 1
        fsel = '*.*';
    case 2
        fsel = varargin{1};
    otherwise
        error('Wrong number of input arguments')
end
cd(seldir)
srch = [pwd,filesep,fsel];
sclw = 8;
sclh = 14;
notfin = true;
while notfin
    d = dir(srch);
    str = {d.name};
    dispstr = {};
    mxsz = 0;
    nitms = length(d);
    for i = 1:nitms
        tmp = [d(i).name,'  ',num2str(d(i).bytes)];
        mxsz = max(mxsz,length(tmp));
        dispstr = [dispstr,tmp];
    end
    [s,v] = listdlg('PromptString',prompt,...
        'ListString',dispstr,'ListSize',[sclw * mxsz,sclh * nitms]);
    if v
        if length(s) == 1 && isdir(str{s})
            cd(str{s})
            srch = [pwd,filesep,fsel];
        else
            filelist = str(s);
            notfin = false;
            seldir = pwd;
        end
    else
        seldir = '';
        filelist = {};
        return
    end
end
