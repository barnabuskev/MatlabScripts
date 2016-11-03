function [V,vsize,vdim,type_str] = giplread2(filename)
% giplread  Read a gipl file of type short, complex float or U_char.
%
%        [V,vsize,vdim] = giplread('filename') reads 
%                                             the gipl file 'filename'
%
%        [V,vsize,vdim] = giplread   brings up a load box  
%
%        giplread or giplread('filename') display information
%   
%        V is the MATLAB matrix of voxels
%        vsize = [ ny nx nz nt]
%        vdim  = [ ydim xdim zdim tdim]
%
%        Currently reads  U_char, shorts and complex float gipls only.
%        Will read volume data.
%        The gipl file is assumed to be ieee-be, i.e. created on UNIX.
%        giplread will read these files on either a PC or UNIX.
%
%        Note MATLAB matrices are in row, column order
%
%        David Atkinson, UMDS, 1997.
%
% %W% , created %G%
%
% See also GIPLWRITE

if nargin < 1
  [filename,pathname] = uigetfile('*.gipl','Load gipl file') ;

  if filename ==0
    error([ ' No file selected.' ])
  end 

  filename = [pathname filename] ;
end


if isempty(findstr(filename,'.'))
        filename=[filename,'.gipl'];
end;


[fid, message] = fopen(filename,'r','ieee-be') ;  % IEEE Big-endian
if fid == -1
  a=['file ',filename,' not found.'];
  error(a);
end


nx = fread(fid,1,'short') ;
ny = fread(fid,1,'short') ;
nz = fread(fid,1,'short') ;
nt = fread(fid,1,'short') ;

image_type = fread(fid,1,'short') ;  

xdim = fread(fid,1,'float') ;
ydim = fread(fid,1,'float') ;
zdim = fread(fid,1,'float') ;
tdim = fread(fid,1,'float') ;

vsize = [ny nx nz nt] ;
vdim =  [ydim xdim zdim tdim] ;

% (header code was in /usr/local/VoxObj/giplHeader.h also see
% GiplHead.cc
% Code has moved to /projects/local/ipg.classes/Common )
% 192 is IT_C_FLOAT , 15 is IT_SHORT , 8 is IT_U_CHAR


switch image_type
  case 192
      type_str = 'complex_float';
      disp([ filename,' is a complex gipl file'])
  case 15
      type_str = 'short';
      disp([ filename,' is a short gipl file'])
  case 8
      type_str = 'u_char';
      disp([ filename,' is a U_char gipl file'])
  otherwise
      disp([ filename,' has unrecognized or unimplemented file type ',...
	  num2str(image_type) ])
end
disp([ 'nx = ',num2str(nx), ...
       ', ny = ',num2str(ny), ...
       ', nz = ',num2str(nz), ...
       '. xdim = ', num2str(xdim) , ...
       ', ydim = ',num2str(ydim), ...
       ', zdim = ',num2str(zdim) ])
   
if nargout == 0
  return
end
 

status = fseek(fid,256,'bof') ;
if status==-1 
  ferror(fid)
end

switch image_type
  case  192
    disp([' Reading the complex gipl file ',filename ])
    %pre-allocate matrices to speed up code
    ridat = zeros(2*nx , ny);
    cdat = zeros(ny,nx,nz) ;

    for iz = 1:nz 
      ridat = fread(fid,[2*nx, ny],'float') ;

      ii = sqrt(-1) ;

      for ix= 1:nx       % this loop should be replaced with shiftdim etc
        for iy = 1:ny
          rd = ridat((2*ix) - 1, iy ) ;
          id = ridat((2*ix) , iy ) ;
          cdat(iy,ix,iz) = rd + ii*id ;   %MATLAB MATRICES ARE ROW-COLUMN ORDER
        end
      end
    end % iz

    V = cdat ;

  case 15   % shorts
    disp([' Reading the short gipl file ',filename])

    sgipl_dat = zeros(nx, ny) ;
    out_dat = zeros(ny,nx,nz) ;

    for iz = 1:nz
      sgipl_dat = fread(fid,[nx, ny],'short') ;
      out_dat(:,:,iz) = shiftdim(sgipl_dat,1) ;
    end
 
    V = out_dat ;

  case 8   %U_CHAR
    disp([ 'Reading the U_CHAR gipl file ',filename])
    
    sgipl_dat = zeros(nx, ny) ;
    out_dat = zeros(ny,nx,nz) ;

    for iz = 1:nz
      sgipl_dat = fread(fid,[nx, ny],'uchar') ;
      out_dat(:,:,iz) = shiftdim(sgipl_dat,1) ;
    end
 
    V = out_dat ;
    
  otherwise  
    disp([ ' image_type ',num2str(image_type),' not recognised.'])
end

fclose(fid) ;

