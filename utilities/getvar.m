function varargout = getvar(varargin)
%function to load specific variables from a mat file using a gui. input
%file name via comand line or omit for gui. number of output arguments
%determine number of variables selected
switch nargin
    case 0
        %get file via gui
        [fn,pn,fi] = uigetfile('*.mat','Get mat file');
        if ~fi
            return
        end
        fnm = [pn,fn];
    case 1
        fnm = varargin{1};
    otherwise
        error('too many input arguments')
end
s = whos('-file',fnm);
nvs = length(s);
listcell = cell(1,nvs);
for ia = 1:nvs
    listcell{ia} = [s(ia).name,' ',s(ia).class,'  [',num2str(s(ia).size),']'];
end
[sel,ok] = listdlg('liststring',listcell,'promptstring','Select variable(s)');
if ok
    tmp = load(fnm,s(sel).name);
    for ia = 1:length(sel)
        varargout{ia} = tmp.(s(sel(ia)).name);
    end
else
    return
end
