% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% plot the probability of fixation onsets relative to kinematic events
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
            % now consider ball and slot fixation onsets relative to
            % approach phases
            ballApproach = currentResult(n).info.timeStamp.ballApproach;
            slotApproach = currentResult(n).info.timeStamp.slotApproach;
            preInterval = 1.5;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
            else
                fixBallOnset = NaN;
            end
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                if ~isempty(currentResult(n).gaze.fixation.offsetsBall)
                    slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > currentResult(n).gaze.fixation.offsetsBall(1), 1, 'first');
                else
                    slotIdx = 1;
                end
                fixSlotOnRelative = currentResult(n).gaze.fixation.onsetsSlot(slotIdx)/200;
                fixSlotOnset = currentResult(n).info.timeStamp.go + fixSlotOnRelative;
            else
                fixSlotOnset = NaN;
            end
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentResult(n).dualTask.changeDetected(i) && ...
                        currentLetterChange < reach && currentLetterChange >= reach-1
                    preReachLC(i) = 1;
                else
                    preReachLC(i) = 0;
                end
                if currentLetterChange < ballApproach && currentLetterChange >= ballApproach-preInterval
                    earlyLC(i) = 1;
                else
                    earlyLC(i) = 0;
                end
                cutoff = max([slotApproach-preInterval ballApproach]);
                if currentLetterChange < slotApproach && currentLetterChange >= cutoff
                    lateLC(i) = 1;
                else
                    lateLC(i) = 0;
                end
            end
            preReachLCs(c) = preReachLC;
            earlyLCs(c) = earlyLC;
            lateLCs(c) = lateLC;
            clear preReachLC earlyLC lateLC
            % ball onsets
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < fixBallOnset
                    currentBallOnset(i) = fixBallOnset-currentLetterChange;
                else
                    if n < stopTrial
                        if ~isempty(currentResult(n+1).gaze.fixation.onsetsBall)
                            fixBallOnRelative = currentResult(n+1).gaze.fixation.onsetsBall(1)/200;
                            currentBallOnset(i) = currentResult(n+1).info.timeStamp.go + fixBallOnRelative - currentLetterChange;
                        else
                            currentBallOnset(i) = NaN;
                        end
                    else
                        currentBallOnset(i) = NaN;
                    end
                end
            end
            ballFixOnsets(c) = currentBallOnset;
            clear currentBallOnset 
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(i);
                if currentLetterChange < fixSlotOnset
                    currentSlotOnset(i) = fixSlotOnset-currentLetterChange;
                else
                    if n < stopTrial
                        if ~isempty(currentResult(n+1).gaze.fixation.onsetsSlot)
                            fixSlotOnRelative = currentResult(n+1).gaze.fixation.onsetsSlot(1)/200;
                            currentSlotOnset(i) = currentResult(n+1).info.timeStamp.go + fixSlotOnRelative - currentLetterChange;
                        else
                            currentSlotOnset(i) = NaN;
                        end
                    else
                        currentSlotOnset(i) = NaN;
                    end
                end
            end
            slotFixOnsets(c) = currentSlotOnset;
            clear currentSlotOnset currentLetterChange slotIdx slotOnset
            clear fixBallOnset fixBallOnRelative fixSlotOnset fixSlotOnRelative
            % ball and slot fixations during reach and transport phase
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern(c) = 99*ones(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(c) = zeros(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(c) = 2*ones(length(currentResult(n).dualTask.tLetterChanges),1);
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(c) = ones(length(currentResult(n).dualTask.tLetterChanges),1);
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern(c) = 3*ones(length(currentResult(n).dualTask.tLetterChanges),1);
                else
                    fixationPattern(c) = 4*ones(length(currentResult(n).dualTask.tLetterChanges),1);
                end
            end

            c = c(end) + 1;
        end

        currentVariable = [currentParticipant*ones(1,length(fixationPattern))' blockID*ones(1,length(fixationPattern))' ...
            fixationPattern' ballFixOnsets' slotFixOnsets' ...
            preReachLCs' earlyLCs' lateLCs'];

        eventsRelativeLetter = [eventsRelativeLetter; currentVariable];
        clear fixationPattern ballFixOnsets slotFixOnsets preReachLCs earlyLCs lateLCs
    end
end

%% Before plotting define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
brightCyan = [0 174 239]./255;
lightBlue = [66,146,198]./255;
lightRed = [239,59,44]./255;
upperBound = 5;
%% plot all ball and slot-only fixations in precision grip trials
fixations_PG_all = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
selectedColumn = 4; % ball fixations
preReach_PG = fixations_PG_all( fixations_PG_all(:,end-2) ==1 ,selectedColumn);
earlyLC_PG = fixations_PG_all( fixations_PG_all(:,end-1) ==1 ,selectedColumn);
lateLC_PG = fixations_PG_all( fixations_PG_all(:,end) ==1 ,selectedColumn);
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_PG_all(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', lightGrey)
histogram(earlyLC_PG, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_PG, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_PG, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

selectedColumn = 5; % slot fixations
selectedPattern = 2; % slot-only
fixations_PG = fixations_PG_all(fixations_PG_all(:,3) == selectedPattern,:);
preReach_PG = fixations_PG( fixations_PG(:,end-2) ==1 ,selectedColumn);
earlyLC_PG = fixations_PG( fixations_PG(:,end-1) ==1 ,selectedColumn);
lateLC_PG = fixations_PG( fixations_PG(:,end) ==1 ,selectedColumn);
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_PG(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_PG, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_PG, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_PG, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

clear fixations_PG preReach_PG earlyLC_PG lateLC_PG
%% plot ball and slot fixations for different fixation patterns in tweezer trials
fixations_TW_all = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
selectedColumn = 4; % ball fixations
selectedPattern = 3; % ball-slot pattern
fixations_TW = fixations_TW_all(fixations_TW_all(:,3) == selectedPattern,:);
preReach_TW = fixations_TW( fixations_TW(:,end-2) ==1 ,selectedColumn);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedColumn*10)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_TW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

selectedColumn = 5; % slot fixations
selectedPattern = 3; % ball-slot pattern
fixations_TW = fixations_TW_all(fixations_TW_all(:,3) == selectedPattern,:);
preReach_TW = fixations_TW( fixations_TW(:,end-2) ==1 ,selectedColumn);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedColumn*10)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_TW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

selectedColumn = 4; % ball fixations
selectedPattern = 4; % ball-display-slot pattern
fixations_TW = fixations_TW_all(fixations_TW_all(:,3) == selectedPattern,:);
preReach_TW = fixations_TW( fixations_TW(:,end-2) ==1 ,selectedColumn);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedColumn*100)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_TW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

selectedColumn = 5; % slot fixations
selectedPattern = 4; % ball-display-slot pattern
fixations_TW = fixations_TW_all(fixations_TW_all(:,3) == selectedPattern,:);
preReach_TW = fixations_TW( fixations_TW(:,end-2) ==1 ,selectedColumn);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedColumn*100)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(preReach_TW, 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', brightCyan)
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
% add slot-only trials in here
selectedPattern = 2; % ball-display-slot pattern
fixations_TW = fixations_TW_all(fixations_TW_all(:,3) == selectedPattern,:);
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))

clear fixations_TW preReach_TW earlyLC_TW lateLC_TW