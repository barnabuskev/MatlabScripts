% Script to process Wesley Connelan's Kinect skeletal data. To get the
% angle of abduction of the left shoulder from the anatomical position

% initialise
sc = 'SHOULDER_CENTER';
sl = 'SHOULDER_LEFT';
el = 'ELBOW_LEFT';
sp = 'SPINE';
headr = {'angle','time'};
savedir = 'C:\KinectData\Wesley\';

% Get file paths of kinect joint position and time stamp data
pathC = getjposfiles;

% For each data acquisition:
for shi = 1:size(pathC,1)
    
    % read skeletal data
    S = ConvertKinectBin(pathC{shi,1},pathC{shi,2});
    disp(['Subject: ',pathC{shi,3}])
    if isempty(S.time)
        disp(['Subject ',pathC{shi,3},' has no skeletal data'])
        break
    end
    % check if there is more than one skeletal data set
    if length(fieldnames(S)) > 2
        disp(['There is more than one set of skeletal data for subject ',pathC{shi,3}])
        break
    end
    
    % get time data & remove time field
    tdat = S.time;
    S = rmfield(S,'time');
    % extract coords of 'SHOULDER_LEFT', 'ELBOW_LEFT', 'SHOULDER_CENTER' & 'SPINE'
    tmp = fieldnames(S);
    skeldat = S.(tmp{1});
    % translate spine vector so SHOULDER_CENTER is at the origin
    svec = skeldat.(sp)(:,[1,2]) - skeldat.(sc)(:,[1,2]);
    % translate arm vector so SHOULDER_LEFT is at the origin
    avec = skeldat.(el)(:,[1,2]) - skeldat.(sl)(:,[1,2]);
    % calculate angles from vector (1,0) - interval [-180,180]
    sangs = atan2d(svec(:,2),svec(:,1));
    % convert to interval [0,-360]
    sangs(sangs>0) = sangs(sangs>0) - 360;
    % calculate angles from vector (1,0) - interval [-180,180]
    aangs = atan2d(avec(:,2),avec(:,1));
    % convert to interval [0,-360]
    aangs(aangs>0) = aangs(aangs>0) - 360;
    % get abduction angle
    abd = sangs - aangs;
    
    % save each aquisition as a CSV file of angles and timestamps
    outmat = mat2cellK([abd,tdat]);
    outC = [headr;outmat];
    outf = fullfile(savedir,['angles',pathC{shi,3},'.csv']);
    writecsv(outC,outf);
end