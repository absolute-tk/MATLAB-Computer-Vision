% Function to detect person using background subtraction
function detectPersonInVideo(videoPath)
    % Read the video file
    videoObj = VideoReader(videoPath);
    
    % Read the first frame as background
    background = readFrame(videoObj);
    background = rgb2gray(background);
    background = imgaussfilt(background, 2); % Apply Gaussian smoothing (Reduce Noise)
    
    % Reset video reader to start
    videoObj.CurrentTime = 0;
    
    % Create a figure window
    figure('Name', 'Person Detection', 'NumberTitle', 'off');
    
    % Process each frame
    while hasFrame(videoObj)
        % Read current frame
        currentFrame = readFrame(videoObj);
        
        % Store original frame for display
        originalFrame = currentFrame;
        
        % Convert to grayscale and smooth
        currentFrame = rgb2gray(currentFrame);
        currentFrame = imgaussfilt(currentFrame, 2);
        
        % Compute absolute difference (Background Subtraction)
        diffFrame = abs(double(background) - double(currentFrame));
        
        % Threshold the difference
        threshold = 50; % Adjust the threshold value based on needs
        binaryMask = diffFrame > threshold;
        
        % Clean up the binary mask (Morphological Operations)
        binaryMask = imclose(binaryMask, strel('square', 5)); %  (dilation followed by erosion) fills small gaps
        binaryMask = imfill(binaryMask, 'holes'); % Fills holes in the detected person
        binaryMask = bwareaopen(binaryMask, 500); % Remove small noise blobs
        
        % Find connected components
        [labeledImage, numObjects] = bwlabel(binaryMask); % Find connected area in binary mask.
        stats = regionprops(labeledImage, 'BoundingBox', 'Area'); % Calculate BoundingBox coordinates, size of detected area.
        
        % Display frame with detection
        imshow(originalFrame);
        hold on;
        
        % Draw bounding boxes around detected objects
        for i = 1:numObjects
            if stats(i).Area > 4000 % Minimum area threshold (Draw box only if area > 1000)
                bbox = stats(i).BoundingBox;
                rectangle('Position', bbox, 'EdgeColor', 'g', 'LineWidth', 2);
            end
        end
        
        hold off;
        drawnow;
    end
end

% Example usage (Type in Cmd Window -> Press Enter) :
% detectPersonInVideo('path_to_your_video.mp4')
% detectPersonInVideo('person_walk_slow.mov')
% detectPersonInVideo('person_walk_quick.mov')
