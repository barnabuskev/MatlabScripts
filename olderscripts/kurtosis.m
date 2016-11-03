function out = kurtosis(vec)
%function to calculate the kurtosis of a set of variables in vector 'vec'. See
%http://en.wikipedia.org/wiki/Kurtosis
%check if vec is a vector
if min(size(vec)) ~= 1
    errordlg('Error from kurtosis','input should be a vector');
    return
end
m = mean(vec);
out = (sum((vec - m).^4) * length(vec) / sum((vec - m).^2)^2) - 3;
