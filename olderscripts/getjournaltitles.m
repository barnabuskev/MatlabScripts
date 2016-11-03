function getjournaltitles
%function to read IE word documents containing BSO student research
%projects & return a list of journal/book/etc titles
%
fcount = 0;
journals = {};
while 1
    %get directory containing IE projects
    [fn,pn,fi] = uigetfile('*.doc','Get IE Microsoft Word file');
    if ~fi
        break
    end
    fcount = fcount + 1;
    scode = input('Enter student name/code  ','s')
    journals{1,fcount} = scode;
    txtFile = saveWordAsText([pn,fn],'C:\tempfile321');
    fclose('all');
    [fid,msg] = fopen([txtFile,'.txt']);
    if fid == -1
        errordlg(['file ',txtFile,' could not be opened: ',msg])
        return
    end
    %text file is open for reading...
    %read string at a time
    try
        % do everything here
        % scroll forward to 'references'
        indx = [];
        while isempty(indx)
            ln = fgetl(fid);
            indx = regexpi(ln,'references\W?$');
        end
        %we're at the start of references! Read each line
        refcount = 1;
        while 1
            ln = fgetl(fid);
            if ~ischar(ln)
                break
            end
            if ~isempty(ln)
                [strt,endd,extents,match,tokens,names] = regexpi(ln,'\(\d\d\d\d\).[^.]+.([^.]+).([^.]+)');
                if ~isempty(strt)
                    t = tokens{:};
                    for j = 1:length(t)
                        disp([num2str(j),': ',t{j}])
                    end
                    disp(' ')
                    choice = input('1, 2 or space?  ','s');
                    switch choice
                        case '1'
                            [strt,endd,extents,match,tokens,names]=regexpi(t{1},'[^,:;]+');
                            match{1}
                            refcount = refcount + 1;
                            journals{refcount,fcount} = match{1};
                        case '2'
                            [strt,endd,extents,match,tokens,names]=regexpi(t{2},'[^,:;]+');
                            match{1}
                            refcount = refcount + 1;
                            journals{refcount,fcount} = match{1};
                        case ' '
                    end
                end
            end
        end
        st = fclose(fid);
        if st
            errordlg('file could not be closed')
            return
        end
    catch
        st = fclose(fid);
        if st
            errordlg('file could not be closed')
            return
        end
    end
end
[fn,pn,fi] = uiputfile('*.xls','Save results');
    if ~fi
        return
    end
xlswrite([pn,fn],journals)