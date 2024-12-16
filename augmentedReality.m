%% Augmented reality function that places the 3D box on the dominant plane plot

function transformedCorners = augmentedReality(points, bestPlane, bestInliers)

    % Getting the plane's normal vector
    normal = bestPlane(1:3); 
    normal = normal / norm(normal); % Normalizing the normal vector
    normal = -normal; 

    % Choosing a vector perpendicular to the normal starting with an arbitrary one, u
    u = [1, 0, 0];
    if abs(dot(normal, u)) > 0.99 % Checking if u is parallel to the normal vector
        u = [0, 1, 0]; % Switching to a different vector that will be perpendicular
    end

    % Computing two perpendicular vectors on the plane
    v = cross(normal, u); % First perpendicular vector
    v = v / norm(v); % Normalizing v
    u = cross(v, normal); % Ensuring u is perpendicular

    % Computing the origin of the local coordinate system (centroid of inliers)
    inlierPoints = points(bestInliers, :);
    centroid = mean(inlierPoints, 1); % This is the local origin 

    % Defining a box in local coordinates centered at the local origin
    boxSize = 0.5; % Size of the box
    boxCorners = [
        -boxSize, -boxSize, 0;
         boxSize, -boxSize, 0;
         boxSize,  boxSize, 0;
        -boxSize,  boxSize, 0;
        -boxSize, -boxSize, boxSize;
         boxSize, -boxSize, boxSize;
         boxSize,  boxSize, boxSize;
        -boxSize,  boxSize, boxSize
    ];

    rotationMatrix = [u; v; normal]'; % Our local to global rotation matrix

    % Transforming the box corners into global coordinates
    transformedCorners = (rotationMatrix * boxCorners')' + centroid;

    % Visualizing the box in the 3D scene

    % Plotting the points and dominant plane
    figure;
    plot3(points(:, 1), points(:, 2), points(:, 3), 'b.'); hold on;
    plot3(inlierPoints(:, 1), inlierPoints(:, 2), inlierPoints(:, 3), 'ro');
    xlabel('X'); ylabel('Y'); zlabel('Z');

    % Drawing the box edges

    edges = [
        1, 2; 2, 3; 3, 4; 4, 1; % Bottom face
        5, 6; 6, 7; 7, 8; 8, 5; % Top face
        1, 5; 2, 6; 3, 7; 4, 8  % Vertical edges
    ];
    
    for i = 1:size(edges, 1)
        plot3(transformedCorners(edges(i, :), 1), transformedCorners(edges(i, :), 2), transformedCorners(edges(i, :), 3), 'g-');
    end

    title('3D Scene with Augmented Reality Box');
    legend('All Points', 'Inliers (Dominant Plane)', 'Augmented Box');
    rotate3d on;
    hold off;
end
