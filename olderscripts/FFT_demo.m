%FFT_demo
function FFT_demo()
%length of signal
sig_len = 5;
%sample rate
samp_rate = 8100;
%number of sample points
samp_points = sig_len * samp_rate;
t = linspace(0,sig_len,samp_points);
%frequency of sine wave in Hertz
input_freq = 300;
sig = sin(input_freq * pi * 2 * t);
gauss_error = randn(size(sig));
sig = sig + gauss_error;
fft_sig = fft(sig);
if length(fft_sig) ~= samp_points
    errordlg('length of fft should be same as number of samples!!')
end
subplot(3,1,1);
plot(t,sig)
axis tight
axis auto
subplot(3,1,2);
plot(fft_sig,'g.')
title('FFT in Complex Plane')
subplot(3,1,3);
frequencies = linspace(0,samp_rate,samp_points);
plot(frequencies(1:samp_points/2),abs(fft_sig(1:samp_points/2)));
axis tight
title('Power Spectrum')
xlabel('Frequency (Hertz)')