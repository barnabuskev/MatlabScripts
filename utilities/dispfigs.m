function dispfigs
%display some figs
seldir = uigetdir('','Get fig directory');
if seldir == 0
    return
end
cd(seldir)
d = dir(fullfile(seldir,'*.fig'));
if isempty(d)
    msgbox('No fig files') 
    return
end
seldir = [seldir,filesep];
str = {d.name};
dispstr = {};
for i = 1:length(d)
    dispstr = [dispstr,[d(i).name,'  ',num2str(d(i).bytes)]];
end
[s,v] = listdlg('PromptString','Select fig files',...
    'ListString',dispstr);
if v
    flst = str(s);
else
    errordlg('No file selected')
    return
end
for ia = 1:length(flst)
    open([seldir,flst{ia}])
    maximize
    set(gcf,'NumberTitle','off','name',[flst{ia}])
    uiwait(gcf)
end