function resizeaxis(ax,wdth,hght)
%function to expand the width and height of axis 'ax' by factor 'wdth'
%and 'hght' respectivley, while leaving the center where it is.
pos = get(ax,'position');
%expand vertically
pos(2) = pos(2) - pos(4) / 2 * (hght - 1);
pos(4) = pos(4) * hght;
%expand horizontally
pos(1) = pos(1) - pos(3) / 2 * (wdth - 1);
pos(3) = pos(3) * wdth;
set(ax,'position',pos)