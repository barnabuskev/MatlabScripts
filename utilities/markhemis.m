% Function to display input image file, mark n points, find centre of n
% points, display center and circle on image. User presses 'space' to
% start next hemisphere. This resets image to original size and calls plot
% points again. When the hemispheres are finished, user pressed 'return' ('enter') to
% exit function and start next file or quit if none left.
% Returns the centres of the circles and radii.
function markdat = markhemis(fln)
% number of points per hemisphere
N = 6;
% display image and configure axes
im_h = imshow(fln,'border','tight');
orgxl = get(gca,'xlim');
orgyl = get(gca,'ylim');
set(gcf,'MenuBar','none')
set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf,'numbertitle','off')
set(gcf,'name','Mark points on hemispheres')
set(title(fln), 'Interpreter', 'none')
%
plotpnts = true;
radii = [];
while true
    if plotpnts
        % get data for one hemisphere
        line_h = plotpoints(im_h,N);
        if isempty(line_h)
            plotpnts = false;
            continue
        end
        % extract point coords
        xd = get(line_h,'xdata');
        yd = get(line_h,'ydata');
        % fit circle & get radius and centre
        par = CircleFitByTaubin([xd;yd]');
        x = par(1);
        y = par(2);
        rad = par(3);
        % plot centre
        if ~exist('circ_h','var')
            % create circle centre line if it doesn't exist
            circ_h = line(x,y,'marker','x','MarkerEdgeColor','green',...
                'linestyle','none','MarkerSize',20);
        else
            % add point to circle centre line
            xd = get(circ_h,'xdata');
            xd = [xd,x];
            set(circ_h,'xdata',xd)
            yd = get(circ_h,'ydata');
            yd = [yd,y];
            set(circ_h,'ydata',yd)
        end
        % pause
        pause(0.5)
        % restore image size
        set(gca,'xlim',orgxl);
        set(gca,'ylim',orgyl);
        % save radius
        radii = [radii,rad];
    end
    k = waitforbuttonpress;
    assert((k==0 || k==1),'output from waitforbuttonpress must be 0 or 1');
    if k == 1
        % key pressed
        cc = get(gcf,'currentcharacter');
        switch cc
            case 32
                % 'space' pressed - get next hemisphere
                plotpnts = true;
            case 13
                % 'return' pressed - get subject code, data & exit
                prompt = 'Enter subject code';
                dlg_title = 'Subject code';
                tmp = inputdlg(prompt,dlg_title);
                markdat.subjcode = tmp{1};
                % get radii
                markdat.radii = radii;
                % get coordinates of markers
                xd = get(circ_h,'xdata');
                yd = get(circ_h,'ydata');
                markdat.cent = [xd;yd];
                return
            otherwise
                % some other button pressed - do nothing
                plotpnts = false;
        end
    else
        % mouse button pressed
        plotpnts = false;
    end
end
