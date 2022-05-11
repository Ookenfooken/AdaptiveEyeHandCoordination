analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%% define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
gazeSequence = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        currentGazeSequence = NaN(numTrials,5);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % ball and slot fixations during reach and transport phase
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end
            letterChange = currentResult(n).dualTask.sampleLetterChange(1);
            graspDifference = (letterChange-currentResult(n).info.phaseStart.ballGrasp)/200; % in seconds
            dropDifference = (letterChange-currentResult(n).info.phaseStart.ballInSlot)/200; % in seconds
            
            currentGazeSequence(n,:) = [blockID currentParticipant fixationPattern ...
                graspDifference dropDifference];
        end
        gazeSequence = [gazeSequence; currentGazeSequence];
    end
end
clear ballIdx ballOffset slotIdx slotOnset ballFixType 
clear letterChange graspDifference dropDifference

%% plot probability of letter change in fingertip trials relative to grasp (Panel A)
blockID = 3;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 4; % 4: grasp, 5: slot entry
lowerBound = -2;
upperBound = 2;
figure(blockID*selectedColumn) % relative to ball grasp
hold on
storedMeans = zeros(5,1);
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3); 
    for n = 1:5
       plot(timePoint, sum(currentTimeWindow == n-1)/length(currentTimeWindow), ...
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationPatternColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in fingertip trials relative to slot entry (Panel B)
blockID = 3;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 5; % 4: grasp, 5: slot entry
lowerBound = -3;
upperBound = 1;
figure(blockID*selectedColumn) % relative to ball grasp
hold on
storedMeans = zeros(5,1);
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3); 
    for n = 1:5
       plot(timePoint, sum(currentTimeWindow == n-1)/length(currentTimeWindow), ...
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationPatternColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in tweezer trials relative to grasp (Panel C)
blockID = 4;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 4; % 4: grasp, 5: slot entry
lowerBound = -2;
upperBound = 2;
figure(blockID*selectedColumn) % relative to ball grasp
hold on
storedMeans = zeros(5,1);
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3); 
    for n = 1:5
       plot(timePoint, sum(currentTimeWindow == n-1)/length(currentTimeWindow), ...
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationPatternColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in tweezer trials relative to slot entry (Panel D)
blockID = 4;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 5; % 4: grasp, 5: slot entry
lowerBound = -3;
upperBound = 1;
figure(blockID*selectedColumn) % relative to ball grasp
hold on
storedMeans = zeros(5,1);
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3); 
    for n = 1:5
       plot(timePoint, sum(currentTimeWindow == n-1)/length(currentTimeWindow), ...
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationPatternColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])