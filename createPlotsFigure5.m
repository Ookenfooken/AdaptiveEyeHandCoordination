analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
gazeSequence = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(blockID).info.subject;
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

%% Plot fixation pattern for each grasp mode (Panel B)
% colours
fixationTypeColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;
% initiate variable to plot mean
fixationPatternAverage = NaN(numParticipants*2,6);
figure(9)
hold on
set(gcf,'renderer','Painters', 'Position', [250 250 800 400])
count = 1;
for blockID = 3:4
    currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,2) == i,3);
        currentParticipant = currentParticipant(~isnan(currentParticipant));
        if blockID < 4
            x = [.8 1.8 2.8 3.8 4.8];
        else
            x = [1.2 2.2 3.2 4.2 5.2];
        end
        for n = 1:5
            plot(x(n), sum(currentParticipant(:,1) == n-1)/length(currentParticipant), ...
                'o', 'MarkerEdgeColor', fixationTypeColors(n,:), 'MarkerFaceColor', fixationTypeColors(n,:))
        end
        fixationPatternAverage(count,:) = [blockID sum(currentParticipant == 0)/length(currentParticipant) ...
            sum(currentParticipant == 1)/length(currentParticipant) sum(currentParticipant == 2)/length(currentParticipant)...
            sum(currentParticipant == 3)/length(currentParticipant) sum(currentParticipant == 4)/length(currentParticipant)];
        count = count + 1;
    end
end
for blockID = 3:4
    if blockID < 4
        x = [.8 1.8 2.8 3.8 4.8];
    else
        x = [1.2 2.2 3.2 4.2 5.2];
    end
    for n = 1:5
        currentBarData = fixationPatternAverage(fixationPatternAverage(:,1) == blockID,2:end);
        b = bar(x(n),mean(currentBarData(:,n)), .3);
        if blockID < 4
            b.FaceColor = fixationTypeColors(n,:);
            b.EdgeColor = fixationTypeColors(n,:);
            b.FaceAlpha = 0.5;
        else
            b.FaceColor = 'none';
            b.EdgeColor = fixationTypeColors(n,:);
        end
    end
end
xlim([.5 5.5])
set(gca, 'Xtick', [1 2 3 4 5], 'XtickLabel', {'display-only', 'ball-only', 'slot-only', 'ball-slot', 'ball-display-slot'})
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

%% plot probability of letter change in fingertip trials relative to grasp (Panel C)
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
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationTypeColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationTypeColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in fingertip trials relative to slot entry (Panel D)
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
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationTypeColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationTypeColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in tweezer trials relative to grasp (Panel D)
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
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationTypeColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationTypeColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
%% plot probability of letter change in tweezer trials relative to slot entry (Panel E)
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
           '-o','MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationTypeColors(n,:))
       if timePoint > lowerBound
          line([timePoint-.5 timePoint],[storedMeans(n) sum(currentTimeWindow == n-1)/length(currentTimeWindow)],...
              'Color', fixationTypeColors(n,:), 'LineWidth', 2) 
       end
       storedMeans(n) = sum(currentTimeWindow == n-1)/length(currentTimeWindow);
    end
end
clear storedMeans
line([0 0], [0 1], 'Color', gray)
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])