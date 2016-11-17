Instructions to open "Joint_Position_....binary" in MATLAB:

fid = fopen('C:\KinectData\Skel\liTimeStamp.binary');
B = fread(fid,'int64');
fclose(fid);

n = 4; % No. of columns of T
BB = reshape(B, n,[]);
T = permute(BB,[2,1]);

fid = fopen('C:\KinectData\Skel\Joint_Position.binary');
A = fread(fid,'float');
fclose(fid);
A(A>5)= 0;
A(A<-5)= 0;
jointNumber = 20;
tracks = 6;
AAAA = reshape(A, 4,jointNumber,tracks,[]);
sensor.Skeleton = permute(AAAA,[1,2,4,3]);
