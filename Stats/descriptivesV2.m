function varargout = descriptivesV2(varargin)
% DESCRIPTIVES M-file for descriptives.fig
%      DESCRIPTIVES, by itself, creates a new DESCRIPTIVES or raises the existing
%      singleton*.
%
%      H = DESCRIPTIVES returns the handle to a new DESCRIPTIVES or the handle to
%      the existing singleton*.
%
%      DESCRIPTIVES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESCRIPTIVES.M with the given input arguments.
%
%      DESCRIPTIVES('Property','Value',...) creates a new DESCRIPTIVES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before descriptives_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to descriptives_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help descriptives

% Last Modified by GUIDE v2.5 17-Nov-2007 11:19:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @descriptives_OpeningFcn, ...
                   'gui_OutputFcn',  @descriptives_OutputFcn, ...
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


% --- Executes just before descriptives is made visible.
function descriptives_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to descriptives (see VARARGIN)
ud.mean = 120;
ud.sd = 10;
ud.dist = 'norm';
ud.n = 15;
ud.plot = 'none';
%create info box
%fill screen
%get(hObject,'outerposition')
set(hObject,'outerposition',[0,0,1,0.95])
ud.boxh = annotation('textbox',[0.03,0.92,0.06,0.045],'fontsize',12,'fontweight','bold',...
    'BackgroundColor',[1,1,1],'linewidth',1,'HorizontalAlignment','center');
set(hObject,'userdata',ud)
%set slider to middle
h = findobj('tag','slider1');
set(h,'value',0.5)
%set windows button down function
set(hObject,'WindowButtonDownFcn',@bdf)
gen1dat(hObject);
plot1dat(hObject);
% Choose default command line output for descriptives
handles.output = hObject;
% Update handles structure
guidata(hObject,handles);



% --- Outputs from this function are returned to the command line.
function varargout = descriptives_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton1_Callback(hObject,eventdata,handles)
% resample callback
%set slider to middle
h = findobj('tag','slider1');
set(h,'value',0.5)
%check what type of data to plot
h = findobj('tag','pop');
stri = get(h,'value');
str = get(h,'string');
switch str{stri}
    case {'None','Histogram','Cumul Poly'}
        %generate & plot univariate data
        gen1dat(gcbf);
        plot1dat(gcbf)
    case 'Scattergram'

end



function pop_Callback(hObject, eventdata, handles)
%handles change in popup menu
% --- Executes during object creation, after setting all properties.
function pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slider1_Callback(hObject,eventdata,handles)
%function executed during slider use
plot1dat(gcbf)
function slider1_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function dist_Callback(hObject, eventdata, handles)
% hObject    handle to dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function param_Callback(hObject,eventdata,handles)
%function for parameters menu
ud = get(gcbf,'userdata');
prompt = {'Mean:','Standard deviation:','Sample size:'};
dlg_title = 'Population parameters & sample size';
num_lines = 1;
def = {num2str(ud.mean),num2str(ud.sd),num2str(ud.n)};
answ = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answ)
    return
end
ud.mean = str2num(answ{1});
ud.sd = str2num(answ{2});
ud.n = str2num(answ{3});
set(gcbf,'userdata',ud)


%----------------------------------------------------
function gen1dat(fig_h)
%function to generate data
ud = get(fig_h,'userdata');
switch ud.dist
    %which distribution 'norm' or 'chi'
    case 'norm'
        %generate normal data using params
        dat = randn(ud.n,1) * ud.sd + ud.mean;
    case 'chi'
end
ud.dat = dat;
set(fig_h,'userdata',ud)

%--------------------------------------------------
function plot1dat(fig_h)
%function to plot univariate data
ud = get(fig_h,'userdata');
dat = ud.dat;
%scale data
h = findobj('tag','slider1');
v = (get(h,'value') - 0.5) * 3;
m = mean(dat);
dat = (dat - m) * exp(v) + m;
%set descriptives in boxes...
%mean
h = findobj('tag','mu');
tmp = num2str(mean(dat),5);
set(h,'string',tmp)
%median
h = findobj('tag','med');
tmp = num2str(median(dat),5);
set(h,'string',tmp)
%range
h = findobj('tag','ran');
tmp = num2str(max(dat) - min(dat),5);
set(h,'string',tmp)
%iq range
h = findobj('tag','iqr');
tmp = quant(dat,[0.25,0.75]);
tmp = tmp(2) - tmp(1);
tmp = num2str(tmp,5);
set(h,'string',tmp)
%standard deviation (sample)
h = findobj('tag','sig');
tmp = num2str(std(dat),5);
set(h,'string',tmp)
%get popup menu string
h = findobj(fig_h,'tag','pop');
str = get(h,'string');
v = get(h,'value');
switch str{v}
    case 'None'
        plot(dat,zeros(size(dat)),'o','MarkerEdgeColor','k',...
            'MarkerFaceColor',[.49 1 .63],'MarkerSize',12,'tag','lin');
        set(gca,'YTickLabel','','xgrid','on','ygrid','on','color',[1,1,0])
        set(gca,'xlim',[ud.mean - ud.sd * 3,ud.mean + ud.sd * 3])
    case 'Histogram'
        hist(dat,max(sqrt(length(dat)),10))
        hold on
        plot(dat,zeros(size(dat)),'o','MarkerEdgeColor','k',...
            'MarkerFaceColor',[.49 1 .63],'MarkerSize',12,'tag','lin')
        set(gca,'xlim',[ud.mean - ud.sd * 3,ud.mean + ud.sd * 3],'color',[1,1,0])
        hold off
    case 'Cumul Poly'
        [a,cump] = quant(dat,[0.25,0.75]);
        plot(sort(dat),cump,'p-')
        hold on
        plot(dat,zeros(size(dat)),'o','MarkerEdgeColor','k',...
            'MarkerFaceColor',[.49 1 .63],'MarkerSize',12,'tag','lin')
        set(gca,'xgrid','on','ygrid','on','color',[1,1,0])
        set(gca,'xlim',[ud.mean - ud.sd * 3,ud.mean + ud.sd * 3])
        hold off
    case 'Scattergram'
end


%--------------------------------------------------------------------
function normd_Callback(hObject, eventdata, handles)
% normal distribution selected
h = findobj('tag','chi');
set(h,'checked','off')
set(hObject,'checked','on')
ud = get(gcbf,'userdata');
ud.dist = 'norm';
set(gcbf,'userdata',ud)

%--------------------------------------------------------------------
function chi_Callback(hObject, eventdata, handles)
% chi-squared distribution selected
h = findobj('tag','normd');
set(h,'checked','off');
set(hObject,'checked','on');
ud = get(gcbf,'userdata');
ud.dist = 'chi';
set(gcbf,'userdata',ud)

%--------------------------------------------------------------------
function bdf(src,evnt)
tmp = get(gca,'currentpoint');
pnt = tmp(1,1:2);
%find close points
lh = findobj('tag','lin');
xd = get(lh,'xdata');
ds = abs(xd - complex(pnt(1),pnt(2)));
cls = find(ds < 0.3);
%find closest
[d,i] = min(ds(cls));
sd = cls(i);
%display value in box
ud = get(gcbf,'userdata');
set(ud.boxh,'string',num2str(xd(sd),5))
%get xdata of closest point & horizontal distance from click
clkdist = pnt(1) - xd(sd);
set(src,'WindowButtonMotionFcn',{@wbmcb,sd,lh,clkdist})
set(src,'WindowButtonUpFcn',{@wbucb,lh})


%--------------------------------------------------------------------
function wbmcb(src,evnt,sd,lh,clkdist)
%button motion function
switch get(src,'SelectionType')
    case 'normal'
        cp = get(gca,'currentpoint');
        xd = get(lh,'xdata');
        xd(sd) = cp(1,1) - clkdist;
        set(lh,'xdata',xd)
    case 'extend'
        cp = get(gca,'currentpoint');
        xd = get(lh,'xdata');
        clkp = xd(sd);
        xd = xd - clkp + cp(1,1) - clkdist;
        set(lh,'xdata',xd)
end


%--------------------------------------------------------------------
function wbucb(src,evnt,lh)
%function to handle button up
%update data from line xdata
xd = get(lh,'xdata');
ud = get(gcbf,'userdata');
%scale data
h = findobj('tag','slider1');
v = (get(h,'value') - 0.5) * 3;
m = mean(xd);
ud.dat = (xd - m) / exp(v) + m;
set(gcbf,'userdata',ud)
plot1dat(gcbf)
set(src,'WindowButtonMotionFcn','')
set(src,'WindowButtonUpFcn','')


