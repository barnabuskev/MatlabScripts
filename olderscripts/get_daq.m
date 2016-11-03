function data = get_daq
%function to read data from daq file & display data
[fname,pname] = uigetfile('*.daq', 'Get Daq file');
[data,time] = daqread([pname,fname]);
plot(data)
axis tight