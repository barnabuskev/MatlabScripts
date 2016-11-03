function line_h = plotpoints(im_h,N)
% Function to plot N points on an image and return the line handle. im_h is
% the image object handle.
% left click - add point
% right click - remove point
% alt left click - centre image at click point and zoom in
% alt right click - centre image at click point and zoom out
% Esc - abort marking current set of points
% parameters...
% zoom factor
fct = 2;
% marker size (points)
ms = 10;
% initialise
set(gcf,'pointer','crosshair')
ud.kp = '';
set(gcf,'userdata',ud)
set(gcf,'KeyPressFcn',@keyPfcn)
set(gcf,'KeyReleaseFcn',@keyRfcn)
% store current axis state for exit
while true
    k = waitforbuttonpress; % loops until N points are marked on the image
    ud = get(gcf,'userdata');
    if k == 0
        % A mouse button has been pressed
        % get current point
        pnt = get(gca,'currentpoint');
        x = pnt(1,1);
        y = pnt(1,2);
        st = get(gcf,'selectiontype');
        switch st
            % determine if left or right mouse button pressed
            case 'normal'
                % left mouse button pressed
                if isempty(ud.kp)
                    %ER disp('left')
                    % plot points - only left mouse button pressed
                    if ~exist('line_h','var')
                        % create line if it doesn't exist
                        line_h = line(x,y,'marker','+','MarkerEdgeColor','red',...
                            'linestyle','none','MarkerSize',ms);
                    else
                        if length(get(line_h,'xdata')) < N
                            % add point to line if specified number of
                            % points
                            xd = get(line_h,'xdata');
                            xd = [xd,x]; %#ok<*AGROW>
                            set(line_h,'xdata',xd)
                            yd = get(line_h,'ydata');
                            yd = [yd,y];
                            set(line_h,'ydata',yd)
                        end
                    end
                    if length(get(line_h,'xdata')) == N
                        % N points have been plotted
                        % change mouse pointer
                        set(gcf,'pointer','arrow')
                        % unset keypressfcn & KeyReleaseFcn
                        set(gcf,'KeyPressFcn','')
                        set(gcf,'KeyReleaseFcn','')
                        % exit plotpoints
                        return
                    end
                end
                if strcmp(ud.kp,'alt')
                    % alt left mouse button pressed - zoom in
                    imzoomer(im_h,fct,x,y)
                end
            case 'extend'
                % shift click left - do nothing
            case 'alt'
                % right mouse button or control click left mouse button
                if isempty(ud.kp) % only respond to right mouse button clicks
                    %ER disp('right')
                    % right mouse button only clicked - remove a point if
                    % line exists
                    if exist('line_h','var')
                        xd = get(line_h,'xdata');
                        yd = get(line_h,'ydata');
                        [indx,d] = findclosepnt([xd;yd],[x,y]);
                        if length(d) == 1
                            % if line has only one marker, delete if close
                            % get distance in points
                            dpnts = norm(ax2pnts(gca,xd-x,yd-y));
                            if dpnts < ms*2
                                delete(line_h)
                                clear('line_h')
                            end
                        else
                            min_d = d(indx);
                            d(indx) = [];
                            if min(d/min_d) > 2
                                % delete point if pointer is at least twice as
                                % close to closest point as other points
                                xd(indx) = [];
                                yd(indx) = [];
                                set(line_h,'xdata',xd)
                                set(line_h,'ydata',yd)
                            end
                        end
                    end
                end
                if strcmp(ud.kp,'alt')
                    % alt right mouse button pressed - zoom out
                    imzoomer(im_h,1/fct,x,y)
                end
            otherwise % double click detected - do nothing
                disp('double click not supported')
        end
    else
        % A key pressed...
        if strcmp(ud.kp,'escape')
            % escape pressed - exit point marking
            % change mouse pointer
            set(gcf,'pointer','arrow')
            if exist('line_h','var')
                delete(line_h)
            end
            line_h = [];
            % unset keypressfcn & KeyReleaseFcn
            set(gcf,'KeyPressFcn','')
            set(gcf,'KeyReleaseFcn','')
            % exit plotpoints
            return
        end
    end
end
end


function keyPfcn(src,event)
% to stop callback being repeatedly executed when key held down
set(src,'KeyPressFcn','')
ud = get(src,'userdata');
ud.kp = event.Key;
set(src,'userdata',ud)
if strcmp(event.Key,'alt')
    set(src,'pointer','circle')
end
end

function keyRfcn(src,event)
set(src,'KeyPressFcn',@keyPfcn)
ud = get(src,'userdata');
% to indicate no longer being pressed
ud.kp = '';
set(src,'userdata',ud)
if strcmp(event.Key,'alt')
    set(src,'pointer','crosshair')
end
end



