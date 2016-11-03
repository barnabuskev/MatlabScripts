function outcell = rmsstr2cell(in)
%convert RMS struct to cell
mxl = max(arrayfun(@(x) length(x.rms),in));
nsb = length(in);
outcell = cell(mxl+1,nsb + 1);
[outcell{:}] = deal('NA');
for ia = 1:nsb
    tmp = mat2cellk(in(ia).rms);
    outcell(2:length(tmp) + 1,ia) = tmp;
    outcell{1,ia} = in(ia).subj;
    %write time variable
    tmp = mat2cellk(1:mxl);
    outcell(2:end,end) = tmp;
    outcell{1,end} = 'time';
end
