function writecsv(cin,varargin)
%function to write a cell array containing scalars and strings to a csv
%file. fln is path to file, cin is the cell...
switch nargin
    case 1
        %get save file
        [fn,pn,fi] = uiputfile('*.csv','Create save file');
        if fi
            fln = [pn,fn];
        else
            return
        end
    case 2
        fln = varargin{1};
    otherwise
        error('wrong number of input arguments')
end
%is input a cell?
if ~iscell(cin)
    error('input should be a cell')
end
%is it multidimensional?
if length(size(cin)) > 2
    error('cell array should not be multidimensional')
end
%check that cells contain scalars or strings or are empty
scl = cellfun(@isscalar,cin);
str = cellfun(@ischar,cin);
empt = cellfun(@isempty,cin);
chk = find(~((scl | str) | empt)); %#ok<EFIND>
if ~isempty(chk)
    error('cells should contain scalars or strings only')
end
%put empty string into empty cell
cin(empt) = {' '};
str = str | empt;
%write file
fid = fopen(fln,'w');
if fid == -1
    errordlg(['cannot open ',fln]);
    return
end
for r = 1:size(cin,1)
    for c = 1:size(cin,2)
    	tmp = cin{r,c};
    	if iscell(tmp)
    		tmp = tmp{1}
    	end
        if str(r,c)
            fprintf(fid,'%s',tmp);
        else
            fprintf(fid,'%g',tmp);
        end
        if c ~= size(cin,2)
            fprintf(fid,'%c',',');
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);
