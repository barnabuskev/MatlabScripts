function renametoblind(typ)
%function to input files, read & store their names, randomly permute the
%list of names, rename them to blind them & store list of original names
%and blinding names. 'typ' is the file extension to search for. This
%function will only search for files in the selected input directory.
%
%get list of files
[seldir,filelist] = GetListFiles('Find directory containing files to rename',typ);
%get destination directory
destd = uigetdir(seldir,'Select destination directory');
if destd == 0
    return
end
%create random part of name
asn = [65:90,97:122];
prm = randperm(length(asn));
rndnm = char(asn(prm(1:6)));
%new file names
nfl = length(filelist);
pds = ceil(log10(nfl));
frmts = ['%0',num2str(pds),'.0f'];
obs = cell(size(filelist));
%get file extension
xtn = regexp(typ,'\w{3}','match','once');
%randomly permute file name list
prm = randperm(nfl);
filelist = filelist(prm);
%copy files to new name & directory
for ia = 1:nfl
    sfx = sprintf(frmts,ia);
    newn = [rndnm,sfx,'.',xtn];
    [st,msg,mid] = copyfile([seldir,filesep,filelist{ia}],[destd,filesep,newn]);
    if ~st
        error(['Copying of file ',[seldir,filelist{ia}],' failed: ',msg])
    end
    obs(ia) = {newn};
end
%save translation table
writecsv([filelist',obs'])


