function out = getvarfrommat(fpth)
%function to select a variable from mat file given file path
warning off all
vrdat = whos('-file',fpth);
nvrs = length(vrdat);
if nvrs == 1
    vrnm = vrdat(1).name;
else
    %create list string
    lstr = cell(nvrs,1);
    for ia = 1:nvrs
        [s,errmsg] = sprintf('%s   %d   %s',vrdat(ia).name,vrdat(ia).size,vrdat(ia).class);
        lstr{ia} = s;
    end
    lstr = ['name   size   class';lstr];
    [sel,ok] = listdlg('PromptString','select data to process','ListString',lstr,'SelectionMode','single');
    if isempty(sel)
        disp('No variables selected')
    end
    vrnm = vrdat(sel - 1).name;
end
tmp = load(fpth,vrnm);
fldn = fieldnames(tmp);
out = tmp.(fldn{1});

