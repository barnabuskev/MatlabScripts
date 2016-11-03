%Filter_daq Version 2
%function to display data from DAQ files and its Fourier
%transform & allow the user to filter the result by entering
%stop bands & display the resulting Fourier transform & filtered
%signal. 
%Copyright Kevin Brownhill March 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%obtain DAQ file
function Filter_daq2
cd('Y:\BSO\StudentFolders')
[fname,pname] = uigetfile('*.daq', 'Get Daq file');
[p,input_name,input_ext,v] = fileparts([pname,fname]);
[data,time] = daqread([pname,fname]);
%subtract mean from data in order to avoid a large value for zero in the
%frequency spectrum
data = data - mean(data);
%obtain relevant parameters from DAQ file
ai_info = daqread([pname,fname],'info');
samp_rate = ai_info.ObjInfo.SampleRate;
samp_points = length(data);
frequencies = linspace(0,samp_rate,samp_points);
fft_data = fft(data);
spectr = abs(fft_data);
%plot signal before filtering
subplot(2,2,1);
set(gcf,'name',[pname,fname])
plot(time,data);
title('Unfiltered Signal')
axis tight
xlim_time = get(gca,'XLim')
ylim_time = get(gca,'YLim');
xt = get(gca,'XTick');
xt = [xt,round(xlim_time(2))]
set(gca,'XMinorTick','on','XTick',xt)
%plot spectrum before filtering
subplot(2,2,3);
plot(frequencies(1:ceil(samp_points/2)),spectr(1:ceil(samp_points/2)));
title('Unfiltered Power Spectrum')
xlabel('Frequency (Hertz)')
axis tight
xlim_freq = get(gca,'XLim');
ylim_freq = get(gca,'YLim');
xt = get(gca,'XTick');
xt = [xt,round(xlim_freq(2))]
set(gca,'XMinorTick','on','XTick',xt)
conv_fact = samp_points / samp_rate;
button = 'Yes';
while strcmp(button,'Yes')
    answer = inputdlg('input a frequency range to remove: ');
    if isempty(answer)
        button = 'No';
    else
        button = questdlg('Do you wish to enter another range Sir/Madam?');
        range = eval(answer{1});
        stop_band = round((range(1) * conv_fact + 1):(range(end) * conv_fact + 1));
        fft_data([stop_band,end-stop_band]) = 0;
    end
end
filt_spectr = abs(fft_data);
filt_data = ifft(fft_data);
%plot signal after filtering
subplot(2,2,2)
plot(time,filt_data,'r')
title('Filtered Signal');
set(gca,'XLim',xlim_time,'YLim',ylim_time,'XMinorTick','on')
%plot spectrum after filtering
subplot(2,2,4);
plot(frequencies(1:ceil(samp_points/2)),filt_spectr(1:ceil(samp_points/2)),'r',);
title('Filtered Power Spectrum')
set(gca,'XLim',xlim_freq,'YLim',ylim_freq,'XMinorTick','on')
xlabel('Frequency (Hertz)')
%save filtered as mat file
native_data = int16((real(filt_data) - ai_info.ObjInfo.Channel.NativeOffset) / ai_info.ObjInfo.Channel.NativeScaling);
[fn,pn] = uiputfile('*.mat','Save filtered data',[input_name,'_filt.mat']);
save([pn,fn],'native_data','ai_info')

