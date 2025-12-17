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

% Create a VideoReader object
videoReader = VideoReader(videoFile);
firstFrame = rgb2gray(readFrame(videoReader));
runningBg = double(firstFrame);
previous_frame = firstFrame;

% i = 0;

% Loop through each frame of the video
while hasFrame(videoReader)
    % Read the next frame
    frame = rgb2gray(readFrame(videoReader));

    % -------- RUNNING AVG --------
    Dt = abs(double(frame) - double(previous_frame));
    motionMask = Dt > tau2;

    % update background where no motion
    runningBg(~motionMask) = (1-alpha)*runningBg(~motionMask) + alpha*double(frame(~motionMask));
    Mt2 = abs(double(frame) - runningBg) > tau1;

    %----------OPTICAL FLOW lucas Kanade ---------

    I1 = double(frame);
    I2 = double(previous_frame); %previous frame
    
    % Spatial derivatives
    [Ix, Iy] = gradient(I1);
    % temporal derivative
    It = I2 - I1;
    
    %loop for each pixel of the frame - compute (u,v)
    % consider only a small window where motion is constant
    [C, R] = size(I1);

    % INITIALIZATION U,V MATRICES
    u = zeros(C,R);
    v = zeros(C,R);
    
    halfW = floor(W/2);
    
    % Loop each pixel
    for y = 1+halfW : C-halfW
        for x = 1+halfW : R-halfW
    
            Ix_w = Ix(y-halfW:y+halfW, x-halfW:x+halfW);
            Iy_w = Iy(y-halfW:y+halfW, x-halfW:x+halfW);
            It_w = It(y-halfW:y+halfW, x-halfW:x+halfW);
    
            A = [Ix_w(:), Iy_w(:)];
            B = -It_w(:);
    
            % rcond tells if the matrix can be inverted or it's near a singular configuration
            if rcond(A' * A) > 1e-3
                flow = (A' * A) \ (A' * B); % similar to the pseudo invers
                u(y,x) = flow(1);
                v(y,x) = flow(2);
            end
        end
    end

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
    title('Static background');

    % Display the binary map obtained with the change detection
    figure(1), subplot(2, 2, 3), imshow(Mt2, 'Border', 'tight');
    title('Binary map 1');
    pause(0.01)
    
    previous_frame = frame;
    % i = i + 1;

end

fprintf('Finished displaying video: %s\n', videoFile);
end