function getbibkeys
%function to bibtex keys from file
[ifn,ipn,fi] = uigetfile({'*.txt','Text files';'*.bib','Bibtex files';'*.tex','Latex files';'*.*','All files'},'Choose file to scan');
if ~fi
    return
end
[ofn,opn,fi] = uiputfile('*.txt','Choose output file');
if ~fi
    return
end
cd(ipn)
ifid = fopen([ipn,ifn]);
mtc = {};
while 1
    %read file & store bibtex keys
    if feof(ifid)
        break
    end
    tln = fgetl(ifid)
    tmp = regexp(tln,'[A-Z][a-zA-Z'']{1}[a-zA-Z''\-]*[1,2]{1}[0-9]{3}[a-z]{0,1}','match');
    mtc = [mtc,tmp];  
end
%remove duplicates & write results
mtc = unique(mtc);
ofid = fopen([opn,ofn],'w');
for ia = 1:length(mtc)
    fprintf(ofid,'%s\n',mtc{ia});
end
fclose(ofid);
fclose(ifid);
