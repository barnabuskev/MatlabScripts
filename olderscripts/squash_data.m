function squashed = squash_data(data_strct)
%function to take the output of getdataA and concatenate the random dof in,
% dof out arrays into matrices and the similarity values, repetition counter into arrays
%
% field values used to select data to concatenate
all_inrdofs = cell2mat({data_strct.inrdof}');
all_outdofs = cell2mat({data_strct.outrdof}');
all_initdofs = cell2mat({data_strct.initdof}');
all_sim = [data_strct.sim];
field_vals = {'subj',{'A','B','C'};
    'slice',{'0000'};
    'vert',{'T11','T12','L1','L2','L3','L4','L5','S1'};
    'sb',[0,1,2];
    'dil',[0,2,3,4];
    'histeq',[0,1]};
%Initialise structure array counter
count = 1;
for i = 1:length(field_vals{1,2})
    for j = 1:length(field_vals{2,2})
        for k = 1:length(field_vals{3,2})
            for el = 1:length(field_vals{4,2})
                for m = 1:length(field_vals{5,2})
                    for n = 1:length(field_vals{6,2})
                        is_subj = strcmp({data_strct.(field_vals{1,1})},field_vals{1,2}{i});
                        %disp(['Subject is :',field_vals{1,2}{i}])
                        is_slice = strcmp({data_strct.(field_vals{2,1})},field_vals{2,2}{j});
                        %disp(['Slice is :',field_vals{2,2}{j}])
                        is_vert = strcmp({data_strct.(field_vals{3,1})},field_vals{3,2}{k});
                        %disp(['Vert is :',field_vals{3,2}{k}])
                        is_sb = ([data_strct.(field_vals{4,1})] == field_vals{4,2}(el));
                        %disp(['sb is :',num2str(field_vals{4,2}(el))])
                        is_dil = ([data_strct.(field_vals{5,1})] == field_vals{5,2}(m));
                        %disp(['dil is :',num2str(field_vals{5,2}(m))])
                        is_histeq = ([data_strct.(field_vals{6,1})] == field_vals{6,2}(n));
                        %disp(['histeq is :',num2str(field_vals{6,2}(n))])
                        foundi = find(is_subj & is_slice & is_vert & is_sb & is_dil & is_histeq);
                        %add to new structure array if data is there
                        if ~isempty(foundi)
                            squashed(count).(field_vals{1,1}) = field_vals{1,2}{i};
                            squashed(count).(field_vals{2,1}) = field_vals{2,2}{j};
                            squashed(count).(field_vals{3,1}) = field_vals{3,2}{k};
                            squashed(count).(field_vals{4,1}) = field_vals{4,2}(el);
                            squashed(count).(field_vals{5,1}) = field_vals{5,2}(m);
                            squashed(count).(field_vals{6,1}) = field_vals{6,2}(n);
                            squashed(count).inrdof = all_inrdofs(foundi,:);
                            squashed(count).outrdof = all_outdofs(foundi,:);
                            squashed(count).sim = all_sim(foundi);
                            squashed(count).initdof = all_initdofs(foundi(1),:);
                            count = count + 1
                        else
                            return
                        end
                    end
                end
            end
        end
    end
end