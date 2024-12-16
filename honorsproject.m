% Loading COLMAP data 
load('cameras.mat');
load('images.mat');

% Loading the points3D.mat file
points = load('points3D.mat');
points3D = table2array(points.points3D);

% Setting RANSAC parameters
iterations = 50000; % Number of RANSAC iterations
threshold = 0.05; % Inlier distance threshold

% Running RANSAC to find the dominant plane
[bestPlane, bestInliers] = RANSACroutinefunction(points3D, threshold, iterations);

% Visualizing the augmented reality box on top of dominant plane
transformedCorners = augmentedReality(points3D, bestPlane, bestInliers);

% Gathering quaternions and translations for each view
quaternions = {img1quart, img2quart, img3quart, img4quart, img5quart, img6quart, img7quart};
translations = {img1tran, img2tran, img3tran, img4tran, img5tran, img6tran, img7tran};

% Size of virtual box
boxSize = 1.0;

% Normal of the dominant plane
planeNormal = bestPlane(1:3);

% Processing each image
for i = 1:7
    % Loading the current image
    image = imread(sprintf('image%d.JPG', i));
    
    % Overlaying the virtual box
    overlay3DBox(image, transformedCorners, quaternions{i}, translations{i}, focallength, principalx, principaly);
end