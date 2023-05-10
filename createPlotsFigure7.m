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
            reach = currentResult(n).info.timeStamp.reach;
            ballGrasp = currentResult(n).info.timeStamp.ballGrasp;
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
                    else
                        continue
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
                % check if letter change is before reach
                if currentLetterChange < reach
                    letterChangeRelativeReach = reach - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeReach = reach - currentLetterChange;
                    else
                        continue
                    end
                end
                % check if letter change is ball contact
                if currentLetterChange < ballGrasp
                    letterChangeRelativeGrasp = ballGrasp - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeGrasp = ballGrasp - currentLetterChange;
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
                letterChangeRelativeReach = reach - currentLetterChange;
                letterChangeRelativeGrasp = ballGrasp - currentLetterChange;
            else
                continue
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
             letterChangeRelativeBallFix letterChangeRelativeReach letterChangeRelativeGrasp];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        ballFixationReLetter = [ballFixationReLetter; currentVariable];
        clear fixationPattern letterChangeRelativeBallFix letterChangeRelativeGrasp letterChangeRelativeReach
        clear fixBallOnRelative fixBallOnset cutoff ballGrasp slotIdx slotOnset ballOffset currentLetterChange
        clear currentVariable detectedChanges reach
    end
end
%% calculate slot fixation onsets relative to letter changes
slotFixationReLetter = [];
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
            transport = currentResult(n).info.timeStamp.transport;
            slotEntry = currentResult(n).info.timeStamp.ballInSlot;
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
                    else
                        continue
                    end
                end
                % check if letter change is before fixation onset
                if currentLetterChange < fixSlotOnset
                    letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                    else
                        continue
                    end
                end
                % check if letter change is before transport onset
                if currentLetterChange < transport
                    letterChangeRelativeTransport = transport - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeTransport = transport - currentLetterChange;
                    else
                        continue
                    end
                end
                % check if letter change is before slot entry
                if currentLetterChange < slotEntry
                    letterChangeRelativeSlotEntry = slotEntry - currentLetterChange;
                else % otherwise use the previous trial
                    if n > 1 && ~isnan(currentResult(n-1).dualTask.tLetterChanges(1))
                        detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                        if numel(detectedChanges) > 0
                            currentLetterChange = detectedChanges(end);
                        else
                            continue
                        end
                        letterChangeRelativeSlotEntry = slotEntry - currentLetterChange;
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
                letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                letterChangeRelativeTransport = transport - currentLetterChange;
                letterChangeRelativeSlotEntry = slotEntry - currentLetterChange;
            else
                continue
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
             letterChangeRelativeSlotFix letterChangeRelativeTransport letterChangeRelativeSlotEntry];

        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        slotFixationReLetter = [slotFixationReLetter; currentVariable];
        clear fixationPattern changeDetected letterChangeRelativeSlotFix letterChangeRelativeSlotEntry
        clear fixSlotOnRelative fixSlotOnset slotIdx slotOnset cutoff slotEntry letterChangeRelativeTransport
        clear ballOffset currentLetterChange currentVariable clear transport
    end
end

%% Before plotting define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
upperBound = 5;
fixationOnsets = 4; % column with fixation onsets
movementOnsets = 5; % column with reach / transport onsets
manipulationOnsets = 6; % column with grasp / slot entry

%% plot ball fixation, reach, and grasp onsets for different patterns in precision grip trials
figure(fixationOnsets)
xymax = 15;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
fixations_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
subplot(3,1,1)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.ball.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.ball.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_back = sum(h.ball.PGback.Values)*h.ball.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.ball.PGtri.Values)*h.ball.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot reach onsets
subplot(3,1,2)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.reach.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_back = sum(h.reach.PGback.Values)*h.reach.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.reach.PGtri.Values)*h.reach.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot ball grasp onsets
subplot(3,1,3)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.grasp.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.grasp.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_back = sum(h.grasp.PGback.Values)*h.grasp.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.grasp.PGtri.Values)*h.grasp.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

clear SP_PG_tri SP_PG_back ballFixations_PG fixations_PG

%% plot slot fixation, transport, and slot etnry for different patterns in precision grip trials
figure(movementOnsets)
xymax = 15;
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude slot-only
fixations_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
subplot(3,1,1)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.slot.PGslot = histogram(fixations_PG(fixations_PG(:,3) == 2,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.slot.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.slot.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_slot = sum(h.slot.PGslot.Values)*h.slot.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.slot.PGback.Values)*h.slot.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.slot.PGtri.Values)*h.slot.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot reach onsets
subplot(3,1,2)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGslot = histogram(fixations_PG(fixations_PG(:,3) == 2,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.reach.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.reach.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_slot = sum(h.reach.PGslot.Values)*h.reach.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.reach.PGback.Values)*h.reach.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.reach.PGtri.Values)*h.reach.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot slot grasp onsets
subplot(3,1,3)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.grasp.PGslot = histogram(fixations_PG(fixations_PG(:,3) == 2,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.grasp.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.grasp.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_PG_slot = sum(h.grasp.PGslot.Values)*h.grasp.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.grasp.PGback.Values)*h.grasp.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.grasp.PGtri.Values)*h.grasp.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

clear SP_PG_tri SP_PG_back slotFixations_PG fixations_PG

%% plot ball fixation, reach, and grasp onsets for different patterns in tweezer trials
figure(fixationOnsets*10)
xymax = 20;
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
fixations_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
subplot(3,1,1)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.ball.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.ball.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_back = sum(h.ball.TWback.Values)*h.ball.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.ball.TWtri.Values)*h.ball.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot reach onsets
subplot(3,1,2)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.reach.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_back = sum(h.reach.TWback.Values)*h.reach.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.reach.TWtri.Values)*h.reach.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot ball grasp onsets
subplot(3,1,3)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.grasp.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.grasp.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_back = sum(h.grasp.TWback.Values)*h.grasp.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.grasp.TWtri.Values)*h.grasp.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

clear SP_TW_tri SP_TW_back ballFixations_TW fixations_TW
%% plot slot fixation, transport, and slot entry for different patterns in tweezer trials
figure(movementOnsets*10)
xymax = 20;
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude slot-only
fixations_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
subplot(3,1,1)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.slot.TWslot = histogram(fixations_TW(fixations_TW(:,3) == 2,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.slot.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.slot.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_slot = sum(h.slot.TWslot.Values)*h.slot.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.slot.TWback.Values)*h.slot.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.slot.TWtri.Values)*h.slot.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot reach onsets
subplot(3,1,2)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWslot = histogram(fixations_TW(fixations_TW(:,3) == 2,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.reach.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.reach.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,movementOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_slot = sum(h.reach.TWslot.Values)*h.reach.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.reach.TWback.Values)*h.reach.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.reach.TWtri.Values)*h.reach.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

% plot slot grasp onsets
subplot(3,1,3)
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.grasp.TWslot = histogram(fixations_TW(fixations_TW(:,3) == 2,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(3,:));
h.grasp.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(5,:));
h.grasp.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,manipulationOnsets), 'BinWidth', .25,...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(4,:));
% calculate expected distribution
SP_TW_slot = sum(h.grasp.TWslot.Values)*h.grasp.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.grasp.TWback.Values)*h.grasp.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.grasp.TWtri.Values)*h.grasp.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% TO-DO ks tests

clear SP_TW_tri SP_TW_back slotFixations_TW fixations_TW

%% correlational plots for fingertips
figure(manipulationOnsets)
xymax = 5;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
ballFix_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);
slotFix_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

% make a scatter plot of fixation onset vs. kinematic phases
subplot(2,2,1)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('reach onset rel. to detected LC')
axis('square')
hold on
plot(ballFix_PG(ballFix_PG(:,3) == 4,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 4,movementOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_PG(ballFix_PG(:,3) == 3,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 3,movementOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,3)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('ball grasp rel. to detected LC')
axis('square')
hold on
plot(ballFix_PG(ballFix_PG(:,3) == 4,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_PG(ballFix_PG(:,3) == 3,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,2)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('transport onset rel. to detected LC')
axis('square')
hold on
plot(slotFix_PG(slotFix_PG(:,3) == 2,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 2,movementOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_PG(slotFix_PG(:,3) == 4,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 4,movementOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_PG(slotFix_PG(:,3) == 3,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 3,movementOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,4)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('slot entry rel. to detected LC')
axis('square')
hold on
plot(slotFix_PG(slotFix_PG(:,3) == 2,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 2,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_PG(slotFix_PG(:,3) == 4,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_PG(slotFix_PG(:,3) == 3,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

%% correlational plots for tweezers
figure(manipulationOnsets*10)
xymax = 5;
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
ballFix_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);
slotFix_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

% make a scatter plot of fixation onset vs. kinematic phases
subplot(2,2,1)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('reach onset rel. to detected LC')
axis('square')
hold on
plot(ballFix_TW(ballFix_TW(:,3) == 4,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 4,movementOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_TW(ballFix_TW(:,3) == 3,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 3,movementOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,3)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('ball grasp rel. to detected LC')
axis('square')
hold on
plot(ballFix_TW(ballFix_TW(:,3) == 4,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_TW(ballFix_TW(:,3) == 3,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,2)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('transport onset rel. to detected LC')
axis('square')
hold on
plot(slotFix_TW(slotFix_TW(:,3) == 2,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 2,movementOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_TW(slotFix_TW(:,3) == 4,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 4,movementOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_TW(slotFix_TW(:,3) == 3,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 3,movementOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')

subplot(2,2,4)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('slot entry rel. to detected LC')
axis('square')
hold on
plot(slotFix_TW(slotFix_TW(:,3) == 2,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 2,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_TW(slotFix_TW(:,3) == 4,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_TW(slotFix_TW(:,3) == 3,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')