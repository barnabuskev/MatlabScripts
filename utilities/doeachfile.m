% function to take a list of files from getfiles.m and carry out a function
% on each. fnc is a pointer to a function
function doeachfile(fn,pn,fnc)
for ia = 1:length(fn)
    fnc([pn,fn{ia}]);
end
