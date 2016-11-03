function out = stripblnk(in)
%function to strip leading and trailing blanks from a string
out = regexprep(in,'^\s+','');
out = regexprep(out,'\s+$','');
