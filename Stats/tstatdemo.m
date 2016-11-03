function varargout = tstatdemo(varargin)
% TSTATDEMO M-file for tstatdemo.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tstatdemo_OpeningFcn, ...
                   'gui_OutputFcn',  @tstatdemo_OutputFcn, ...
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



function tstatdemo_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before tstatdemo is made visible.
ay = 0.67;
by = 0.33;
%set slider properties
ud.dmsh = findobj('tag','diffmslid');
ud.vsh = findobj('tag','varslid');
ud.ssh = findobj('tag','sampszslid');
ss = 30;
mu = 4;
%create data
ud.adat = [randn(200,1) + mu,ones(200,1) * ay];
ud.bdat = [randn(200,1) + mu,ones(200,1) * by];
%create data & plot
ud.ah = plot(ud.adat(1:ss,1),ud.adat(1:ss,2),'ko','markersize',10,'MarkerFaceColor','r');
hold on
ud.bh = plot(ud.bdat(1:ss,1),ud.bdat(1:ss,2),'ko','markersize',10,'MarkerFaceColor','g');
hold off
set(ud.ssh,'max',100)
set(ud.ssh,'min',5)
set(ud.ssh,'value',ss)
set(ud.dmsh,'max',3)
set(ud.dmsh,'min',-3)
smd = mean(ud.adat(1:ss,1)) - mean(ud.bdat(1:ss,1));
set(ud.dmsh,'value',smd)
set(ud.vsh,'max',1.6)
set(ud.vsh,'min',0.2)
cv = comvar(ud.adat(1:ss,1),ud.bdat(1:ss,1));
set(ud.vsh,'value',cv)
set(gca,'ylim',[0,1])
set(gca,'yticklabel',{'Group B','Group A'});
set(gca,'ytick',[by,ay])
%expand xlimits
xlm = get(gca,'xlim');
tmp = mean(xlm);
xlm = (xlm - tmp) * 1.3 + tmp;
set(gca,'xlim',xlm)
%set axes color
set(gca,'color',[1,1,0.9])
%display t stat
[tstat,df] = ttest(ud.adat(1:ss,1),ud.bdat(1:ss,1));
ud.ttxh = text('string',['t = ',num2str(tstat,'%+4.2f')],'fontname','courier new','edgecolor','k',...
    'linewidth',2,'margin',8,'fontsize',18,'color',[0.9,0.9,0],'BackgroundColor',[0,0,0.9],...
    'fontweight','bold','HorizontalAlignment','center','position',[mean(xlm) - (xlm(2) - xlm(1))/5,0.9]);
%display difference in means
Dm = mean(ud.adat(1:ss,1)) - mean(ud.bdat(1:ss,1));
ud.mtxh = text('string',['Dmean = ',num2str(Dm,'%+4.2f')],'fontname','courier new','edgecolor','k',...
    'linewidth',2,'margin',8,'fontsize',18,'color',[0.9,0.9,0],'BackgroundColor',[0,0,0.9],...
    'fontweight','bold','HorizontalAlignment','center','position',[mean(xlm) + (xlm(2) - xlm(1))/5,0.9]);
set(hObject,'userdata',ud);
% Update handles structure
guidata(hObject, handles);



function diffmslid_Callback(hObject, eventdata, handles)
% - executes when diffmslid moves
ud = get(gcbf,'userdata');
diffm = get(hObject,'value');
dta = get(ud.ah,'xdata');
dtb = get(ud.bh,'xdata');
ss = length(dta);
tmp = mean(dta - dtb);
dta = dta - tmp / 2 + diffm / 2;
dtb = dtb + tmp / 2 - diffm / 2;
set(ud.ah,'xdata',dta,'ydata',ud.adat(1:ss,2))
set(ud.bh,'xdata',dtb,'ydata',ud.bdat(1:ss,2))
[tstat,df] = ttest(dta,dtb);
set(ud.ttxh,'string',['t = ',num2str(tstat,'%+4.2f')])
Dm = mean(dta - dtb);
set(ud.mtxh,'string',['Dmean = ',num2str(Dm,'%+4.2f')])
drawnow
set(gcbf,'userdata',ud);


function varslid_Callback(hObject, eventdata, handles)
% --- Executes on variance slider movement.
ud = get(gcbf,'userdata');
cvn = get(hObject,'value');
dta = get(ud.ah,'xdata');
dtb = get(ud.bh,'xdata');
comvar(dta,dtb)
ss = length(dta);
[dta,dtb] = chngvar(dta,dtb,cvn);
comvar(dta,dtb)
set(ud.ah,'xdata',dta,'ydata',ud.adat(1:ss,2))
set(ud.bh,'xdata',dtb,'ydata',ud.bdat(1:ss,2))
[tstat,df] = ttest(dta,dtb);
set(ud.ttxh,'string',['t = ',num2str(tstat,'%+4.2f')])
Dm = mean(dta - dtb);
set(ud.mtxh,'string',['Dmean = ',num2str(Dm,'%+4.2f')])
drawnow
set(gcbf,'userdata',ud);



function sampszslid_Callback(hObject, eventdata, handles)
% --- Executes on sampszslid slider movement.
ud = get(gcbf,'userdata');
ss = round(get(hObject,'value'));
set(hObject,'value',ss)
dta = ud.adat(1:ss,1);
dtb = ud.bdat(1:ss,1);
%adjust variance of sample
vsh = findobj('tag','varslid');
cvn = get(vsh,'value');
[dta,dtb] = chngvar(dta,dtb,cvn);
tmp = mean(dta - dtb);
dms = findobj('tag','diffmslid');
diffm = get(dms,'value');
dta = dta - tmp / 2 + diffm / 2;
dtb = dtb + tmp / 2 - diffm / 2;
set(ud.ah,'xdata',dta,'ydata',ud.adat(1:ss,2))
set(ud.bh,'xdata',dtb,'ydata',ud.bdat(1:ss,2))
[tstat,df] = ttest(dta,dtb);
set(ud.ttxh,'string',['t = ',num2str(tstat,'%+4.2f')])
Dm = mean(dta - dtb);
set(ud.mtxh,'string',['Dmean = ',num2str(Dm,'%+4.2f')])
drawnow
guidata(hObject, handles);



%SUBFUNCTIONS
%------------
function cv = comvar(dat1,dat2)
%function to return combined variance of two vectors dat1 & dat2 as used in
%the t-test
if ~(isvector(dat1) && isvector(dat2))
    error('inputs must be vectors')
end
n1 = length(dat1);
n2 = length(dat2);
mu1 = mean(dat1);
mu2 = mean(dat2);
%sum of squares
SS1 = sum((dat1 - mu1).^2);
SS2 = sum((dat2 - mu2).^2);
df = n1 + n2 - 2;
%combined variance
cv = (SS1 + SS2) / df;


function [dat1,dat2] = chngvar(dat1,dat2,cvn)
%fucntion to alter combined variance of data dat1 & dat2 to new combined
%variance cvn
%get old combined variance
cvo = comvar(dat1,dat2);
scl = sqrt(cvn / cvo);
mu1 = mean(dat1);
mu2 = mean(dat2);
%subtract means
dat1 = dat1 - mu1;
dat2 = dat2 - mu2;
%scale to new variance & add mean back
dat1 = dat1 * scl + mu1;
dat2 = dat2 * scl + mu2;

function diffmslid_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function varslid_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function varargout = tstatdemo_OutputFcn(hObject, eventdata, handles)  %#ok<STOUT>
% --- Outputs from this function are returned to the command line.
function sampszslid_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.



