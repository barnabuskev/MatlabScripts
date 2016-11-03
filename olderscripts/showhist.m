function varargout = ShowHist(varargin)
% TEMP M-file for ShowHist.fig
%      TEMP, by itself, creates a new TEMP or raises the existing
%      singleton*.
%
%      H = TEMP returns the handle to a new TEMP or the handle to
%      the existing singleton*.
%
%      TEMP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMP.M with the given input arguments.
%
%      TEMP('Property','Value',...) creates a new TEMP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ShowHist_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ShowHist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ShowHist

% Last Modified by GUIDE v2.5 15-Oct-2002 23:24:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ShowHist_OpeningFcn, ...
                   'gui_OutputFcn',  @ShowHist_OutputFcn, ...
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


% --- Executes just before ShowHist is made visible.
function ShowHist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ShowHist (see VARARGIN)
handles.sd = 20;
handles.mean = 120;
set(handles.samp,'String','15');
set(handles.bin,'String','5');
handles.XlimVec = [];
handles.YlimVec = [];
handles.ax_ind = 1;
handles.two = [];
handles.linem1 = [];
handles.linesd1 = [];
% Choose default command line output for ShowHist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ShowHist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ShowHist_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in Gen.
function Gen_Callback(hObject, eventdata, handles)
% hObject    handle to Gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samp_size=str2num(get(handles.samp,'String'));
bins=str2num(get(handles.bin,'String'));
data=sort(randn(samp_size,1) * handles.sd + handles.mean);
m_hat = mean(data);
sd = std(data);
[N,bc] = hist(data,bins);
i = handles.ax_ind;
if i == 1
    if ~isempty(handles.two)
        delete(handles.two);
        handles.two = [];
        handles.XlimVec = [];
        handles.YlimVec = [];
    end
    bar(bc,N,1);
    temp = findobj(get(gca,'Children'),'Type','patch');
    set(temp,'FaceColor',[1,0,1],'LineWidth',2);
    xlimit = get(gca,'XLim');
    ylimit = get(gca,'YLim');
    if get(handles.overlay,'Value') == 0
        handles.ax_ind = 0;
    else
        handles.XlimVec(i,:) = xlimit;
        handles.YlimVec(i,:) = ylimit;
    end
    if get(handles.showmean,'Value')
        handles.linem1 = line([m_hat,m_hat],[ylimit(1),ylimit(2)],'Color','k'...
            ,'EraseMode','xor','LineWidth',2);
    end
    if get(handles.showsd,'Value')
        handles.linesd1 = line([m_hat-sd,m_hat,m_hat+sd],[ylimit(2),ylimit(2),ylimit(2)]/2,...
            'Marker','+','MarkerEdgeColor','g','Color','k',...
            'EraseMode','xor','LineWidth',2);
    end
    if get(handles.dots,'Value')
        line(data,zeros(size(data)),'LineStyle','none','Marker','o','MarkerEdgeColor','k',...
            'MarkerFaceColor','k');
    end   
else %overlay graph
    %set overlaying graph to have same position as graph underneath
    handles.two = axes('Position',get(gca,'Position'));
    bar(bc,N,1);
    %Get patches making up bar graph & set properties
    temp = findobj(get(gca,'Children'),'Type','patch');
    set(temp,'FaceAlpha',0.5,'FaceColor',[0,1,1],'EdgeColor',[1,0,0],'LineWidth',2);
    %Read min & ax values of y & x axis
    handles.XlimVec(i,:) = get(gca,'XLim');
    min_x = min(handles.XlimVec(:,1));
    max_x = max(handles.XlimVec(:,2));
    handles.YlimVec(i,:) = get(gca,'YLim');
    min_y = min(handles.YlimVec(:,1));
    max_y = max(handles.YlimVec(:,2));
    %force both axes to have the same x & y limits
    temp = findobj(get(gcf,'Children'),'Type','axes');
    set(temp,'XLim',[min_x,max_x],'YLim',[min_y,max_y]);
    %set background of overlaying graph to be see-through
    set(gca,'Color','none');
    %if dots selected, display
    if ~isempty(handles.linem1)
        temp = get(handles.linem1,'YData');
        temp(2) = max_y;
        set(handles.linem1,'YData',temp);
    end
    %display mean if requested
    if get(handles.showmean,'Value')
        handles.linem2 = line([m_hat,m_hat],[min_y,max_y],'Color','r',...
            'EraseMode','xor','LineWidth',2);
    end
    %display sd if requested
    if get(handles.showsd,'Value')
        handles.linesd2 = line([m_hat-sd,m_hat,m_hat+sd],[max_y,max_y,max_y]*2/3,...
            'Marker','o','MarkerEdgeColor','g','Color','r'...
            ,'EraseMode','xor','LineWidth',2);
    end
    handles.ax_ind = 0;
    
end
% temp=findobj(get(gcf,'Children'),'Type','axes');
% temp = findobj(temp,'Type','patch');
% prop_pairs(temp);
handles.ax_ind = handles.ax_ind + 1;
string=[sprintf('%s\n\n','DATA'),sprintf('%4.2f  ',data)];
set(handles.DataDisp,'String',string);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function samp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function samp_Callback(hObject, eventdata, handles)
% hObject    handle to samp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samp as text
%        str2double(get(hObject,'String')) returns contents of samp as a double




% --- Executes during object creation, after setting all properties.
function bin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bin_Callback(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bin as text
%        str2double(get(hObject,'String')) returns contents of bin as a double


% --------------------------------------------------------------------
function options_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function samp_params_Callback(hObject, eventdata, handles)
% hObject    handle to samp_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Enter mean:','Enter standard deviation:'};
dlg_title = 'Sample parameters';
num_lines= 1;
def = {num2str(handles.mean),num2str(handles.sd)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
handles.mean = str2num(answer{1});
handles.sd = str2num(answer{2});
guidata(hObject, handles);



% --- Executes on button press in overlay.
function overlay_Callback(hObject, eventdata, handles)
% hObject    handle to overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(hObject,'Value')


% --- Executes on button press in showmean.
function showmean_Callback(hObject, eventdata, handles)
% hObject    handle to showmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showmean


% --- Executes on button press in showsd.
function showsd_Callback(hObject, eventdata, handles)
% hObject    handle to showsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showsd


% --- Executes on button press in dots.
function dots_Callback(hObject, eventdata, handles)
% hObject    handle to dots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dots


