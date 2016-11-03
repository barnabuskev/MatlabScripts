function varargout = DataGraph(varargin)
% DATAGRAPH M-file for DataGraph.fig
%      DATAGRAPH, by itself, creates a new DATAGRAPH or raises the existing
%      singleton*.
%
%      H = DATAGRAPH returns the handle to a new DATAGRAPH or the handle to
%      the existing singleton*.
%
%      DATAGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAGRAPH.M with the given input arguments.
%
%      DATAGRAPH('Property','Value',...) creates a new DATAGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataGraph_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataGraph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataGraph

% Last Modified by GUIDE v2.5 04-Oct-2002 18:00:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataGraph_OpeningFcn, ...
                   'gui_OutputFcn',  @DataGraph_OutputFcn, ...
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


% --- Executes just before DataGraph is made visible.
function DataGraph_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataGraph (see VARARGIN)
% Choose default command line output for DataGraph
handles.output = hObject;
switch varargin{1}
    case 'Go'
        %Called with DataGraph('Go',chan_info,samp_freq,file_name)
        %chan_info is a cell array with rows:
        %   channel number - this corresponds to the hardware channel i.e.
        %   0-15
        %   Channel string - e.g. 'EMG'
        chan_info = varargin{2};
        %Create device objects
        handles.ai = analoginput('nidaq',1);
        handles.dio = digitalio('nidaq',1);
        %Create DIO lines & set properties
        addline(handles.dio,0:7,'out');
        %'SingleEnded' is used as the output from the biopotential
        %amplifier is referenced to the same ground as the DAQ board.
        %AISENSE is used as default. This guards against differences in the
        %ground between the GPIB and the DAQ board
        set(handles.ai,'InputType','SingleEnded');
        %Add AI channels & assign names
        no_channels=size(chan_info,1);
        for i=1:no_channels
            addchannel(handles.ai,chan_info{i,1},chan_info{i,2});
        end
        %CONFIGURE ANALOGUE INPUT PROPERTIES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(handles.ai,'SampleRate',varargin{3});
        set(handles.ai,'TriggerType','Manual');
        set(handles.ai,'SamplesPerTrigger',Inf)
        %setup samples acquired event handler
        handles.ai.TimerPeriod = no_channels / 5;
        SR = round(get(handles.ai,'SampleRate'));
        handles.chunk = round(handles.ai.TimerPeriod * SR);
        %set logging mode
        set(handles.ai,'LoggingMode','Disk');
        %set LogFileName
        set(handles.ai,'LogFileName',varargin{4});
        %SET UP AXES & FIGURE
        %%%%%%%%%%%%%%%%%%%%%%%%
        %display sampling rate
        set(handles.text10,'String',[num2str(get(handles.ai,'SampleRate')),' Hz']);
        %double buffer on
        set(hObject,'DoubleBuffer','on');
        %misc initialisation
        fig = get(hObject,'Position');
        frame = get(handles.graph_frame,'Position');
        h_ratio=frame(4)/fig(4);
        w_ratio=frame(3)/fig(3);
        Xrange = [0,5];
        handles.Xrange = Xrange;
        %set up close function
        set(hObject,'CloseRequestFcn',{@close_DG,handles});
        %work out matrix size of axes
        switch no_channels
            case 1
                ax_mat = [1,1];
            case 2
                ax_mat = [2,1];
            case 3
                ax_mat = [3,1];
            case 4
                ax_mat = [2,2];
            case {5,6}
                ax_mat = [3,2];
            case {7,8}
                ax_mat = [4,2];
            case 9
                ax_mat = [3,3];
            case {10,11,12}
                ax_mat = [4,3];
            case {13,14,15,16}
                ax_mat = [4,4];
        end
        %SET UP INDIVIDUAL AXES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        last_col=rem(no_channels - 1,ax_mat(2)) + 1;
        handles.line_h = zeros(1,no_channels);
        handles.d_points = SR * abs(Xrange(1) - Xrange(2)) + 1;
        handles.flag = 2;
        for i=1:no_channels
%             %configure biopotential amplifier
%             temp = handles.ai.Channel(i).ChannelName;
%             switch temp
%                 %datalab uses bottom 6 bits
%                 case {'ECG','GSR'}
%                     hwc = handles.ai.Channel(i).HwChannel;
%                     bv = [dec2binvec(hwc,4),logical([0,0])];
%                     putvalue(handles.dio.Line(1:6),bv);
%                     pause(0.5)
%                 case 'EMG'
%                     hwc = handles.ai.Channel(i).HwChannel;
%                     bv = [dec2binvec(hwc,4),logical([0,1])];
%                     putvalue(handles.dio.Line(1:6),bv);
%                     pause(0.5)
%             end
            %create axes
            ax(i) = subplot(ax_mat(1),ax_mat(2),i);
            %font size
            set(ax(i),'Units','Character','FontSize',8);
            %set position of axes to invisible frame
            temp = get(ax(i),'Position');
            temp(3) = temp(3) * w_ratio;
            temp(1) = temp(1) * w_ratio;
            temp(4) = temp(4) * h_ratio;
            temp(2) = temp(2) * h_ratio;
            temp(1) = temp(1) + frame(1);
            temp(2) = temp(2) + frame(2);
            set(ax(i),'Position',temp);
            %create title & set at top of graph
            h = title([get(handles.ai.Channel(i),'ChannelName'),...
                    ' Channel:',num2str(get(handles.ai.Channel(i),'HwChannel'))]);
            tit_pos = get(h,'Position');
            tit_pos(2) = 1;
            set(h,'Units','normalized','Position',tit_pos);
            %set y label
            axis_data.ylabel = ylabel(get(handles.ai.Channel(i),'Units'));
            set(axis_data.ylabel,'Units','points');
            temp = get(axis_data.ylabel,'Position');
            temp(1) = -10;
            set(axis_data.ylabel,'Position',temp);
            %remove xlabel if axis not on bottom row
            %1st condition: on last row
            cond1 = i > (ax_mat(1) - 1) * ax_mat(2);
            %2nd condition: greater than last column
            cond2 = (rem(i - 1,ax_mat(2)) + 1) > last_col;
            %3rd condition: on 2nd to last row
            cond3 = ceil(i / ax_mat(2)) == ax_mat(1) - 1;
            if ~(cond1 | (cond2 & cond3))
                set(ax(i),'XTickLabel',{});
            end
            %set x label
            if (cond1 | (cond2 & cond3))
                xlabel('Secs');
            end
            %set XLim
            set(ax(i),'XLim',Xrange);
            %plot zeros to create line objects & save line handles
            handles.line_h(i) = line(Xrange(1):1/SR:Xrange(2),zeros(1,handles.d_points));
            %set YLim to input voltage range
            set(ax(i),'YLim',get(handles.ai.Channel(i),'InputRange'));
            %create structure to store with axes & store initial
            %calibration status and channel number
            axis_data.calibstate = [0,0];
            axis_data.channel = i;
            %display not calibrated text
            tempY = get(ax(i),'YLim');
            tempX = get(ax(i),'XLim');
            posX = (tempX(2) - tempX(1))/2 + tempX(1);
            posY = (tempY(2) - tempY(1))/2 + tempY(1);
            axis_data.text_h = text(posX,posY,'Not Calibrated');
            set(axis_data.text_h,'HorizontalAlignment','center','FontSize',15,'Color','r');
            %set ButtonDownFcn
            set(ax(i),'ButtonDownFcn',{@config_channel,handles});
            %save axis data
            set(ax(i),'UserData',axis_data);
        end
        for i=1:no_channels
            %set ButtonDownFcn
            set(ax(i),'ButtonDownFcn',{@config_channel,handles});
        end
%         %DEBUG
%         handles.fid = fopen('debug.txt','w');
%         %DEBUG
        handles.flag = 1;
        %clear ProcessData persistent variables
        ProcessData([],[],handles);
        %assign timer function
        handles.flag = 0;
        handles.ai.TimerFcn = {@ProcessData,handles};
        %store handles structure
        guidata(hObject, handles);
        %start analogue input object
        start(handles.ai);
    case 'close_DG'
        close_DG(hObject)
end


%---close the DAQ objects
function close_DG(obj,event,handles)
temp = handles.ai.LogFileName;
stop(daqfind);
delete(temp)
delete(daqfind);
closereq;



% --- Outputs from this function are returned to the command line.
function varargout = DataGraph_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in togglebutton1. Start/stop data logging
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Used to toggle logging data to disk
if(get(hObject,'Value')==1)
    % Toggle button appearance
    set(hObject,'String','Stop Data Logging');
    set(hObject,'BackgroundColor',[0.8,0,0]);
    set(hObject,'ForegroundColor',[0,0,0]);
    %Get analogue input object to record data to disk
    trigger(handles.ai);
else
    % Toggle button appearance
    set(hObject,'String','Start Data Logging');
    set(hObject,'BackgroundColor',[0,0.5,0]);
    set(hObject,'ForegroundColor',[1,0.5,0]);
    stop(handles.ai);
    %increment file name
    temp = get(handles.ai,'LogFileName');
    [a,b,c] = fileparts(temp);
    if b(end)>'9'|b(end-1)>'9'
        %not a file number
        b=[b,'01'];
        set(handles.ai,'LogFileName',[a,'\',b,c]);
    else
        %add file number
        tempi = str2num(b(end-1:end));
        tempi = tempi + 1;
        if length(num2str(tempi)) == 1
            b = [b(1:end-2),'0',num2str(tempi)];
        else
            b = [b(1:end-2),num2str(tempi)];
        end
        set(handles.ai,'LogFileName',[a,'\',b,c]);
    end
    start(handles.ai)
end


% --- Called externally to display data
function ProcessData(obj,event,handles)
persistent YD mark;
switch handles.flag
    case 0  %called from event handler
        data = peekdata(obj,handles.chunk);
        temp = size(data,1);
        if mark + temp > handles.d_points
            mark = 0;
            YD = zeros(handles.d_points,size(handles.line_h,2));
        end
        YD((mark + 1):(mark + temp),:) = data;
        mark = mark + temp;
        for i = 1:length(handles.line_h)
            %DEBUG
%             debug_ah = get(handles.line_h(i),'Parent');
%             fprintf(handles.fid,'%s,',get(debug_ah,'XlimMode'));
%             fprintf(handles.fid,'%s,',get(debug_ah,'YlimMode'));
%             fprintf(handles.fid,'%s,',get(debug_ah,'DataAspectRatioMode'));
%             fprintf(handles.fid,'%d %d,',get(debug_ah,'Xlim'));
%             fprintf(handles.fid,'%d %d\r',get(debug_ah,'Ylim'));
            %DEBUG
            set(handles.line_h(i),'YData',YD(:,i));
        end
    case 1  %called on opening fig
        mark = 0;
        YD = zeros(handles.d_points,size(handles.line_h,2));
    case 2 %stop displaying data
end

%----------------------------------------------------------------
function config_channel(obj,event,handles)
% called whenever an axis is clicked in
temp = get(obj,'UserData');
name = get(handles.ai.Channel(temp.channel),'ChannelName');
stop(handles.ai)
fig = gcf;
set(fig,'Pointer','watch');
switch name
    case 'EMG'
        EMGsetup(temp.calibstate,handles.ai...
            ,temp.channel,obj);
        uiwait(gcf);
    case 'ECG'
        ECGsetup(temp.calibstate,handles.ai...
            ,temp.channel,obj);
        uiwait(gcf);
    case 'Spirometer'
        spirosetup(temp.calibstate,handles.ai...
            ,temp.channel,obj);
        uiwait(gcf);
    otherwise
        beep
end
%get UserData again as it has been altered
temp = get(obj,'UserData');
a = temp.calibstate(1);
b = temp.calibstate(2);
if a & b
    set(temp.text_h,'Visible','off');
else
    set(temp.text_h,'Visible','on');
end
set(temp.ylabel,'String',get(handles.ai.Channel(temp.channel),'Units'));
set(fig,'Pointer','arrow');
set(obj,'UserData',temp);
start(handles.ai)




% --------------------------------------------------------------------
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


