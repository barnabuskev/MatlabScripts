function varargout = projectemo(varargin)
% Function to record whether two objects are rated as the same or
% different. If a subject does not respond in time, press Ctrl+x to record
% as a non-response. Press Ctrl+b to delete the last mouse/touchpad click.
% Coding of responses is as follows: 'not same' = 0,
% 'same' = 1, 'no response' = 2.
% 

% PROJECTEMO MATLAB code for projectemo.fig
%      PROJECTEMO, by itself, creates a new PROJECTEMO or raises the existing
%      singleton*.
%
%      H = PROJECTEMO returns the handle to a new PROJECTEMO or the handle to
%      the existing singleton*.
%
%      PROJECTEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTEMO.M with the given input arguments.
%
%      PROJECTEMO('Property','Value',...) creates a new PROJECTEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projectemo

% Last Modified by GUIDE v2.5 07-Oct-2014 15:10:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @projectemo_OpeningFcn, ...
    'gui_OutputFcn',  @projectemo_OutputFcn, ...
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
end


function projectemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
ud.yready = false;
ud.sready = false;
ud.data.sbj = '';
ud.data.year = '';
ud.data.cmps = [];
ud.tmp = [];
ud.savefile = '';
% read wav files
cd('C:\Users\Researcher\Documents\MATLAB\ProjectEmo')
[ud.same,Fs] = audioread('same.wav');
[ud.notsame,Fs] = audioread('notsame.wav');
ud.fs = Fs;
set(hObject,'UserData',ud)
% Choose default command line output for projectemo
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
end


function varargout = projectemo_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
end


function yearpop_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% side
% get ud and make ud.yready true if year chosen
fig_h = get(hObject,'Parent');
ud = get(fig_h,'UserData');
contents = cellstr(get(hObject,'String'));
year = contents{get(hObject,'Value')};
ud.yready = ~strcmp(year,'NA');
set(fig_h,'UserData',ud);
% update readytxt and donetxt if both true
if ud.yready && ud.sready
    reset(handles)
end
end

function yearpop_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% side
end


function subjtxt_Callback(hObject, eventdata, handles)
% subject code
% get ud and make ud.sready true string entered
fig_h = get(hObject,'Parent');
ud = get(fig_h,'UserData');
code = get(hObject,'String');
ud.sready = ~isempty(code);
set(fig_h,'UserData',ud);
% update readytxt & donetxt if both true
if ud.yready && ud.sready
    reset(handles)
end
end

function subjtxt_CreateFcn(hObject, eventdata, handles)
% subject code
end


function numcomps_Callback(hObject, eventdata, handles)
% number of comparisons
end

function numcomps_CreateFcn(hObject, eventdata, handles)
% number of comparisons
end


function reset(handles)
ud = get(handles.figure1,'UserData');
set(handles.readytxt,'String','Ready')
set(handles.readytxt,'BackgroundColor','green')
set(handles.subjtxt,'enable','off')
set(handles.yearpop,'enable','off')
set(handles.donetxt,'enable','inactive')
set(handles.figure1,'KeyPressFcn',{@figure1_KeyPressFcn,handles})
set(handles.figure1,'WindowButtonDownFcn',{@figure1_WindowButtonDownFcn,handles})
%wait until Ctrl+d pressed allowing mouse click data to be obtained
uiwait(handles.figure1)
ud = get(handles.figure1,'UserData');
% unset callbacks
set(handles.figure1,'WindowButtonDownFcn','')
set(handles.figure1,'KeyPressFcn','')
% get subject and year data
contents = cellstr(get(handles.yearpop,'String'));
year = contents{get(handles.yearpop,'Value')};
if isempty(ud.data(1).sbj)
    ud.data.sbj = get(handles.subjtxt,'String');
    ud.data.year = year;
    ud.data.cmps = ud.tmp;
else
    nextfree = length(ud.data)+1;
    ud.data(nextfree).sbj = get(handles.subjtxt,'String');
    ud.data(nextfree).year = year;
    ud.data(nextfree).cmps = ud.tmp;
end
ud.tmp = [];
set(handles.subjtxt,'enable','on')
ud.sready = false;
set(handles.yearpop,'enable','on')
ud.yready = false;
% change ready text
set(handles.readytxt,'String','Not Ready')
set(handles.readytxt,'BackgroundColor','red')
set(handles.figure1,'UserData',ud)
set(handles.numcomps,'String','0');
set(handles.donetxt,'enable','off')
savedat(handles.figure1)
end


function savedat(fig_h)
ud = get(fig_h,'UserData');
datcell(1,:) = {'subject','side','compares'};
if isempty(ud.savefile)
    [fn, pn, fi] = uiputfile('*.csv','Select save file');
    if fi == 0
        return
    end
    sf = [pn,fn];
    % store fine path
    ud.savefile = sf;
else
    sf = ud.savefile;
end
% save data as CSV file...
% create cell array
N = length(ud.data);
for ia = 1:N
    % get number of comparisons
    ncmp = length(ud.data(ia).cmps);
    if ncmp == 0
        continue
    end
    % create cell array of year and subject of same length as cmps
    sbjtmp = repmat(ud.data(ia).sbj,ncmp,1);
    sbjtmp = cellstr(sbjtmp);
    yeartmp = repmat(ud.data(ia).year,ncmp,1);
    yeartmp = cellstr(yeartmp);
    % convert cmps to cell array
    cmpstmp = num2cell(ud.data(ia).cmps);
    datcell = [datcell;[sbjtmp,yeartmp,cmpstmp']]; %#ok<AGROW>
end
%save cell array
cell2csv(sf, datcell)
set(fig_h,'UserData',ud);
end


function figure1_KeyPressFcn(src, eventdata, handles)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
if length(eventdata.Modifier) ~= 1 || ~strcmp(eventdata.Modifier,'control')
    return
end
switch eventdata.Key
    case 'd'
        % Ctrl + d pressed - save data and restart
        uiresume(src)
    case 'x'
        % Ctrl + x pressed. 2 signifies that subject hasn't responded in time
        ud = get(src,'UserData');
        ud.tmp = [ud.tmp,2];
        set(handles.numcomps,'String',num2str(length(ud.tmp)));
        set(src,'UserData',ud)
    case 'b'
        % delete the previous comparison
        ud = get(src,'UserData');
        if ~isempty(ud.tmp)
            ud.tmp = ud.tmp(1:end-1);
            set(handles.numcomps,'String',num2str(length(ud.tmp)));
        end
        set(src,'UserData',ud)
end
end


function figure1_WindowButtonDownFcn(src,eventdata,handles)
% mouse button pressed
ud = get(src,'UserData');
st = get(src,'SelectionType');
switch st
    case 'normal'
        % = 1 if left mouse button pressed
        ud.tmp = [ud.tmp,1];
        set(handles.numcomps,'String',num2str(length(ud.tmp)));
        soundsc(ud.same,ud.fs)
    case 'alt'
        % = 0 if right mouse button pressed
        ud.tmp = [ud.tmp,0];
        set(handles.numcomps,'String',num2str(length(ud.tmp)));
        soundsc(ud.notsame,ud.fs)
    otherwise
        beep
        disp('press left or right mouse button only & don''t double-click')
end
set(src,'UserData',ud)
end


function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% mouse moves
set(gcf,'currentpoint',[20,10])
end
