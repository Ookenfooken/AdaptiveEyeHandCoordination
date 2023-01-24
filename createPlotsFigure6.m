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

letterChanges_FT = letterChanges(letterChanges(:,2) == 3,:);
letterChanges_TW = letterChanges(letterChanges(:,2) == 4,:);
numChanges = 1; % specificy percentage for 0, 1, 2, or 3 changes
numFT = length(letterChanges_FT(letterChanges_FT(:,3) == numChanges, 3)) /  ...
    length(letterChanges_FT(letterChanges_FT(:,3) >= 0,3));
numTW = length(letterChanges_TW(letterChanges_TW(:,3) == numChanges, 3)) /  ...
    length(letterChanges_TW(letterChanges_TW(:,3) >= 0,3));

%% readout vigilance task performance
numParticipants = 11;
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
%% plot the response time (reach onset relative to go signal) vs. the time 
% of the last detected letter change (relative to go) --> Panels C & D
numParticipants = 11;
numVariables = 6;
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
            preInterval = 1;
            nextChange = 0;
            % check whether a letter change was detected in the current
            % trial
            if sum(currentResult(n).dualTask.changeDetected) > 0
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                detectedChange = detectedChanges(1);
                if length(detectedChanges) > 1 
                    nextChangeLC = detectedChanges(2);
                else
                    if n < stopTrial
                        if sum(currentResult(n+1).dualTask.changeDetected) > 0
                            nextLCs = currentResult(n+1).dualTask.tLetterChanges(currentResult(n+1).dualTask.changeDetected);
                            nextChangeLC = nextLCs(1);                          
                        end
                    else 
                        nextChangeLC = NaN;
                    end
                end
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    detectedChange = detectedChanges(end);
                    nextChangeLC = NaN;
                else
                    continue
                end
            end
            % if the change happened before the go-signal good
            if detectedChange <= goTime
                letterChangeRelativeGo = detectedChange - goTime;
                nextLCRelativeGo = nextChangeLC - goTime;
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeRelativeGo = detectedChanges(end) - goTime;
                    if sum(currentResult(n).dualTask.changeDetected) > 0
                        nextLCs = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                        nextChangeLC = nextLCs(1);
                        nextLCRelativeGo = nextChangeLC - goTime;
                    end
                else
                    continue
                end
            end
            if nextChangeLC > goTime && nextChangeLC-goTime <= reach - goTime
                nextChange = 1;
            end
            goToReach = reach-goTime;

            currentVariable(n,:) = [currentParticipant blockID letterChangeRelativeGo ...
                goToReach nextLCRelativeGo nextChange];
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
    end
end

%%
lightGrey = [189,189,189]./255;
red = [1 0 0]; % [141 189 221]./255;
orange = [255,127,0]./255;
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% go signal
nextChanges = relativeChanges_PG(relativeChanges_PG(:,end) == 1,3);
lowerLimit = -5;
upperLimit = 1.5;
figure(33)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
ylim([-1 1.5])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_PG(:,3), relativeChanges_PG(:,4), '.', 'Color', lightGrey)
plot(nextChanges, relativeChanges_PG(relativeChanges_PG(:,end) == 1,4), ...
    '.', 'Color', red)
for i = lowerLimit+.5:0.5:upperLimit+.5
    reactBin = median(relativeChanges_PG(relativeChanges_PG(:,3) < i & relativeChanges_PG(:,3) > i-0.5, 4));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
end
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
nextChanges = relativeChanges_TW(relativeChanges_TW(:,end) == 1,3);
figure(44)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
ylim([-1 1.5])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_TW(:,3), relativeChanges_TW(:,4), '.', 'Color', lightGrey)
plot(nextChanges, relativeChanges_TW(relativeChanges_TW(:,end) == 1,4), ...
    '.', 'Color', red)
for i = lowerLimit+.5:0.5:upperLimit+.5
    reactBin = median(relativeChanges_TW(relativeChanges_TW(:,3) < i & relativeChanges_TW(:,3) > i-0.5, 4));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
end

%% Histograms in Panel E&F
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
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            reach = currentResult(n).info.timeStamp.reach;
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

        currentVariable = [blockID*ones(numTrials,1) ...
            letterChangeRelativeReach];

        reachRelativeLetter = [reachRelativeLetter; currentVariable];
    end
end

%% plot reach onset relative to letter change for PG and TW
fixations_PG_all = reachRelativeLetter( reachRelativeLetter(:,1) == 3,:);
fixations_PG_detected = fixations_PG_all(~isnan(fixations_PG_all(:,2)),:);
[p_PG, ks2statPG] = kstest(fixations_PG_detected(:,2));

fixations_TW_all = reachRelativeLetter( reachRelativeLetter(:,1) == 4,:);
fixations_TW_detected = fixations_TW_all(~isnan(fixations_TW_all(:,1)),:);
[p_TW, ks2statTW] = kstest(fixations_TW_detected(:,2));

selectedColumn = 2; % reach onset
upperBound = 6.5;
reaches_PG = fixations_PG_detected(fixations_PG_detected(:,selectedColumn) < upperBound, selectedColumn);
reaches_TW = fixations_TW_detected(fixations_TW_detected(:,selectedColumn) < upperBound, selectedColumn);
figure(selectedColumn)
set(gcf,'renderer','Painters')
histogram(reaches_PG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 50])
box off
figure(selectedColumn*10)
set(gcf,'renderer','Painters')
histogram(reaches_TW, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 50])
box off