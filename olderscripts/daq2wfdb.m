function daq2wfdb
%function to obtain a Matlab DAQ file containing an ECG trace and
%converting it into appropriate WFDB files for later analysis.
%
%check cygwin is running
button = questdlg('Is CYGWIN running?','Message from daq2wfdb','Yes','No','Yes');
if strcmp(button,'No')
    msgbox('Run Cygwin from the desktop and start again','Message from daq2wfdb')
    return
end
%get DAQ files
select = getlistfiles(pwd,'Select directory containing ECG signal files','Get file containing ECG signal (DAQ or MAT file)');
pname = [select.pth,'\'];
cd(pname)
for file_i = 1:length(select.files)
    fname = select.files{file_i}
    %get extension & read file
    [pathstr,name,ext,versn] = fileparts([pname,fname]);
    switch ext
        case '.daq'
            [data,time,abstime,events,daqinfo] = daqread([pname,fname],'DataFormat','native');
        case '.mat'
            daqdata = load([pname,fname]);
            data = daqdata.native_data;
            daqinfo = daqdata.ai_info;
        otherwise
            disp('no files trapped')
            return
    end
    %create a wfdb signal file...(http://www.physionet.org/physiotools/matlab/wfdb_tools/WFDB_tools/doc/wfdb_tools/node13.html)
    %
    %1) Create signal information structure
    no_sigs = size(data,2);
    if no_sigs > 1
        error('this version of daq2wfdb will only deal with one-signal files')
    end
    sigstruct = WFDB_Siginfo(no_sigs);
    %(C:\cygwin\home\wfdb_tools\WFDB_tools-0.5.3\doc\wfdb_tools\wfdb_tools.pdf
    %pg 34) fill in relevant fields for each signal
    for i = 1:no_sigs
        sigstruct(i).fname = name;
        sigstruct(i).adcres = 16;
    end
    %2) Create signal file. Set sample frequency, set basetime, write signal
    %vector to signal file.
    WFDB_osigfopen(sigstruct)
    WFDB_setsampfreq(daqinfo.ObjInfo.SampleRate);
    time = datestr(daqinfo.ObjInfo.InitialTriggerTime,13);
    date = datestr(daqinfo.ObjInfo.InitialTriggerTime,24);
    WFDB_setbasetime([time,' ',date])
    WFDB_putvec(double(data))
    WFDB_newheader(name)
    WFDB_wfdbquit
end
