function immont
%function to create image montage
%get files
[datpn,flist] = GetListFiles('Select image files');
if isempty(flist)
    return
end
cd(datpn)
nf = length(flist);
sz = zeros(nf,2);
inimg = cell(nf,1);
for ia = 1:nf
    %create cell array of file names
    fn = [datpn,filesep,flist{ia}];
    imgi = imfinfo(fn);
    sz(ia,2) = imgi.Width;
    sz(ia,1) = imgi.Height;
    I = imread(fn);
    inimg{ia} = imadjust(I,stretchlim(I),[]);
end
%resize to largest
[m,mi] = max(prod(sz,2));
h = sz(mi,1);
w = sz(mi,2);
rzims = zeros(h,w,3,nf);
for ia = 1:nf
    tmp = imresize(inimg{ia},[h,w]);
    rzims(:,:,:,ia) = tmp;
end
tmp = inputdlg(['Enter dimensions for ',num2str(nf),' images'],'',1,{'[3,4]'});
dms = eval(tmp{1});
while prod(dms) ~= nf
    tmp = inputdlg(['Dimensions does not match no. of images (',num2str(nf),'). Try again']);
    dms = eval(tmp{1});
end
%create background
bdr = 3;
bkr = zeros(h * dms(1) + bdr * (dms(1) + 1), w * dms(2) + bdr * (dms(2) + 1),3);
clr = [0,128,0];
for ia = 1:3
    bkr(:,:,ia) = clr(ia);
end
for ib = 1:dms(1)
    %for each row
    for ia = 1:dms(2)
        %for each column
        imi = ia + dms(2) * (ib - 1);
        tlw = bdr * ia + w * (ia - 1) + 1;
        tlh = bdr * ib + h * (ib - 1) + 1;
        bkr(tlh:tlh + h - 1,tlw:tlw + w - 1,:) = rzims(:,:,:,imi) / 256;
    end
end
imshow(bkr)
%h = montage(rzims,'Size',dms,'displayrange',[0,255]);
