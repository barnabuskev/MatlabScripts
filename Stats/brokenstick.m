function out = brokenstick(datmat)
%function to calculate which PCs to retain using the broken stick method.
%input is a data matrix, rows obj, cols variables.
[vec,val] = eig(cov(datmat));
val = diag(val);
val = flipud(val);
%covert to %age explained var
val = val / sum(val);
nv = length(val);
out = [];
for ia = 1:nv
    %for each eigval
    len = lenstk(nv,ia);
    if val(ia) > len
        %store eg val no if above thresh
        out = [out,ia];
    end
end

function len = lenstk(brk,pcs)
%function to compute the expected length 'len' of piece 'pcs' when stick is
%broken randomly into 'brk' pieces
if pcs > brk
    error('Index of piece exceeds number of pieces')
end
len = (1 / brk) * sum(1 ./ (pcs:brk));