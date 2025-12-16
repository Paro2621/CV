function [] = segmentAndTrack(videoFile, tau1, alpha, tau2) 
% This function ...
% tau1 is the threshold for the change detection
% alpha is the parameter to weight the contribution of current image and
% previous background in the running average
% tau2 is the threshold for the image differencing in the running average
% Add here input parameters to control the tracking procedure if you need...

% Create a VideoReader object
videoReader = VideoReader(videoFile);

i = 0;

% Loop through each frame of the video
while hasFrame(videoReader)
    % Read the next frame
    frame = readFrame(videoReader);

    % Display the frame
    figure(1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));

    % Update the running average and perform change detection

    if(i == 1380)
        pause;

        % In this frame there is a person wearing in white, this is the
        % target you must track
        % Pick a point manually on the person to initialize your trajectory

    elseif(i > 1380)

        % * Perform change detection and update the background model
        % * Identify the connected components in the binary map using the
        %   Matlab function bwconncomp
        % * Extract a description for each connected component using the
        %   Matlab function regionprops
        % * Now you have the positions of all connected components observed
        %   in the current frame and you can associate the target to its new
        %   position --> Append the new position to the trajectory

    end

    i = i + 1;

end

 % * At the end of the video, visualize the trajectory in the last
 %   frame

% Close the figure when playback is finished
close all;

fprintf('Finished displaying video: %s\n', videoFile);
end