function [fn,pn,avi] = getavi
%function to get & read an avi file into matlab
[fn,pn,filtind] = uigetfile('*.avi','Get AVI movie file');
if ~filtind
    errordlg('No movie selected','Message from getavi')
end
cd(pn);
aviinfo([pn,fn])
avi = aviread([pn,fn]);
