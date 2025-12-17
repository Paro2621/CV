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

% -------------------compute static background-----------------------
% background duration (1 minute)
maxTime = 60;  

firstFrame = rgb2gray(readFrame(videoReader));
[H, W] = size(firstFrame);

% Initialize background structure
bgModel.sum   = zeros(H, W, 'double');   % Accumulate pixel values
bgModel.count = 0;                          % Number of frames

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
staticBg = double(bgModel.sum / bgModel.count);
fprintf('Background computed from %d frames (%.2f seconds)\n',bgModel.count, videoReader.CurrentTime);


% --------------------running average--------------------------
%we compute the difference between two consecutive frames to understand if a pixel is moving or not
runningBg = staticBg;
previous_frame = firstFrame;

while hasFrame(videoReader)

    frame = rgb2gray(readFrame(videoReader));

    % -------- STATIC BG --------
    Mt1 = abs(double(frame) - staticBg) > tau1;

    % -------- RUNNING AVG --------
    Dt = abs(double(frame) - double(previous_frame));
    motionMask = Dt > tau2;

    % update background where no motion
    runningBg(~motionMask) = (1-alpha)*runningBg(~motionMask) + alpha*double(frame(~motionMask));

    Mt2 = abs(double(frame) - runningBg) > tau1;

    previous_frame = frame;


    % Display the frame
    figure(1), subplot(2, 3, 1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
   
    % Display the static background
    figure(1), subplot(2, 3, 2), imshow(uint8(staticBg), 'Border', 'tight');
    title('Static background');

    % Display the binary map obtained with the static background
    figure(1), subplot(2, 3, 3), imshow(Mt1, 'Border', 'tight');
    title('Binary map 1');

    % Display the running average
    figure(1), subplot(2, 3, 5), imshow(uint8(runningBg), 'Border', 'tight');
    title('Running average');

    % Display the binary map obtained with the running average
    figure(1), subplot(2, 3, 6), imshow(Mt2, 'Border', 'tight');
    title('Binary map 2');
    pause(0.01)

end

% Close the figure when playback is finished
% close all force;

fprintf('Finished displaying video: %s\n', videoFile);
end