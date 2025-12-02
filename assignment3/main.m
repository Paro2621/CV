% TODO
% IF WE CHANGE THE NUMBER OF POINTS TO ESTIMATE F ? WHAT CHANGES?
% FOR OUR IMAGE DISCUSS HOW WE FOUND THE POINTS  

%% Part 1: estimation of the fundamental matrix with manually selected correspondences
clear, clc;
close all;

addpath('include')
addpath('media')

% Load images
img1 = imread('Rubik1.pgm');
img2 = imread('Rubik2.pgm');

% Load points
P1orig = load('Rubik1.points'); % [13r, 2c]
P2orig = load('Rubik2.points');

%P1orig = P1orig(1:10,:);
%P2orig = P2orig(1:10,:);

n = size(P1orig,1);

% Add the third component to work in homogeneous coordinates
P1 = [P1orig'; ones(1,n)];
P2 = [P2orig'; ones(1,n)];


% Estimate the fundamental matrix
function F = EightPointsAlgorithm(P1, P2)
    n = size(P1,2);

    m2 = [1 0 0; 1 0 0; 1 0 0; 0 1 0; 0 1 0; 0 1 0; 0 0 1; 0 0 1; 0 0 1];
    m1 = [1 0 0; 0 1 0; 0 0 1; 1 0 0; 0 1 0; 0 0 1; 1 0 0; 0 1 0; 0 0 1];

    A = zeros(n,9);

    for i = 1:n        
        A(i, :) = (m2*P2(:, i))' .* (m1*P1(:, i))' ;
    end

    [~, ~, V] = svd(A);
    
    V_end = V(:, end);
    
    F = [V_end(1:3)'; V_end(4:6)'; V_end(7:9)'];
    
    % since rank(F) == 3 we anforce rank 2
    [U1, D1, V1] = svd(F);   
    D1(3, 3) = 0;

    F = U1*D1*V1';
end

% ---- w/out normalization ---- 
F = EightPointsAlgorithm(P1, P2);
figure
visualizeEpipolarLines(img1, img2, F, P1orig, P2orig, 1);

% ---- w/ normalization ----
Fn = EightPointsAlgorithmN(P1, P2);
figure
visualizeEpipolarLines(img1, img2, Fn, P1orig, P2orig, 2);
title("Normalized points");


% task 2.1 - epipolar constraint check
% ---- evaluation ----
z = [];
for i = 1:n
    z(i) = P2(:, i)' * Fn * P1(:, i);
end 

TH = 1e-2;
z
abs(z)
sum(abs(z))
sum(abs(z))< TH % false!!! without normal. the values are worse!

% task 2.2 - epipoles
[U, W, V] = svd(Fn);

disp("Left epipoles") 
disp(U(:, end)')

disp("Right epipoles") 
disp(V(:, end)')

% pause
% % close all
% visualizeEpipolarLines(img1, img2, F, [], [], 110);


%% Part 1: w/ Mire
clc; clear;
addpath('include')
addpath('media')

% Load images
img1 = imread('Mire1.pgm');
img2 = imread('Mire2.pgm');

% Load points
P1orig = load('Mire1.points');
P2orig = load('Mire2.points');

n = size(P1orig,1);

% Add the third component to work in homogeneous coordinates
P1 = [P1orig'; ones(1,n)];
P2 = [P2orig'; ones(1,n)];

% ---- w/out normalization ---- 
F = EightPointsAlgorithm(P1, P2);
figure
visualizeEpipolarLines(img1, img2, F, P1orig, P2orig, 1);

% ---- w/ normalization ----
Fn = EightPointsAlgorithmN(P1, P2);
figure
visualizeEpipolarLines(img1, img2, Fn, P1orig, P2orig, 2);

% task 2.1 - epipolar constraint check
% ---- evaluation ----
z = [];
for i = 1:n
    z(i) = P2(:, i)' * Fn * P1(:, i);
end 

TH = 1e-2;
z
abs(z)
sum(abs(z))
sum(abs(z))< TH % false!!! without normal. the values are worse!

% task 2.2 - epipoles
[U, W, V] = svd(Fn);

disp("Left epipoles") 
disp(U(:, end)')

disp("Right epipoles") 
disp(V(:, end)')


%% Part 2: assessing the use of RANSAC 
clc, clear all;
addpath('include')
addpath('media')

% Load images
img1 = imread('Rubik1.pgm');
img2 = imread('Rubik2.pgm');

% Load points
P1orig = load('Rubik1.points');
P2orig = load('Rubik2.points');

% Add random points (to assess RANSAC)
x1r = double(round(size(img1,1)*rand(5,1)));
y1r = double(round(size(img1,2)*rand(5,1)));

x2r = double(round(size(img2,1)*rand(5,1)));
y2r = double(round(size(img2,2)*rand(5,1)));

P1orign = [P1orig; [x1r, y1r]];
P2orign = [P2orig; [x2r, y2r]];

n = size(P1orign,1);

% Add the third component to work in homogeneous coordinates
P1 = [P1orign'; ones(1,n)];
P2 = [P2orign'; ones(1,n)];

% -------------------------------------------------------------------------
% Estimate the fundamental matrix with RANSAC
th = 10^(-2);
[F, consensus, outliers] = ransacF(P1, P2, th);
% -------------------------------------------------------------------------

% EXTRACT ONLY THE GOOD MATCHES (INLIERS)
P1_inliers = consensus(1:3, :);
P2_inliers = consensus(4:6, :);

% Visualize the epipolar lines
visualizeEpipolarLines(img1, img2, F, P1_inliers(1:2, :)', P2_inliers(1:2, :)', 120);

% epipolar constraint check on inliers only
% ---- evaluation ----
z = [];
num_inliers = size(P1_inliers, 2); 

for i = 1:num_inliers
    % Calculate x' * F * x
    z(i) = P2_inliers(:, i)' * F * P1_inliers(:, i);
end

TH = 1e-2;
z;
% 2. Analysis
mean_error = mean(abs(z)); % Better to use mean than sum
max_error = max(abs(z));   % Check the worst outlier

disp(['Mean Algebraic Error: ', num2str(mean_error)]);

% 3. Boolean Check
TH = 1e-2; % Threshold
is_valid = mean_error < TH;

if is_valid
    disp('Epipolar constraint holds.');
else
    disp('Epipolar constraint violated (or F is incorrect).');
end

% abs(z)
% sum(abs(z))
% sum(abs(z))< TH % false!!! without normal. the values are worse!

% task 2.2 - epipoles
[U, W, V] = svd(F);

disp("Left epipoles") 
disp(U(:, end)')

disp("Right epipoles") 
disp(V(:, end)')



%% Part 3: using image matching+ransac
clc, close all, clear all;
addpath('include')
addpath('media')

% Load images
img1 = rgb2gray(imread('charbel_side1.jpg'));
img2 = rgb2gray(imread('charbel_side2.jpg'));

img1 = imresize(img1, 0.5);
img2 = imresize(img2, 0.5);

% extraction of keypoints and matching
list = imageMatching(img1, img2, 'POSNCC', 0.65, 1, 100);

n = size(list,1);

% Add the third component to work in homogeneous coordinates
P1 = [list(:,2)'; list(:,1)'; ones(1,n)];
P2 = [list(:,4)'; list(:,3)'; ones(1,n)];

% Estimate the fundamental matrix with RANSAC
th = 10^(-2);
[F, consensus, outliers] = ransacF(P1, P2, th);

% Visualize the epipolar lines
visualizeEpipolarLines(img1, img2, F, P1(1:2,:)', P2(1:2,:)', 130);

[U, W, V] = svd(F);

disp("Left epipoles") 
disp(U(:, end)')

disp("Right epipoles") 
disp(V(:, end)')

