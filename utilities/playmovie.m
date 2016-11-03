function playmovie(varargin)
%function to get movie mat file & display it
%get file
switch nargin
    case 0
        [fn,pn,fi] = uigetfile('*.mat','Get matlab movie file');
        fpth = [pn,fn];
        if fi
            load(fpth)
        else
            return
        end
    case 1
        fpth = varargin{1};
        load(fpth)
end
[pathstr,fn,x,x] = fileparts(fpth);
%get movie
S = whos;
cl = {S.class};
sind = find(cellfun(@(x) isequal(x,'struct'),cl));
if isempty(sind)
    error('File loaded is not a movie')
end
M = eval(S(sind).name);
test = {'cdata';'colormap'};
if ~isequal(fieldnames(M),test)
    error('File loaded is not a movie')
end
answer = inputdlg('How many frames to play?','playmovie',1,{'20'});
n = str2double(answer{1});
fh = figure;
set(gca,'xtick',[],'ytick',[])
title(fn)
set(gcf,'resize','off')
movie(gca,M,n,5)

