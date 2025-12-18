function [] = segmentAndTrack(videoFile, tau1, alpha, tau2) 
% This function ...
% tau1 is the threshold for the change detection
% alpha is the parameter to weight the contribution of current image and
% previous background in the running average
% tau2 is the threshold for the image differencing in the running average
% Add here input parameters to control the tracking procedure if you need...

% Create a VideoReader object
videoReader = VideoReader(videoFile);
firstFrame = rgb2gray(readFrame(videoReader));
runningBg = double(firstFrame);
previous_frame = firstFrame;
i = 0;

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

    % Display the frame
    figure(1), subplot(2,2,1), imshow(frame, 'Border', 'tight');
    title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));

    % Display the running average
    figure(1), subplot(2, 2, 3), imshow(uint8(runningBg), 'Border', 'tight');
    title('background');

    % Display the binary map obtained with the change detection
    figure(1), subplot(2, 2, 2), imshow(Mt2, 'Border', 'tight');
    title('Binary map 1');
    pause(0.0005)
    
    % Update the running average and perform change detection

    if(i == 1380)
        imshow(frame);
        title('Click on the person wearing white');
        pause;
        
        [x, y] = ginput(1);
        x = round(x);
        y = round(y);
        
        trajectory = [x, y];


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
    
        % --- Post-processing della mappa binaria ---
        BW = bwareaopen(Mt2, 50);      % rimuove blob piccoli (rumore)
        BW = imfill(BW, 'holes');      % riempie i buchi
    
        % --- Connected Components ---
        cc = bwconncomp(BW);
    
        % --- Estrazione delle proprietà ---
        stats = regionprops(cc, 'Centroid', 'Area');
    
        % Se non ci sono oggetti, mantieni l'ultima posizione
        if isempty(stats)
            trajectory = [trajectory; trajectory(end, :)];
        else
            % --- Associazione del target ---
            lastPos = trajectory(end, :);
            minDist = inf;
            newPos = lastPos;
    
            for k = 1:length(stats)
                c = stats(k).Centroid;
                d = norm(c - lastPos);
    
                if d < minDist
                    minDist = d;
                    newPos = c;
                end
            end
    
            % --- Aggiorna la traiettoria ---
            trajectory = [trajectory; newPos];
        end
    
        % --- Visualizzazione del tracking ---
        subplot(2,2,1)
        hold on
        plot(trajectory(:,1), trajectory(:,2), 'r-', 'LineWidth', 2)
        plot(newPos(1), newPos(2), 'ro', 'MarkerSize', 8)
        hold off


    end

    previous_frame = frame;
    i = i + 1;

end

 % * At the end of the video, visualize the trajectory in the last
 %   frame

% Close the figure when playback is finished
close all;

fprintf('Finished displaying video: %s\n', videoFile);
end