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
fixationDurations = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        currentFixations = NaN(numTrials,4);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                continue;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                continue;
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
            startTime = currentResult(n).info.trialStart;
            ballGrasp = currentResult(n).info.phaseStart.ballGrasp-startTime;
            slotEntry = currentResult(n).info.phaseStart.ballInSlot-startTime;
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballFixRelGrasp = (ballGrasp - currentResult(n).gaze.fixation.onsetsBall(1))/200;
            else
                ballFixRelGrasp = NaN;
            end
            if ~isempty(currentResult(n).gaze.fixation.offsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
            else
                slotIdx = 1;
            end
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                slotFixRelGrasp = (slotEntry - slotOnset)/200;
            else
                slotFixRelGrasp = NaN;
            end
            currentFixations(n,:) = [blockID fixationPattern ballFixRelGrasp ...
                slotFixRelGrasp];

        end
        fixationDurations = [fixationDurations; currentFixations];
        clear currentGazeSequence
    end
end

fingertipDurations = fixationDurations(fixationDurations(:,1) == 3, :);
tweezerDurations = fixationDurations(fixationDurations(:,1) == 4, :);
medianFixDurations = NaN(2,3);
medianFixDurations(1,1:3) = [3 nanmedian(fingertipDurations(fingertipDurations(:,2) > 2, 3)) ...
    nanmedian(fingertipDurations(fingertipDurations(:,2) == 2, 4))];
medianFixDurations(2,1:3) = [4 nanmedian(tweezerDurations(tweezerDurations(:,2) > 2, 3:4))];
%%
gazeSequence = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        currentGazeSequence = NaN(numTrials,8);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            LCused = 0;
            ballGrasp = currentResult(n).info.timeStamp.ballGrasp;
            currentGazeSequence(n,1:2) = [blockID currentParticipant];
            currentGazeSequence(n,5) = currentResult(n).info.timeStamp.reach - ballGrasp;
            currentGazeSequence(n,6) = currentResult(n).info.timeStamp.transport - ballGrasp;
            currentGazeSequence(n,7) = currentResult(n).info.timeStamp.ballInSlot - ballGrasp;
            currentGazeSequence(n,8) = currentResult(n).info.timeStamp.return - ballGrasp;
            % cannot classify trials in which the ball is fixated multiple times
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
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
            % for display only and slot only use slot-entry - median(slot_fixation_onset)
            % for ball patterns use ball-contact - median(ball_fixation_onset)
            if blockID == 3
                if fixationPattern == 2 || fixationPattern == 0
                    decisionPoint = currentResult(n).info.timeStamp.ballInSlot - medianFixDurations(1,3);
                elseif fixationPattern > 2
                    decisionPoint = currentResult(n).info.timeStamp.ballGrasp - medianFixDurations(1,2);
                else
                    continue
                end
            else
                if fixationPattern > 2
                    decisionPoint = currentResult(n).info.timeStamp.ballGrasp - medianFixDurations(2,3);
                else
                    continue
                end
            end
            % find the last detected letter change before decision point
            if ~isnan(currentResult(n).dualTask.tLetterChanges(1))
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                if numel(detectedChanges) > 0
                    currentLetterChange = detectedChanges(1);
                    if currentLetterChange < decisionPoint
                        graspDifference = currentLetterChange-ballGrasp;
                        LCused = 1;
                    end
                end
            end
            if ~LCused && n > 1
                if ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    if numel(detectedChanges) > 0
                        currentLetterChange = detectedChanges(end);
                        if currentLetterChange < decisionPoint
                            graspDifference = currentLetterChange-ballGrasp;
                            LCused = 1;
                        end
                    end
                end
            end
            if ~LCused && n > 2
                if ~isnan(currentResult(n-2).dualTask.tLetterChanges(1))
                    detectedChanges = currentResult(n-2).dualTask.tLetterChanges(currentResult(n-2).dualTask.changeDetected);
                    if numel(detectedChanges) > 0
                        currentLetterChange = detectedChanges(end);
                        if currentLetterChange < decisionPoint
                            graspDifference = currentLetterChange-ballGrasp;
                            LCused = 1;
                        end
                    end
                end
            end
            if ~LCused
                continue
            end
            
            currentGazeSequence(n,3:4) = [fixationPattern graspDifference];
            
        end
        gazeSequence = [gazeSequence; currentGazeSequence];
        clear currentGazeSequence
    end
end
clear ballIdx ballOffset slotIdx slotOnset ballFixType
clear letterChange graspDifference selectedTrial

%% determine average phase onsets relative to grasp for adding lines
phaseOnsetsPat = NaN(2*numParticipants,5);
patCount = 1;
for blockID = 3:4
    currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,2) == i,5:end);
        phaseOnsetsPat(patCount,:) = [blockID nanmean(currentParticipant)];
        patCount = patCount + 1;
    end
end
phaseOnsetsGrasp = NaN(2,4);
phaseOnsetsGrasp(1,:) = mean(phaseOnsetsPat(phaseOnsetsPat(:,1) == 3, 2:end));
phaseOnsetsGrasp(2,:) = mean(phaseOnsetsPat(phaseOnsetsPat(:,1) == 4, 2:end));
%% plot probability of letter change in fingertip trials relative to grasp (Panel A)
blockID = 3;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 4; % 4: grasp
lowerBound = -4;
upperBound = 0.75;
figure(blockID*selectedColumn) % relative to ball grasp
set(gcf,'renderer','Painters')
hold on
probabilities = NaN(3,9);
t = 1;
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3);
    probabilities(1,t) = sum(currentTimeWindow == 0)/length(currentTimeWindow);
    probabilities(2,t) = sum(currentTimeWindow == 2)/length(currentTimeWindow);
    probabilities(3,t) = sum(currentTimeWindow > 2)/length(currentTimeWindow);
    t = t+1;
end

for n = 1:3
    if n == 1
        pickedColour = fixationPatternColors(1,:);
    elseif n == 2
        pickedColour = fixationPatternColors(3,:);
    else
        pickedColour = gray;
    end
    b = bar(lowerBound:.5:upperBound, probabilities(n,:), 1);
    b.EdgeColor = 'none';
    b.FaceColor = pickedColour;
    b.FaceAlpha = .5;
end
line([0 0], [0 1], 'Color', 'r')
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
clear probabilities

% add kinematic events
% reach
line([phaseOnsetsGrasp(1,1) phaseOnsetsGrasp(1,1)], [0 1], ...
     'Color', gray, 'LineStyle', '--')
% transport
line([phaseOnsetsGrasp(1,2) phaseOnsetsGrasp(1,2)], [0 1], ...
     'Color', gray, 'LineStyle', '--')
% slot entry
line([phaseOnsetsGrasp(1,3) phaseOnsetsGrasp(1,3)], [0 1], ...
     'Color', gray, 'LineStyle', '--')
 
clear probabilities
%% plot probability of letter change in tweezer trials relative to grasp (Panel C)
blockID = 4;
currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
selectedColumn = 4; % 4: grasp, 5: slot entry
lowerBound = -4.5;
upperBound = 0;
figure(blockID*selectedColumn) % relative to ball grasp
set(gcf,'renderer','Painters')
hold on
probabilities = NaN(3,9);
t = 1;
for timePoint = lowerBound:.5:upperBound
    currentTimeWindow = currentTool(currentTool(:,selectedColumn) > timePoint-.25 & ...
        currentTool(:,selectedColumn) < timePoint+.25, 3);
    probabilities(1,t) = sum(currentTimeWindow == 2)/length(currentTimeWindow);
    probabilities(2,t) = sum(currentTimeWindow == 3)/length(currentTimeWindow);
    probabilities(3,t) = sum(currentTimeWindow == 4)/length(currentTimeWindow);
    t = t+1;
end
for n = 1:3
    b = bar(lowerBound:.5:upperBound, probabilities(n,:), 1);
    b.EdgeColor = 'none';
    b.FaceColor = fixationPatternColors(n+2,:);
    b.FaceAlpha = .5;
end
line([0 0], [0 1], 'Color', 'r')
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

% add kinematic events
% reach
line([phaseOnsetsGrasp(2,1) phaseOnsetsGrasp(2,1)], [0 1], ...
     'Color', gray, 'LineStyle', '--')
% % transport
% line([phaseOnsetsGrasp(2,2) phaseOnsetsGrasp(2,2)], [0 1], ...
%      'Color', gray, 'LineStyle', '--')
% % slot entry
% line([phaseOnsetsGrasp(2,3) phaseOnsetsGrasp(2,3)], [0 1], ...
%      'Color', gray, 'LineStyle', '--')
 
clear probabilities