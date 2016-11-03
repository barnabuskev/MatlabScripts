function varargout = Estimators(varargin)
% ESTIMATORS M-file for Estimators.fig
%      ESTIMATORS, by itself, creates a new ESTIMATORS or raises the existing
%      singleton*.
%
%      H = ESTIMATORS returns the handle to a new ESTIMATORS or the handle to
%      the existing singleton*.
%
%      ESTIMATORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ESTIMATORS.M with the given input arguments.
%
%      ESTIMATORS('Property','Value',...) creates a new ESTIMATORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Estimators_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Estimators_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Estimators

% Last Modified by GUIDE v2.5 08-Nov-2003 22:44:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Estimators_OpeningFcn, ...
                   'gui_OutputFcn',  @Estimators_OutputFcn, ...
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


% --- Executes just before Estimators is made visible.
function Estimators_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Estimators (see VARARGIN)
% Choose default command line output for Estimators
handles.popmean = 120;
handles.popsd = 10;
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Estimators_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in mean.
function mean_Callback(hObject, eventdata, handles)
% hObject    handle to mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Sampsd,'Value',0);
set(handles.Popsd,'Value',0);
set(hObject,'value',1);


% --- Executes on button press in Popsd.
function Popsd_Callback(hObject, eventdata, handles)
% hObject    handle to Popsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Sampsd,'Value',0);
set(handles.mean,'Value',0);
set(hObject,'value',1);

% --- Executes on button press in Sampsd.
function Sampsd_Callback(hObject, eventdata, handles)
% hObject    handle to Sampsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Popsd,'Value',0);
set(handles.mean,'Value',0);
set(hObject,'value',1);

% --- Executes on button press in normal.
function normal_Callback(hObject, eventdata, handles)
% hObject    handle to normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.exp,'Value',0);
set(hObject,'value',1);


% --- Executes on button press in exp.
function exp_Callback(hObject, eventdata, handles)
% hObject    handle to exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.normal,'Value',0);
set(hObject,'value',1);


% --- Executes during object creation, after setting all properties.
function sampsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function sampsize_Callback(hObject, eventdata, handles)
% hObject    handle to sampsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function nosamps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosamps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function nosamps_Callback(hObject, eventdata, handles)
% hObject    handle to nosamps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Read text boxes
temp = get(handles.sampsize,'String');
if isempty(temp)
    errordlg('No sample size specified!','Error from go_Callback') 
    return
end
%Read sample size (ss)
ss = str2num(temp);
temp = get(handles.nosamps,'String');
if isempty(temp)
    errordlg('Number of samples not specified!','Error from go_Callback') 
    return
end
%Read number of samples (ns)
ns = str2num(temp);
%Create samples data in columns
switch get(handles.normal,'Value')
    case 1 %sample from normal distribution
        data = randn(ss,ns) * handles.popsd + handles.popmean;
    case 0 %sample from exponential distribution
        temp1 = randn(ss,ns);
        temp2 = randn(ss,ns);
        temp1 = temp1.^2;
        temp2 = temp2.^2;
        data = temp1 + temp2;
end
%Read radio buttons & draw histogram
switch get(handles.mean,'Value')
    case 1
        %get means of samples
        if ss == 1
            means = data;
        else
            means = mean(data);
        end
        %determine number of bins to use
        if ns < 50 & ns > 25
            bins = 7;
        else
            if ns <= 25
                bins = 5;
            else
                bins = round(ns/15);
            end
        end
        hist(means,bins);
        %plot dots if number of samples <= 15
        if ns <= 15
            line(means,zeros(size(means)),'LineStyle','none','Marker','o','MarkerEdgeColor','g',...
                'MarkerFaceColor','g','MarkerSize',10);
        end
        %plot 'X' at mean of means
        mean_mean = mean(means);
        SD_mean = std(means);
        line(mean_mean,0,'LineStyle','none','Marker','x','MarkerEdgeColor','r',...
            'MarkerFaceColor','r','MarkerSize',32);
        %Write mean of estimations
        set(handles.AverageEst,'String',['Average = ',num2str(mean_mean,3)]);
        %Write standard deviation of estimations
        set(handles.SDEst,'String',['Standard Error = ',num2str(SD_mean,3)]);
    case 0 %get standard deviation of samples
        %generate sample standard deviations
        if get(handles.Popsd,'Value')
            sds = std(data,1);
        else
            sds = std(data);
        end
        %determine number of bins to use
        if ns < 50 & ns > 25
            bins = 7;
        else
            if ns <= 25
                bins = 5;
            else
                bins = round(ns/10);
            end
        end
        if ns > 10
            hist(sds,bins);
        end
        %plot dots if number of samples <= 15
        if ns <= 15
            line(sds,zeros(size(sds)),'LineStyle','none','Marker','o','MarkerEdgeColor','g',...
                'MarkerFaceColor','g','MarkerSize',10);
        end
        %get mean of estimations
        mean_sds = mean(sds);
        %get standard deviation of estimations
        sd_sds = std(sds);
        %plot 'X' at mean of sds
        line(mean_sds,0,'LineStyle','none','Marker','x','MarkerEdgeColor','r',...
            'MarkerFaceColor','r','MarkerSize',32);
        %Write mean of estimations
        set(handles.AverageEst,'String',['Average = ',num2str(mean_sds,3)]);
        %Write standard deviation of estimations
        set(handles.SDEst,'String',['Standard Error = ',num2str(sd_sds,3)]);
end


% --- Executes during object creation, after setting all properties.
function AverageEst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AverageEst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Sampsd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sampsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SDEst.
function SDEst_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SDEst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


