function pdf2svgwrapper
%function to provide wrapper to pdf2svg command line
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[pdfdir,filelist] = GetListFiles('Get PDF file(s)','*.pdf');
%get output directory
sdir = uigetdir(pwd,'Get directory to save SVG files');
%create string to pass to pdf2svg
exstr = 'pdf2svg';
for ia = 1:length(filelist)
    exstr = [exstr,' ',filelist{ia}];
end
exstr = [exstr,' -o "',sdir,'"',' -i'];
but = questdlg(['system command to execute is ',exstr,'. Is this correct?'],'pdf2svgwrapper','Yes','No','Yes');
switch but
    case 'Yes'
        [status, result] = system(exstr);
        if status
            disp('Something went wrong')
        else
            disp('executed OK')
        end
        disp(result)
    case 'No'
        return
end
