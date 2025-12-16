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

i = 0;

% Loop through each frame of the video
while hasFrame(videoReader)
    % Read the next frame
    frame = readFrame(videoReader);

    % Display the frame
    figure(1), subplot(2, 2, 1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));

    % Fake image, just for the sake of running --> In the visualization
    % below replace with the appropriate image
    fake_img = uint8(128*ones(size(frame)));

    % Display the map of the optical flow
    % You can obtain the map by using the convertToMagDir function
    figure(1), subplot(2,2, 2), imshow(fake_img, 'Border', 'tight');
    title('Optical Flow');

    % Display the running average
    figure(1), subplot(2, 2, 4), imshow(fake_img, 'Border', 'tight');
    title('Static background');

    % Display the binary map obtained with the change detection
    figure(1), subplot(2, 2, 3), imshow(fake_img, 'Border', 'tight');
    title('Binary map 1');
    
    previous_frame = frame;

    i = i + 1;

end

fprintf('Finished displaying video: %s\n', videoFile);
end