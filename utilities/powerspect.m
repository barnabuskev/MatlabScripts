function [power,f] = powerspect(dat,sr)
%function to calculate power spectrum of vector or matrix of column
%vectors. Requires 2 arguments: data and sample rate, and
%outputs spectrum and vector of frequencies of same length as spectrum e.g.
%[power,f] = powerspect(data,samplerate).
%test:
%cycles = 50;freq = 2;sr = 100;t = 0:1/sr:cycles/freq;sig = sin(t*2*pi*freq);
%[power,f] = powerspect(sig,sr);plot(f,power)
if ~isequal(class(dat),'double')
    error('Input must be array of doubles')
end
if ndims(dat) ~= 2
    error('input must be a vector or matrix')
end
if ~isscalar(sr)
    error('sample rate must be a scalar')
end
if isvector(dat)
    np = length(dat);
else
    np = size(dat,1);
end
tmp = fft(dat,np) / np;
fpts = round(np/2);
power = 2 * abs(tmp(1:fpts));
f = sr/2*linspace(0,1,fpts);