% read in saved gaze data structure
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
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
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
% plot fingertip trials
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3), letterDetectViewTime(letterDetectViewTime(:,2) == 3, 4),...
    'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
% plot tool trials
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

%% plot the response time (reach onset relative to go signal) vs. the time 
% of the last detected letter change (relative to go) --> Panels C & D
numParticipants = 11;
numVariables = 7;
speedRelativeLetterChange = [];

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        currentVariable = NaN(numTrials,numVariables);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end

            tStart = currentResult(n).info.timeStamp.start;
            goTime = currentResult(n).info.timeStamp.go;
            reach = currentResult(n).info.timeStamp.reach;
            preInterval = 1;
            earlyTrial = 0;
            % check whether a letter change was detected in the current
            % trial
            if sum(currentResult(n).dualTask.changeDetected) > 0
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                detectedChange = detectedChanges(1);
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    detectedChange = detectedChanges(end);
                else
                    continue
                end
            end
            if reach - detectedChanges(1) > 0 && reach - detectedChanges(1) <= preInterval
                earlyTrial = 1;
            end
            % if the change happened before the reach good
            if detectedChange <= reach
                letterChangeBeforeReach = detectedChange - reach;
                letterChangeRelativeGo = detectedChange - goTime;
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeBeforeReach = detectedChanges(end) - reach;
                    letterChangeRelativeGo = detectedChanges(end) - goTime;
                else
                    continue
                end
            end

            goToReach = reach-goTime;
            reachDuration = currentResult(n).info.phaseDuration.primaryReach/200;

            currentVariable(n,:) = [currentParticipant blockID letterChangeBeforeReach letterChangeRelativeGo ...
                goToReach reachDuration earlyTrial];
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
    end
end

%%
lightGrey = [189,189,189]./255;
brightCyan = [0 174 239]./255;
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% go signal
earlyChanges = relativeChanges_PG(relativeChanges_PG(:,end) == 1,4);
figure(33)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
line([-5 2],[0 0], 'Color', lightGrey)
plot(relativeChanges_PG(:,4), relativeChanges_PG(:,5), '.', 'Color', lightGrey)
plot(earlyChanges, relativeChanges_PG(relativeChanges_PG(:,end) == 1,5), ...
    '.', 'Color', brightCyan)
for i = -6:0.5:2
    reactBin = median(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5, 5));
    moveBin = median(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
end
figure(333)
set(gcf,'renderer','Painters')
xlim([-6.5 2])
hold on
histogram(relativeChanges_PG(:,4), 'BinWidth', .5, 'facecolor', lightGrey, 'edgecolor', 'none')
histogram(earlyChanges, 'BinWidth', .5, 'facecolor', brightCyan, 'edgecolor', 'none')
[h,p_FT, ks2stat_FT] = kstest(relativeChanges_PG(:,4));
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
earlyChanges = relativeChanges_TW(relativeChanges_TW(:,end) == 1,4);
figure(44)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
line([-6.5 2],[0 0], 'Color', lightGrey)
plot(relativeChanges_TW(:,4), relativeChanges_TW(:,5), '.', 'Color', lightGrey)
plot(earlyChanges, relativeChanges_TW(relativeChanges_TW(:,end) == 1,5), ...
    '.', 'Color', brightCyan)
for i = -6:0.5:2
    reactBin = median(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5, 5));
    moveBin = median(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
end
figure(444)
set(gcf,'renderer','Painters')
xlim([-6.5 2])
ylim([0 50])
hold on
histogram(relativeChanges_TW(:,4), 'BinWidth', .5, 'facecolor', lightGrey, 'edgecolor', 'none')
histogram(earlyChanges, 'BinWidth', .5, 'facecolor', brightCyan, 'edgecolor', 'none')
[h,p_TW, ks2stat_TW] = kstest(relativeChanges_PG(:,4));

