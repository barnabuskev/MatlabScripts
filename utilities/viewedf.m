function ts = viewedf
% gui to get and view edf file
[fn, pn] = uigetfile('*.edf','Get EDF file');
[hdr, record] = edfread([pn,filesep,fn]);
disp(hdr);
time = (0:size(record,2)-1) / hdr.samples(1);
size(time)
size(record,2)
ts = timeseries(record(1:2,:),time);
plot(ts)
end
