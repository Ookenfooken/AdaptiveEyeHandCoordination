% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);


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
ballOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,:);
ballOnset_early = ballOnsetPG( ballOnsetPG(:,end-1) ==1 ,selectedColumn);
ballOnset_late = ballOnsetPG( ballOnsetPG(:,end) ==1 ,selectedColumn);
%ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
histogram(ballOnsetPG(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', lightGrey)
histogram(ballOnset_early, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(ballOnset_late, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
%histogram(ballOffsetPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
%%
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
slotOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,:);
slotOnset_early = slotOnsetPG( slotOnsetPG(:,end-1) ==1 ,selectedColumn);
slotOnset_late = slotOnsetPG( slotOnsetPG(:,end) ==1 ,selectedColumn);
%ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,selectedColumn+1);
figure(selectedColumn)
set(gcf,'renderer','Painters')
hold on
histogram(slotOnsetPG(:,selectedColumn), 'BinWidth', .25, 'facecolor', 'none', 'edgecolor', lightGrey)
histogram(slotOnset_early, 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(slotOnset_late, 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
%histogram(ballOffsetPG, 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none')
ymax = 25;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
%%
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
ballOnset_early = ballOnsetTW( ballOnsetTW(:,end-1) ==1 ,:);
ballOnset_late = ballOnsetTW( ballOnsetTW(:,end) ==1 ,:);
%ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 3;
figure(fixationPattern)
set(gcf,'renderer','Painters')
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(ballOnset_early(ballOnset_early(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(ballOnset_late(ballOnset_late(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
fixationPattern = 4;
figure(fixationPattern)
set(gcf,'renderer','Painters')
hold on
histogram(ballOnsetTW(ballOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(ballOnset_early(ballOnset_early(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(ballOnset_late(ballOnset_late(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% add fixation types for tweezers for the slot fixations
balFixations_TW = eventsRelativeLetter( eventsRelativeLetter(:,2) == 4,:);
selectedColumn = 9;
slotOnsetTW = balFixations_TW( balFixations_TW(:,selectedColumn) > lowerBound & balFixations_TW(:,selectedColumn) < upperBound ,:);
slotOnset_early = slotOnsetTW( slotOnsetTW(:,end-1) ==1 ,:);
slotOnset_late = slotOnsetTW( slotOnsetTW(:,end) ==1 ,:);
%ballOffsetTW = balFixations_TW( balFixations_TW(:,selectedColumn+1) > lowerBound & balFixations_TW(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 3;
figure(fixationPattern*10)
set(gcf,'renderer','Painters')
hold on
histogram(slotOnsetTW(slotOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(slotOnset_early(slotOnset_early(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(slotOnset_late(slotOnset_late(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)
fixationPattern = 4;
figure(fixationPattern*10)
set(gcf,'renderer','Painters')
hold on
histogram(slotOnsetTW(slotOnsetTW(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(slotOnset_early(slotOnset_early(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(slotOnset_late(slotOnset_late(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
histogram(slotOnsetTW(slotOnsetTW(:,3) == 2,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(2+1,:))
% histogram(ballOffsetTW(ballOffsetTW(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% add fixation types for fingertips for the slot fixations
balFixations_PG = eventsRelativeLetter( eventsRelativeLetter(:,2) == 3,:);
selectedColumn = 9;
slotOnsetPG = balFixations_PG( balFixations_PG(:,selectedColumn) > lowerBound & balFixations_PG(:,selectedColumn) < upperBound ,:);
slotOnset_early = slotOnsetPG( slotOnsetPG(:,end-1) ==1 ,:);
slotOnset_late = slotOnsetPG( slotOnsetPG(:,end) ==1 ,:);
%ballOffsetPG = balFixations_PG( balFixations_PG(:,selectedColumn+1) > lowerBound & balFixations_PG(:,selectedColumn+1) < upperBound ,:);
fixationPattern = 2;
figure(fixationPattern*10)
set(gcf,'renderer','Painters')
hold on
histogram(slotOnsetPG(slotOnsetPG(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', 'none', 'edgecolor', fixationPatternColors(fixationPattern+1,:))
histogram(slotOnset_early(slotOnset_early(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightBlue, 'edgecolor', 'none')
histogram(slotOnset_late(slotOnset_late(:,3) == fixationPattern,selectedColumn), 'BinWidth', .25, ...
    'facecolor', lightRed, 'edgecolor', 'none')
% histogram(ballOffsetPG(ballOffsetPG(:,3) == fixationPattern,selectedColumn+1), 'BinWidth', .25, ...
%     'facecolor', fixationPatternColors(fixationPattern+1,:), 'edgecolor', 'none')
ymax = 40;
xlim([0 upperBound])
ylim([0 ymax])
line([0 0], [0 ymax], 'Color', lightGrey)
line([1.5 1.5], [0 ymax], 'Color', lightGrey)

%% display fixation probability relative to letter change (previous Fig 5
%% plot fixation probability relative time of letter change
preLetterChange = 100;
postLetterChange = 300;
fixationRateDisplay = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        fixationVectorDisplay = NaN(numTrials,preLetterChange+postLetterChange);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if currentResult(n).info.cuedSlot == 1
                slotPosition = [-1.9 5.2];
            elseif currentResult(n).info.cuedSlot == 2
                slotPosition = [-1.9 8.2];
            elseif currentResult(n).info.cuedSlot == 3
                slotPosition = [-1.9 11.2];
            end
            criticalLocations = [0 0; ... % ball centre
                slotPosition; % selected slot
                13.63 16.68]; % visual display
            startTime = currentResult(n).info.trialStart;
            letterChange = currentResult(n).dualTask.sampleLetterChange(1)-startTime;           
            if isnan(letterChange) || currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.trialEnd 
                continue
            end
            % determine fixation vector
            relativeOnset = 1;
            if letterChange < preLetterChange
                relativeOnset = preLetterChange - letterChange;
            end
            relativeOffset = preLetterChange+postLetterChange;
            if relativeOffset > length(currentResult(n).gaze.Xinterpolated)
                relativeOffset = length(currentResult(n).gaze.Xinterpolated);
            end
            fixationVectorDisplay(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            gazeXinterpolated = currentResult(n).gaze.Xinterpolated;
            gazeYinterpolated = currentResult(n).gaze.Yinterpolated;
            distancesGaze = NaN(length(criticalLocations), length(gazeXinterpolated));
            for m = 1:length(criticalLocations)
                for sample = 1:length(gazeXinterpolated)
                    distancesGaze(m,sample) = sqrt((gazeXinterpolated(sample) - criticalLocations(m,1)).^2 ...
                        +  (gazeYinterpolated(sample) - criticalLocations(m,2)).^2);
                end
            end
            gazeVelocity = [diff(sqrt(gazeXinterpolated.^2 + gazeYinterpolated.^2)); NaN];
            fixations = abs(gazeVelocity) < 0.05;
            fixationDetect = [fixations; NaN] - [NaN; fixations];
            fixationOnsets = find(fixationDetect == 1) + 3;
            fixationOffsets = find(fixationDetect == -1) -4;
            if numel(fixationOnsets) > 0 && numel(fixationOffsets) > 0
                if fixations(1) == 1
                    fixationOnsets = [1; fixationOnsets];
                end
                if fixations(end) == 1
                    fixationOffsets = [fixationOffsets length(fixations)];
                end
                if fixationOffsets(1) < fixationOnsets(1)
                    fixationOnsets(1) = [];
                    fixationOffsets(1) = [];
                end
                for fix = 1:length(fixationOnsets)
                   if fixationOffsets(fix) - fixationOnsets(fix) < 20
                        continue
                   end
                    fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-letterChange)]);
                    fixOffset = min([preLetterChange+(fixationOffsets(fix)-letterChange) length(fixationVectorDisplay)]);
                    minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                    fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                    if fixationOn == 3 % indicates fixation on display
                        fixationVectorDisplay(n,fixOnset:fixOffset) = 1;
                    end
                end
            end
        end
        currentFixationRateDisplay = [j i nanmean(fixationVectorDisplay)];
        fixationRateDisplay= [fixationRateDisplay; currentFixationRateDisplay];
        clear criticalLocations fixationDetect fixationOnsets fixationOffsets 
        clear minimalDistance gazeVelocity gazeXinterpolated gazeYinterpolated
        clear distancesGaze fixationOn startTime slotPosition currentFixationRateDisplay 
        clear relativeOnset relativeOffset
    end
end

%% draw plot (Panel C)
blue = [49,130,189]./255;
grey = [150,150,150]./255;
orange = [255,127,0]./255;
xLength = preLetterChange+ postLetterChange;
% plot display abd ball fixation rate and reach probability for fingertips
figure(11)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', grey, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineStyle', '--', 'LineWidth', 2)

%% orange and grey figure from V3
%% plot movement events and time of letter change relative to time of grasp
histogramFixations = [];
cumulativeReach = [];
vectorLength = 600;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = blockID*ones(numTrials,1);
        ballGrasp = NaN(numTrials,1);
        ballOnset = NaN(numTrials,1);
        trialEnd = NaN(numTrials,1);
        reachOnset = NaN(numTrials,vectorLength);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballGrasp(n) = currentResult(n).info.phaseStart.ballGrasp; 
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballOnset(n) = currentResult(n).gaze.fixation.onsetsBall(1) + currentResult(n).info.trialStart;
            end
            reachToGrasp = currentResult(n).info.phaseStart.ballGrasp-currentResult(n).info.phaseStart.primaryReach;
            if reachToGrasp > vectorLength
                continue
            end
            trialEnd(n) = currentResult(n).info.trialEnd;
            reachOnset(n,:) = [zeros(1,vectorLength-reachToGrasp) ones(1,reachToGrasp)];
        end
        currentVariable = [testID ballGrasp ...
                           ballOnset trialEnd];
        cumulativeReach = [cumulativeReach; [blockID nansum(reachOnset)]];
        histogramFixations = [histogramFixations; currentVariable];
        clear startTime trialLength
    end
end

histogramLetterChanges = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        c = 1;
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            startTime = currentResult(n).info.trialStart;
            letterChange = currentResult(n).dualTask.sampleLetterChange;
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            ballGrasp = currentResult(n).info.phaseStart.ballGrasp; 
            letterChangeVector(c,:) = [blockID*ones(length(c),1) ...
                ballGrasp*ones(length(c),1) currentResult(n).dualTask.sampleLetterChange'];
            c = c(end) + 1;
        end
        
        histogramLetterChanges = [histogramLetterChanges; letterChangeVector];
        clear startTime trialLength letterChangeVector
    end
end

%%
stepWidth = .25;
figure(13)
set(gcf,'renderer','Painters')
hold on
box off
xlim([-2 1.5])
set(gca, 'Xtick', [-2 -1.5 -1 -.5 0 .5 1 1.5])
ylim([0 140])
figure(14)
set(gcf,'renderer','Painters')
hold on
box off
xlim([-2 1.5])
set(gca, 'Xtick', [-2 -1.5 -1 -.5 0 .5 1 1.5])
ylim([0 140])
ksTestData = [];
for j= 3:4
    letterChangeRelativeGrasp = (histogramLetterChanges(histogramLetterChanges(:,1) == j,3) - ...
        histogramLetterChanges(histogramLetterChanges(:,1) == j,2))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeGrasp) - 3*nanstd(letterChangeRelativeGrasp);
    upperBound = nanmean(letterChangeRelativeGrasp) + 3*nanstd(letterChangeRelativeGrasp);
    letterChangeRelativeGrasp(letterChangeRelativeGrasp < lowerBound) = [];
    letterChangeRelativeGrasp(letterChangeRelativeGrasp > upperBound) = [];
    ballOnsetRelativelGrasp = (histogramFixations(histogramFixations(:,1) == j,3) - ...
        histogramFixations(histogramFixations(:,1) == j,2))/200; % in seconds
    lowerBound = nanmean(ballOnsetRelativelGrasp) - 3*nanstd(ballOnsetRelativelGrasp);
    upperBound = nanmean(ballOnsetRelativelGrasp) + 3*nanstd(ballOnsetRelativelGrasp);
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp < lowerBound) = [];
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp > upperBound) = [];
    if j == 3
        figure(13)
        histogram(letterChangeRelativeGrasp, 'BinWidth', stepWidth, 'facecolor', grey, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', stepWidth, 'facecolor', orange, 'edgecolor', 'none')
        letterChangeDistribution_FT = cumsum(letterChangeRelativeGrasp);
    else
        figure(14)
        histogram(letterChangeRelativeGrasp, 'BinWidth', stepWidth, 'facecolor', grey, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', stepWidth, 'facecolor', orange, 'edgecolor', 'none')
        letterChangeDistribution_TW = cumsum(letterChangeRelativeGrasp);
    end
    clear lowerBound upperBound letterChangeRelativeGrasp ballOnsetRelativelGrasp slotOnsetRelativeGrasp
end
%% add trial counts for PG and TW
% create vector with trials in which a letter change earlier than xx
% samples could not have happened (grasp was earlier) and after xx samples
% letter change could not have happened (trial end)
%cutOffVector = [400 300 200 100 0 100 200]; --> for larger bin size
cutOffVector = [400 350 300 250 200 150 100 50 0 50 100 150 200 250];
trialCount = NaN(1, length(cutOffVector));
xVector = -1.875:stepWidth:1.4; %-1.75:stepWidth:1.25;
trialRatio = stepWidth/4;
for j = 3:4
    graspTimes = histogramFixations(histogramFixations(:,1) == j,2);
    graspToEnd = histogramFixations(histogramFixations(:,1) == j,end) - histogramFixations(histogramFixations(:,1) == j,2);
    for i = 1:length(cutOffVector)
        if i < length(cutOffVector)/2+2
            trialCount(1,i) = sum(graspTimes > cutOffVector(i));
        else
            trialCount(1,i) = sum(graspToEnd > cutOffVector(i));
        end
    end
    if j == 3
        figure(13)
        b = bar(xVector, trialCount*trialRatio);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
        [h,p_FT, ks2stat_FT] = kstest2(letterChangeDistribution_FT, cumsum(trialCount*trialRatio));
    else
        figure(14)
        b = bar(xVector, trialCount*trialRatio);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
        [h,p_TW, ks2stat_TW] = kstest2(letterChangeDistribution_TW, cumsum(trialCount*trialRatio));
    end
end

%% add cumulative curves and lines
phaseToGraspAll = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
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
            reachToGrasp = currentResult(n).info.phaseStart.primaryReach - ...
                currentResult(n).info.phaseStart.ballGrasp;
            phaseToGraspAll = [phaseToGraspAll; [blockID reachToGrasp]];
        end
    end
    clear reachToGrasp
end

for j = 3:4
    xVector_reach = -3:.005:-0.0009;
    if j == 3
        figure(13)
    else
        figure(14)
    end
    plot(xVector_reach,(sum(cumulativeReach(cumulativeReach(:,1) == j, 2:end))/...
        sum(cumulativeReach(cumulativeReach(:,1) == j,end))*100), 'k', 'LineWidth', 1.5)
    % optional: add line at median position
%     line([nanmedian(phaseToGraspAll(phaseToGraspAll(:,1) == j, 2))/200 ...
%           nanmedian(phaseToGraspAll(phaseToGraspAll(:,1) == j, 2))/200],...
%         [0 180], 'Color', 'k', 'LineStyle', '--')
end
