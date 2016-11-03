%Filter_daq Version 1
%function to display data from DAQ files and its Fourier
%transform & allow the user to filter the result by entering
%stop bands & display the resulting Fourier transform & filtered
%signal. 
%Copyright Kevin Brownhill March 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%obtain DAQ file
function Filter_daq
[fname,pname] = uigetfile('*.daq', 'Get Daq file');
[p,input_name,input_ext,v] = fileparts([pname,fname]);
[data,time] = daqread([pname,fname]);
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
plot(time,data,'ButtonDownFcn',@click_handler);
title('Unfiltered Signal')
axis tight
xlim_time = get(gca,'XLim');
ylim_time = get(gca,'YLim');
set(gca,'ButtonDownFcn',@click_handler)
%plot spectrum before filtering
subplot(2,2,3);
plot(frequencies(1:ceil(samp_points/2)),spectr(1:ceil(samp_points/2)),'ButtonDownFcn',@click_handler);
title('Unfiltered Power Spectrum')
xlabel('Frequency (Hertz)')
axis tight
xlim_freq = get(gca,'XLim');
ylim_freq = get(gca,'YLim');
set(gca,'ButtonDownFcn',@click_handler)
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
plot(time,filt_data,'r','ButtonDownFcn',@click_handler)
title('Filtered Signal');
set(gca,'XLim',xlim_time,'YLim',ylim_time,'ButtonDownFcn',@click_handler)
%plot spectrum after filtering
subplot(2,2,4);
plot(frequencies(1:ceil(samp_points/2)),filt_spectr(1:ceil(samp_points/2)),'r','ButtonDownFcn',@click_handler);
title('Filtered Power Spectrum')
set(gca,'XLim',xlim_freq,'YLim',ylim_freq,'ButtonDownFcn',@click_handler)
xlabel('Frequency (Hertz)')
%save filtered as mat file
native_data = int16((real(filt_data) - ai_info.ObjInfo.Channel.NativeOffset) / ai_info.ObjInfo.Channel.NativeScaling);
[fn,pn] = uiputfile('*.mat','Save filtered data',[input_name,'_filt.mat']);
save([pn,fn],'native_data','ai_info')

function click_handler(obj,eventdata)
%function to increase x-axis scale when axis clicked
%in its upper half, and decrease scale to previous scale
%when clicked in lower half.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get handle of axis if line object clicked on
if strcmp(get(obj,'type'),'line')
    obj = get(obj,'Parent');
end
%see which half of axis clicked on
CP = get(obj,'CurrentPoint');
YL = get(obj,'YLim');
if CP(1,2) >= (YL(1) + YL(2))/2
    %enlarge
    %%%%%%%%%
    %store current XLim in UserData cell array
    scales = get(obj,'UserData');
    if isempty(scales)
        scales = {};
    end
    XL = get(obj,'XLim');
    scales = {scales{:},XL};
    set(obj,'UserData',scales);
    %obtain new XLim interval & set
    set(obj,'XLim',newXL(XL,CP));
else
    %reduce
    %%%%%%%%
    scales = get(obj,'UserData');
    if ~isempty(scales);
        set(obj,'XLim',scales{end});
        if length(scales) > 1
            scales = scales(1:end-1);
        else
            scales = {};
        end
        set(obj,'UserData',scales);
    end
end


function out = newXL(in,pointer)
%divide XLim into 5 equal intervals
divs = linspace(in(1),in(2),6);
%find which interval mouse click lives
logic = pointer(1,1) > divs;
temp = find(xor(logic(1:end-1),logic(2:end)));
out = [divs(temp),divs(temp + 1)];

