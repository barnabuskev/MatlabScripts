function out = withinsubjsd(dat)
%function to compute the within-subject standard deviation for a set of
%ratings 'dat'. Each column represents a rating/measurement and each row
%represents a subject or target of measurement.
%number of raters/ratings
k = size(dat,2);
%number of targets
n = size(dat,1);
%mean per target
mpt = mean(dat,2);
%mean per rater/rating
mpr = mean(dat);
%get total mean
tm = mean(mpt);
%within target sum sqrs
WSS = sum(sum(bsxfun(@minus,dat,mpt).^2));
%within target mean sqrs
WMS = WSS / (n * (k - 1));
%return within subject standard deviation
out = sqrt(WMS);