
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
%%

changesPhases = [];
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
            reach = currentResult(n).info.timeStamp.reach;
            ballApproach = currentResult(n).info.timeStamp.ballApproach;
            grasp = currentResult(n).info.timeStamp.ballGrasp;
            transport = currentResult(n).info.timeStamp.transport;
            slotApproach = currentResult(n).info.timeStamp.slotApproach;
            slotEntry = currentResult(n).info.timeStamp.ballInSlot;
            returnOn = currentResult(n).info.timeStamp.return;
            trialEnd = currentResult(n).info.timeStamp.trialEnd;
            phase0 = 0;
            phase1 = 0;
            phase2 = 0;
            phase3 = 0;
            phase4 = 0;
            phase5 = 0;
            phase6 = 0;
            ohase7 = 0;
            
            if n < stopTrial
                nextReach = currentResult(n+1).info.timeStamp.reach;
            else
                nextReach = trialEnd;
            end
            
            for i = 1:length(currentResult(n).dualTask.tLetterChanges)
                if currentResult(n).dualTask.tLetterChanges(i) <= reach
                    phase0 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > reach && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= ballApproach
                    phase1 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > ballApproach && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= grasp
                    phase2 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > grasp && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= transport
                    phase3 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > transport && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= slotApproach
                    phase4 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > slotApproach && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= slotEntry
                    phase5 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > slotEntry && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= returnOn
                    phase6 = 1;
                elseif currentResult(n).dualTask.tLetterChanges(i) > returnOn && ...
                        currentResult(n).dualTask.tLetterChanges(i) <= nextReach
                    phase7 = 1;
                end
                currentPerformance(c+i-1,:) = [currentParticipant blockID ...
                    currentResult(n).dualTask.changeDetected(i) ...
                    phase0 phase1 phase2 phase3 phase4 phase5 phase6 phase7];
                c = c + 1;
            end
                          
        end
        
        changesPhases = [changesPhases; currentPerformance];
        clear currentPerformance
    end
end
clear c 
%%
letterChanges_PG = changesPhases(changesPhases(:,2) == 3, :);
detected_PG = letterChanges_PG(letterChanges_PG(:,3) == 1, :);
missed_PG = letterChanges_PG(letterChanges_PG(:,3) == 0, :);
PG_misses_relative = sum(missed_PG(:, 4:end));%./sum(letterChanges_PG(:, 4:end));

letterChanges_TW = changesPhases(changesPhases(:,2) == 4, :);
detected_TW = letterChanges_TW(letterChanges_TW(:,3) == 1, :);
missed_TW = letterChanges_TW(letterChanges_TW(:,3) == 0, :);
TW_misses_relative = sum(missed_TW(:, 4:end));%./sum(letterChanges_TW(:, 4:end));

barData = [PG_misses_relative' TW_misses_relative'];

figure(13)
set(gcf,'renderer','Painters')
hold on
xlim([0.5 8.5])
set(gca, 'Xtick', [1 2 3 4 5 6 7 8], 'Xticklabel', ...
    {'reach', 'ball approach', 'grasp', 'transport', ...
    'slot approach', 'slot', 'return', 'ITI'})
b = bar(barData);
box off
b(1).FaceColor = 'none';
b(1).EdgeColor = 'k';
b(2).FaceColor = 'k';
b(2).FaceAlpha = 0.5;
b(2).EdgeColor = 'none';
legend('fingertips', 'tweezers')

%% histograms of different fixatin durations in different functional zones
selectedColumn = 7; % 7: fixReachDuration; 8: fixBallDuration; 9: fixTransportDuration
upperBound = 1000;
ymax = 40;
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
fixations = ballFixFunctions(ballFixFunctions(:,selectedColumn) ~= 0,:);
histogram(fixations(fixations(:,2) == 4, selectedColumn), 'BinWidth', 50, ...
    'facecolor', lightGrey, 'edgecolor', 'none')
histogram(fixations(fixations(:,2) == 3, selectedColumn), 'BinWidth', 50, ...
    'facecolor', darkGrey, 'edgecolor', 'none')
xlim([0 upperBound])
set(gca, 'Xtick', [0 200 400 600 800 1000])
ylim([0 ymax])
set(gca, 'Ytick', [0 10 20 30 40])
box off
%title('reach fixations')
%title('ball approach & grasp fixations')
title('transport fixations')
%%
selectedColumn = 7; % 7: fixTransportDuration; 8: fixSlotDuration; 9: fixReturnDuration
upperBound = 1000;
ymax = 40;
figure(selectedColumn*10)
set(gcf,'renderer','Painters')
hold on
fixations = slotFixFunctions(slotFixFunctions(:,selectedColumn) ~= 0,:);
histogram(fixations(fixations(:,2) == 4, selectedColumn), 'BinWidth', 50, ...
    'facecolor', lightGrey, 'edgecolor', 'none')
histogram(fixations(fixations(:,2) == 3, selectedColumn), 'BinWidth', 50, ...
    'facecolor', darkGrey, 'edgecolor', 'none')
xlim([0 upperBound])
set(gca, 'Xtick', [0 200 400 600 800 1000])
ylim([0 ymax])
set(gca, 'Ytick', [0 10 20 30 40])
box off
%title('transport fixations')
%title('slot approach & slot fixations')
title('return fixations')
