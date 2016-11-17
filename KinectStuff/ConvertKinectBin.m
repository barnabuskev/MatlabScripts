function jpos_dat = ConvertKinectBin
% Function to read Kinect sensor timestamp and joint position binary files
% and export data as a structure with the following fields:
% skel_1, skel_2, ..., skel_6 (up to 6 skeletons. Empty skeletons are not
% recorded. Empty skeletons are those with all joints being not tracked)
% each of these fields has n_jts subfields, one for each joint.
% within each of these subfields, is a nframe * jt_per_tp  array giving
% coordinates and joint tracking status for each time point at each joint in each
% skeleton.
% 1st col: joint name
% 2nd col: x position data
% 3rd col: y position data
% 4th col: z position data
% 5th col: time data (millisecs)
% rows represent point position at a point in time
% See more at: https://kinectstreamsaver.codeplex.com/
% OPTIONS...
% joint order
j_ord = {'HIP_CENTER', 'SPINE', 'SHOULDER_CENTER', 'HEAD', 'SHOULDER_LEFT',...
    'ELBOW_LEFT', 'WRIST_LEFT', 'HAND_LEFT', 'SHOULDER_RIGHT', 'ELBOW_RIGHT',...
    'WRIST_RIGHT', 'HAND_RIGHT', 'HIP_LEFT', 'KNEE_LEFT', 'ANKLE_LEFT', 'FOOT_LEFT',...
    'HIP_RIGHT', 'KNEE_RIGHT', 'ANKLE_RIGHT', 'FOOT_RIGHT'};
% whether to display raw timestamp data (true or false)
disp_time = false;
% number of rows per time point in time data (always 5 I think)
td_rows_per_tp = 5;
% get number of values per joint per time point (always 4 I think)
jt_per_tp = 4;
% number of joints per skeleton (always 20 I think)
n_jts = 20;
% number of skeletons (always 6 I think)
n_skel = 6;
% GET TIME DATA
[fn,pn,fi] = uigetfile('*.binary','Get timestamp data');
if fi==0
    disp('No timestamp data chosen. Exiting ConvertKinectBin');
    return
end
% read file
fid = fopen(fullfile(pn,fn));
t_dat = fread(fid,'int64');
fclose(fid);
% change to this directory
cd(pn)
% reshape data
t_dat = transpose(reshape(t_dat,td_rows_per_tp,[]));
% display raw data from timestamp file, if set in options
if disp_time
    disp(uint32(t_dat))
end

% GET JOINT POSITION DATA
[fn,pn,fi] = uigetfile('.binary','Get joint position data');
if fi==0
    disp('No joint position data chosen. Exiting ConvertKinectBin');
    return
end
% read joint position file
fid = fopen(fullfile(pn,fn));
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
end

function is_skel_empty(skeldat)
% function takes a jt_per_tp * n_jts * nframe array and returns true if
% empty, otherwise false
end
















