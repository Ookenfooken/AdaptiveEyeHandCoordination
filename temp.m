%% Histograms in Panel E&F
ballFixRelativeLetter = [];
numParticipants = 11;

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        letterChangeRelativeBallFix = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
            else
                continue
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
            if detectedChange <= fixBallOnset
                letterChangeRelativeBallFix(n) = fixBallOnset - detectedChange ;
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeRelativeBallFix(n) = fixBallOnset - detectedChanges(end);
                else
                    continue
                end
            end            
        end

        currentVariable = [blockID*ones(numTrials,1) ...
            letterChangeRelativeBallFix];

        ballFixRelativeLetter = [ballFixRelativeLetter; currentVariable];
    end
end

%% plot reach onset relative to letter change for PG and TW
orange = [255,127,0]./255;

fixations_TW_all = ballFixRelativeLetter( ballFixRelativeLetter(:,1) == 4,:);
fixations_TW_detected = fixations_TW_all(~isnan(fixations_TW_all(:,1)),:);
[p_TW, ks2statTW] = kstest(fixations_TW_detected(:,2));

ballFix_TW = fixations_TW_detected(fixations_TW_detected(:,selectedColumn) < upperBound, selectedColumn);
selectedColumn = 2; % reach onset
upperBound = 6.5;

figure(selectedColumn*10)
set(gcf,'renderer','Painters')
histogram(ballFix_TW, 'BinWidth', .25, 'facecolor', orange, 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 50])
box off

%% Histograms in Panel E&F
slotFixRelativeLetter = [];
numParticipants = 11;

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        letterChangeRelativeSlotFix = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
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
            if detectedChange <= fixSlotOnset
                letterChangeRelativeSlotFix(n) = fixSlotOnset - detectedChange ;
            else % otherwise use the previous trial
                if n > 1 && sum(currentResult(n-1).dualTask.changeDetected) > 0
                    detectedChanges = currentResult(n-1).dualTask.tLetterChanges(currentResult(n-1).dualTask.changeDetected);
                    letterChangeRelativeSlotFix(n) = fixSlotOnset - detectedChanges(end);
                else
                    continue
                end
            end            
        end

        currentVariable = [blockID*ones(numTrials,1) ...
            letterChangeRelativeSlotFix];

        slotFixRelativeLetter = [slotFixRelativeLetter; currentVariable];
    end
end

%%
green = [77,175,74]./255;

fixations_PG_all = slotFixRelativeLetter( slotFixRelativeLetter(:,1) == 3,:);
fixations_PG_detected = fixations_PG_all(~isnan(fixations_PG_all(:,2)),:);
[p_PG, ks2statPG] = kstest(fixations_PG_detected(:,2));
slotFix_PG = fixations_PG_detected(fixations_PG_detected(:,selectedColumn) < upperBound, selectedColumn);
figure(selectedColumn)
set(gcf,'renderer','Painters')
histogram(slotFix_PG, 'BinWidth', .25, 'facecolor', green, 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 20])
box off