function runlatex
%function to simplify calling latex
[fn,pn,fi] = uigetfile('*.tex','Get latex file');
if ~fi
    return
end
cd(pn)
rsp = questdlg('What type of output?','Message from runlatex','DVI','PDF','DVI');
auxdir = 'auxfiles';
if ~exist(auxdir,'dir')
    [success,message,messageid] = mkdir(auxdir);
    if ~success
        error(message,messageid)
    end
end
[pathstr,name,ext,versn] = fileparts([pn,fn]);
dpth = [pn,auxdir,filesep];
fpth = [dpth,name];
[success,message,messageid] = copyfile([pn,fn],[fpth,ext]);
if ~success
    error(message,messageid)
end
switch rsp
    case 'DVI'
        [status,result] = system(['latex -output-directory=',dpth,' ',fpth,' &']);
        [status,result] = system(['bibtex ',fpth,' &']);
        [status,result] = system(['latex -output-directory=',dpth,' ',fpth,' &']);
        [status,result] = system(['latex -output-directory=',dpth,' ',fpth,' &']);
    case 'PDF'
        [status,result] = system(['pdflatex -output-directory=',dpth,' ',fpth,' &']);
        [status,result] = system(['bibtex ',fpth,' &']);
        [status,result] = system(['pdflatex -output-directory=',dpth,' ',fpth,' &']);
        [status,result] = system(['pdflatex -output-directory=',dpth,' ',fpth,' &']);
    otherwise
        return
end
