function scrolldata(data)
r = size(data,1);
chunk = 30;
for i = 1:chunk:r
    fin = i + chunk - 1;
    if fin > r
        fin = r;
    end
    disp(data(i:fin,:))
    pause
end