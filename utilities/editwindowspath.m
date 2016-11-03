function editwindowspath
%function to edit windows path
[s,r] = system('path');
pth = regexp(r,'[=;]','split');
[sel,ok] = listdlg('ListString',pth,'ListSize',[300,300]);