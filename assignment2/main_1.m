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


img = im2gray(imread(images{1}));
red_car =       img(360:420,690:770);
turning_car =   img(370:412,555:645);
big_window =    img(320:462,495:705);   
    % bigger window black car - slower
small_window =  img(387:395,595:605);   
    % smaller window black car - we do not find the car anymore


TemplateMatching(red_car,       images, "Red car")
TemplateMatching(turning_car,   images, " Black car");
TemplateMatching(big_window,    images, "Big window black car");
TemplateMatching(small_window,  images, " Small window black car");


function TemplateMatching(window_size,images,Templatename)

figure, imagesc(window_size), axis equal, colormap gray
[h, l] = size(window_size);
fprintf('Window size: %d (height) x %d (lenght)\n', h, l);

figure
for i = 1:numel(images)
    img = im2gray(imread(images{i}));

    tic
    c = normxcorr2(window_size, img);
    elapsed_time = toc;


    fprintf('Image #%d, Template "%s: time = %.4f secondi\n', i,Templatename, elapsed_time);

    maxval = max(max(c));
    mask = c > 0.99*maxval;
    
    % figure, imagesc(mask), axis equal, colormap gray
    stats = regionprops("table", mask, "Centroid");
    centers = stats.Centroid(1,:); % first object's centroid (x, y)
   
    
    % Adjust centroid to top-left corner for rectangle placement
    x_corner = centers(1) - l;
    y_corner = centers(2) - h;
    
    subplot(2,3,i)
    imagesc(img), axis equal, hold on, colormap gray
    rectangle('Position', [x_corner, y_corner, l, h], 'EdgeColor', 'r')
    plot(centers(1)-l/2, centers(2)-h/2, '*r');
    title(images{i})
end

end


