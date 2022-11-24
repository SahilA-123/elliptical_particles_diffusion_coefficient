function out = diff_coefficient_calculation(C, pixel_size, frame_rate)
 
% multiplying the row which contains x positions of the table with pixel size
C.XPosition = C.XPosition * pixel_size; 
% multiplying the row which contains y positions of the table with pixel size
C.YPosition = C.YPosition * pixel_size;
% converting the table to cell for some specific operations
Centroids = table2cell(C)
% while calculating diffusion coefficient, some particles need to be skipped
particles_to_be_skipped = [];
% defining number of particles and the longest track
number_of_particles = max( cell2mat(Centroids(:,4)) );
particles = cell( 1, number_of_particles );
the_longest_track_length = 0;
 
% iterating through each particle
for iterator = 1 : number_of_particles
    % taking each elliptial particle
    each_elliptical_particle = Centroids (cell2mat (Centroids(:, 4)) == iterator, :);
    no_of_samples = size(each_elliptical_particle,1); 
    no_of_mean_square_displacements = round(no_of_samples - 1);
    particles{iterator} = struct();
    particles{iterator}.number = no_of_mean_square_displacements;
    % calculating the mean square displacement
    particles{iterator}.msd = zeros(1, no_of_mean_square_displacements);
    % the msd uncertainity of each eliptical particle
    particles{iterator}.msdUncertainty = zeros(1, no_of_mean_square_displacements);
     
    if no_of_mean_square_displacements == 0
        particles_to_be_skipped = [particles_to_be_skipped iterator];
    else
        % for each mean square displacement
        for iterator2 = 1 : no_of_mean_square_displacements
            % distance travelled in x (dx)
            small_distance_x = cell2mat(each_elliptical_particle(1 : 1 : (end - iterator2), 1)) - cell2mat(each_elliptical_particle((iterator2 + 1) : 1 : end, 1));
            % distance travelled in direction y(dy)
            small_distance_y = cell2mat(each_elliptical_particle(1 : 1 : (end - iterator2), 2)) - cell2mat(each_elliptical_particle((iterator2 + 1) : 1 : end, 2));
            % dx square + dy square --> mean square displacement
            msd = mean(small_distance_x .^ 2 + small_distance_y .^ 2);
            % final msd and uncertainity calculation 
            particles{iterator}.msd(iterator2) = msd;
            particles{iterator}.msdUncertainty(iterator2) = std(small_distance_x .^ 2 + small_distance_y .^ 2)/sqrt(length(small_distance_x .^ 2 + small_distance_y .^ 2));
        end

        particles{iterator}.diffusionCoefficient = particles{iterator}.msd(1) / (2 * 2 * frame_rate ^ -1);
        the_longest_track_length = max (the_longest_track_length, no_of_samples);
        loglog( (1 : no_of_mean_square_displacements) / frame_rate, particles{iterator}.msd(1 : no_of_mean_square_displacements), 'color', rand(1,3) );
        hold on;
    end
end
 
d = zeros(1, number_of_particles);
avg_mean_square_disp = zeros( 1, the_longest_track_length );
avg_mean_square_disp_count = zeros( 1, the_longest_track_length);
 
% iterating through each particle
for each_particle = 1 : number_of_particles
    if sum(particles_to_be_skipped == each_particle) == 0 
        no_of_mean_square_displacements = length(particles{each_particle}.msd);
        % for each particle, we calculate the following
        % diff coefficent, avg msd, and avg msd count
        d(each_particle) = particles{each_particle}.diffusionCoefficient;
        avg_mean_square_disp(1:no_of_mean_square_displacements) = avg_mean_square_disp(1:no_of_mean_square_displacements) + particles{iterator}.msd;
        avg_mean_square_disp_count(1:no_of_mean_square_displacements) = avg_mean_square_disp_count(1:no_of_mean_square_displacements) + 1;
    end
end
 
% plotting 
avg_mean_square_disp = avg_mean_square_disp ./ avg_mean_square_disp_count;
loglog((1 : the_longest_track_length) / frame_rate, avg_mean_square_disp, 'k', 'linewidth', 3);
% y axis will have the mean square displacement in m^2
ylabel('MSD (m^2)');
% x axis will have the time in seconds
xlabel('Time (s)');
title('MSD versus Time Interval');
 
out = struct();
out.diffusionCoefficient = mean(d);
out.diffusionCoefficientUncertainty = std(d)/sqrt(length(d));
out.particles = particles;