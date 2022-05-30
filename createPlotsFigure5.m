% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%%
numParticipants = 11;
letterChanges = [];

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        subject = currentParticipant*ones(numTrials, 1);
        testID = blockID*ones(numTrials,1);
        letterChange = NaN(numTrials,1);
        numLetterChange = NaN(numTrials,1);
        reachOnset = NaN(numTrials,1);
        displayFixationTime = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            startTime = currentResult(n).info.trialStart;
            letterChange(n) = currentResult(n).dualTask.sampleLetterChange(1);
            if isnan(currentResult(n).dualTask.sampleLetterChange)
                numLetterChange(n) = 0;
            else
                numLetterChange(n) = numel(currentResult(n).dualTask.sampleLetterChange);
            end
            reachOnset(n) = currentResult(n).info.phaseStart.primaryReach; 
            displayFixationTime(n) = sum(currentResult(n).gaze.fixation.durationDisplay)./...
                                     (sum(currentResult(n).gaze.fixation.durationBall) + ...
                                     sum(currentResult(n).gaze.fixation.durationSlot) + ...
                                     sum(currentResult(n).gaze.fixation.durationDisplay));          
        end
        currentVariable = [subject testID numLetterChange letterChange ...
                           reachOnset displayFixationTime];
        
        letterChanges = [letterChanges; currentVariable];
        clear startTime trialLength
    end
end

%% plot frequency of letter changes in a trial for fintertips and tweezers (Panel A)
letterChangeNo = NaN(2, 4);
for j = 1:2 % hand and tweezer
    currentData = letterChanges(letterChanges(:,2) == j+2, :);
    currentData = currentData(~isnan(currentData(:,3)),:);
    allTrials = size(currentData,1);
    for blockID = 1:4
        letterChangeNo(j,blockID) = length(currentData(currentData(:,3) == blockID-1,:))/allTrials;
    end
    clear allTrials    
end
figure(123)
hold on
xlim([.5 4.5])
set(gca, 'Xtick', [1 2 3 4], 'XtickLabel', {'0 letter changes', '1 letter change', '2 letter changes', '3 letter changes'})
ylim([0 .75])
set(gca, 'Ytick', [0 .25 .5 .75])

for blockID = 1:4
    plot(blockID, letterChangeNo(1,blockID), 'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
    plot(blockID, letterChangeNo(2,blockID), 'o', 'MarkerFaceColor', 'none','MarkerEdgeColor', 'k')
end
line([1 2], [letterChangeNo(1,1) letterChangeNo(1,2)], 'Color', 'k')
line([2 3], [letterChangeNo(1,2) letterChangeNo(1,3)], 'Color', 'k')
line([3 4], [letterChangeNo(1,3) letterChangeNo(1,4)], 'Color', 'k')
line([1 2], [letterChangeNo(2,1) letterChangeNo(2,2)], 'Color', 'k', 'LineStyle', '--')
line([2 3], [letterChangeNo(2,2) letterChangeNo(2,3)], 'Color', 'k', 'LineStyle', '--')
line([3 4], [letterChangeNo(2,3) letterChangeNo(2,4)], 'Color', 'k', 'LineStyle', '--')

%% readout vigilance task performance
dualTaskPerformance = [];
dualTaskSamples = [];
cAll = 1;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over blocks/experimental conditions
        c = 1;
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        stopTrial = min([numTrials 30]);
        numTrials = length(currentResult);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            changeDetected(c) = currentResult(n).dualTask.changeDetected;
            changeMissed(c) = currentResult(n).dualTask.changeMissed;
                        
            c = c(end) + 1;
        end
        currentPerformance = [currentParticipant blockID c-1 sum(changeDetected) sum(changeMissed)];
        
        dualTaskPerformance = [dualTaskPerformance; currentPerformance];
        clear letterChangePhase changeDetected changeMissed currentPerformance
    end
end
clear c 
%% plot vigilance performance vs. relative time on display (Panel B)
letterDetectViewTime = NaN(numParticipants,3);
for i = 1:numParticipants
    currentDataset = letterChanges(letterChanges(:,1) == i, :);
    relativeTime = currentDataset(:,6);
    letterDetectViewTime(i,:) = [i nanmean(relativeTime) ...
        sum(dualTaskPerformance(dualTaskPerformance(:,1) == i,4))/sum(dualTaskPerformance(dualTaskPerformance(:,1) == i,3))];
end
figure(5)
hold on
plot(letterDetectViewTime(:,2), letterDetectViewTime(:, 3),...
    'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
%% plot trend lines
letterDetectViewTime = NaN(numParticipants*2,4);
count = 1;
for j= 3:4
    currentTool = letterChanges(letterChanges(:,2) == j, :);
    currentVigilance = dualTaskPerformance(dualTaskPerformance(:,2) == j,:);
    for i = 1:numParticipants
        currentDataset = currentTool(currentTool(:,1) == i, :);
        relativeTime = currentDataset(:,6);
        letterDetectViewTime(count,:) = [i j nanmean(relativeTime) ...
            currentVigilance(currentVigilance(:,1) == i,4)/currentVigilance(currentVigilance(:,1) == i,3)];
        count = count+1;
    end
end
clear count
figure(5)
hold on
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3), letterDetectViewTime(letterDetectViewTime(:,2) == 3, 4),...
    'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
% remove outlier
p_FT = polyfit(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3),letterDetectViewTime(letterDetectViewTime(:,2) == 3, 4),1);
y_FT = polyval(p_FT,letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3));
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3), y_FT, 'k-')
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3), letterDetectViewTime(letterDetectViewTime(:,2) == 4, 4),...
    'o', 'MarkerFaceColor', 'none','MarkerEdgeColor', 'k')
p_TW = polyfit(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3),letterDetectViewTime(letterDetectViewTime(:,2) == 4, 4),1);
y_TW = polyval(p_TW,letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3));
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3), y_TW, 'k--')

ylim([0.5 1])
set(gca, 'Ytick', [.5 .75 1])
xlim([0.5 1])
set(gca, 'Xtick', [.5 .75 1])

cd(savePath)
save('letterDetectViewTime', 'letterDetectViewTime')
cd(analysisPath)
clear p_FT y_FT p_TW y_TW

%% plot fixation probability relative time of letter change
preLetterChange = 100;
postLetterChange = 300;
fixationRateDisplay = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        fixationVectorDisplay = NaN(numTrials,preLetterChange+postLetterChange);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if currentResult(n).info.cuedSlot == 1
                slotPosition = [-1.9 5.2];
            elseif currentResult(n).info.cuedSlot == 2
                slotPosition = [-1.9 8.2];
            elseif currentResult(n).info.cuedSlot == 3
                slotPosition = [-1.9 11.2];
            end
            criticalLocations = [0 0; ... % ball centre
                slotPosition; % selected slot
                13.63 16.68]; % visual display
            startTime = currentResult(n).info.trialStart;
            letterChange = currentResult(n).dualTask.sampleLetterChange(1)-startTime;           
            if isnan(letterChange) || currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.trialEnd 
                continue
            end
            % determine fixation vector
            relativeOnset = 1;
            if letterChange < preLetterChange
                relativeOnset = preLetterChange - letterChange;
            end
            relativeOffset = preLetterChange+postLetterChange;
            if relativeOffset > length(currentResult(n).gaze.Xinterpolated)
                relativeOffset = length(currentResult(n).gaze.Xinterpolated);
            end
            fixationVectorDisplay(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            gazeXinterpolated = currentResult(n).gaze.Xinterpolated;
            gazeYinterpolated = currentResult(n).gaze.Yinterpolated;
            distancesGaze = NaN(length(criticalLocations), length(gazeXinterpolated));
            for m = 1:length(criticalLocations)
                for sample = 1:length(gazeXinterpolated)
                    distancesGaze(m,sample) = sqrt((gazeXinterpolated(sample) - criticalLocations(m,1)).^2 ...
                        +  (gazeYinterpolated(sample) - criticalLocations(m,2)).^2);
                end
            end
            gazeVelocity = [diff(sqrt(gazeXinterpolated.^2 + gazeYinterpolated.^2)); NaN];
            fixations = abs(gazeVelocity) < 0.05;
            fixationDetect = [fixations; NaN] - [NaN; fixations];
            fixationOnsets = find(fixationDetect == 1) + 3;
            fixationOffsets = find(fixationDetect == -1) -4;
            if numel(fixationOnsets) > 0 && numel(fixationOffsets) > 0
                if fixations(1) == 1
                    fixationOnsets = [1; fixationOnsets];
                end
                if fixations(end) == 1
                    fixationOffsets = [fixationOffsets length(fixations)];
                end
                if fixationOffsets(1) < fixationOnsets(1)
                    fixationOnsets(1) = [];
                    fixationOffsets(1) = [];
                end
                for fix = 1:length(fixationOnsets)
                   if fixationOffsets(fix) - fixationOnsets(fix) < 20
                        continue
                   end
                    fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-letterChange)]);
                    fixOffset = min([preLetterChange+(fixationOffsets(fix)-letterChange) length(fixationVectorDisplay)]);
                    minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                    fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                    if fixationOn == 3 % indicates fixation on display
                        fixationVectorDisplay(n,fixOnset:fixOffset) = 1;
                    end
                end
            end
        end
        currentFixationRateDisplay = [j i nanmean(fixationVectorDisplay)];
        fixationRateDisplay= [fixationRateDisplay; currentFixationRateDisplay];
        clear criticalLocations fixationDetect fixationOnsets fixationOffsets 
        clear minimalDistance gazeVelocity gazeXinterpolated gazeYinterpolated
        clear distancesGaze fixationOn startTime slotPosition currentFixationRateDisplay 
        clear relativeOnset relativeOffset
    end
end

%% draw plot (Panel C)
blue = [49,130,189]./255;
grey = [150,150,150]./255;
orange = [255,127,0]./255;
xLength = preLetterChange+ postLetterChange;
% plot display abd ball fixation rate and reach probability for fingertips
figure(11)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', grey, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineStyle', '--', 'LineWidth', 2)

%% plot movement events and time of letter change relative to time of grasp
histogramFixations = [];
cumulativeReach = [];
vectorLength = 600;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = blockID*ones(numTrials,1);
        ballGrasp = NaN(numTrials,1);
        ballOnset = NaN(numTrials,1);
        trialEnd = NaN(numTrials,1);
        reachOnset = NaN(numTrials,vectorLength);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballGrasp(n) = currentResult(n).info.phaseStart.ballGrasp; 
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballOnset(n) = currentResult(n).gaze.fixation.onsetsBall(1) + currentResult(n).info.trialStart;
            end
            reachToGrasp = currentResult(n).info.phaseStart.ballGrasp-currentResult(n).info.phaseStart.primaryReach;
            if reachToGrasp > vectorLength
                continue
            end
            trialEnd(n) = currentResult(n).info.trialEnd;
            reachOnset(n,:) = [zeros(1,vectorLength-reachToGrasp) ones(1,reachToGrasp)];
        end
        currentVariable = [testID ballGrasp ...
                           ballOnset trialEnd];
        cumulativeReach = [cumulativeReach; [blockID nansum(reachOnset)]];
        histogramFixations = [histogramFixations; currentVariable];
        clear startTime trialLength
    end
end

histogramLetterChanges = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        c = 1;
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            startTime = currentResult(n).info.trialStart;
            letterChange = currentResult(n).dualTask.sampleLetterChange;
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            ballGrasp = currentResult(n).info.phaseStart.ballGrasp; 
            letterChangeVector(c,:) = [blockID*ones(length(c),1) ...
                ballGrasp*ones(length(c),1) currentResult(n).dualTask.sampleLetterChange'];
            c = c(end) + 1;
        end
        
        histogramLetterChanges = [histogramLetterChanges; letterChangeVector];
        clear startTime trialLength letterChangeVector
    end
end

%%
stepWidth = .25;
figure(13)
set(gcf,'renderer','Painters')
hold on
box off
xlim([-2 1.5])
set(gca, 'Xtick', [-2 -1.5 -1 -.5 0 .5 1 1.5])
ylim([0 140])
figure(14)
set(gcf,'renderer','Painters')
hold on
box off
xlim([-2 1.5])
set(gca, 'Xtick', [-2 -1.5 -1 -.5 0 .5 1 1.5])
ylim([0 140])
ksTestData = [];
for j= 3:4
    letterChangeRelativeGrasp = (histogramLetterChanges(histogramLetterChanges(:,1) == j,3) - ...
        histogramLetterChanges(histogramLetterChanges(:,1) == j,2))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeGrasp) - 3*nanstd(letterChangeRelativeGrasp);
    upperBound = nanmean(letterChangeRelativeGrasp) + 3*nanstd(letterChangeRelativeGrasp);
    letterChangeRelativeGrasp(letterChangeRelativeGrasp < lowerBound) = [];
    letterChangeRelativeGrasp(letterChangeRelativeGrasp > upperBound) = [];
    ballOnsetRelativelGrasp = (histogramFixations(histogramFixations(:,1) == j,3) - ...
        histogramFixations(histogramFixations(:,1) == j,2))/200; % in seconds
    lowerBound = nanmean(ballOnsetRelativelGrasp) - 3*nanstd(ballOnsetRelativelGrasp);
    upperBound = nanmean(ballOnsetRelativelGrasp) + 3*nanstd(ballOnsetRelativelGrasp);
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp < lowerBound) = [];
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp > upperBound) = [];
    if j == 3
        figure(13)
        histogram(letterChangeRelativeGrasp, 'BinWidth', stepWidth, 'facecolor', grey, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', stepWidth, 'facecolor', orange, 'edgecolor', 'none')
        letterChangeDistribution_FT = cumsum(letterChangeRelativeGrasp);
    else
        figure(14)
        histogram(letterChangeRelativeGrasp, 'BinWidth', stepWidth, 'facecolor', grey, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', stepWidth, 'facecolor', orange, 'edgecolor', 'none')
        letterChangeDistribution_TW = cumsum(letterChangeRelativeGrasp);
    end
    clear lowerBound upperBound letterChangeRelativeGrasp ballOnsetRelativelGrasp slotOnsetRelativeGrasp
end
%% add trial counts for PG and TW
% create vector with trials in which a letter change earlier than xx
% samples could not have happened (grasp was earlier) and after xx samples
% letter change could not have happened (trial end)
%cutOffVector = [400 300 200 100 0 100 200]; --> for larger bin size
cutOffVector = [400 350 300 250 200 150 100 50 0 50 100 150 200 250];
trialCount = NaN(1, length(cutOffVector));
xVector = -1.875:stepWidth:1.4; %-1.75:stepWidth:1.25;
trialRatio = stepWidth/4;
for j = 3:4
    graspTimes = histogramFixations(histogramFixations(:,1) == j,2);
    graspToEnd = histogramFixations(histogramFixations(:,1) == j,end) - histogramFixations(histogramFixations(:,1) == j,2);
    for i = 1:length(cutOffVector)
        if i < length(cutOffVector)/2+2
            trialCount(1,i) = sum(graspTimes > cutOffVector(i));
        else
            trialCount(1,i) = sum(graspToEnd > cutOffVector(i));
        end
    end
    if j == 3
        figure(13)
        b = bar(xVector, trialCount*trialRatio);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
        [h,p_FT, ks2stat_FT] = kstest2(letterChangeDistribution_FT, cumsum(trialCount*trialRatio));
    else
        figure(14)
        b = bar(xVector, trialCount*trialRatio);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
        [h,p_TW, ks2stat_TW] = kstest2(letterChangeDistribution_TW, cumsum(trialCount*trialRatio));
    end
end

%% add cumulative curves and lines
phaseToGraspAll = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            reachToGrasp = currentResult(n).info.phaseStart.primaryReach - ...
                currentResult(n).info.phaseStart.ballGrasp;
            phaseToGraspAll = [phaseToGraspAll; [blockID reachToGrasp]];
        end
    end
    clear reachToGrasp
end

for j = 3:4
    xVector_reach = -3:.005:-0.0009;
    if j == 3
        figure(13)
    else
        figure(14)
    end
    plot(xVector_reach,(sum(cumulativeReach(cumulativeReach(:,1) == j, 2:end))/...
        sum(cumulativeReach(cumulativeReach(:,1) == j,end))*100), 'k', 'LineWidth', 1.5)
    % optional: add line at median position
%     line([nanmedian(phaseToGraspAll(phaseToGraspAll(:,1) == j, 2))/200 ...
%           nanmedian(phaseToGraspAll(phaseToGraspAll(:,1) == j, 2))/200],...
%         [0 180], 'Color', 'k', 'LineStyle', '--')
end
