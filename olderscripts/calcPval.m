function p_val = calcPval(triple,pair,single)
%m-file for calculating the p value given a set of results from Jasmine
%Bevan's & James Horwood's experiments. Where triple = the number of subjects in which the
%location of the maximum was the same in all three cases, pair = the number
%of subjects in which two of the maxima were the same & single = the number
%of subjects in which none of the maxima were at the same location.
%copyright Kevin Brownhill Jan 2004
n_subj = triple + pair + single;
%get triple, pair & single probabilities
pt = multinom([3,0,0,0,0,0]) * factorial(6) / factorial(5);
pp = multinom([2,1,0,0,0,0]) * factorial(6) / factorial(4);
ps = multinom([1,1,1,0,0,0]) * factorial(6) / (factorial(3) * factorial(3));
%initialise
results = [];
%calculate deviation from ex
for t = 0:n_subj
    for p = 0:(n_subj-t)
        s = n_subj - p - t;
        %calculate deviation from expected frequencies
        dev = (pt*n_subj-t)^2/pt*n_subj + (pp*n_subj-p)^2/pp*n_subj + (ps*n_subj-s)^2/ps*n_subj;
        %calculate number of permutations for frequencies t,p,s
        perms = factorial(n_subj)/(factorial(t)*factorial(p)*factorial(s));
        %calculate probability of frequencies
        prob = pt^t * pp^p * ps^s * perms;
        results = [results;t,p,s,dev,prob];
    end
end
%sort results into ascending order of deviation from expected freq
results = sortrows(results,4);
%find index of row for observed frequencies
ind_array = (results(:,1) == triple) & (results(:,2) == pair) & (results(:,3) == single);
eq_row = find(ind_array);
%return sum of probabilities for all deviations equal to or greater than
%deviation of observed frequencies from expected frequencies
p_val = sum(results(eq_row:end,5));