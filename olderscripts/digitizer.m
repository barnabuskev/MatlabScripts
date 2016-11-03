function out = digitizer
%select image
[FName,PName] = uigetfile('*.tiff;*.TIF;*.gif;*.GIF;*.jpeg;*.JPEG;*.jpg;*.JPG;*.pbm;*.bmp','Get Image File');
if isequal(FName,0) | isequal(PName,0)
    disp('User pressed cancel')
else
    cd(PName)
    %read image
    Im = imread(FName);
    size(Im)
    class(Im)
    %display image
    imagesc(Im);
    colormap(gray)
    [x,y] = ginput(11)
end
