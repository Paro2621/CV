function [] = compareCDOF(videoFile, tau1, alpha, tau2, W) 
% This function compares the output of the change detection algorithm based
% on a running average, and of the optical flow estimated with the
% Lucas-Kanade algorithm.
% You must visualize the original video, the background and binary map
% obtained with the change detection, the magnitude and direction of the
% optical flow.
% tau1 is the threshold for the change detection
% alpha is the parameter to weight the contribution of current image and
% previous background in the running average
% tau2 is the threshold for the image differencing in the running average
% W is the side of the square patch to compute the optical flow
warning('off', 'MATLAB:rankDeficientMatrix');
% Create a VideoReader object
videoReader = VideoReader(videoFile);
firstFrame = rgb2gray(readFrame(videoReader));
runningBg = double(firstFrame);
previous_frame = firstFrame;

% Loop through each frame of the video
while hasFrame(videoReader)

    % Read the next frame
    frame = rgb2gray(readFrame(videoReader));

    % -------- RUNNING AVG --------
    Dt = abs(double(frame) - double(previous_frame));
    motionMask = Dt > tau2;

    % update background where no motion
    runningBg(~motionMask) = (1-alpha)*runningBg(~motionMask) + alpha*double(frame(~motionMask));
    
    %actual motion detected
    Mt2 = abs(double(frame) - runningBg) > tau1;

    %----------OPTICAL FLOW lucas Kanade ---------
     I1 = double(previous_frame); %previous frame
     I2 = double(frame); 
                
    % compute space and time derivatives
    %where I1 is the previous frame and I2 is the current frame
    %here we are comparing 
    [fx, fy, ft] = ComputeDerivatives(I1, I2);
    
    % % Spatial derivatives
    % [Ix, Iy] = gradient(I1);
    % % temporal derivative
    % It = I2 - I1;
    % 
    % %loop for each pixel of the frame - compute (u,v)
    % % consider only a small window where motion is constant
    % [C, R] = size(I1);

    % INITIALIZATION U,V MATRICES
    u = zeros(size(I1));
    v = zeros(size(I1));
    
    halfW = floor(W/2);
    
    % Loop each pixel
    for i = 1+halfW : size(fx,1)-halfW
        for j = 1+halfW : size(fx,2)-halfW
    
            Ix_w = fx(i-halfW:i+halfW, j-halfW:j+halfW);
            Iy_w = fy(i-halfW:i+halfW, j-halfW:j+halfW);
            It_w = ft(i-halfW:i+halfW, j-halfW:j+halfW);
    
            A = [Ix_w(:), Iy_w(:)];
            B = -It_w(:);
    
            U= A\B;

            u(i,j)=U(1);
            v(i,j)=U(2);

            % rcond tells if the matrix can be inverted or it's near a singular configuration
            % if rcond(A' * A) > 1e-3
            %     flow = (A' * A) \ (A' * B); % similar to the pseudo invers
            %     u(y,x) = flow(1);
            %     v(y,x) = flow(2);
            % end
        end
    end  
    
    % adjust NaN, incase of rank deficiency set values to zero
     u(isnan(u))=0;
     v(isnan(v))=0;
   
    % show the optical flow
    flowRGB = convertToMagDir(u, v);

    % Display the frame
    figure(1), subplot(2, 2, 1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));

    % Display the map of the optical flow
    % You can obtain the map by using the convertToMagDir function
    figure(1), subplot(2,2, 2), imshow(flowRGB, 'Border', 'tight');
    title('Optical Flow');

    % Display the running average
    figure(1), subplot(2, 2, 4), imshow(uint8(runningBg), 'Border', 'tight');
    title('background');

    % Display the binary map obtained with the change detection
    figure(1), subplot(2, 2, 3), imshow(Mt2, 'Border', 'tight');
    title('Binary map 1');
    pause(0.01)
    
    previous_frame = frame;
end

fprintf('Finished displaying video: %s\n', videoFile);
end

%--------------------------------------------------------------------------
function [fx, fy, ft] = ComputeDerivatives(im1, im2)

if (size(im1,1) ~= size(im2,1)) | (size(im1,2) ~= size(im2,2))
   error('the two frames have different sizes');
end

if (size(im1,3)~=1) | (size(im2,3)~=1)
   error('images must be gray level');
end

% derivative estimation through convolution
fx = conv2(double(im1),0.25* [-1 1; -1 1]) + conv2(double(im2), 0.25*[-1 1; -1 1]);
fy = conv2(double(im1), 0.25*[-1 -1; 1 1]) + conv2(double(im2), 0.25*[-1 -1; 1 1]);
ft = conv2(double(im1), 0.25*ones(2)) + conv2(double(im2), -0.25*ones(2));

% adjusting the images size
fx=fx(1:size(fx,1)-1, 1:size(fx,2)-1);
fy=fy(1:size(fy,1)-1, 1:size(fy,2)-1);
ft=ft(1:size(ft,1)-1, 1:size(ft,2)-1);
end