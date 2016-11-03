function varargout = distlogmap(r)
%function to examine the distribution of population values for the logistic
%map model of population growth. 'r' is the parameter of the model. For r >
%3.57, it is mostly chaotic
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%inititial number of iterations to ignore
ign = 1000;
%number of iterations of model
its = 10000;
%initial population
p = 0.48;
%do initial ignored iterations
for ia = 1:ign
    p = iter(r,p);
end
Y = [];
for ia = 1:its
    Y = [Y;p];
    p = iter(r,p);
end
hist(Y,sqrt(its))
if nargout == 1
    varargout{1} = Y;
end


function out = iter(r,p)
%function to output one iteration of the logistic map model of population growth
out = r .* p .* (1.-p);