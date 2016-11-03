function out = randpass(nchr)
%function to generate random passwords given number of characters nchr
%permitted characters
prmchr = ['A':'Z','a':'z','0':'9','+','*','%','$','£','&'];
lchr = length(prmchr);
sel = randi(lchr,nchr,1);
out = prmchr(sel);

