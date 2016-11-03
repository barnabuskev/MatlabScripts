function writearray(arry)
%function to save matrix 'arry' as csv file
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[fn,pn,fi] = uiputfile('*.csv','Save array as CSV file');
if fi
    csvwrite([pn,fn],arry)
end

