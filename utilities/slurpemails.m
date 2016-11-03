function out = slurpemails(pat)
%function to get a load of files containing email addresses, extract
%email addresses & save them as a sorted text file. pat is a search pattern
%for the files in the directory (& subdirectories) e.g. '*.txt'
drs = searchdirstruct(pat);
tmp = {};
for ia = 1:length(drs)
    fls = drs(ia).filecell;
    for ib = 1:length(fls)
        fnm = [drs(ia).dirpth,filesep,fls{ib}];
        fid = fopen(fnm);
        if fid == -1
            disp(['Could not read file ',fnm])
            break
        end
        while ~feof(fid)
            %while not at end of file
            tline = fgetl(fid);
            %skip attachments
            m = regexp(tline,'^Content-Type','match','once');
            if ~isempty(m)
                break
            end
            %get email on From: line
            m = regexp(tline,'^From.*<([a-zA-Z_0-9.]+@[a-zA-Z_0-9.]+\.[a-zA-Z_0-9.]+)>','tokens','once');
            %exclude my own email address
            if ~isempty(m) && ~strcmp(m,'kevin.brownhill@kcl.ac.uk')
                tmp = [tmp,m];
            end
        end
        fclose(fid);
    end
end
tmp = sort(tmp);
out = {};
%get rid of duplicates
ia = 1;
nem = length(tmp);
while ia <= nem
    out = [out,tmp{ia}];
    pnt = ia + 1;
    if pnt > nem
        return
    end
    while strcmp(tmp{ia},tmp{pnt})
        pnt = pnt + 1;
        if pnt > nem
            return
        end
    end
    ia = pnt;
end

