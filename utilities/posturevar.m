function rslt = posturevar
% function to:
% 1) fit circles to hemispherical markers
% 2) obtain coords of center of hemispheres
% 3) carry out Procrustes shape analysis to obtain main modes of variation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get batch of files
[fn,pn,fi] = uigetfile('*.xls','Get coordinate file','/home/kevin/Documents/Work/BSO/Students');
if ~fi
    return
end
cd(pn)
fp = [pn,fn];
[status,sheets] = xlsfinfo(fp);
nsbj = length(sheets);
crds = cell(nsbj,1);
for ia = 1:length(sheets)
    raw = xlsread(fp,sheets{ia});
    if size(raw,1) ~= 21
    	disp(['Sheet ',sheets{ia},' does not contain 21 coordinates!!']);
    	continue
    end
    % create empty matrix for coords
    tmpc = zeros(5,2);
    % convert to cartesian coords
    raw(:,2) = -raw(:,2);
    % plot
    plot(raw(:,1),raw(:,2))
    axis equal
    % save first coord
    tmpc(1,:) = raw(1,:);
    % fit circles
    for ib = 1:4
    	si = (ib-1)*5+1;
    	prms = CircleFitByTaubin(raw(si:si+4,:));
    	tmpc(ib+1,:) = prms(1:2)
    end
    crds{ia} = 
end

