function simspace3(instrct,mode)
% function to create an Andrews plot of a matrix of rigid transformations (allout)
% with associated similarity values. Each row of allout consists of the 6
% rigid transformation parameters: tx, ty, tz, rx, ry, rz. sim is a column
% vector wih the same number of rows as allout. The function plots a 6D
% Andrews plot and colours each line according to its similarity value
% using the 'jet' colourmap, with high similarity values having 'hot'
% colours. 'indof' is a file name of a dof file to be plotted with a
% thicker line, used to compare with a starting estimate, e.g.
%
% Get handles for each line of plot
for strci = 1:length(instrct)
    allin = instrct(strci).inrdof;
    allout = instrct(strci).outrdof;
    inarray = instrct(strci).initdof;
    sim = instrct(strci).sim;
    subplot(length(instrct),1,strci);
    temp = andrewsplot([allin;allout;inarray(1:6)],'Standardize','on');
    in_h = temp(end);
    set(in_h,'LineWidth',3,'LineStyle','--','Color','r')
    outline_h = temp(size(allin,1)+1:end-1,:);
    inline_h = temp(1:size(allin,1),:);
    switch mode
        case 'in'
            set(outline_h,'Visible','off')
        case 'out'
            set(inline_h,'Visible','off')
    end
    set(gca,'YLim',[-7,7]);
    % Set colour resolution
    c_res = 128;
    % Get hot colourmap
    cmap = colormap(hot(c_res));
    % scale similarity values & round to nearest integer for use as indexes
    % into the colourmap.
    scaled_sim = round((sim - min(sim))/(max(sim) - min(sim)) * (c_res - 1)) + 1;
    % convert cmap into a cell array NX1 cell array, each row with one rgb
    % array
    try
        cmap_cell = mat2cell(cmap,ones(1,length(cmap)),3);
        set(outline_h,{'Color'},cmap_cell(scaled_sim,:));
    catch
        delete(outline_h)
    end
    set(gca,'Color',[0.7,0.7,0.7]);
    title(['vert ',instrct(strci).vert,',sb ',num2str(instrct(strci).sb),...
        ',dil ',num2str(instrct(strci).dil),...
        ',histeq ',num2str(instrct(strci).histeq)])
    %draw colour bar
    colorbar('YTick',[])
end

