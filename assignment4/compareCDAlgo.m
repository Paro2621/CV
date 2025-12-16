function [] = compareCDAlgo(videoFile, tau1, alpha, tau2) 
% This function compares the output of the change detection algorithm when
% using two possible background models:
% 1. A static model, e.g. a single frame or the average of N frames.
% In this case, the background is computed once and for all
% 2. A running average to update the model. In this case the background is
% updated, if needed, at each time instant
% You must visualize the original video, the background and binary map
% obtained with 1., the background and binary map
% obtained with 2.
% tau1 is the threshold for the change detection
% alpha is the parameter to weight the contribution of current image and
% previous background in the running average
% tau2 is the threshold for the image differencing in the running average

% Create a VideoReader object
videoReader = VideoReader(videoFile);

% compute background
% background duration (1 minute)
maxTime = 60;   % seconds

% Read first frame to get dimensions
firstFrame = rgb2gray(readFrame(videoReader));
[H, W] = size(firstFrame);

% Initialize background structure
bgModel.sum   = zeros(H, W, 'double');   % Accumulate pixel values
bgModel.count = 0;                          % Number of frames
bgModel.mean  = [];

% Accumulate frames for first 1 minute
% Add first frame
bgModel.sum   = bgModel.sum + double(firstFrame);
bgModel.count = bgModel.count + 1;

while hasFrame(videoReader) && videoReader.CurrentTime < maxTime

    frame = rgb2gray(readFrame(videoReader));

    bgModel.sum   = bgModel.sum + double(frame);
    bgModel.count = bgModel.count + 1;
end

% Compute per-pixel mean background
bgModel.mean = uint8(bgModel.sum / bgModel.count);
fprintf('Background computed from %d frames (%.2f seconds)\n',bgModel.count, videoReader.CurrentTime);


% Loop through each frame of the video
while hasFrame(videoReader)
    % Read the next frame
    frame = readFrame(videoReader);

    % Display the frame
    figure(1), subplot(2, 3, 1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));

    %binary map
    Mt= abs(frame - bgModel.mean)> tau1;
 
    % Display the static background
    figure(1), subplot(2, 3, 2), imshow(bgModel.mean, 'Border', 'tight');
    title('Static background');

    % Display the binary map obtained with the static background
    figure(1), subplot(2, 3, 3), imshow(Mt, 'Border', 'tight');
    title('Binary map 1');

    % % Display the running average
    % figure(1), subplot(2, 3, 5), imshow(fake_img, 'Border', 'tight');
    % title('Running average');
    % 
    % % Display the binary map obtained with the running average
    % figure(1), subplot(2, 3, 6), imshow(fake_img, 'Border', 'tight');
    % title('Binary map 2');
    pause(0.01)

end

% Close the figure when playback is finished
close all;

fprintf('Finished displaying video: %s\n', videoFile);
end