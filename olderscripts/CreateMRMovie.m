function fnm=CreateMRMovie
%Load mat file into 3D matrix
[fnm,pnm]=uigetfile('*.*','CreateMRMovie');
[pathstr,name,ext,versn]=fileparts([pnm,fnm]);
temp=load([pnm,fnm]);
fld=fieldnames(temp);
if prod(size(fld))~=1
    error('More than one variable in mat file')
    return
end
threeD=getfield(temp,fld{1});
movie=mov_slice(threeD,'t',name);
movie2avi(movie,[pnm,name,'Trans','.avi'],'quality',100,'fps',10)
movie=mov_slice(threeD,'s',name);
movie2avi(movie,[pnm,name,'Sagit','.avi'],'quality',100,'fps',10)
movie=mov_slice(threeD,'c',name);
movie2avi(movie,[pnm,name,'Coron','.avi'],'quality',100,'fps',10)

function M=mov_slice(in_array,s,tit)
%obtain movie
array_size=ndims(in_array);
if array_size~=3
    errordlg('Not a 3D array','Error')
    return
end
slice_thick=2;
pix_size=4/3;
L_lim=0;
%select 'bone' greyscale colormap
cm=colormap(bone(256));
%View slices
switch s
case {'T','t'}
	%obtain transverse images
	in=squeeze(in_array(1,:,:))-L_lim;
	h=image(in,'EraseMode','none');
	ax_h=get(h,'Parent');
    set(get(ax_h,'Parent'),'name',[tit,'trans'])
	set(ax_h,'DataAspectRatio',[pix_size,slice_thick,1]);
	M(1)=getframe(ax_h);
	n=size(in_array,1);
	for i=2:n
        in=squeeze(in_array(i,:,:))-L_lim;
        set(h,'CData',in);
        drawnow
        M(i)=getframe(ax_h);
	end
case {'S','s'}
	%obtain sagital images
	in=squeeze(in_array(:,:,1)-L_lim);
	h=image(in,'EraseMode','none');
    ax_h=get(h,'Parent');
    set(get(ax_h,'Parent'),'name',[tit,'sagit'])
	set(ax_h,'DataAspectRatio',[1,1,1]);
	M(1)=getframe(ax_h);
	n=size(in_array,3);
	for i=2:n
        in=squeeze(in_array(:,:,i))-L_lim;
        set(h,'CData',in);
        drawnow
        M(i)=getframe(ax_h);
    end
case {'C','c'}
	%obtain coronal images
	in=squeeze(in_array(:,1,:))-L_lim;
	h=image(in,'EraseMode','none');
    ax_h=get(h,'Parent');
    set(get(ax_h,'Parent'),'name',[tit,'coron'])
	set(ax_h,'DataAspectRatio',[pix_size,slice_thick,1]);
    M(1)=getframe(ax_h);
	n=size(in_array,2);
	for i=2:n
        in=squeeze(in_array(:,i,:))-L_lim;
        set(h,'CData',in);
        drawnow
        M(i)=getframe(ax_h);
	end
end
