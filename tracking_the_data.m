function [tr tr_sorted sorted_results_particles] = process_tracking_data(number_of_frames, positions_for_each_frame)
tr = csvread('Tracked_Particles_Input.csv'); 

for each_row = 1 : length(tr)
    tr(each_row,4) = tr(each_row,4) + 1; 
end
for each_row = 1 : length(tr)
    tr(each_row, 5) = each_row;
end

maximum_text = max(tr(:,4));

for each_row = 1 : length(tr)
    tr(each_row, 1) = fix(tr(each_row,1) * 10^4) / 10^4; 
    tr(each_row, 2) = fix(tr(each_row,2)*10^4) / 10^4; 
end

for i = 1 : number_of_frames
    clear rows_on_the_right right_tracking left_tracking tracking_inner_table tracking_inner
    rows_on_the_right = find (tr (:,3) == i);

    left_tracking = table(positions_for_each_frame{1,i} (:,3), [positions_for_each_frame{1,i}(:,1),positions_for_each_frame{1,i}(:,2)],...
        'VariableNames', ...
        {'pos' 'localid'}); 

    right_tracking = table([tr(rows_on_the_right(1,1):rows_on_the_right(length(rows_on_the_right),1),1),tr(rows_on_the_right(1,1):rows_on_the_right(length(rows_on_the_right),1),2)], ... 
    tr(rows_on_the_right(1,1):rows_on_the_right(length(rows_on_the_right),1),5),...
        'VariableNames',{'pos' 'row number'}); 

    tracking_inner_table = innerjoin(left_tracking,right_tracking); 
    tracking_inner = table2cell(tracking_inner_table); 

    for each_row = 1 : length(tracking_inner)
        tr(tracking_inner{each_row, 6}, 5) = tracking_inner{each_row, 1}; 
        tr(tracking_inner{each_row, 6}, 6) = tracking_inner{each_row, 3}; 
        tr(tracking_inner{each_row, 6}, 7) = tracking_inner{each_row, 4}; 
    end
end

new_tr = num2cell(tr); 

final_results = cell2table(new_tr,  'VariableNames', {'XPosition' 'YPosition' 'Frame' 'ParticleID' 'LocalID' 'LocalChainID' 'ChainList'});
sorted_results = sortrows(final_results, 3); 
sorted_results_particles = sortrows(final_results, 4); 
tr_sorted = table2array (sorted_results(: , 1 : 7)); 