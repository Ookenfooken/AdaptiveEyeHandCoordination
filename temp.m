% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%%
numParticipants = 11;
eyeShift = 20;
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
        for n = 2:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end

            tStart = currentResult(n).info.timeStamp.start;
            goTime = currentResult(n).info.timeStamp.go;
            reach = currentResult(n).info.timeStamp.reach;

            % check whether a letter change was detected in the current
            % trial
            if sum(currentResult(n).dualTask.changeDetected) > 0
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                selectedTrial = n;
            else % otherwise use the previous trial
                if sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    selectedTrial = n-1;
                else
                    continue
                end
            end
            % if the change happened before the reach good
            if detectedChanges(1) < reach
                letterChangeBeforeReach = detectedChanges(1) - reach;
                letterChangeRelativeGo = detectedChanges(1) - goTime;
            else % otherwise use the previous trial
                if sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    selectedTrial = n-1;
                    letterChangeBeforeReach = detectedChanges(1) - reach;
                    letterChangeRelativeGo = detectedChanges(1) - goTime;
                else
                    continue
                end
            end

            goToReach = reach-goTime;
            reachDuration = currentResult(n).info.phaseDuration.primaryReach/200;

            % ball and slot fixations during reach and transport phase
            if numel(currentResult(selectedTrial).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && ~isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(selectedTrial).gaze.fixation.onsetsBall) && isempty(currentResult(selectedTrial).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(selectedTrial).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(selectedTrial).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(selectedTrial).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end

            currentVariable(n,:) = [currentParticipant blockID letterChangeBeforeReach letterChangeRelativeGo ...
                goToReach reachDuration fixationPattern];
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
lightGrey = [189,189,189]./255;
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
figure(3)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([-6.5 2],[0 0], 'Color', lightGrey)
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_PG(relativeChanges_PG(:,end) == 0,3), relativeChanges_PG(relativeChanges_PG(:,end) == 0,5), ...
    '.', 'Color', fixationPatternColors(1,:))
plot(relativeChanges_PG(relativeChanges_PG(:,end) == 2,3), relativeChanges_PG(relativeChanges_PG(:,end) == 2,5), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,3), ...
    relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = median(relativeChanges_PG(relativeChanges_PG(:,3) < i & relativeChanges_PG(:,3) > i-0.5, 5));
    moveBin = median(relativeChanges_PG(relativeChanges_PG(:,3) < i & relativeChanges_PG(:,3) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
% plot(relativeChanges_PG(:,3), relativeChanges_PG(:,5), 'k.')
% plot(relativeChanges_PG(:,3), relativeChanges_PG(:,6), 'r.')

% plot time of last detected letter change (before reach onset) relative to
% go signal
figure(33)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_PG(relativeChanges_PG(:,end) == 0,4), relativeChanges_PG(relativeChanges_PG(:,end) == 0,5), ...
    '.', 'Color', fixationPatternColors(1,:))
plot(relativeChanges_PG(relativeChanges_PG(:,end) == 2,4), relativeChanges_PG(relativeChanges_PG(:,end) == 2,5), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,4), ...
    relativeChanges_PG(relativeChanges_PG(:,end) ~= 0 & relativeChanges_PG(:,end) ~= 2,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = median(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5, 5));
    moveBin = median(relativeChanges_PG(relativeChanges_PG(:,4) < i & relativeChanges_PG(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
% plot(relativeChanges_PG(:,4), relativeChanges_PG(:,5), 'k.')
% plot(relativeChanges_PG(:,4), relativeChanges_PG(:,6), 'r.')
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
figure(4)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([-6.5 2],[0 0], 'Color', lightGrey)
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_TW(relativeChanges_TW(:,end) == 3,3), relativeChanges_TW(relativeChanges_TW(:,end) == 3,5), ...
    '.', 'Color', fixationPatternColors(4,:))
plot(relativeChanges_TW(relativeChanges_TW(:,end) == 4,3), relativeChanges_TW(relativeChanges_TW(:,end) == 4,5), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(relativeChanges_TW(relativeChanges_TW(:,end) ~= 3 & relativeChanges_TW(:,end) ~= 4,3), ...
    relativeChanges_TW(relativeChanges_TW(:,end) ~= 3 & relativeChanges_TW(:,end) ~= 4,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = median(relativeChanges_TW(relativeChanges_TW(:,3) < i & relativeChanges_TW(:,3) > i-0.5, 5));
    moveBin = median(relativeChanges_TW(relativeChanges_TW(:,3) < i & relativeChanges_TW(:,3) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
% plot(relativeChanges_TW(:,3), relativeChanges_TW(:,5), 'k.')
% plot(relativeChanges_TW(:,3), relativeChanges_TW(:,6), 'r.')
% plot time of last detected letter change (before reach onset) relative to
% go signal
figure(44)
hold on
xlim([-6.5 2])
ylim([-1 2])
line([0 0],[-1 2], 'Color', lightGrey)
plot(relativeChanges_TW(relativeChanges_TW(:,end) == 3,4), relativeChanges_TW(relativeChanges_TW(:,end) == 3,5), ...
    '.', 'Color', fixationPatternColors(4,:))
plot(relativeChanges_TW(relativeChanges_TW(:,end) == 4,4), relativeChanges_TW(relativeChanges_TW(:,end) == 4,5), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(relativeChanges_TW(relativeChanges_TW(:,end) ~= 3 & relativeChanges_TW(:,end) ~= 4,4), ...
    relativeChanges_TW(relativeChanges_TW(:,end) ~= 3 & relativeChanges_TW(:,end) ~= 4,5), '.', 'Color', 'm')
for i = -6:0.5:2
    reactBin = median(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5, 5));
    moveBin = median(relativeChanges_TW(relativeChanges_TW(:,4) < i & relativeChanges_TW(:,4) > i-0.5,6));
    line([i-.5 i], [reactBin reactBin], 'Color', 'k')
    %line([i-.5 i], [moveBin moveBin], 'Color', 'r')
end
% plot(relativeChanges_TW(:,4), relativeChanges_TW(:,5), 'k.')
% plot(relativeChanges_TW(:,4), relativeChanges_TW(:,6), 'r.')

%%
% 1. try to color code dots in fixation types
% 2. replicate Roland thingy and add fixation types
% overlay cumulative hists of trials
% or color code the light blue into the relative-go thing
% probability of silent period in normalized time & <= 1s
% plot the time of ball fixation reltaive to letter change (last letter
% change before ball fixation)

reachRelativeLetter = [];
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
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixOnsetRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixationOnset = currentResult(n).info.timeStamp.go + fixOnsetRelative;
            else
                fixationOnset = NaN;
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
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < fixationOnset+1.5
                    currentOnset(i) = fixationOnset-currentLetterChange;
                else
                    if n < stopTrial
                        if ~isempty(currentResult(n+1).gaze.fixation.onsetsBall)
                            fixOnsetRelative = currentResult(n+1).gaze.fixation.onsetsBall(1)/200;
                            currentOnset(i) = currentResult(n+1).info.timeStamp.go + fixOnsetRelative - currentLetterChange;
                        else
                            currentOnset(i) = NaN;
                        end
                    else
                        currentOnset(i) = NaN;
                    end
                end
            end
            ballFixOnsets(c) = currentOnset;
            clear currentOnset
            selectedTrial = n;
            % ball and slot fixations during reach and transport phase
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
            fixationPattern' changeDetected' changeMissed' reachOnsets' ballFixOnsets'];

        reachRelativeLetter = [reachRelativeLetter; currentVariable];
        clear fixationPattern changeDetected changeMissed reachOnsets ballFixOnsets
    end
end

%%
letterReaches_PG = reachRelativeLetter( reachRelativeLetter(:,2) == 3,:);
reachPG = letterReaches_PG( letterReaches_PG(:,6) > -1.5 & letterReaches_PG(:,6) < 3.5 ,6);
figure(3)
histogram(reachPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')

%%
letterReaches_TW = reachRelativeLetter( reachRelativeLetter(:,2) == 4,:);
reachTW = letterReaches_TW( letterReaches_TW(:,6) > -1.5 & letterReaches_TW(:,6) < 3.5 ,:);
figure(4)
hold on
histogram(reachTW(:,6), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
% indicate ball-slot trials
histogram(reachTW(reachTW(:,3) == 3,6), 'BinWidth', .25, 'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none')
%%
letterReaches_TW = reachRelativeLetter( reachRelativeLetter(:,2) == 4,:);
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