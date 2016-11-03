function varargout = getcounts(varargin)
% GETCOUNTS M-file for getcounts.fig
%      GETCOUNTS, by itself, creates a new GETCOUNTS or raises the existing
%      singleton*.
%
%      H = GETCOUNTS returns the handle to a new GETCOUNTS or the handle to
%      the existing singleton*.
%
%      GETCOUNTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETCOUNTS.M with the given input arguments.
%
%      GETCOUNTS('Property','Value',...) creates a new GETCOUNTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before getcounts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to getcounts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help getcounts

% Last Modified by GUIDE v2.5 10-Jul-2012 16:47:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @getcounts_OpeningFcn, ...
                   'gui_OutputFcn',  @getcounts_OutputFcn, ...
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


% --- Executes just before getcounts is made visible.
function getcounts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to getcounts (see VARARGIN)

% Choose default command line output for getcounts
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes getcounts wait for user response (see UIRESUME)
% uiwait(handles.getcounts_fig);


% --- Outputs from this function are returned to the command line.
function varargout = getcounts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function enterhb_edit_Callback(hObject, eventdata, handles)
% hObject    handle to enterhb_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get input
inp = str2double(get(hObject,'String'));
if ~isnan(inp) && rem(inp,1) == 0
    % user has entered a valid number
    % get userdata & store count
    passdat = get(handles.getcounts_fig,'userdata');
    passdat.count = inp;
    set(handles.getcounts_fig,'userdata',passdat);
    % restore focus to main figure
    set(hObject, 'Enable', 'off');
    drawnow;
    set(hObject, 'Enable', 'on');
    % resume main script
    uiresume(handles.getcounts_fig)
else
    % user not entered a valid number
    errordlg('invalid entry')
end
%user has entered a valid number


% --- Executes during object creation, after setting all properties.
function enterhb_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enterhb_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
