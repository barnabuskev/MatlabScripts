function pathcell = getjposfiles
% function to get several joint position and time stamp pairs of binary
% files, and name of session directory, and return them as an N*3 cell
% array. The 1st col is the timestamp files, the second is the point
% position files, the 3rd is the name of the session dir

% initialise
tsstr = 'liTimeStamp.binary';
jpsstr = 'Joint_Position.binary';
skldir = 'Skel';

% loop through directory selections. Stop by cancelling gui
pathcell = {};
keepon = true;
while keepon
    shsdir = uigetdir(pwd,'Select a session directory containing Skel directory with time and joint position data');
    if shsdir==0
        keepon = false; %#ok<NASGU>
        break
    end
    % get session name
    tmp = strsplit(shsdir,filesep);
    shsnm = tmp{end};
    % extract files from directory
    tfl = fullfile(shsdir,skldir,tsstr);
    if ~exist(tfl,'file')
        error(['File ',tfl,' does not exist'])
    end
    jpfl = fullfile(shsdir,skldir,jpsstr);
    if ~exist(jpfl,'file')
        error(['File ',jpfl,' does not exist'])
    end
    pathcell = [pathcell;{tfl,jpfl,shsnm}]; %#ok<AGROW>
    % go to directory above current dir
    cd(shsdir)
    cd('..')
end
%
