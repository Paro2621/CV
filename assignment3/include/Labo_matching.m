clc, clear all, close all;

filename1 = 'images/Ex01_01.jpg';
filename2 = 'images/Ex01_02.jpg';

% load the images pair
img1 = imread(filename1);
if(length(size(img1)) > 2)
    img1 = rgb2gray(img1);
end
img2 = imread(filename2);
if(length(size(img2)) > 2)
    img2 = rgb2gray(img2);
end

% if the images are too large you might want to resize them to a smaller
% size
img1 = imresize(img1, 0.8);
img2 = imresize(img2, 0.8);

%%
method = 'POS'; 
% It can be:
% -- POS (position only)
% -- NCC (Normalized cross-correlation only)
% -- POSNCC (position + NCC)
% -- POSSURF (position + SURF)

threshold = 0.95; % A value between 0 and 1

flag = 0; % Set to 1 if you want to use to SVD decomposition

sigma = 10; % The scale of the exponential for the position contribution

list = findMatches(img1, img2, method, threshold, flag, sigma);
figure(10), show_matches(img1, img2, list, 0, 10);


