function ands = getbibfield
%function to get bibtex author field & correct from file
field = 'author';
ifn = 'CROAM LIB FINAL BIBTEX.txt';
ipn = '/home/kev/Documents/Work/BSO/Misc/CROAM';
%[ifn,ipn,fi] = uigetfile({'*.bib','Bibtex files';'*.txt','Text files';'*.tex','Latex files';'*.*','All files'},'Choose file to scan');
%if ~fi
%    return
%end
[opn,ofn,extn] = fileparts([ipn,ifn]);
outfp = [opn,filesep,ofn,'_CLEANED',extn];
cd(ipn)
ifid = fopen([ipn,ifn]);
ofid = fopen(outfp,'w');
ands = {};
while 1
    %read file
    if feof(ifid)
        break
    end
    tln = fgetl(ifid);
    strm = ['\s+',field,'\s+=\s{'];
    tmp = regexp(tln,strm,'match');
    if ~isempty(tmp)
        %if not on 1 line, read other lines
        tmp = regexp(tln,'{(.*)','tokens');
        fldstr = char(tmp{1});
        nrflag = true;
        while nrflag
            k = findstr(fldstr,'}');
            if isempty(k)
                %not all lines read
                tln = fgetl(ifid);
                tln = stripblnk(tln);
                fldstr = [fldstr,' ',tln];
            else
                nrflag = false;
                fldstr = regexprep(fldstr,'},{0,1}','');
            end
        end
        %field obtained
        %test if it contains .,
        k = findstr(fldstr,'.,');
        if ~isempty(k)
            %contains ., - replace with dot
            fldstr = regexprep(fldstr,'\.,','.');
        end
        k = findstr(fldstr,'and');
        if ~isempty(k)
            %author field contains 'and'
            auts = regexp(fldstr,' and ','split');
            auts_n = {};
            for ia = 1:length(auts)
                tmp = regexp(auts{ia},'([A-Z][a-z]{1}[a-zA-Z-]*),(.*)','tokens');
                if ~isempty(tmp)
                    %names with commas after
                    sname = tmp{1}{1};
                    rest = tmp{1}{2};
                    rest = stripblnk(rest);
                    auts_n  = [auts_n,[rest,' ',sname]];
                else
                    %names with 'and' but no commas or commas before rest
                    k = findstr(auts{ia},',');
                    if ~isempty(k)
                        %contains comma
                        tmp = regexp(auts{ia},',','split');
                        if length(tmp) ~= 2
                            error('author does not split into 2')
                        end
                        sname = stripblnk(tmp{2});
                        rest = tmp{1};
                        auts_n  = [auts_n,[rest,' ',sname]];
                    end
                end
            end
            if ~isempty(auts_n)
                %remake author field
                tmp = auts_n{1};
                for ia = 2:length(auts_n)
                    tmp = [tmp,' and ',auts_n{ia}];
                end
                fprintf(ofid,'%s,\n',['  author = {',tmp,'}']);
            end
        else
           %author field does not contain 'and'
           k = findstr(fldstr,',');
           if ~isempty(k)
                %contains comma
%               fldstr
           else
                %no comma
                tmp = regexp(fldstr,'[A-Z][a-z]{1}[a-zA-Z-]*','match');
                if length(tmp) == 1
                    %one name string sname before rest
                    tmp = regexp(fldstr,'([A-Z][a-z]{1}[a-zA-Z-]*)(.*)','tokens');
                    sname = tmp{1}{1};
                    rest = tmp{1}{2};
                    %strip spaces and fullstops
                    rest = regexprep(rest,'[\s\.]','');
                    fprintf(ofid,'%s,\n',['  author = {',rest,' ',sname,'}']);
                else
                    %more than 1 name string
                    but = questdlg(fldstr,'Surname first names/initials?')
                    switch but
                        case 'Yes'
                            tmp = regexp(fldstr,'([A-Z][a-z]{1}[a-zA-Z-]*)(.*)','tokens');
                            sname = tmp{1}{1};
                            rest = stripblnk(tmp{1}{2});
                            fprintf(ofid,'%s,\n',['  author = {',rest,' ',sname,'}']);
                        case 'No'
                            fprintf(ofid,'%s,\n',['  author = {',fldstr,' hitler}']);
                        case 'Cancel'
                            break
                    end
                    
                end
                
           end
        end
    else
        %line does not contain author field
        fprintf(ofid,'%s\r',tln);
    end 
end
fclose(ofid);
fclose(ifid);


