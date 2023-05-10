% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% calculate letter changes per trial
numParticipants = 11;
letterChanges = [];

for j = 1:numParticipants % loop over participants
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        participant = currentParticipant*ones(numTrials, 1);
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
        currentVariable = [participant testID numLetterChange letterChange ...
                           reachOnset displayFixationTime];
        
        letterChanges = [letterChanges; currentVariable];
        clear startTime trialLength
    end
end

letterChanges_FT = letterChanges(letterChanges(:,2) == 3,:);
letterChanges_TW = letterChanges(letterChanges(:,2) == 4,:);
% to calculate mean number of changes run:
% nanmean(letterChanges_FT(:,3))
% nanmean(letterChanges_TW(:,3))

clear currentVariable displayFixationTime letterChange numLetterChange reachOnset participant testID
%% readout vigilance task performance
numParticipants = 11;
dualTaskPerformance = [];
for j = 1:numParticipants % loop over participants
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

%% average and save vigilance task performance 
letterDetectAverage_FT = NaN(numParticipants,3);
selectedData = dualTaskPerformance(dualTaskPerformance(:,2) == 3,:);
for i = 1:numParticipants
    letterDetectAverage_FT(i,:) = [i 3 sum(selectedData(selectedData(:,1) == i,4))/...
        sum(selectedData(selectedData(:,1) == i,3))];
end
letterDetectAverage_TW = NaN(numParticipants,3);
selectedData = dualTaskPerformance(dualTaskPerformance(:,2) == 4,:);
for i = 1:numParticipants
    letterDetectAverage_TW(i,:) = [i 4 sum(selectedData(selectedData(:,1) == i,4))/...
        sum(selectedData(selectedData(:,1) == i,3))];
end

letterDetectAverage = [letterDetectAverage_FT; letterDetectAverage_TW];

cd(savePath)
save('letterDetectAverage', 'letterDetectAverage')
cd(analysisPath)

clear selectedData
%% Histograms in Panel A & B
reachRelativeLetter = [];
numParticipants = 11;

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        letterChangeRelativeReach = NaN(numTrials,1);
        landmarkFixation = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            reach = currentResult(n).info.timeStamp.reach;
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                landmarkFixation(n) = 0;
            else
                landmarkFixation(n) = 1;
            end
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

            % if the change happened before the reach good
            if detectedChange <= reach
                letterChangeRelativeReach(n) = reach - detectedChange ;
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeRelativeReach(n) = reach - detectedChanges(end);
                else
                    continue
                end
            end            
        end

        currentVariable = [blockID*ones(numTrials,1) landmarkFixation ...
            letterChangeRelativeReach];

        reachRelativeLetter = [reachRelativeLetter; currentVariable];
    end
end

clear blockID landmarkFixation letterChangeRelativeReach
%% plot reach onset relative to letter change for PG and TW
lightGrey = [189,189,189]./255;
blue = [55,126,184]./255; % display only

fixations_PG_all = reachRelativeLetter( reachRelativeLetter(:,1) == 3,:);
fixations_PG_detected = fixations_PG_all(~isnan(fixations_PG_all(:,3)),:);

fixations_TW_all = reachRelativeLetter( reachRelativeLetter(:,1) == 4,:);
fixations_TW_detected = fixations_TW_all(~isnan(fixations_TW_all(:,3)),:);

selectedColumn = 3; % reach onset
upperBound = 6.5;
reaches_PG = fixations_PG_detected(fixations_PG_detected(:,selectedColumn) < upperBound, :);
reaches_TW = fixations_TW_detected(fixations_TW_detected(:,selectedColumn) < upperBound, :);
figure(selectedColumn)
hold on
set(gcf,'renderer','Painters')
h.PG1 = histogram(reaches_PG(reaches_PG(:,2) == 1, selectedColumn), 'BinWidth', .25, 'facecolor', blue, 'edgecolor', 'none');
h.PG2 = histogram(reaches_PG(:, selectedColumn), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none');
xlim([0 upperBound])
ylim([0 50])
box off
figure(selectedColumn*10)
hold on
set(gcf,'renderer','Painters')
h.TW1 = histogram(reaches_TW(reaches_TW(:,2) == 1, selectedColumn), 'BinWidth', .25, 'facecolor', blue, 'edgecolor', 'none');
h.TW2 = histogram(reaches_TW(:, selectedColumn), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none'); 
xlim([0 upperBound])
ylim([0 50])
box off

% generate expected distribution
% solve for silent period value
SP_PG1 = sum(h.PG1.Values)*h.PG1.BinWidth / 4;
SP_PG2 = sum(h.PG2.Values)*h.PG2.BinWidth / 4;
figure(selectedColumn)
line([0 1.5], [SP_PG1 SP_PG1], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG1 0], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([0 1.5], [SP_PG2 SP_PG2], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG2 0], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)

SP_TW1 = sum(h.TW1.Values)*h.TW1.BinWidth / 4;
SP_TW2 = sum(h.TW2.Values)*h.TW2.BinWidth / 4;
figure(selectedColumn*10)
line([0 1.5], [SP_TW1 SP_TW1], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW1 0], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([0 1.5], [SP_TW2 SP_TW2], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW2 0], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
%% test distribution against expected distribution
% generate mock distribution
binWidth = .25;
expectedDistribution = [];
slope = SP_PG1/5;
% landmark fixation
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG1)*ones((1-SP_PG1+floor(SP_PG1))*10000,1); ...
            ceil(SP_PG1)*ones((1-ceil(SP_PG1)+SP_PG1)*10000,1)];
    else
        binCount = [floor(SP_PG1-(i-1.5)*slope)*ones((1-SP_PG1+floor(SP_PG1-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG1-(i-1.5)*slope)*ones((1-ceil(SP_PG1-(i-1.5)*slope)+SP_PG1)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test landmark fixation
[h_PG1, p_PG1, ks2statPG1] = kstest2(reaches_PG(reaches_PG(:,2) == 1, selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope

expectedDistribution = [];
slope = SP_PG2/5;
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG2)*ones((1-SP_PG2+floor(SP_PG2))*10000,1); ...
            ceil(SP_PG2)*ones((1-ceil(SP_PG2)+SP_PG2)*10000,1)];
    else
        binCount = [floor(SP_PG2-(i-1.5)*slope)*ones((1-SP_PG2+floor(SP_PG2-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG2-(i-1.5)*slope)*ones((1-ceil(SP_PG2-(i-1.5)*slope)+SP_PG2)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test all fixations
[h_PG2, p_PG2, ks2statPG2] = kstest2(reaches_PG(:,selectedColumn), expectedDistribution);


expectedDistribution = [];
slope = SP_TW1/5;
% landmark fixation
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW1)*ones((1-SP_TW1+floor(SP_TW1))*10000,1); ...
            ceil(SP_TW1)*ones((1-ceil(SP_TW1)+SP_TW1)*10000,1)];
    else
        binCount = [floor(SP_TW1-(i-1.5)*slope)*ones((1-SP_TW1+floor(SP_TW1-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW1-(i-1.5)*slope)*ones((1-ceil(SP_TW1-(i-1.5)*slope)+SP_TW1)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test landmark fixation
[h_TW1, p_TW1, ks2statTW1] = kstest2(reaches_TW(reaches_TW(:,2) == 1, selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope

expectedDistribution = [];
slope = SP_TW2/5;
for i = 0:binWidth:6.5
    if i <= 1.5
        binCount = [floor(SP_TW2)*ones((1-SP_TW2+floor(SP_TW2))*10000,1); ...
            ceil(SP_TW2)*ones((1-ceil(SP_TW2)+SP_TW2)*10000,1)];
    else
        binCount = [floor(SP_TW2-(i-1.5)*slope)*ones((1-SP_TW2+floor(SP_TW2-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW2-(i-1.5)*slope)*ones((1-ceil(SP_TW2-(i-1.5)*slope)+SP_TW2)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binWidth))),1)];
end
% ks test all fixations
[h_TW2, p_TW2, ks2statTW2] = kstest2(reaches_TW(:,selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope
%% plot the response time (reach onset relative to go signal) vs. the time 
% of the last detected letter change (relative to go) --> Panels C & D
numParticipants = 11;
numVariables = 5;
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

            goTime = currentResult(n).info.timeStamp.go;
            reach = currentResult(n).info.timeStamp.reach;
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                landmarkFixation = 0;
            else
                landmarkFixation = 1;
            end
            if reach-goTime > 1
                x = 2;
            end
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
            % if the change happened before the go-signal good
            if detectedChange < goTime%reach
                letterChangeRelativeReach = reach - detectedChange;
            else % otherwise use the previous trial
                clear detectedChanges detectedChange
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeRelativeReach = reach - detectedChanges(end);
                else
                    continue
                end
            end
            goToReach = reach-goTime;

            currentVariable(n,:) = [currentParticipant blockID landmarkFixation...
                letterChangeRelativeReach goToReach];

            clear detectedChange goTime reach detectedChanges
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
    end
end

%%
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% go signal
lowerLimit = 0;
upperLimit = 5;
binWidth = .25;
figure(33)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
ylim([-1 1.5])
line([1.5 1.5],[-1 2], 'Color', lightGrey)
line([0 5],[0 0], 'Color', lightGrey)
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 0, 4), relativeChanges_PG(relativeChanges_PG(:,3) == 0,5), '.', 'Color', lightGrey)
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 1, 4), relativeChanges_PG(relativeChanges_PG(:,3) == 1,5), '.', 'Color', blue)

for i = lowerLimit+binWidth:binWidth:upperLimit+binWidth
    reactBin = median(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5, 5));
    line([i-binWidth i], [reactBin reactBin], 'Color', 'k')
end
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
figure(44)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
ylim([-1 1.5])
line([1.5 1.5],[-1 2], 'Color', lightGrey)
line([0 5],[0 0], 'Color', lightGrey)
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 0, 4), relativeChanges_TW(relativeChanges_TW(:,3) == 0,5), '.', 'Color', lightGrey)
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 1, 4), relativeChanges_TW(relativeChanges_TW(:,3) == 1,5), '.', 'Color', blue)

for i = lowerLimit+binWidth:binWidth:upperLimit+binWidth
    reactBin = median(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5, 5));
    line([i-binWidth i], [reactBin reactBin], 'Color', 'k')
end

