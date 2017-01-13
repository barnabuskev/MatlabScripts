function outstruct = ConvertKinectBin(varargin)
% Function to read Kinect sensor timestamp and joint position binary files
% and export data as a structure with the following fields: time, skel_1, skel_2,
% ..., skel_6 (up to 6 skeletons. Empty skeletons are not recorded. Empty
% skeletons are those with all joints being not tracked) each of these has
% a sub field for each joint (numbering n_jts subfields - see below).
% Each subfield contains an nframe * 3 cell array:
%  1st col: x position data
%  2nd col: y position data
%  3rd col: z position data
% 
% Details on data format at: https://kinectstreamsaver.codeplex.com/

% Input:
% if no arguments given, then user selects time stamp and joint position
% files. Otherwise 2 arguments must be given with the full file path of
% timestamp and joint position files:
% ConvertKinectBin('path\to\liTimeStamp.binary','path\to\Joint_Position.binary')


% check inputs
if nargin~=0 && nargin~=2
    error('Wrong number of input arguments. Either none or filepath of timestamp and joint position file')
end


% OPTIONS...
% joint order
j_ord = {'HIP_CENTER', 'SPINE', 'SHOULDER_CENTER', 'HEAD', 'SHOULDER_LEFT',...
    'ELBOW_LEFT', 'WRIST_LEFT', 'HAND_LEFT', 'SHOULDER_RIGHT', 'ELBOW_RIGHT',...
    'WRIST_RIGHT', 'HAND_RIGHT', 'HIP_LEFT', 'KNEE_LEFT', 'ANKLE_LEFT', 'FOOT_LEFT',...
    'HIP_RIGHT', 'KNEE_RIGHT', 'ANKLE_RIGHT', 'FOOT_RIGHT'};
% number of rows per time point in time data (always 5 I think)
td_rows_per_tp = 5;
% get number of values per joint per time point (always 4 I think)
jt_per_tp = 4;
% number of joints per skeleton
n_jts = length(j_ord);
% number of skeletons (always 6 I think)
n_skel = 6;

% GET TIME DATA
if nargin == 0
    [tsfn,tspn,fi] = uigetfile('*.binary','Get timestamp data');
    if fi==0
        disp('No timestamp data chosen. Exiting ConvertKinectBin');
        return
    end
    tsfile = fullfile(tspn,tsfn);
else
    tsfile = varargin{1};
    [tspn,~,~] = fileparts(tsfile);
end

% read time data
fid = fopen(tsfile);
t_dat = fread(fid,'int64');
fclose(fid);
% change to this directory
cd(tspn)
% reshape data
t_dat = transpose(reshape(t_dat,td_rows_per_tp,[]));
% discard all except time stamp data (last column assumed) and convert to seconds
t_dat = t_dat(:,end)/1000;
% start time stamp at zero
t_dat = t_dat - t_dat(1);
% save time data in structure
outstruct = struct('time',t_dat);



% GET JOINT POSITION DATA
if nargin == 0
    [jpfn,jppn,fi] = uigetfile('.binary','Get joint position data');
    if fi==0
        disp('No joint position data chosen. Exiting ConvertKinectBin');
        return
    end
    jpfile = fullfile(jppn,jpfn);
else
    jpfile = varargin{2};
end

% read joint position file
fid = fopen(jpfile);
jpos_dat = fread(fid,'float');
fclose(fid);
% get number of frames (time points)
nframe = size(t_dat,1);
% reshape so that each row is a coordinate or tracking status
% [x,y,z,tracking_status], each column is a joint, the 3rd dim is skeleton,
% the 4th is time point. The next line should give an error if number of
% frames is not same in timestamp data as joint position data
jpos_dat = reshape(jpos_dat,jt_per_tp,n_jts,n_skel,nframe);


% STORE NON-EMPTY SKELETON DATA IN A STRUCTURE
for skeli = 1:n_skel
    skeldat = jpos_dat(:,:,skeli,:);
    if is_skel_empty(skeldat)
        continue
    else
        % Add data to structure
        % field name
        skelf = strcat('skel_',num2str(skeli));
        for jnti = 1:n_jts
            tmp = squeeze(skeldat(1:3,jnti,:));
            outstruct.(skelf).(j_ord{jnti}) = tmp';
        end
    end
end
end


function empt = is_skel_empty(skeldat)
% function takes a jt_per_tp * n_jts * nframe array and returns true if
% empty, otherwise false
empt = all(all(all(skeldat==0)));
end
















