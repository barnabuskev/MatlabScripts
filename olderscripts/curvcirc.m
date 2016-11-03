function results = curvcirc
%Function to take a set of points (e.g. along the thoracic spine) and fit a
%circle through the points. The curvature is calculated as the reciprocal
%of the radius of the circle. This is done by minimising an error function.
%The error function is 'centrecircerror'. This calculates the sum of
%squares of errors for each point. This error is obtained by calculating
%the distance between each point and an estimate of the location of the
%centre of the circle, and finding the difference between this distance and
%the mean distance for all the points. Points on a circle should have an
%error = zero for a correctly estimated centre.
%
select = getlistfiles('C:\','Get directory containing marked points','select files');
cd(select.pth)
cnt = 1;
for file_i = 1:length(select.files)
    datfile = select.files{file_i};
    k = strfind(datfile,'.csv');
    if ~isempty(k)
        points = csvread(datfile);
        %Get initial estimate (average of all points)
        est = mean(points);
        %obtain centre
        centre = fminsearch(@centrecircerror,est,[],points);
        %Calculate average distance from estimated centre
        no_points = size(points,1);
        r = [];
        for i = 1:no_points
            r = [r,norm(points(i,:) - centre)];
        end
        rmean = mean(r);
        %plot results
        plot(points(:,1),points(:,2),'b.');
        hold on;
        plot(centre(1),centre(2),'rx');
        for theta = 0:pi/50:2*pi
            [X,Y] = pol2cart(theta,rmean);
            plot(X+centre(1),Y+centre(2));
        end
        axis equal;
        title(datfile)
        hold off;
        curv = 1/rmean;
        results{cnt,1} = datfile;
        results{cnt,2} = curv;
        cnt = cnt + 1;
        pause
    end
end
[fn,pn] = uiputfile('*.csv','Save data as...')
fid = fopen([pn,fn,'.csv'],'w');
for i = 1:length(results)
    fprintf(fid,'%s,',results{i,1});
    fprintf(fid,'%g\n',results{i,2});
end
fclose(fid);