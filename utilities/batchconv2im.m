function batchconv2im
%function to convert all fig files in a directory (& subdirectories to
%chosen image file)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get directory
out = searchdirstruct('*.fig');
if isempty(out)
    return
end
imf = {'bmp','emf','eps','jpg','pbm','pdf','png','tif','svg'};
%get filetypes to convert to
[sel,ok] = listdlg('ListString',imf,'PromptString','Get filetypes to convert to','Name','batchconv2im');
if ok == 0
    return
end
wb = waitbar(0,'Converting...','name','batchconv2im');
lout = length(out);
for ia = 1:lout
    pn = out(ia).dirpth;
    fc = out(ia).filecell;
    lfc = length(fc);
    for ib = 1:lfc
        waitbar((ib/lfc + ia - 1) / lout)
        open([pn,filesep,fc{ib}])
        [pn,fn,ext,versn] = fileparts([pn,filesep,fc{ib}]);
        for ic = 1:length(sel)
            typ = imf{sel(ic)};
            f = [pn,filesep,fn];
            if strcmp(typ,'svg')
                f = [f,'.svg'];
                try
                    plot2svg(f)
                catch
                    disp(['File ',f,' failed to convert'])
                    fch = fclose('all');
                    if fch ~= -1
                        delete(f)
                    end
                end
            else
                try
                    saveas(gcf,[pn,filesep,fn],typ)
                catch
                    disp(['File ',f,' failed to convert'])
                    fch = fclose('all');
                    if fch ~= -1
                        delete(f)
                    end
                end
            end
        end
        close(gcf)
    end
end
close(wb)