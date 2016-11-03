%test fft
%length of signal in seconds
sig_length = 10;
%frequency of signal in Hz
freq = 20;
%sample rate in samples per second
s_rate = 200;
%create sampling grid of (sample rate X length of signal + 1) samples
no_samples = s_rate * sig_length;
samp_period = sig_length / no_samples;
t = 0:samp_period:sig_length;
%create signal
sig = sin(freq*t*2*pi);
plot(0:200/(length(abs(fft(sig)))-1):200,abs(fft(sig)))