function varargout = ECGsetup(varargin)
% ECGSETUP M-file for ECGsetup.fig
%copyright Kevin Brownhill
%version 1 Aug 2005
%      ECGSETUP, by itself, creates a new ECGSETUP or raises the existing
%      singleton*.
%
%      H = ECGSETUP returns the handle to a new ECGSETUP or the handle to
%      the existing singleton*.
%
%      ECGSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ECGSETUP.M with the given input arguments.
%
%      ECGSETUP('Property','Value',...) creates a new ECGSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ECGsetup_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ECGsetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help ECGsetup
% Last Modified by GUIDE v2.5 23-Aug-2005 11:20:24
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ECGsetup_OpeningFcn, ...
                   'gui_OutputFcn',  @ECGsetup_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT




% --- Executes just before ECGsetup is made visible.
function ECGsetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ECGsetup (see VARARGIN)
%
% Called as follows: calibstate = ECGsetup(calibstate,ai,channel,dg_axes)
% dg_axes = handles of datagraph axes
handles.calibstate = varargin{1};
handles.ai = varargin{2};
handles.channel = varargin{3};
handles.dg_axes = varargin{4};
%set initial state of calibration radiobuttons & get handles & save
set(handles.high,'Value',1);
set(handles.low,'Value',0);
%set initial state of input voltage radio buttons & get handles
temp = handles.ai.Channel(handles.channel).InputRange;
temp = temp(2);
switch temp
    case 0.05
        set(handles.button005,'Value',1);
    case 0.5
        set(handles.button050,'Value',1);
    case 5
        set(handles.button500,'Value',1);
    case 10
        set(handles.button1000,'Value',1);
end
if handles.calibstate(1) & handles.calibstate(2)
    handles.initIR = temp;
end
%Set up instructions
handles.high_str = sprintf('%s%s%s',['Hold down the +5mV button on the top ',...
            'of the biopotential amplifier and click on the ''Ready'' button when you are ready.',...
            ' You will hear a beep when higher value calibration is complete.']);
handles.low_str = sprintf('%s',['Now select ''low'' button do the same for -5mV']);
if handles.calibstate(1) & handles.calibstate(2)
    set(handles.info,'FontSize',20);
    str = sprintf('\n%s','Calibrated!');
    set(handles.info,'String',str);
    set(handles.ready,'string','Recalibrate');
else
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
end
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ECGsetup_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure


% --- Executes on button press in low.
function low_Callback(hObject, eventdata, handles)
% hObject    handle to low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set radio buttons
set(handles.low,'Value',1);
set(handles.high,'Value',0);
guidata(hObject, handles);


% --- Executes on button press in high.
function high_Callback(hObject, eventdata, handles)
% hObject    handle to high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set radio buttons
set(handles.high,'Value',1);
set(handles.low,'Value',0);
guidata(hObject, handles);


% --- Executes on button press in ready.
function ready_Callback(hObject, eventdata, handles)
% hObject    handle to ready (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(handles.calibstate(1) & handles.calibstate(2)) %channel not calibrated
    if get(handles.high,'Value') %high button selected
        %save initial input range
        handles.initIR = handles.ai.Channel(handles.channel).InputRange;
        %inactivate input range buttons
        set(handles.button005,'Enable','off');
        set(handles.button050,'Enable','off');
        set(handles.button500,'Enable','off');
        set(handles.button1000,'Enable','off');
        %prepare data aquisition
        set(handles.ai,'TriggerType','Immediate');
        set(handles.ai,'LoggingMode','Memory');
        temp = get(handles.ai,'SampleRate');
        set(handles.ai,'SamplesPerTrigger',3 * temp)
        %get data
        start(handles.ai);
        data = getdata(handles.ai);
        %restore settings
        set(handles.ai,'TriggerType','Manual');
        set(handles.ai,'SamplesPerTrigger',inf);
        set(handles.ai,'LoggingMode','Disk');
        %get mean
        handles.avg_high = mean(data(:,handles.channel));
        beep
        %set calibration state
        handles.calibstate = [1,0];
        %display next instructions
        set(handles.info,'FontSize',8);
        set(handles.info,'String',handles.low_str);
    else %low button selected
        if handles.calibstate(1)
            set(handles.ai,'TriggerType','Immediate');
            set(handles.ai,'LoggingMode','Memory');
            temp = get(handles.ai,'SampleRate');
            set(handles.ai,'SamplesPerTrigger',3 * temp)
            start(handles.ai);
            data = getdata(handles.ai);
            set(handles.ai,'TriggerType','Manual');
            set(handles.ai,'SamplesPerTrigger',inf);
            set(handles.ai,'LoggingMode','Disk');
            handles.avg_low = mean(data(:,handles.channel));
            beep
            handles.calibstate = [1,1];
            set(handles.info,'FontSize',20);
            str = sprintf('\n%s','Calibrated!');
            set(handles.info,'String',str);
            set(handles.ready,'string','Recalibrate');
            %activate input range buttons
            set(handles.button005,'Enable','on');
            set(handles.button050,'Enable','on');
            set(handles.button500,'Enable','on');
            set(handles.button1000,'Enable','on');
        else
            beep
            msgbox('Calibrate High first!','Message from ECGSetup')
        end
    end
else %channel is calibrated
    handles.calibstate = [0,0];
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
    set(handles.ready,'string','Ready');
end
guidata(hObject, handles);


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%read axis UserData in temporary structure
temp_struct = get(handles.dg_axes,'UserData');
if ~handles.calibstate(1) | ~handles.calibstate(2)
    %..not fully calibrated
    %set status to completely uncalibrated
    handles.calibstate = [0,0];
else
    %..fully calibrated
    temp = handles.ai.Channel(handles.channel).InputRange;
    if handles.initIR ~= temp
        handles.calibstate = [0,0];
        set(handles.info,'FontSize',8)
        set(handles.info,'String',handles.high_str);
        set(handles.ready,'string','Ready');
        uiwait(msgbox('You will need to recalibrate','Message from ECGSetup','modal'));
        return
    end
    %calibrate channnel
    handles.ai.Channel(handles.channel).UnitsRange = [-5,5];
    handles.ai.Channel(handles.channel).SensorRange = [handles.avg_low,handles.avg_high];
    %set Units to millivolts
    handles.ai.Channel(handles.channel).Units = 'mV';
end
%save data structures. This is so that the calibration status
%of the channel associated with selected axis is stored 
%with the axis data.
temp_struct.calibstate = handles.calibstate;
set(handles.dg_axes,'UserData',temp_struct);
guidata(hObject, handles);
close
    
    
% --- Executes on closing ECG window
function close_ECG




% --- Executes on button press in button005.

function button005_Callback(hObject, eventdata, handles)
% hObject    handle to button005 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button005,'Value',1);
set(handles.button050,'Value',0);
set(handles.button500,'Value',0);
set(handles.button1000,'Value',0);
%alter channel to new input range
handles.ai.Channel(handles.channel).InputRange = [-0.05,0.05];
%Alter graph YLim property
set(handles.dg_axes,'YLim',[-0.05,0.05]);
%check if user has messed about with input values after calibrating
if handles.calibstate == [1,1] & handles.initIR ~= [-0.05,0.05]
    handles.calibstate = [0,0];
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
    set(handles.ready,'string','Ready');
    handles.ai.Channel(handles.channel).Units = 'Volts';
    uiwait(msgbox('You will need to recalibrate','Message from ECGSetup','modal'));
end
guidata(hObject, handles);


% --- Executes on button press in button050.
function button050_Callback(hObject, eventdata, handles)
% hObject    handle to button050 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button005,'Value',0);
set(handles.button050,'Value',1);
set(handles.button500,'Value',0);
set(handles.button1000,'Value',0);
%alter channel to new input range
handles.ai.Channel(handles.channel).InputRange = [-0.5,0.5];
%Alter graph YLim property
set(handles.dg_axes,'YLim',[-0.5,0.5]);
%check if user has messed about with input values after calibrating
if handles.calibstate == [1,1] & handles.initIR ~= [-0.5,0.5]
    handles.calibstate = [0,0];
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
    set(handles.ready,'string','Ready');
    handles.ai.Channel(handles.channel).Units = 'Volts';
    uiwait(msgbox('You will need to recalibrate','Message from ECGSetup','modal'));
end
guidata(hObject, handles);


% --- Executes on button press in button500.
function button500_Callback(hObject, eventdata, handles)
% hObject    handle to button500 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button005,'Value',0);
set(handles.button050,'Value',0);
set(handles.button500,'Value',1);
set(handles.button1000,'Value',0);
%alter channel to new input range
handles.ai.Channel(handles.channel).InputRange = [-5,5];
%Alter graph YLim property
set(handles.dg_axes,'YLim',[-5,5]);
%check if user has messed about with input values after calibrating
if handles.calibstate == [1,1] & handles.initIR ~= [-5,5]
    handles.calibstate = [0,0];
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
    set(handles.ready,'string','Ready');
    handles.ai.Channel(handles.channel).Units = 'Volts';
    uiwait(msgbox('You will need to recalibrate','Message from ECGSetup','modal'));
end
guidata(hObject, handles);


% --- Executes on button press in button1000.
function button1000_Callback(hObject, eventdata, handles)
% hObject    handle to button1000 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button005,'Value',0);
set(handles.button050,'Value',0);
set(handles.button500,'Value',0);
set(handles.button1000,'Value',1);
%alter channel to new input range
handles.ai.Channel(handles.channel).InputRange = [-10,10];
%Alter graph YLim property
set(handles.dg_axes,'YLim',[-10,10]);
%check if user has messed about with input values after calibrating
if handles.calibstate == [1,1] & handles.initIR ~= [-10,10]
    handles.calibstate = [0,0];
    set(handles.info,'FontSize',8)
    set(handles.info,'String',handles.high_str);
    set(handles.ready,'string','Ready');
    handles.ai.Channel(handles.channel).Units = 'Volts';
    uiwait(msgbox('You will need to recalibrate','Message from ECGSetup','modal'));
end
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over done.
function done_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function done_CreateFcn(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function done_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


