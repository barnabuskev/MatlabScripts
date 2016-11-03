function out = get_hrv
%function to read a set of wfdb ECG annotation files to work out power
%spectrum, integrated LF power (summed from 0.04-0.15Hz), integrated HF
%power (summed from 0.15-0.4Hz) & normalised LF & HF (LF/(total power -  power <= 0.04Hz), same for HF )
button = questdlg('Is CYGWIN running?','Message from get_hrv','Yes','No','Yes');
if strcmp(button,'No')
    msgbox('Run Cygwin from the desktop and start again','Message from daq2wfdb')
    return
end
%function to obtain heart rate variability power spectra from a load of
%wfdb siganl and annotation files using tach and fft from physiotolkit
select = getlistfiles('C:\cygwin\home\kevinb\ecg_records','Get directory containing wfdb files & annotations','select wfdb files');
cd(select.pth)
outfile = ['temp',num2str(round(rand*10000000))];
cnt = 1;
for file_i = 1:length(select.files)
    k = strfind(select.files{file_i},'.');
    if isempty(k)
        [status, result] = system(['tach -r ',select.files{file_i},' -a qrs > ',outfile]);
        if status
            disp(['file '],select.files{file_i},' was not processed correctly')
        else
            rr_ints = load(outfile);
            freq_dom = fft(rr_ints);
            power = freq_dom .* conj(freq_dom);
            N = length(power);
            %nyquist is half sampling frequency (2 Hz)
            nyquist = 1;
            freq = (1:N/2)/(N/2)*nyquist;
            plot(freq(2:end),power(2:length(freq)))
            grid on
            xlabel('Frequency (Hz)')
            s = regexprep(select.files{file_i},'_','\_');
            title(['HRV: ',s])
            out(cnt).file = select.files{file_i};
            out(cnt).spectr = [freq',power(1:length(freq))];
            tot = sum(power(find(freq' > 0.04)));
            out(cnt).LF = sum(power(find(freq' > 0.04 & freq' < 0.15)));
            out(cnt).HF = sum(power(find(freq' > 0.15 & freq' < 0.4)));
            out(cnt).LF_norm = out(cnt).LF / tot;
            out(cnt).HF_norm = out(cnt).HF / tot;
            out(cnt).LFHFratio = out(cnt).LF / out(cnt).HF;
            pause
            cnt = cnt + 1;
        end
    end
end
[fn,pn] = uiputfile('*.csv','Save data as...')
fid = fopen([pn,fn,'.csv'],'w');
fprintf(fid,'%s,','file');
fprintf(fid,'%s,','LF');
fprintf(fid,'%s,','HF');
fprintf(fid,'%s,','LF norm');
fprintf(fid,'%s,','HF norm');
fprintf(fid,'%s\n','LF/HF ratio');
for i = 1:length(out)
    fprintf(fid,'%s,',out(i).file);
    fprintf(fid,'%g,',out(i).LF);
    fprintf(fid,'%g,',out(i).HF);
    fprintf(fid,'%g,',out(i).LF_norm);
    fprintf(fid,'%g,',out(i).HF_norm);
    fprintf(fid,'%g\n',out(i).LFHFratio);
end
fclose(fid);