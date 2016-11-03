function varargout = EMGsession(varargin)
% EMGSESSION MATLAB code for EMGsession.fig
%      EMGSESSION, by itself, creates a new EMGSESSION or raises the existing
%      singleton*.
%
%      H = EMGSESSION returns the handle to a new EMGSESSION or the handle to
%      the existing singleton*.
%
%      EMGSESSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGSESSION.M with the given input arguments.
%
%      EMGSESSION('Property','Value',...) creates a new EMGSESSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EMGsession_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EMGsession_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EMGsession

% Last Modified by GUIDE v2.5 25-Sep-2014 09:17:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EMGsession_OpeningFcn, ...
    'gui_OutputFcn',  @EMGsession_OutputFcn, ...
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

% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EMGsession (see VARARGIN)


% --- Executes just before EMGsession is made visible.
function EMGsession_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% Choose default command line output for EMGsession
% create data structure
snm = get(handles.seshnametxt,'String');
pdir = get(handles.projdirtxt,'String');
dat_strct = struct('prj_dir',pdir,'session',snm,'EMGtrace',[]);
setappdata(0,'dat_strct',dat_strct);
handles.output = handles;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EMGsession wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EMGsession_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;


function seshnametxt_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% name of session
dat_strct = getappdata(0,'dat_strct');
dat_strct.session = get(hObject,'String');
setappdata(0,'dat_strct',dat_strct);

function seshnametxt_CreateFcn(hObject, eventdata, handles)
% name of session
sesh = ['sesh_',datestr(date,'yyyy_mm_dd'),'_01'];
set(hObject,'String',sesh)



function projdirtxt_Callback(hObject, eventdata, handles)
% project directory path
dat_strct = getappdata(0,'dat_strct');
dat_strct.prj_dir = get(hObject,'String');
setappdata(0,'dat_strct',dat_strct);

function projdirtxt_CreateFcn(hObject, eventdata, handles)
% project directory path
set(hObject,'String',pwd)


function newEMG_Callback(hObject, eventdata, handles)
% open new EMG interval timing window
EMGtimer_fig_h = EMGtimer;
uiwait(EMGtimer_fig_h)
% save data
dat_strct = getappdata(0,'dat_strct');
snm = get(handles.seshnametxt,'String');
pdir = get(handles.projdirtxt,'String');
save([pdir,filesep,snm],'dat_strct')
% inform user
msgh = msgbox(['Data added to ',snm], 'Data saved','help');
uiwait(msgh,2)
try
    close(msgh)
catch
end


function getdirbut_Callback(hObject, eventdata, handles)
% Executes on button press in getdirbut.
prjdir = uigetdir(get(handles.projdirtxt,'String'),'Select project directory');
if prjdir ~= 0
    set(handles.projdirtxt,'String',prjdir)
    dat_strct = getappdata(0,'dat_strct');
    dat_strct.prj_dir = prjdir;
    setappdata(0,'dat_strct',dat_strct);
end
