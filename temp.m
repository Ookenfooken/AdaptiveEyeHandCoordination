% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%%
numParticipants = 11;
numVariables = 8;
speedRelativeLetterChange = [];

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        currentVariable = NaN(numTrials,numVariables);
        stopTrial = min([numTrials 30]);
        for n = 2:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end

            tStart = currentResult(n).info.timeStamp.start;
            goTime = currentResult(n).info.timeStamp.go;
            reach = currentResult(n).info.timeStamp.reach;
            transport = currentResult(n).info.timeStamp.transport;
            earlyTrial = 0;
            lateTrial = 0;
            % check whether a letter change was detected in the current
            % trial
            if sum(currentResult(n).dualTask.changeDetected) > 0
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                detectedChange = detectedChanges(1);
            else % otherwise use the previous trial
                if sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    detectedChange = detectedChanges(end);
                else
                    continue
                end
            end
            if reach - detectedChanges(1) > 0 && reach - detectedChanges(1) <= 1
                earlyTrial = 1;
            end
            if transport - detectedChanges(1) > 0 && transport - detectedChanges(1) <= 1
                lateTrial = 1;
            end
            % if the change happened before the reach good
            if detectedChange < reach
                letterChangeBeforeReach = detectedChange - reach;
                letterChangeRelativeGo = detectedChange - goTime;
            else % otherwise use the previous trial
                if sum(currentResult(n-1).dualTask.changeDetected) > 0
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
                goToReach reachDuration earlyTrial lateTrial];
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
    end
end

%%
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightBlue = [66,146,198]./255;
lightRed = [239,59,44]./255;
lightGrey = [189,189,189]./255;
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
% figure(3)
% hold on
% xlim([-6.5 2])
% ylim([-1 2])
% line([-6.5 2],[0 0], 'Color', lightGrey)
% line([0 0],[-1 2], 'Color', lightGrey)
% plot(relativeChanges_PG(relativeChanges_PG(:,end) == 0,3), relativeChanges_PG(relativeChanges_PG(:,end) == 0,5), ...
%     '.', 'Color', fixationPatternColors(1,:))
% plot(relativeChanges_PG(relativeChanges_PG(:,end) == 2,3), relativeChanges_PG(relativeChanges_PG(:,end) == 2,5), ...
%     '.', 'Color', fixationPatternColors(3,:))
% plot(relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,3), ...
%     relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,5), '.', 'Color', 'm')
% for i = -6:0.5:2
%     reactBin = median(relativeChanges_PG(relativeChanges_PG(:,3) < i & relativeChanges_PG(:,3) > i-0.5, 5));
%     moveBin = median(relativeChanges_PG(relativeChanges_PG(:,3) < i & relativeChanges_PG(:,3) > i-0.5,6));
%     line([i-.5 i], [reactBin reactBin], 'Color', 'k')
%     %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
% end
% plot(relativeChanges_PG(:,3), relativeChanges_PG(:,5), 'k.')
% plot(relativeChanges_PG(:,3), relativeChanges_PG(:,6), 'r.')

% plot time of last detected letter change (before reach onset) relative to
% go signal
earlyChanges = relativeChanges_PG(relativeChanges_PG(:,end-1) == 1,4);
%lateChanges = relativeChanges_PG(relativeChanges_PG(:,end) == 1,4);
figure(33)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_PG(:,4), relativeChanges_PG(:,5), '.', 'Color', lightGrey)
plot(earlyChanges, relativeChanges_PG(relativeChanges_PG(:,end-1) == 1,5), ...
    '.', 'Color', lightBlue)
% plot(lateChanges, relativeChanges_PG(relativeChanges_PG(:,end) == 1,5), ...
%     '.', 'Color', lightRed)
% plot(relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,4), ...
%     relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = mean(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5, 5));
    moveBin = mean(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
%plot(relativeChanges_PG(:,4), relativeChanges_PG(:,5), 'k.')
% plot(relativeChanges_PG(:,4), relativeChanges_PG(:,6), 'r.')
figure(333)
xlim([-6.5 2])
hold on
histogram(relativeChanges_PG(relativeChanges_PG(:,4) > -6.5 & relativeChanges_PG(:,4) < 2,4), 'BinWidth', .5, 'facecolor', lightGrey, 'edgecolor', 'none')
histogram(earlyChanges, 'BinWidth', .5, 'facecolor', lightBlue, 'edgecolor', 'none')
%histogram(lateChanges, 'BinWidth', .25, 'facecolor', lightRed, 'edgecolor', 'none')
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
earlyChanges = relativeChanges_TW(relativeChanges_TW(:,end-1) == 1,4);
%lateChanges = relativeChanges_TW(relativeChanges_TW(:,end) == 1,4);
figure(44)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_TW(:,4), relativeChanges_TW(:,5), '.', 'Color', lightGrey)
plot(earlyChanges, relativeChanges_TW(relativeChanges_TW(:,end-1) == 1,5), ...
    '.', 'Color', lightBlue)
% plot(lateChanges, relativeChanges_TW(relativeChanges_TW(:,end) == 1,5), ...
%     '.', 'Color', lightRed)
% plot(relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,4), ...
%     relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = mean(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5, 5));
    moveBin = mean(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
%plot(relativeChanges_PG(:,4), relativeChanges_PG(:,5), 'k.')
% plot(relativeChanges_PG(:,4), relativeChanges_PG(:,6), 'r.')
figure(444)
xlim([-6.5 2])
hold on
histogram(relativeChanges_TW(relativeChanges_TW(:,4) > -6.5 & relativeChanges_TW(:,4) < 2,4), 'BinWidth', .5, 'facecolor', lightGrey, 'edgecolor', 'none')
histogram(earlyChanges, 'BinWidth', .5, 'facecolor', lightBlue, 'edgecolor', 'none')
%histogram(lateChanges, 'BinWidth', .25, 'facecolor', lightRed, 'edgecolor', 'none')

%%
% 1. try to color code dots in fixation types
% 2. replicate Roland thingy and add fixation types
% overlay cumulative hists of trials
% or color code the light blue into the relative-go thing
% probability of silent period in normalized time & <= 1s
% plot the time of ball fixation reltaive to letter change (last letter
% change before ball fixation)

eventsRelativeLetter = [];
numParticipants = 11;
eyeShift = 20;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        c = 1;
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
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            reach = currentResult(n).info.timeStamp.reach;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOffRelative = currentResult(n).gaze.fixation.offsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
                fixBallOffset = currentResult(n).info.timeStamp.go + fixBallOffRelative;
            else
                fixBallOnset = NaN;
                fixBallOffset = NaN;
            end
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                if ~isempty(currentResult(n).gaze.fixation.offsetsBall)
                    slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > currentResult(n).gaze.fixation.offsetsBall(1), 1, 'first');
                else
                    slotIdx = 1;
                end
                fixSlotOnRelative = currentResult(n).gaze.fixation.onsetsSlot(slotIdx)/200;
                fixSlotOffRelative = currentResult(n).gaze.fixation.offsetsSlot(slotIdx)/200;
                fixSlotOnset = currentResult(n).info.timeStamp.go + fixSlotOnRelative;
                fixSlotOffset = currentResult(n).info.timeStamp.go + fixSlotOffRelative;
            else
                fixSlotOnset = NaN;
                fixSlotOffset = NaN;
            end
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            changeDetected(c) = currentResult(n).dualTask.changeDetected;
            changeMissed(c) = currentResult(n).dualTask.changeMissed;
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < reach+1.5
                    currentReach(i) = reach-currentLetterChange;
                else
                    if n < stopTrial
                        currentReach(i) = currentResult(n+1).info.timeStamp.reach - currentLetterChange;
                    else
                        currentReach(i) = NaN;
                    end
                end
            end
            reachOnsets(c) = currentReach;
            clear currentReach
            % ball onsets
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < fixBallOnset
                    currentBallOnset(i) = fixBallOnset-currentLetterChange;
                    currentBallOffset(i) = fixBallOffset-currentLetterChange;
                else
                    if n < stopTrial
                        if ~isempty(currentResult(n+1).gaze.fixation.onsetsBall)
                            fixBallOnRelative = currentResult(n+1).gaze.fixation.onsetsBall(1)/200;
                            fixBallOffRelative = currentResult(n+1).gaze.fixation.offsetsBall(1)/200;
                            currentBallOnset(i) = currentResult(n+1).info.timeStamp.go + fixBallOnRelative - currentLetterChange;
                            currentBallOffset(i) = currentResult(n+1).info.timeStamp.go + fixBallOffRelative - currentLetterChange;
                        else
                            currentBallOnset(i) = NaN;
                            currentBallOffset(i) = NaN;
                        end
                    else
                        currentBallOnset(i) = NaN;
                        currentBallOffset(i) = NaN;
                    end
                end
            end
            ballFixOnsets(c) = currentBallOnset;
            ballFixOffsets(c) = currentBallOffset;
            clear currentBallOnset currentBallOffset
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < fixSlotOnset
                    currentSlotOnset(i) = fixSlotOnset-currentLetterChange;
                    currentSlotOffset(i) = fixSlotOffset-currentLetterChange;
                else
                    if n < stopTrial
                        if ~isempty(currentResult(n+1).gaze.fixation.onsetsSlot)
                            fixSlotOnRelative = currentResult(n+1).gaze.fixation.onsetsSlot(1)/200;
                            fixSlotOffRelative = currentResult(n+1).gaze.fixation.offsetsSlot(1)/200;
                            currentSlotOnset(i) = currentResult(n+1).info.timeStamp.go + fixSlotOnRelative - currentLetterChange;
                            currentSlotOffset(i) = currentResult(n+1).info.timeStamp.go + fixSlotOffRelative - currentLetterChange;
                        else
                            currentSlotOnset(i) = NaN;
                            currentSlotOffset(i) = NaN;
                        end
                    else
                        currentSlotOnset(i) = NaN;
                        currentSlotOffset(i) = NaN;
                    end
                end
            end
            slotFixOnsets(c) = currentSlotOnset;
            slotFixOffsets(c) = currentSlotOffset;
            clear currentSlotOnset currentSlotOffset
            % ball and slot fixations during reach and transport phase
            selectedTrial = n;
            if numel(currentResult(selectedTrial).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern(c) = 99*ones(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern(c) = zeros(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && ~isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern(c) = 2*ones(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif ~isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern(c) = ones(length(currentResult(n).dualTask.tLetterChanges),1);
            else
                ballOffset = currentResult(selectedTrial).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(selectedTrial).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(selectedTrial).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern(c) = 3*ones(length(currentResult(n).dualTask.tLetterChanges),1);
                else
                    fixationPattern(c) = 4*ones(length(currentResult(n).dualTask.tLetterChanges),1);
                end
            end

            c = c(end) + 1;
        end

        currentVariable = [currentParticipant*ones(1,length(fixationPattern))' blockID*ones(1,length(fixationPattern))' ...
            fixationPattern' changeDetected' changeMissed' reachOnsets' ballFixOnsets' ballFixOffsets' slotFixOnsets' slotFixOffsets'];

        eventsRelativeLetter = [eventsRelativeLetter; currentVariable];
        clear fixationPattern changeDetected changeMissed reachOnsets ballFixOnsets ballFixOffsets slotFixOnsets slotFixOffsets
    end
end

%%
letterReaches_PG = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
reachPG = letterReaches_PG( letterReaches_PG(:,6) > -1.5 & letterReaches_PG(:,6) < 3.5 ,6);
figure(3)
histogram(reachPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')

%%
letterReaches_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
reachTW = letterReaches_TW( letterReaches_TW(:,6) > -1.5 & letterReaches_TW(:,6) < 3.5 ,:);
figure(4)
hold on
histogram(reachTW(:,6), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
% indicate ball-slot trials
histogram(reachTW(reachTW(:,3) == 3,6), 'BinWidth', .25, 'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none')
%%
letterReaches_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
fixTW = letterReaches_TW( letterReaches_TW(:,7) > -1.5 & letterReaches_TW(:,7) < 3.5 ,:);
figure(43)
hold on
histogram(fixTW(:,7), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
% indicate ball-slot trials
histogram(fixTW(fixTW(:,3) == 3,7), 'BinWidth', .25, 'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none')
figure(44)
hold on
histogram(fixTW(:,7), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
% indicate ball-slot trials
histogram(fixTW(fixTW(:,3) == 4,7), 'BinWidth', .25, 'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none')
%% plot ball on and offset
lowerBound = -1.5;
upperBound = 5;
balFixations_PG = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
selectedColumn = 7;
ballOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,selectedColumn);
ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn)
hold on
histogram(ballOnsetPG, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
histogram(ballOffsetPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 80;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
%
balFixations_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
ballOnsetTW = balFixations_TW( balFixations_TW(:,selectedColumn) > lowerBound & balFixations_TW(:,selectedColumn) < upperBound ,selectedColumn);
ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn+1)
hold on
histogram(ballOnsetTW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
histogram(ballOffsetTW, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 80;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
 
%% plot slot on and offset
balFixations_PG = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
selectedColumn = 9;
ballOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,selectedColumn);
ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn)
hold on
histogram(ballOnsetPG, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
histogram(ballOffsetPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 80;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
%
balFixations_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
ballOnsetTW = balFixations_TW( balFixations_TW(:,selectedColumn) > lowerBound & balFixations_TW(:,selectedColumn) < upperBound ,selectedColumn);
ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn+1)
hold on
histogram(ballOnsetTW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
histogram(ballOffsetTW, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 80;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% add fixation types for tweezers for the slot fixations
balFixations_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
selectedColumn = 7;
ballOnsetTW = balFixations_TW( balFixations_TW(:,selectedColumn) > lowerBound & balFixations_TW(:,selectedColumn) < upperBound ,:);
ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 3;
figure(fixationPattern)
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
fixationPattern = 4;
figure(fixationPattern)
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% add fixation types for tweezers for the slot fixations
balFixations_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
selectedColumn = 9;
ballOnsetTW = balFixations_TW( balFixations_TW(:,selectedColumn) > lowerBound & balFixations_TW(:,selectedColumn) < upperBound ,:);
ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 3;
figure(fixationPattern*10)
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
fixationPattern = 4;
figure(fixationPattern*10)
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(ballOnsetTW(ballOnsetTW(:,3) == 2,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(2+1,:))
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% add fixation types for fingertips for the slot fixations
balFixations_PG = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
selectedColumn = 9;
ballOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,:);
ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 2;
figure(fixationPattern*10)
hold on
histogram(ballOnsetPG(ballOnsetPG(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
% histogram(ballOffsetPG(ballOffsetPG(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
