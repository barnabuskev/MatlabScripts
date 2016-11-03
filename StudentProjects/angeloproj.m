% Angelo Zanfardino's project 
workdir = 'C:\Users\Researcher\Documents\MATLAB\Angelo';
% 2XN cell array giving info on N poins - name and type (single point or hemisphere)
marker_cell = {'plumbU','point';'plumbL','point';'nasion','point';'inion','hemi';'C7','hemi';'T7','hemi';'T12','hemi';
    'L3','hemi';'L5','hemi';'Gtroch','point';'fib','point';'latmal','point'};
% NX3 cell array with N = number of different factors, 1st col name of
% factor. 2nd col is a regex to identify factor from file name. Empty
% reg string means get from image. Don't specify this field if no factors
% specified. Regex should be able to identify all levels of factor,
% e.g.{before|after},{treatment|control}. 3rd 1 X P col is cell array of level
% names where P=number of levels.
factor_cell = {'fatigue','\d{3}(fat|nonfat)',{'fat','nonfat'}};
% regex to get subject code from file name
subj_reg = 'IMG_(\d{3})';
conf_strct = struct('markers',{marker_cell},'factors',{factor_cell},'subj_reg',subj_reg);
getmarkers(conf_strct,workdir)
