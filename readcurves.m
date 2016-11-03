function readcurves
% function to read & process bowel sounds...
% get files
[fn,pn,fi] = uigetfile('*.csv','Select CSV files','MultiSelect','on');
if fi == 0
    disp('No file selected')
    return
end
cd(pn)
if ~iscell(fn)
    fn = {fn};
end
nfiles = length(fn);
for ia = 1:nfiles
    disp([pn,fn{ia}])
    
end