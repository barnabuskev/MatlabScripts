function varargout = EMGtimer(varargin)
% EMGTIMER MATLAB code for EMGtimer.fig
%      EMGTIMER, by itself, creates a new EMGTIMER or raises the existing
%      singleton*.
%
%      H = EMGTIMER returns the handle to a new EMGTIMER or the handle to
%      the existing singleton*.
%
%      EMGTIMER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGTIMER.M with the given input arguments.
%
%      EMGTIMER('Property','Value',...) creates a new EMGTIMER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EMGtimer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EMGtimer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EMGtimer

% Last Modified by GUIDE v2.5 10-Oct-2014 09:00:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EMGtimer_OpeningFcn, ...
                   'gui_OutputFcn',  @EMGtimer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function EMGtimer_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before EMGtimer is made visible.
% This function has no output args, see OutputFcn.
% create temporary structure to put data for this EMG trace
% read current contents of breath and muscle and save
contents = cellstr(get(handles.breathpop,'String'));
breath = contents{get(handles.breathpop,'Value')};
contents = cellstr(get(handles.mscpop,'String'));
muscle = contents{get(handles.mscpop,'Value')};
tmp_strct = struct('subject','','muscle',muscle,'breath',breath,'start',[],'stop',[]);
set(hObject,'UserData',tmp_strct)
%set(hObject.UserData,tmp_strct)
% Choose default command line output for EMGtimer
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


function varargout = EMGtimer_OutputFcn(hObject, eventdata, handles) 
% Outputs from this function are returned to the command line.
% Get default command line output from handles structure
varargout{1} = handles.output;


function timerbut_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Executes on button press in timerbut.
tnow = clock;
fig_h = get(hObject,'Parent');
tmp_strct = get(fig_h,'UserData');
if strcmp(get(hObject,'String'),'Start')
    tmp_strct.start = tnow;
    set(fig_h,'UserData',tmp_strct)
    set(hObject,'String','Stop')
    set(hObject,'BackgroundColor','red')
    guidata(hObject, handles);
else
    tmp_strct.stop = tnow;
    % save data into dat_strct
    dat_strct = getappdata(0,'dat_strct');
    dat_strct.EMGtrace = [dat_strct.EMGtrace,tmp_strct];
    setappdata(0,'dat_strct',dat_strct);
    close(fig_h)
end



function sbjtxt_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% subject code
% overwrite subject name in tmp_strct every timecallback is called
fig_h = get(hObject,'Parent');
tmp_strct = get(fig_h,'UserData');
tmp_strct.subject = get(hObject,'String');
set(fig_h,'UserData',tmp_strct)
guidata(hObject, handles);

function sbjtxt_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% subject code


function breathpop_Callback(hObject, eventdata, handles)
% breath popup menu
% overwrite breath variable in tmp_strct every timecallback is called
fig_h = get(hObject,'Parent');
tmp_strct = get(fig_h,'UserData');
contents = cellstr(get(hObject,'String'));
tmp_strct.breath = contents{get(hObject,'Value')};
set(fig_h,'UserData',tmp_strct)
guidata(hObject, handles);

function breathpop_CreateFcn(hObject, eventdata, handles)
% breath popup menu



function mscpop_Callback(hObject, eventdata, handles)
% Muscle popup menu
% overwrite muscle variable in tmp_strct every timecallback is called
fig_h = get(hObject,'Parent');
tmp_strct = get(fig_h,'UserData');
contents = cellstr(get(hObject,'String'));
tmp_strct.muscle = contents{get(hObject,'Value')};
set(fig_h,'UserData',tmp_strct)
guidata(hObject, handles);

function mscpop_CreateFcn(hObject, eventdata, handles)
% Muscle popup menu
