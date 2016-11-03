function deletefiles(typ)
%function to delete files down through a directory structure with prompts
out = searchdirstruct(typ);
for ia = 1:length(out)
    for ib = 1:length(out(ia).filecell)
        fle = [out(ia).dirpth,filesep,out(ia).filecell{ib}];
        btn = questdlg(['Delete file ',fle],'Confirm file delete','Yes');
        switch btn
            case 'Yes'
                delete(fle)
            case 'Cancel'
                return
            otherwise
                %do nothing
        end
    end
end