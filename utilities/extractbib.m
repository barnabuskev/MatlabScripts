function extractbib
%function to take list of bibtex keys and a bibtex file and create a new
%bibtex file containing all the entries in the 1st bibtex file which are in
%the list
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get bib key list
[kfn,kpn,fi] = uigetfile('*.txt','Choose bibtex keys file');
if ~fi
    return
end
cd(kpn)
kfid = fopen([kpn,kfn]);
tmp = textscan(kfid,'%s');
bkys = tmp{1};
fclose(kfid);
%read input bibtex file
[ifn,ipn,fi] = uigetfile('*.bib','Choose Bibtex file to scan');
if ~fi
    return
end
[ofn,opn,fi] = uiputfile('*.bib','Choose output Bibtex file');
if ~fi
    return
end
ifid = fopen([ipn,ifn]);
ofid = fopen([opn,ofn],'w');
while 1
    if feof(ifid)
        break
    end
    tln = fgetl(ifid);
    tmp = regexp(tln,'^@[A-Z]+\{([A-Z]+[a-zA-Z\-'']+[0-9]{4}[a-z]{0,1})','tokens');
    if ~isempty(tmp)
        mtc = tmp{1};
        %go through list & find match
        ind = strcmp(mtc,bkys);
        if sum(ind) > 0
            %if there's a match...
            bkys(ind) = [];
            fprintf(ofid,'%s\n',tln);
            while 1
                %print bibtex entry to file
                tln = fgetl(ifid);
                tmp = regexp(tln,'^}$','once');
                if ~isempty(tmp)
                    fprintf(ofid,'%s\n\n',tln);
                    break
                end
                fprintf(ofid,'%s\n',tln);
            end
        end 
    end
end
fclose(ofid);
fclose(ifid);
