function plotbox(data,cols)
%function that plots a box & whisker plot of the levels of factors in
%columns 'cols'
group = cell(1,2);
for i = 1:length(cols)
    group(i) = {data(2:end,cols(i))};
end
boxplot(cell2mat(data(2:end,10)),group)