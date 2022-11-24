% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% Calculate ball fixation onsets relative to letter changes
ballFixationReLetter = [];
numParticipants = 11;
eyeShift = 20;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 6;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
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
                continue
            end
            if ~isnan(currentResult(n).dualTask.tLetterChanges(1))
                detectedChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                if numel(detectedChanges) > 0
                    currentLetterChange = detectedChanges(1);
                else
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                    end
                end
                % check if letter change is before fixation onset
                if currentLetterChange < fixBallOnset
                    letterChangeRelativeBallFix = fixBallOnset - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeBallFix = fixBallOnset - currentLetterChange;
                    else
                        continue
                    end
                end
            elseif n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(end))
                detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                if numel(detectedChanges) > 0
                    currentLetterChange = detectedChanges(end);
                else
                    continue
                end
                letterChangeRelativeBallFix = fixBallOnset - currentLetterChange;
            else
                continue
            end
            % label early and late letter changes for plotting    
            if currentLetterChange < ballApproach && currentLetterChange >= ballApproach-preInterval
                earlyLC = 1;
            else
                earlyLC = 0;
            end
            cutoff = max([slotApproach-preInterval ballApproach]);
            if currentLetterChange < slotApproach && currentLetterChange >= cutoff
                lateLC = 1;
            else
                lateLC = 0;
            end           
            % ball and slot fixations during reach and transport phase
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
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
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             letterChangeRelativeBallFix earlyLC lateLC];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        ballFixationReLetter = [ballFixationReLetter; currentVariable];
        clear fixationPattern letterChangeRelativeBallFix earlyLC lateLC 
        clear fixBallOnRelative fixBallOnset cutoff ballApproach slotApproach slotIdx slotOnset ballOffset
    end
end
%% calculate slot fixation onsets relative to letter changes
slotFixationReLetter = [];
numParticipants = 11;
eyeShift = 20;
preInterval = 1.5;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 7;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            detectedChange = NaN;
            missedChange = NaN;
            % now consider ball and slot fixation onsets relative to
            % approach phases
            ballApproach = currentResult(n).info.timeStamp.ballApproach;
            slotApproach = currentResult(n).info.timeStamp.slotApproach;
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
                continue
            end
            if ~isnan(currentResult(n).dualTask.tLetterChanges(1))
                currentLetterChange = currentResult(n).dualTask.tLetterChanges(1);
                if currentLetterChange < fixSlotOnset
                    letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                    if currentResult(n).dualTask.changeDetected
                        changeDetected = 1;
                    else
                        changeDetected = 0;
                    end
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        currentLetterChange = currentResult(n-1).dualTask.tLetterChanges(end);
                        letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                        if currentResult(n-1).dualTask.changeDetected(end)
                            changeDetected = 1;
                        else
                            changeDetected = 0;
                        end
                    else
                        continue
                    end
                end
            elseif n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                currentLetterChange = currentResult(n-1).dualTask.tLetterChanges(end);
                letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                if currentResult(n-1).dualTask.changeDetected(end)
                    changeDetected = 1;
                else
                    changeDetected = 0;
                end
            else
                continue
            end
            % label early and late letter changes for plotting    
            if currentLetterChange < ballApproach && currentLetterChange >= ballApproach-preInterval
                earlyLC = 1;
            else
                earlyLC = 0;
            end
            cutoff = max([slotApproach-preInterval ballApproach]);
            if currentLetterChange < slotApproach && currentLetterChange >= cutoff
                lateLC = 1;
            else
                lateLC = 0;
            end           
            % ball and slot fixations during reach and transport phase
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
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
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             changeDetected letterChangeRelativeSlotFix earlyLC lateLC];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        slotFixationReLetter = [slotFixationReLetter; currentVariable];
        clear fixationPattern changeDetected letterChangeRelativeSlotFix earlyLC lateLC  ballOffset
        clear fixSlotOnRelative fixSlotOnRelative slotIdx slotOnset cutoff ballApproach slotApproach
    end
end

%% Before plotting define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
lightBlue = [66,146,198]./255;
lightRed = [239,59,44]./255;
upperBound = 5;
ymax = 20;
selectedColumn = 4; % fixation onsets

%% plot all ball and slot-only fixations in precision grip trials
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
%ballFixation_PG_detected = ballFixations_PG(ballFixations_PG(:,4) == 1, :);
%ballFixation_PG_missed = ballFixations_PG(ballFixations_PG(:,4) == 0, :);
earlyLC_PG = ballFixations_PG( ballFixations_PG(:,end-1) ==1 ,selectedColumn);
lateLC_PG = ballFixations_PG( ballFixations_PG(:,end) ==1 ,selectedColumn);
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
histogram(ballFixations_PG(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', lightGrey)
histogram(earlyLC_PG, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_PG, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
%histogram(ballFixation_PG_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%%
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
slotFixation_PG_detected = slotFixations_PG(slotFixations_PG(:,4) == 1, :);
slotFixation_PG_missed = slotFixations_PG(slotFixations_PG(:,4) == 0, :);
selectedPattern = 2; % slot-only
fixations_PG = slotFixation_PG_detected(slotFixation_PG_detected(:,3) == selectedPattern,:);
fixations_PG_missed = slotFixation_PG_missed(slotFixation_PG_missed(:,3) == selectedPattern,:);
earlyLC_PG = fixations_PG( fixations_PG(:,end-1) ==1 ,selectedColumn);
lateLC_PG = fixations_PG( fixations_PG(:,end) ==1 ,selectedColumn);
figure(selectedPattern)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_PG(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_PG, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_PG, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(fixations_PG_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

clear fixations_PG fixations_PG_missed earlyLC_PG lateLC_PG
%% plot ball fixations for different fixation patterns in tweezer trials
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
selectedPattern = 3; % ball-slot pattern
fixations_TW = ballFixations_TW(ballFixations_TW(:,3) == selectedPattern,:);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedPattern)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
%histogram(fixations_TW_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

clear fixations_TW earlyLC_TW lateLC_TW
% add ball-only trials in here
selectedPattern = 1; % ball-only pattern
fixations_TW = ballFixation_TW_detected(ballFixation_TW_detected(:,3) == selectedPattern,:);
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
%%
selectedPattern = 4; % ball-display-slot pattern
fixations_TW = ballFixation_TW_detected(ballFixation_TW_detected(:,3) == selectedPattern,:);
fixations_TW_missed = ballFixation_TW_missed(ballFixation_TW_missed(:,3) == selectedPattern,:);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedPattern)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(fixations_TW_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
clear fixations_TW fixations_TW_missed earlyLC_TW lateLC_TW
%%
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
slotFixation_TW_detected = slotFixations_TW(slotFixations_TW(:,4) == 1, :);
slotFixation_TW_missed = slotFixations_TW(slotFixations_TW(:,4) == 0, :);
selectedPattern = 3; % ball-slot pattern
fixations_TW = slotFixation_TW_detected(slotFixation_TW_detected(:,3) == selectedPattern,:);
fixations_TW_missed = slotFixation_TW_missed(slotFixation_TW_missed(:,3) == selectedPattern,:);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedPattern*10)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(fixations_TW_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
clear fixations_TW fixations_TW_missed earlyLC_TW lateLC_TW
%%
selectedPattern = 4; % ball-display-slot pattern
fixations_TW = slotFixation_TW_detected(slotFixation_TW_detected(:,3) == selectedPattern,:);
fixations_TW_missed = slotFixation_TW_missed(slotFixation_TW_missed(:,3) == selectedPattern,:);
earlyLC_TW = fixations_TW( fixations_TW(:,end-1) ==1 ,selectedColumn);
lateLC_TW = fixations_TW( fixations_TW(:,end) ==1 ,selectedColumn);
figure(selectedPattern*10)
set(gcf,'renderer','Painters')
hold on
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))
histogram(earlyLC_TW, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(lateLC_TW, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(fixations_TW_missed(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', 'k')
xlim([0 upperBound])
ylim([0 ymax])
set(gca, 'Ytick', [0 5 10 15 20])
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
clear fixations_TW fixations_TW_missed earlyLC_TW lateLC_TW
% add slot-only trials in here
selectedPattern = 2; % ball-display-slot pattern
fixations_TW = slotFixation_TW_detected(slotFixation_TW_detected(:,3) == selectedPattern,:);
histogram(fixations_TW(:,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(selectedPattern+1,:))

