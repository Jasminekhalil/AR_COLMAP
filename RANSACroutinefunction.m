%% RANSAC routine function for finding the dominant plane in the scene 

function [bestPlane, bestInliers] = RANSACroutinefunction(points, threshold, iterations)

    % Initializing variables for the routine
    bestInliers = [];
    maxInliers = 0;
    bestPlane = [0, 0, 0, 0];

    for i = 1:iterations
        % Randomly selecting 3 unique points to define a plane from the points array
        randomIndices = randperm(size(points, 1), 3); 
        p1 = points(randomIndices(1), :);
        p2 = points(randomIndices(2), :);
        p3 = points(randomIndices(3), :);

        % Calculating the plane equation Ax+By+Cz+D = 0 by findng the normal vector by cross product of (p2 - p1) and (p3 - p1)
        normal = cross(p2 - p1, p3 - p1);
        A = normal(1);
        B = normal(2);
        C = normal(3);
        D = -dot(normal, p1);

        % Calculating distance of ALL points to the plane
        distances = abs(A * points(:,1) + B * points(:,2) + C * points(:,3) + D) / norm(normal);
        % Finding inliers based on the distance threshold
        inliers = distances < threshold;

        % Checking if this plane has more inliers than the previous best plane
        numInliers = sum(inliers);
        if numInliers > maxInliers
            maxInliers = numInliers;
            bestInliers = inliers;
            bestPlane = [A, B, C, D];
        end
    end
    
    bestInlierPoints = points(bestInliers, :);
    points(bestInliers, :);

    % Displaying the point cloud and the inliers
    figure;
    plot3(points(:,1), points(:,2), points(:,3), 'b.'); hold on;
    plot3(bestInlierPoints(:, 1), bestInlierPoints(:, 2), bestInlierPoints(:, 3), 'ro');
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('3D Point Cloud with Dominant Plane Inliers');
    legend('All Points', 'Inliers (Dominant Plane)');
    rotate3d on
    hold off;
end