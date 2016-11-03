function writecell2csv(cell)
%Function to write cells to a CSV file.
if ~iscell(cell)
    msgbox('Input to writecell2csv must be a cell','Message from writecell2csv');
    return
end
[fn,pn,fi] = uiputfile('*.csv','Save CSV file');
fid = fopen([pn,fn,'.csv'],'w');
cols = size(cell,2);
rows = size(cell,1);
for i = 1:rows
    for j = 1:cols
        if j == cols
            sep = '\n';
        else
            sep = ',';
        end
        switch class(cell{i,j})
            case 'char'
                fprintf(fid,['%s',sep],cell{i,j});
            case 'double'
                c = num2str(cell{i,j});
                fprintf(fid,['%s',sep],c);
            otherwise
                msgbox('writecell2csv can only handle cell arrays containing strings and doubles','Message from writecell2csv');
                return
        end
    end
end
fclose(fid);

