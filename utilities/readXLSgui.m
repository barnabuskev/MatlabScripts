function outcell = readXLSgui
%function to read excel file via gui
[fn,pn,fi] = uigetfile('*.xls','Get Excel file');
if ~fi
    return
end
cd(pn)
[num,txt,outcell] = xlsread([pn,filesep,fn],-1);