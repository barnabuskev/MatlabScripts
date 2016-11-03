function out = searchdirstruct(typ)
%function to search into a directory structure for files of type 'typ'
%where typ is wildcard file search string e.g. '*.mat' 'out' is a
%structure with fields 'dirpth' - directory path & 'filecell' containing a
%cell array of file names
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get highest directory - start of search
topdir = uigetdir(pwd,'Get directory to search into');
out = struct([]);
if topdir == 0
    return
end
cd(topdir)
out = recrsfnd(topdir,out,typ);


function found = recrsfnd(thisdir,found,srchstr)
%function to return files found in the input directory 'thisdir' using
%search string 'srchstr'. It calls itself recursively
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get size of input strucure
sl = length(found);
%get desired files
d = dir([thisdir,filesep,srchstr]);
%return cell array of file names and this directory
if ~isempty(d)
    found(sl + 1).filecell = {d.name};
    found(sl + 1).dirpth = thisdir;
end
%get list of directories in this directory
d = dir(thisdir);
dirlist = {d([d.isdir]).name};
dl = length(dirlist) - 2;
for ia = 1:dl
    found = recrsfnd([thisdir,filesep,dirlist{ia + 2}],found,srchstr);
end
