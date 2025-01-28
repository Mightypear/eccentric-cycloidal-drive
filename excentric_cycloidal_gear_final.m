function excentric_cycloidal_gear()

    % Parameters
    pin_radius = 10;
    pin_circle_radius = 71.1; 
    number_of_pins = 19;
    
    % The circumference of the rolling circle needs to be exactly equal to the pitch of the pins
    rolling_circle_radius = pin_circle_radius / number_of_pins; 
    reduction_ratio = number_of_pins - 1; % reduction ratio
    cycloid_base_radius = reduction_ratio * rolling_circle_radius; % base circle diameter of cycloidal disk

    contraction = 1; % :)
    
    % Set up the figure
    figure;
    hold on;
    grid on ; 
    axis equal;
    axis off;
    xlim([-pin_circle_radius-4*pin_radius, pin_circle_radius+4*pin_radius]);
    ylim([-pin_circle_radius-4*pin_radius, pin_circle_radius+4*pin_radius]);

    % Plot cycloid base circle
    theta = linspace(0, 360, 361);
    plot(cycloid_base_radius * cosd(theta), cycloid_base_radius * sind(theta), 'k--', 'LineWidth', 2);

    % Plot rolling circle
    rolling_circle = rectangle('Position', [-rolling_circle_radius, -rolling_circle_radius, ...
        2*rolling_circle_radius, 2*rolling_circle_radius], 'Curvature', [1 1], 'EdgeColor', 'b', 'LineWidth', 2);

    % Initialize variables for epicycloid
    epicycloid_points = [];

    % Main loop for epicycloid drawing (0.1 degree step for finer resolution)
    for angle = 0:0.5:360
        % Rotate rolling circle around the center of the cycloid
        x = (cycloid_base_radius + rolling_circle_radius) * cosd(angle);
        y = (cycloid_base_radius + rolling_circle_radius) * sind(angle);
        set(rolling_circle, 'Position', [x-rolling_circle_radius, y-rolling_circle_radius, ...
            2*rolling_circle_radius, 2*rolling_circle_radius]);

        % Calculate the epicycloid points
        point_x = x + (rolling_circle_radius - contraction) * cosd(number_of_pins * angle);
        point_y = y + (rolling_circle_radius - contraction) * sind(number_of_pins * angle);
        epicycloid_points = [epicycloid_points; point_x, point_y];

        % Plot epicycloid (more points increase smoothness)
        if size(epicycloid_points, 1) > 1
            plot(epicycloid_points(:,1), epicycloid_points(:,2), 'r', 'LineWidth', 2);
        end
        
        pause(0.001); % Slows down the animation
    end

    % % Draw pins
    % for pin_angle = linspace(0, 360, number_of_pins + 1)
    %     pin_x = pin_circle_radius * cosd(pin_angle) + rolling_circle_radius - contraction;
    %     pin_y = pin_circle_radius * sind(pin_angle);
    %     rectangle('Position', [pin_x-pin_radius, pin_y-pin_radius, 2*pin_radius, 2*pin_radius], ...
    %         'Curvature', [1 1], 'EdgeColor', 'g', 'LineWidth', 2);
    % end

    % Use the new approach to calculate the offset epicycloid
    offset_epicycloid_points = offset_epicycloid_normals(epicycloid_points, pin_radius);

    % Plot the offset epicycloid
    plot(offset_epicycloid_points(:,1), offset_epicycloid_points(:,2), 'b', 'LineWidth', 2);

    hold off;

end

% Define the offset_epicycloid_normals function below the main function
function offset_points = offset_epicycloid_normals(points, offset_distance)
    % Initialize the offset points array
    num_points = size(points, 1);
    offset_points = zeros(num_points, 2);
    
    % Loop through the points and calculate normals for each segment
    for i = 1:num_points
        % Find the previous and next points
        if i == 1
            prev_point = points(end, :);  % Loop around for the first point
        else
            prev_point = points(i-1, :);
        end
        
        if i == num_points
            next_point = points(1, :);  % Loop around for the last point
        else
            next_point = points(i+1, :);
        end

        % Compute the tangent vector between the next and previous points
        tangent = next_point - prev_point;
        
        % Compute the normal vector (perpendicular to the tangent)
        normal = [-tangent(2), tangent(1)];  % Rotate by 90 degrees
        
        % Normalize the normal vector
        normal = normal / norm(normal);
        
        % Offset the point in the direction of the normal vector
        offset_points(i, :) = points(i, :) + offset_distance * normal;
    end
end
