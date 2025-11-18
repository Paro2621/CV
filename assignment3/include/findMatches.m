function [list] = findMatches(img1, img2, type, THRESH, withSVD, sigma)


% extract SIFTs from both images
% f1_all and f2_all contain the keypoints positions 
% d1_all and d2_all contain the sift descriptors 

points1 = detectFASTFeatures(img1);
f1_all = points1.Location;
d1_all = extractFeatures(img1,points1.Location,Method="SURF");

points2 = detectFASTFeatures(img2);
f2_all = points2.Location;
d2_all = extractFeatures(img2,points2.Location,Method="SURF");


f1_all = f1_all';
f2_all = f2_all';
d1_all = d1_all';
d2_all = d2_all';

% Eliminating features too close to borders (where the patch would partially fall outside the image)
delta = 10;
idx = f1_all(1,:) > delta & f1_all(1,:) < size(img1,2)-delta & f1_all(2,:) > delta & ...
    f1_all(2,:) < size(img1,1)-delta;
F1 = f1_all(:,idx);
D1 = d1_all(:,idx);

idx = f2_all(1,:) > delta & f2_all(1,:) < size(img2,2)-delta & f2_all(2,:) > delta & ...
    f2_all(2,:) < size(img2,1)-delta;
F2 = f2_all(:,idx);
D2 = d2_all(:,idx);

figure(1);
imshow(img1),hold on;
plot(F1(1,:), F1(2,:), '*');

figure(2);
imshow(img2),hold on;
plot(F2(1,:), F2(2,:), '*');

% From now on, we use F1, D1 and F2, D2
if(strcmp(type, 'POS'))
    
    %% MATCHING CONSIDERING EUCLIDEAN DISTANCE BETWEEN POSITIONS

    % Initialize the affinity matrix
    A = zeros(size(F1,2), size(F2, 2));

    % Build the affinity matrix
    for i = 1 : size(F1,2)

        for j = 1 : size(F2,2)

            A(i,j) = similarity('POS', F1(:, i)', F2(:, j)', [], [], [], [], sigma);

        end
    end

elseif(strcmp(type, 'NCC'))
    
    %% MATCHING CONSIDERING PATCHES SIMILARITY

    % SET THE PATCH SIZE (for the NCC contribution) TO AN APPROPRIATE VALUE 
    % (delta is half the size of the patch, i.e. if delta=2 the patch is 5x5)
    delta = 5; 

    % Initialize the affinity matrix
    A = zeros(size(F1,2), size(F2, 2));


    % Build the affinity matrix
    for i = 1 : size(F1,2)

        % select the patch around the keypoint
        Qi = img1(round(F1(2,i))-delta:round(F1(2,i))+delta, round(F1(1,i))-delta:round(F1(1,i))+delta);

        for j = 1 : size(F2,2)

            % select the patch around the keypoint
            Qj = img2(round(F2(2,j))-delta:round(F2(2,j))+delta, round(F2(1,j))-delta:round(F2(1,j))+delta);  

            A(i,j) = similarity('NCC', [], [], Qi, Qj, [], [], 0.);

        end
    end

elseif(strcmp(type, 'POSNCC'))
    
    %% MATCHING CONSIDERING EUCLIDEAN DISTANCE BETWEEN POSITIONS AND PATCHES SIMILARITY

    % SET THE PATCH SIZE (for the NCC contribution) TO AN APPROPRIATE VALUE 
    % (delta is half the size of the patch, i.e. if delta=2 the patch is 5x5)
    delta = 5; 

    % Initialize the affinity matrix
    A = zeros(size(F1,2), size(F2, 2));


    % Build the affinity matrix
    for i = 1 : size(F1,2)

        % select the patch around the keypoint
        Qi = img1(round(F1(2,i))-delta:round(F1(2,i))+delta, round(F1(1,i))-delta:round(F1(1,i))+delta);

        for j = 1 : size(F2,2)

            % select the patch around the keypoint
            Qj = img2(round(F2(2,j))-delta:round(F2(2,j))+delta, round(F2(1,j))-delta:round(F2(1,j))+delta);  

            A(i,j) = similarity('POSNCC', F1(:, i)', F2(:, j)', Qi, Qj, [], [], sigma);

        end
    end

elseif(strcmp(type,'POSSURF'))


    %% MATCHING USING POSITIONS AND SIFT DESCRIPTORS

    A = zeros(size(D1, 2), size(D2, 2));

    for i = 1 : size(A, 1)
        for j = 1 : size(A, 2)
            A(i,j) = similarity('POSSURF', F1(:, i)', F2(:, j)', [], [], D1(:, i), D2(:, j), sigma);

        end
    end
end

figure, imagesc(A), colorbar
title('Original similarity matrix');

% Enhancing good matches with SVD
if(withSVD==1)
    [U, D, V] = svd(A);
    I = eye(size(D));
    A1 = U*I*V';

    figure, imagesc(A1), colorbar
    title('Enforcing good matches with SVD')
else
    A1 = A;
end




% Detecting good matches
list = [];

for i = 1 : size(A1, 1)

    [maxvali, j] = max(A1(i,:));
    [maxvalj, k] = max(A1(:,j));

    if(k==i && maxvali >= THRESH) % IF YOU WANT TO CONSIDER A THRESHOLD ADD A CONDITION: && maxvali >= THRESH
        list = [list; F1(2:-1:1,i)' F2(2:-1:1,j)'];
    end
end