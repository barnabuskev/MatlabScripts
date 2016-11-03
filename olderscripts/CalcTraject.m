function out = CalcTraject
%function to take a results file from Mia Rabjohn's project & calculate the
%average length of the tragectory per frame of the centre of the ping pong ball
%obtain a results file
allresults = getlistfiles('C:\StudentsStuff\MiaRabjohn\Results','Get directory of results','select all results files');
%Process each result file in turn
out = {};
for i = 1:length(allresults.files)
    fn = allresults.files{i};
    result = load([allresults.pth,'\',fn]);
    %extract centre coords & convert to matrix
    temp = cell2mat(result.pts(:,3));
    %calculate length of tragectory of centre of ball
    frms = size(temp,1);
    traj = 0;
    for j = 1:frms-1
        diffvect = temp(j,:) - temp(j+1,:);
        traj = traj + norm(diffvect);
    end
    out = [out;{fn},{traj/frms}];
end
%store results
[outfn,outpn] = uiputfile(fn,'Store mean trajectory lengths');
save([outpn,outfn],'out');
