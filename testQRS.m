% function to test qrs detection on normal subject data from PTB database. This data is stored as a a signed 16 bit binary data with each channel, of 12 channels, interleaved. i.e. each channel is sampled in turn
% load data
function testQRS
sr = 1000;
dattype = "int16";
[infl,inpth,fi] = uigetfile("*.dat","Select data file from PTB database");
if infl == 0
	disp('No file selected')
	return
end
fptr = fopen([inpth,infl]);
% read data
[vals,cnt] = fread(fptr,dattype);
fclose(fptr);
% convert into matrix form, rows represent channels
chnls = reshape(vals,12,cnt/12);

% display results of qrs detection
nchk = 5; %number of chunks to divide channel into
ns = size(chnls,2); % number of samples
chksz = ns / nchk; %size of chunk
meth = 1; %qrs detection method (see qrsdetect.m documentation)
for ia = 1:1
	%detect qrs'
	dat = chnls(ia,:)';
	HDR = qrsdetect(dat,sr,meth);
	qrs = HDR.EVENT.POS;
	for ib = 1:nchk
		intv = (ib-1)*chksz+1:(ib)*chksz;
		plot(intv,dat(intv));
		%get relevant qrs positions
		qrsc = qrs(qrs >= min(intv) & qrs <= max(intv));
		%plot qrs marks at 1/2 hieght of axis
		yl = get(gca,'ylim');
		ys = ((yl(2) - yl(1)) / 2 + yl(1)) * ones(length(qrsc),1);
		text(qrsc,ys,'O','color','r','horizontalalignment','center','fontsize',32,'fontweight','bold');
		pause(0.4)
	end
end

