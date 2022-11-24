pos_index = 1; 
classification_per_frame = cell(1,1); 
inputs_of_positions_for_tracking = zeros(20*10, 3); 
positions_for_each_frame = cell(1,1); 
number_of_frames = 115; 

run('Parameters.m'); 
% going into the directory of the frames
cd Frames 

for each_frame = 1 : number_of_frames
    image_original = imread(['image', num2str(each_frame), '.jpg']);
    if param.cropping == 1
        image = imcrop(image_original, [param.crop_x1 param.crop_y1 param.crop_x2 param.crop_y2]);
    end
    
    binary_image = image_preprocessing(image_original);
    [image_connected, number_of_particles] = bwlabel(binary_image); 
    regionprops_features_extraction = regionprops(image_connected,'Area', 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'PixelIdxList', 'Perimeter'); 
    centroids_preallocation = zeros(number_of_particles, 2);

    for each_particle = 1 : number_of_particles
        centroids_preallocation(each_particle, :) = regionprops_features_extraction(each_particle).Centroid;
    end
    
    inputs_of_positions_for_tracking(pos_index:(pos_index + number_of_particles -1), 1) = centroids_preallocation(:,1); 
    inputs_of_positions_for_tracking(pos_index:(pos_index + number_of_particles -1), 2) = centroids_preallocation(:,2); 
    inputs_of_positions_for_tracking(pos_index:(pos_index + number_of_particles -1), 3) = each_frame; 

    pos_index = pos_index + number_of_particles; 
    positions_for_each_frame{1, each_frame} = [fix(centroids_preallocation(:, 1) * 10^4) / 10^4, fix(centroids_preallocation(:, 2) * 10^4)/10^4];
    particle_distances = squareform(pdist(cell2mat({regionprops_features_extraction(:).Centroid}'))); 

end

tracked_table = array2table(inputs_of_positions_for_tracking, 'VariableNames', {'x','y', 'frame'});
writetable(tracked_table,'Tracker_Input.csv')
pause
[tr tr_sorted sorted_results_particles] = tracking_the_data(number_of_frames, positions_for_each_frame);

return