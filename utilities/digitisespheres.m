function digitisespheres
%function to batch digitise images containing spherical markers. For each
%sphere, user places several markers on the edge of the sphere, and the
%centre of the circle (being the 2D projection of the sphere) is
%calculated. Pressing the space bar starts point marking, pressing space
%bar again stops point marking and calculates centre. The coordinates of
%each circle centre is stored, in the order it was marked, along with the
%file name. points are entered until return is pressed. Uses 'circfit.m' by
%Izhak bucher copyright 25/oct/1991
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%get files
[filelist,seldir,fi] = uigetfile({'*.jpg';'*.bmp';'*.gif';'*.tif'},...
    'Select image files','','MultiSelect','on');
if fi == 0
    return
end
cd(seldir)
%load each file
if ischar(filelist)
    filelist = {filelist};
end
nfl = length(filelist);
%spacebar toggle state
ud.spctog = false;
%create output data cell
outdat = cell(nfl,3);
for ia = 1:nfl
    fnm = filelist{ia};
    img = imread([seldir,filesep,fnm]);
    ih = imagesc(img);
    axis(gca,'equal')
    set(gca,'xtick',[],'ytick',[],'nextplot','add')
    %display file name
    set(gcf,'NumberTitle','off')
    set(gcf,'Name',fnm)
    %create userdata variables for centre and edge points of current image
    ud.xc = [];
    ud.yc = [];
    ud.epts = {};
    %save userdata (clear previous)
    set(gcf,'userdata',ud)
    %set event handlers
    set(gcf,'WindowKeyPressFcn',@keyprs)
    set(ih,'buttondownfcn',@mseclk)
    %wait until all points marked...
    uiwait
    %get data...
    ud = get(gcf,'userdata');
    %save filename
    outdat{ia,1} = fnm;
    %save circle centre points for current image
    outdat{ia,2} = [ud.xc,ud.yc];
    %save edge points for current image
    outdat{ia,3} = ud.epts;
    delete(gcf)
end
%save points
[ofn,opn,fi] = uiputfile('*.mat','Save data');
if fi == 0
    but = questdlg('Are you sure you don''t want to save data?','Data Not Saved','Yes','No','Yes');
    if isequal(but,'Yes')
        return
    else
        [ofn,opn,fi] = uiputfile('*.mat','Save data');
        if fi == 0
            return
        end
    end
end
%save data
save([opn,ofn],'outdat')


function keyprs(src,eventdata)
%function to handle keypresses
ud = get(gcf,'userdata');
switch eventdata.Key
    case 'space'
        %space is a toggle that toggles between getting points and not,
        %return ends all spheres
        if ~ud.spctog
            %if first toggle... change pointer to crosshair
            set(gcf,'pointer','crosshair')
            %toggle spacebar flag
            ud.spctog = true;
            set(gcf,'userdata',ud)
        else
            %second toggle
            set(gcf,'pointer','arrow')
            %toggle state
            ud.spctog = false;
            if isfield(ud,'pts')
                %calculate centre of sphere
                xd = get(ud.pts,'xdata');
                yd = get(ud.pts,'ydata');
                [xc,yc,R,a] = circfit(xd,yd);
                plot(xc,yc,'+w','MarkerFaceColor','g',...
                    'MarkerSize',12)
                %save centre points for current sphere
                ud.xc = [ud.xc;xc];
                ud.yc = [ud.yc;yc];
                %save edge points for current sphere
                ud.epts = [ud.epts;{[xd',yd']}];
                %remove points field
                ud = rmfield(ud,'pts');
            end
            set(gcf,'userdata',ud)
        end
    case 'return'
        %return key pressed...
        %check if in point gathering mode
        if ud.spctog
            %gathering points, don't quit
            beep
        else
            %not gathering points, next image if there is one
            uiresume(gcf)
        end
    case 'pageup'
        zoom(2)
    case 'pagedown'
        zoom(0.5)
    case 'backspace'
        %delete previous point
        if isfield(ud,'pts')
            %if line has started
            xd = get(ud.pts,'xdata');
            xd = xd(1:end-1);
            yd = get(ud.pts,'ydata');
            yd = yd(1:end-1);
            if isempty(xd)
                %delete line
                delete(ud.pts)
                %remove points field
                ud = rmfield(ud,'pts');
                %change pointer
                set(gcf,'pointer','arrow')
                %toggle state
                ud.spctog = false;
                %save user data
                set(gcf,'userdata',ud)
            else
                set(ud.pts,'xdata',xd,'ydata',yd);
            end
        end
end

function mseclk(src,eventdata)
%function to handle mouse clicks
ud = get(gcf,'userdata');
if ud.spctog
    cpt = get(gca,'currentpoint');
    if ~isfield(ud,'pts')
        %create line object
        ud.pts = plot(cpt(1,1),cpt(1,2),'xr','MarkerSize',12);
    else
        %add points to existing line object
        xd = get(ud.pts,'xdata');
        xd = [xd,cpt(1,1)];
        yd = get(ud.pts,'ydata');
        yd = [yd,cpt(1,2)];
        set(ud.pts,'xdata',xd,'ydata',yd);
    end
    %save userdata
    set(gcf,'userdata',ud)
end

