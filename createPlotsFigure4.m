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
    for numBlock = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,numBlock};
        currentParticipant = currentResult(numBlock).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        subject = currentParticipant*ones(numTrials, 1);
        testID = numBlock*ones(numTrials,1);
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
    for numBlock = 1:4
        letterChangeNo(j,numBlock) = length(currentData(currentData(:,3) == numBlock-1,:))/allTrials;
    end
    clear allTrials    
end
figure(123)
hold on
xlim([.5 4.5])
set(gca, 'Xtick', [1 2 3 4], 'XtickLabel', {'0 letter changes', '1 letter change', '2 letter changes', '3 letter changes'})
ylim([0 .75])
set(gca, 'Ytick', [0 .25 .5 .75])

for numBlock = 1:4
    plot(numBlock, letterChangeNo(1,numBlock), 'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
    plot(numBlock, letterChangeNo(2,numBlock), 'o', 'MarkerFaceColor', 'none','MarkerEdgeColor', 'k')
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
    for numBlock = 3:4 % loop over blocks/experimental conditions
        c = 1;
        currentResult = pulledData{j,numBlock};
        currentParticipant = currentResult(numBlock).info.subject;
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
            cAll = cAll:cAll+length(currentResult(n).dualTask.tLetterChanges)-1;
            changeDetected(c) = currentResult(n).dualTask.changeDetected;
            changeMissed(c) = currentResult(n).dualTask.changeMissed;
                        
            c = c(end) + 1;
            cAll = cAll(end) + 1;
        end
        currentPerformance = [currentParticipant numBlock c-1 sum(changeDetected) sum(changeMissed)];
        
        dualTaskPerformance = [dualTaskPerformance; currentPerformance];
        clear letterChangePhase changeDetected changeMissed currentPerformance
    end
end
clear c cAll
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
%%
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
%% plot frequency of first letter change relative to reach onset (Panel C)
figure(13)
set(gcf,'renderer','Painters')
gray = [189,189,189]./255;
hold on
box off
xlim([-2 4])
ylim([0 80])
for j= 3:4
    letterChangeRelativeReach = (letterChanges(letterChanges(:,2) == j,4) - ...
        letterChanges(letterChanges(:,2) == j,5))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeReach) - 3*nanstd(letterChangeRelativeReach);
    upperBound = nanmean(letterChangeRelativeReach) + 3*nanstd(letterChangeRelativeReach);
    letterChangeRelativeReach(letterChangeRelativeReach < lowerBound) = [];
    letterChangeRelativeReach(letterChangeRelativeReach > upperBound) = [];
    if j == 3
        histogram(letterChangeRelativeReach, 'facecolor', 'k', 'edgecolor', 'none')
    else
        histogram(letterChangeRelativeReach, 'facecolor', 'none', 'edgecolor', 'k')
    end
    clear lowerBound upperBound
end

%% plot display fixation probability relative to letter change (Panel D)
preLetterChange = 50;
postLetterChange = 200;
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
            if isnan(letterChange) || letterChange < preLetterChange || letterChange+postLetterChange > length(currentResult(n).gaze.VelXYinterpolated)
                continue
            end
            % determine fixation vector
            fixationVectorDisplay(n,:) = zeros(1,preLetterChange+postLetterChange);
            gazeXinterpolated = currentResult(n).gaze.Xinterpolated(letterChange-(preLetterChange-1):letterChange+postLetterChange);
            gazeYinterpolated = currentResult(n).gaze.Yinterpolated(letterChange-(preLetterChange-1):letterChange+postLetterChange);
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
                if fixationOffsets(1) < fixationOnsets(1)
                    fixationOnsets(1) = [];
                    fixationOffsets(1) = [];
                end
                for fix = 1:length(fixationOnsets)
                    if fixationOffsets(fix) - fixationOnsets(fix) < 20
                        continue
                    end
                    minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                    fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                    if fixationOn == 3
                        fixationVectorDisplay(n,fixationOnsets(fix):fixationOffsets(fix)) = 1;
                    end
                end
            end
            
        end
        currentFixationRateDisplay = [j i nanmean(fixationVectorDisplay)];
        fixationRateDisplay= [fixationRateDisplay; currentFixationRateDisplay];
        clear criticalLocations fixationDetect fixationOnsets fixationOffsets 
        clear minimalDistance gazeVelocity gazeXinterpolated gazeYinterpolated
        clear distanceGaze fixationOn startTime slotPosition
    end
end

%%
blue = [49,130,189]./255;

figure(11)
hold on
xlim([0 250])
set(gca, 'Xtick', [0 50 100 150 200 250], 'XtickLabel', [-.25 0 .25 .5 .75 1])
ylim([0 .75])
set(gca, 'Ytick', [0 .25 .5 .75])
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineStyle', '--',  'LineWidth', 2)