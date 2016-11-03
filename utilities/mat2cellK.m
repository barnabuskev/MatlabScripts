function outcell = mat2cellK(inmat)
%function to take a matrix inmat and pop each element into a seperate cell
outcell = mat2cell(inmat,ones(1,size(inmat,1)),ones(1,size(inmat,2)));