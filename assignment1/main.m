% NOTE: 
% ricordati di aggiungere il path delle *testimages*
% imfilter dovrebbe fare la stessa cosa di conv2(, 'same')

clear, close, clc;

addpath("testimages/")

% -- functions --
function printBW(out)
    imagesc(out),colormap gray
    axis square
end

function out = randnNoise(IN, stdd)
    out = double(IN) + stdd*randn(size(IN));
end

function out = spNoise(IN, noise_d)
    IN = double(IN);
    [rr,cc] = size(IN);
    maxv = max(max(IN));
    indices = full(sprand(rr,cc,noise_d)); % 0.3 is the noise density 
    mask1 = indices>0 & indices<0.5;  mask2=indices>=0.5;
    out = IN.*(~mask1) ;
    out = out.*(~mask2)+maxv*mask2;
end

% -- main --
% (1) import tree image
IN=imread('tree.png');

figure
subplot(1,2,1), printBW(IN), title('initial image')
subplot(1,2,2), axis square, imhist(uint8(IN),256)

% (1) just Gaussian noise
img = randnNoise(IN, 20); %20 is the standard deviation
figure 
subplot(1,2,1), printBW(img), title('added gaussian noise')
subplot(1,2,2), axis square, imhist(uint8(img),256)

% (1) add salt and pepper 
img = spNoise(img, 0.2);
figure
subplot(1,2,1), printBW(img), title('added salt and pepper noise')
subplot(1,2,2), axis square, imhist(uint8(img),256)

%% smoothing techniques
% (2) smoothing by averaging 3x3
[X,Y]=meshgrid(1:3);

K = ones(3)/9;
out_a3 = conv2(img,K,'same');

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), surf(X, Y, K), title('Average 3x3 kernel')
subplot(1, 3, 3), printBW(out_a3),title('Smoothing by averaging 3x3')

% (2) non-linear filter 3x3
out_nl3 = medfilt2(img,[3,3]);

figure
subplot(1, 2, 1), printBW(img), title('Input image')
subplot(1, 2, 2), printBW(out_nl3),title('Smoothing by median 3x3')

% (2) gaussian 3x3
fsize = 3;
sigma = fsize; % a seen 
h = fspecial('gaussian', fsize, sigma);
out_g3 = imfilter(img, h); 

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), surf(X, Y, h), title('Gaussian 3x3 kernel')
subplot(1, 3, 3), printBW(out_g3),title('Gaussian smoothing 3x3')

%% smoothing thecniques 2
% (2) smoothing by averaging 7x7
[X,Y]=meshgrid(1:7);
K = ones(7)/49;
out_a7 = conv2(img,K,'same');

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), surf(X, Y, K), title('Average 7x7 kernel')
subplot(1, 3, 3), printBW(out_a7),title('Smoothing by averaging 7x7')

% (2) non-linear filter 7x7
out_nl7 = medfilt2(img,[7,7]);

figure
subplot(1, 2, 1), printBW(img), title('Input image')
subplot(1, 2, 2), printBW(out_nl7), title('Smoothing by median 7x7')

% (2) gaussian 7x7
fsize = 7;
sigma = fsize/6;
h = fspecial('gaussian', fsize, sigma);
out_g7 = imfilter(img, h); 

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), surf(X, Y, h), title('Gaussian 7x7 kernel')
subplot(1, 3, 3), printBW(out_g7),title('Gaussian smoothing 7x7')

%% (3) sharpening
% attenzione, nelle slide c'è una sezione su come ottimizzare
% efficientemente i filtri dati dalla composizione di altri filtri

% ---- FILTER DEFINITION --------------------------------------------------
Fsize = 7; % filter size (odd number)
[X,Y]=meshgrid(1:Fsize);

% filter "same"     sF
sF = zeros(Fsize); 
sF(ceil(Fsize/2), ceil(Fsize/2)) = 1;

% filter "average"  aF
aF = ones(Fsize)./(Fsize^2);

% filter "sharpening" h 
alpha = 1;
h = sF + alpha*(sF - aF);

% filtro "move"     mF
px_sx = 20;
px_up = 40;

sizeF = max(px_sx, px_up);
mF = zeros(sizeF*2+1); 
mF(sizeF+ px_up, sizeF + px_sx) = 1;

% -------------------------------------------------------------------------
% sharpening w/ covolution 
out_s = imfilter(IN, h);

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), surf(X, Y, h), title('Sharpening kernel')
subplot(1, 3, 3), printBW(out_s),title('Sharpened image')

% sharpening w/ subtraction and addition 
base = im2double(IN);
smoothed = imfilter(base, aF, 'replicate', 'same');
detail = base - smoothed;
sharpened = base + alpha*detail;

figure
subplot(1, 4, 1), printBW(base), title('Initial')
subplot(1, 4, 2), printBW(smoothed), title('Smoothed')
subplot(1, 4, 3), printBW(detail), title('Detail')
subplot(1, 4, 4), printBW(sharpened), title('Sharpened')

% traslation 
out_s = conv2(IN, mF, 'same');

figure
subplot(1, 3, 1), printBW(img), title('Input image')
subplot(1, 3, 2), spy(mF), title('Traslation kernel (spy)'), grid on
subplot(1, 3, 3), printBW(out_s), title('Traslated')

%% (4) FFT
printBW(IN), title('immagine iniziale')

% modulo base
img = double(IN);
IMG = fft2(img);
MOD = abs(IMG);
% PHI = angle(IMG); % not in use
printBW(log(fftshift(MOD))), colormap gray, xlabel('wx'), ylabel('wy')

% applico filtro gaussiano
fsize = 101;
sigma = 5;
h = fspecial('gaussian', fsize, sigma);
out_g101 = imfilter(img, h, 'replicate', 'same'); 
printBW(out_g101), title('gaussian smoothing 101x101')

% display del filtro gaussiano
[X,Y] = meshgrid(1:fsize);
figure,surf(X, Y, h), title('gaussiano 101x101')

IMG = fft2(out_g101);
MOD = abs(IMG);
figure, printBW(log(fftshift(MOD))), colormap gray,xlabel('wx'),ylabel('wy')

% sharpening
sF = zeros(7); sF(3,3) = 1;
aF = ones(7)./49;
h = sF + sF - aF;

out_s7 = imfilter(IN, h);
figure, printBW(out_s7),title('sharpened output')

IMG = fft2(out_s7);
MOD = abs(IMG);
figure, printBW(log(fftshift(MOD))), colormap gray,xlabel('wx'),ylabel('wy')
