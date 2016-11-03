function add2windowspath
%function to add an app to path
%get app directory
pn = uigetdir('C:\');
exstr = ['PATH ',pn,';%PATH%'];
but = questdlg(['DOS command to execute is ',exstr,'. Is this correct?'],'add2windowspath','Yes','No','No');
switch but
    case 'Yes'
        [status, result] = dos(exstr);
    case 'No'
        return
end
