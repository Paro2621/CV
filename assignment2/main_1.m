close all;
clear, clc;

addpath("testimages/")

% second part
images = { 'ur_c_s_03a_01_L_0376.png', ...
           'ur_c_s_03a_01_L_0377.png', ...
           'ur_c_s_03a_01_L_0378.png', ...
           'ur_c_s_03a_01_L_0379.png', ...
           'ur_c_s_03a_01_L_0380.png', ...
           'ur_c_s_03a_01_L_0381.png' };
%% first part
y_min = 350;
y_max = 440;

x_min = 670;
x_max = 790;


img = im2gray(imread(images{1}));
turning_car = img(y_min:y_max, x_min:x_max, :);

figure, imagesc(turning_car), axis equal, colormap gray

c = normxcorr2(turning_car,img);

maxval = max(max(c));

mask = c > 0.99*maxval;

% figure, imagesc(mask), axis equal, colormap gray
stats = regionprops("table", mask, "Centroid");
centers = stats.Centroid(1,:); % first object's centroid (x, y)

l = x_max - x_min;
h = y_max - y_min;

% Adjust centroid to top-left corner for rectangle placement
x_corner = centers(1) - l;
y_corner = centers(2) - h;

figure
for i = 1:numel(images)
    img = im2gray(imread(images{i}));

    c = normxcorr2(turning_car,img);

    maxval = max(max(c));
    mask = c > 0.99*maxval;
    
    % figure, imagesc(mask), axis equal, colormap gray
    stats = regionprops("table", mask, "Centroid");
    centers = stats.Centroid(1,:); % first object's centroid (x, y)
    
    l = x_max - x_min;
    h = y_max - y_min;
    
    % Adjust centroid to top-left corner for rectangle placement
    x_corner = centers(1) - l;
    y_corner = centers(2) - h;
    
    subplot(2,3,i)
    imagesc(img), axis equal, hold on, colormap gray
    rectangle('Position', [x_corner, y_corner, l, h], 'EdgeColor', 'r')
    title(images{i})
end

%% second part
y_min = 370;
y_max = 412;

x_min = 550;
x_max = 645;

img = im2gray(imread(images{1}));
turning_car = img(y_min:y_max, x_min:x_max, :);

figure, imagesc(turning_car), axis equal, colormap gray

c = normxcorr2(turning_car,img);

maxval = max(max(c));

mask = c > 0.99*maxval;

% figure, imagesc(mask), axis equal, colormap gray
stats = regionprops("table", mask, "Centroid");
centers = stats.Centroid(1,:); % first object's centroid (x, y)

l = x_max - x_min;
h = y_max - y_min;

% Adjust centroid to top-left corner for rectangle placement
x_corner = centers(1) - l;
y_corner = centers(2) - h;

figure
for i = 1:numel(images)
    img = im2gray(imread(images{i}));

    c = normxcorr2(turning_car,img);

    maxval = max(max(c));
    mask = c > 0.99*maxval;
    
    % figure, imagesc(mask), axis equal, colormap gray
    stats = regionprops("table", mask, "Centroid");
    centers = stats.Centroid(1,:); % first object's centroid (x, y)
    
    l = x_max - x_min;
    h = y_max - y_min;
    
    % Adjust centroid to top-left corner for rectangle placement
    x_corner = centers(1) - l;
    y_corner = centers(2) - h;
    
    subplot(2,3,i)
    imagesc(img), axis equal, hold on, colormap gray
    rectangle('Position', [x_corner, y_corner, l, h], 'EdgeColor', 'r')
    title(images{i})
end
