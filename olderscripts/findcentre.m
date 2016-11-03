function centre = findcentre(points)
%function to output the centre of the circle of 'points' which are approximately
%lying on the circumference of the circle
est = mean(points);
%[centre,fval,exitflag,output] = fminsearch(@centrecircerror,est);
centre = fminsearch(@centrecircerror,est);
    function out = centrecircerror(est)
        %Function which calculates a sum of squares error for an estimate of the
        %position of the centre of a circle which passes through a set of points.
        %The error is the difference between the mean radii and each individual
        %radii. This should be zero if all the points lie on a circle and est is
        %the centre of the circle.
        %'Points' is a NX2 matrix of coordinates: 1st col are x-values, 2nd col are
        %y-values. 'est' is the estimated centre
        %TEST
        plot(est(1),est(2),'g.')
        pause
        %END TEST
        resd = bsxfun(@minus,points,est);
        %length of each resid vector
        len = sqrt(diag(resd * resd'));
        %get sum of lengths from centre
        out = sum(len);
    end
end