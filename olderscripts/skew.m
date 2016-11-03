function out = skew(vec)
%function to calculate the skew of a set of variables in vector 'vec'. See
%http://en.wikipedia.org/wiki/Skewness
%check if vec is a vector
if min(size(vec)) ~= 1
    errordlg('Error from skew','input should be a vector');
    return
end
m = mean(vec);
out = sum((vec - m).^3) * sqrt(length(vec)) / sum((vec - m).^2)^1.5;

