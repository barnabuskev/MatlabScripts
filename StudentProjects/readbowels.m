function readbowels
% function to read & process bowel sounds...
% get files
[fn,pn,fi] = uigetfile('*.wav','Select WAV files','MultiSelect','on');
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
    [y,Fs,nbits] = wavread([pn,fn{ia}]);
    plot((1:length(y))/Fs,y)
    xlabel('Time in seconds')
    axis tight
    pause
end
