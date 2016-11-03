function r = scatter(str)
n = 20;
data = randn(1,n);
x = data * 5 + 120;
switch str
    case 'strong'
        p = 0.9;
        y = (data * p + randn(1,n) * (1 - p)) * 5 + 70;
        cov = corrcoef(x,y);
    case 'weak'
        p = 0.6;
        y = (data * p + randn(1,n) * (1 - p)) * 5 + 70;
        cov = corrcoef(x,y);
    case 'none'
        p = 0;
        y = (data * p + randn(1,n) * (1 - p)) * 5 + 70;
        cov = corrcoef(x,y);
    otherwise
        beep
        return
end
line_h = plot(x,y,'bo');
set(line_h,'MarkerFaceColor','b');
Xlabel('Blood Pressure (mmHg)');
YLabel('Weight (Kg)');
r = cov(1,2);