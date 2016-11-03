function outm = centremean(in)
%centre in about its mean
mn = repmat(mean(in),size(in,1),1);
outm = in - mn;