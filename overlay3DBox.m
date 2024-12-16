%% Overlaying 3D box onto real scene function

function overlay3DBox(image, boxCorners, quaternion, translation, focallength, principalx, principaly)

    % Defining the 6 faces of the box 
    faces = [
        1, 2, 3, 4; % Bottom face
        5, 6, 7, 8; % Top face
        1, 2, 6, 5; % Front face
        2, 3, 7, 6; % Right face
        3, 4, 8, 7; % Back face
        4, 1, 5, 8  % Left face
    ];

    % Projecting the box corners to 2D using the project3DTo2D function (pinhole camera model)
    projectedCorners = project3DTo2D(boxCorners, quaternion, translation, focallength, principalx, principaly);

    % Computing the depth of each face using the camera's principal axis (the z-axis in world space)

    faceDepths = zeros(size(faces, 1), 1);

    % Converting the quaternion of the current view into a rotation matrix
    R = quat2rotm(quaternion); 

    for i = 1:size(faces, 1)
        faceCorners = boxCorners(faces(i, :), :); % Getting the 4 corners of the face in 3D space

        % Projecting the center of the face to the camera's coordinate system
        faceCenter = mean(faceCorners, 1); % The average position of the 4 corners

        % Rotating and translating the face center into the camera's coordinate
        rotatedFaceCenter = (R * faceCenter')' + translation; 

        % Finding depth as the z-coordinate in the camera's coordinate system
        depth = rotatedFaceCenter(3);

        faceDepths(i) = depth; 
    end

    % Sorting the faces by depth from farthest to closest
    [~, sortedIndices] = sort(faceDepths, 'descend');

    % Defining a color gradient from pink to yellow for the faces
    pink = [1, 0.75, 0.8]; % RGB for pink
    yellow = [1, 1, 0]; % RGB for yellow

    % Computing the color for each face based on depth
    colorGradient = zeros(length(sortedIndices), 3);
    minDepth = min(faceDepths);
    maxDepth = max(faceDepths);

    for i = 1:length(sortedIndices)
        % Interpolating between pink and yellow based on depth
        depthNormalized = (faceDepths(sortedIndices(i)) - minDepth) / (maxDepth - minDepth);
        colorGradient(i, :) = (1 - depthNormalized) * pink + depthNormalized * yellow;  
    end

    % Displaying the current image view
    figure; imshow(image); hold on;

    % Drawing the faces in the correct order based on the sorted depth
    for i = 1:length(sortedIndices)
        faceIdx = sortedIndices(i);
        faceCorners = projectedCorners(faces(faceIdx, :), :); % Getting the 4 corners of the face in 2D
        fill(faceCorners(:, 1), faceCorners(:, 2), colorGradient(i, :), 'FaceAlpha', 1); % Drawing filled polygon
    end

    hold off;
end