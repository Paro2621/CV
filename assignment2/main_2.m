% TODO: show corners on R-score map

close all;
clear, clc;

addpath("testimages/")

img_rgb=imread('i235.png');
figure,image(img_rgb), axis equal, colormap gray
title("initial image")

% Harris corner detector
tmp = img_rgb;
I=double(tmp);

% compute x and y derivative of the image
dx=[1 0 -1; 2 0 -2; 1 0 -1];
dy=[1 2 1; 0  0  0; -1 -2 -1];

Ix=conv2(I,dx,'same');
Iy=conv2(I,dy,'same');

% compute products of derivatives at every pixel
Ix2=Ix.*Ix; Iy2=Iy.*Iy; Ixy=Ix.*Iy;

% compute the sum of products of  derivatives at each pixel
g = fspecial('gaussian', 9, 1.2);
%figure,imagesc(g),colormap gray,title('Gaussian')

Sx2=conv2(Ix2,g,'same'); 
Sy2=conv2(Iy2,g,'same'); 
Sxy=conv2(Ixy,g,'same');

% features detection
[rr,cc]=size(Sx2);

edge_reg=zeros(rr,cc); 
corner_reg=zeros(rr,cc); 
flat_reg=zeros(rr,cc);

R_map=zeros(rr,cc);
k=0.05;

for i=1:rr
    for j=1:cc
        % define at each pixel x,y the matrix
        M=[Sx2(i,j),Sxy(i,j);Sxy(i,j),Sy2(i,j)];
        % compute the response of the detector at each pixel
        R = det(M) - k*(trace(M).^2);
        R_map(i,j)=R;
        % threshod on value of R
        if R<-300000
            edge_reg(i,j)=1;
        elseif R>300000
            corner_reg(i,j)=1;
        else
            flat_reg(i,j)=1;
        end
    end
end

%figure,imagesc(edge_reg.*I),colormap gray,title('edge regions')
%figure,imagesc(corner_reg.*I),colormap gray,title('corner regions')
%figure,imagesc(flat_reg.*I),colormap gray,title('flat regions')
%figure,imagesc(R_map),colormap gray,title('R map')

%% Required plot
close all;

% partial derivatives
figure
subplot(1,2,1), imagesc(Ix),colormap gray,title('Ix'),axis square
subplot(1,2,2), imagesc(Iy),colormap gray,title('Iy'),axis square

% gaussian filter
figure,
imagesc(g),colormap gray,title('Gaussian'), axis square

% R score map
figure,
imagesc(R_map),colormap gray,title('R map'), axis square

% spotted corners
figure,
imagesc(I),colormap gray,title('corner regions spotted')
axis square, hold on

max_R_map = max(max(R_map));

corner_reg_star = R_map > 0.3*max_R_map;

stats = regionprops("table",corner_reg_star,"Centroid");

centers = stats.Centroid;

plot(centers(:, 1), centers(:, 2), '*r')
