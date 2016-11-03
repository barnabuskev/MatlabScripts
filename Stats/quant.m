function varargout = quant(vec,at)
%function to return the quantiles at locations for 'vec'
if ~isvector(vec) || isscalar(vec)
    error('input data should be a vector')
end
if ~isvector(at)
    error('at should be a vector')
end
if size(vec,1) == 1
    vec = vec';
end
n = length(vec);
cump = (((1:n) - 0.5) / n)';
vec = sort(vec);
switch nargout
    case 1
        varargout{1} = interp1(cump,vec,at);
    case 2
        varargout{1} = interp1(cump,vec,at);
        varargout{2} = cump;
end
