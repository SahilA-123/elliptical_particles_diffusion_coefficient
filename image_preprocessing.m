function binary_image = image_preprocess(image_original)

% below are the parameter defined
cropping = 1;
top_left_cropping = 0; 
bottom_left_cropping = 0 
top_right_cropping = 1000; 
bottom_right_cropping = 1000; 
neighbourhodd_stdlift_function = 11; 
threshold_value_stdlift_function = 7; 
std_deviation_gaussian = 1; 
threshold_for_image_intensity = 100; 
low_range_intensities_gaussian = 100; 
low_range_intensities_scaled = 0; 
high_range_intensities_scaled = 255; 
high_range_intensities_gaussian = 170; 
smallest_particle_area_filer = 70; 
biggest_particle_area_filter = 155; 
perimeter_threshold = 50; 
eccentricity_threshold = 0.7; 
 
checking_the_rgb_value = size(image_original,3);
if checking_the_rgb_value == 1
    defining_class_of_rgb = 0; 
else
    defining_class_of_rgb = 1; 
end

if parameter_cropping == 1
    processed_image = imcrop(image_original, [top_left_cropping bottom_left_cropping top_right_cropping bottom_right_cropping]);    
else
    processed_image = image_original;
end

if defining_class_of_rgb == 1
    processed_image = rgb2gray(processed_image);
end

image_obtained_from_stdfilt_image = stdfilt(double(processed_image), ones(neighbourhodd_stdlift_function)); 
rough_filtered_image = threshold_value_stdlift_function < image_obtained_from_stdfilt_image; 
rough_image = processed_image .* uint8(rough_filtered_image);
image_after_gaussian_filtering = imgaussfilt(rough_image,std_deviation_gaussian); 
remapping_gaussian_values = [low_range_intensities_gaussian high_range_intensities_gaussian]/255; 
remapping_scaled_values = [low_range_intensities_scaled high_range_intensities_scaled]/255; 
adjusted_image = imadjust(image_after_gaussian_filtering, remapping_gaussian_values, remapping_scaled_values); 
betweewn_image = adjusted_image > threshold_for_image_intensity; 
filtered_image = bwareafilt(betweewn_image, [smallest_particle_area_filer biggest_particle_area_filter]); 

[a_i_labeled_image, i_particles_count_eccentricity] = bwlabel(filtered_image); 
eccentricity_value = regionprops(a_i_labeled_image, 'Perimeter','Eccentricity', 'PixelIdxList'); 
particles_to_remove = [eccentricity_value.Eccentricity] < eccentricity_threshold | [eccentricity_value.Perimeter] > perimeter_threshold ; 
binary_image = filtered_image;
binary_image( vertcat( eccentricity_value(particles_to_remove).PixelIdxList ) ) = 0; 
