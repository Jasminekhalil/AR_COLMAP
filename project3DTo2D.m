%% Projecting 3D to 2D function using pinhole camera model

function projectedCorners = project3DTo2D(points3D, quaternion, translation, focallength, principalx, principaly)

    % Converting current quaternion to rotation matrix
    R = quat2rotm(quaternion);

    % Constructing intrinsic camera matrix
    K = [focallength, 0, principalx;
         0, focallength, principaly;
         0, 0, 1];

    t = translation(:);

    % Combining rotation and translation into the extrinsic matrix
    extrinsicMatrix = [R, t];

    % Converting 3D points to homogeneous coordinates
    points3D_hom = [points3D, ones(size(points3D, 1), 1)]'; 

    % Projecting 3D points to 2D using pinhole camera model
    projectedPoints_hom = K * extrinsicMatrix * points3D_hom; 

    % Normalizing to Cartesian coordinates
    projectedCorners = projectedPoints_hom(1:2, :) ./ projectedPoints_hom(3, :); 
    projectedCorners = projectedCorners'; 
end

