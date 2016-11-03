function varargout = sixesprob(N)
%function to work out and plot the distribution of number of sixes for a
%fair die.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%var to store probabilities
prob = zeros(N+1,1);
p6 = 1/6;
prest = 5/6;
for ia = 0:N
    psingle = (p6)^(N-ia) * prest^(ia);
    Ncmbs = nchoosek(N,ia);
    prob(ia+1) = psingle * Ncmbs;
end
plot(N:-1:0,prob,'--+r','color','g','markeredgecolor','r','linewidth',2)
xlim([0,N])
title('Probabilty of each outcome of sixes experiment','fontsize',14,...
    'fontweight','bold')
xlabel('Number of sixes','fontsize',12,'fontweight','bold')
ylabel('Probability','fontsize',12,'fontweight','bold')
switch nargout
    case 0
        %do nothing
    case 1
        varargout(1) = {prob};
    otherwise
        error('wrong number of output arguments')
end