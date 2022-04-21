% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%%
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
            ballOnset(n)
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

%% plot frequency of letter changes in a trial for fintertips and tweezers (Panel A)
letterChangeNo = NaN(2, 4);
for j = 1:2 % hand and tweezer
    currentData = letterChanges(letterChanges(:,2) == j+2, :);
    currentData = currentData(~isnan(currentData(:,3)),:);
    allTrials = size(currentData,1);
    for blockID = 1:4
        letterChangeNo(j,blockID) = length(currentData(currentData(:,3) == blockID-1,:))/allTrials;
    end
    clear allTrials    
end
figure(123)
hold on
xlim([.5 4.5])
set(gca, 'Xtick', [1 2 3 4], 'XtickLabel', {'0 letter changes', '1 letter change', '2 letter changes', '3 letter changes'})
ylim([0 .75])
set(gca, 'Ytick', [0 .25 .5 .75])

for blockID = 1:4
    plot(blockID, letterChangeNo(1,blockID), 'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
    plot(blockID, letterChangeNo(2,blockID), 'o', 'MarkerFaceColor', 'none','MarkerEdgeColor', 'k')
end
line([1 2], [letterChangeNo(1,1) letterChangeNo(1,2)], 'Color', 'k')
line([2 3], [letterChangeNo(1,2) letterChangeNo(1,3)], 'Color', 'k')
line([3 4], [letterChangeNo(1,3) letterChangeNo(1,4)], 'Color', 'k')
line([1 2], [letterChangeNo(2,1) letterChangeNo(2,2)], 'Color', 'k', 'LineStyle', '--')
line([2 3], [letterChangeNo(2,2) letterChangeNo(2,3)], 'Color', 'k', 'LineStyle', '--')
line([3 4], [letterChangeNo(2,3) letterChangeNo(2,4)], 'Color', 'k', 'LineStyle', '--')

%% readout vigilance task performance
dualTaskPerformance = [];
dualTaskSamples = [];
cAll = 1;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over blocks/experimental conditions
        c = 1;
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        stopTrial = min([numTrials 30]);
        numTrials = length(currentResult);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            cAll = cAll:cAll+length(currentResult(n).dualTask.tLetterChanges)-1;
            changeDetected(c) = currentResult(n).dualTask.changeDetected;
            changeMissed(c) = currentResult(n).dualTask.changeMissed;
                        
            c = c(end) + 1;
            cAll = cAll(end) + 1;
        end
        currentPerformance = [currentParticipant blockID c-1 sum(changeDetected) sum(changeMissed)];
        
        dualTaskPerformance = [dualTaskPerformance; currentPerformance];
        clear letterChangePhase changeDetected changeMissed currentPerformance
    end
end
clear c cAll
%% plot vigilance performance vs. relative time on display (Panel B)
letterDetectViewTime = NaN(numParticipants,3);
for i = 1:numParticipants
    currentDataset = letterChanges(letterChanges(:,1) == i, :);
    relativeTime = currentDataset(:,6);
    letterDetectViewTime(i,:) = [i nanmean(relativeTime) ...
        sum(dualTaskPerformance(dualTaskPerformance(:,1) == i,4))/sum(dualTaskPerformance(dualTaskPerformance(:,1) == i,3))];
end
figure(5)
hold on
plot(letterDetectViewTime(:,2), letterDetectViewTime(:, 3),...
    'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
%%
letterDetectViewTime = NaN(numParticipants*2,4);
count = 1;
for j= 3:4
    currentTool = letterChanges(letterChanges(:,2) == j, :);
    currentVigilance = dualTaskPerformance(dualTaskPerformance(:,2) == j,:);
    for i = 1:numParticipants
        currentDataset = currentTool(currentTool(:,1) == i, :);
        relativeTime = currentDataset(:,6);
        letterDetectViewTime(count,:) = [i j nanmean(relativeTime) ...
            currentVigilance(currentVigilance(:,1) == i,4)/currentVigilance(currentVigilance(:,1) == i,3)];
        count = count+1;
    end
end
clear count
figure(5)
hold on
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3), letterDetectViewTime(letterDetectViewTime(:,2) == 3, 4),...
    'o', 'MarkerFaceColor', 'k','MarkerEdgeColor', 'k')
% remove outlier
p_FT = polyfit(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3),letterDetectViewTime(letterDetectViewTime(:,2) == 3, 4),1);
y_FT = polyval(p_FT,letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3));
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 3, 3), y_FT, 'k-')
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3), letterDetectViewTime(letterDetectViewTime(:,2) == 4, 4),...
    'o', 'MarkerFaceColor', 'none','MarkerEdgeColor', 'k')
p_TW = polyfit(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3),letterDetectViewTime(letterDetectViewTime(:,2) == 4, 4),1);
y_TW = polyval(p_TW,letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3));
plot(letterDetectViewTime(letterDetectViewTime(:,2) == 4, 3), y_TW, 'k--')

ylim([0.5 1])
set(gca, 'Ytick', [.5 .75 1])
xlim([0.5 1])
set(gca, 'Xtick', [.5 .75 1])

cd(savePath)
save('letterDetectViewTime', 'letterDetectViewTime')
cd(analysisPath)
clear p_FT y_FT p_TW y_TW

%% plot display fixation probability relative to letter change (Panel D)
preLetterChange = 100;
postLetterChange = 300;
fixationRateDisplay = [];
fixationRateBall = [];
fixationRateSlot = [];
reachRate = [];
transportRate = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        fixationVectorDisplay = NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorBall= NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorSlot = NaN(numTrials,preLetterChange+postLetterChange);
        vectorReach = NaN(numTrials,preLetterChange+postLetterChange);
        vectorTrasnport = NaN(numTrials,preLetterChange+postLetterChange);
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
            fixationVectorBall(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            fixationVectorSlot(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
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
                    fixOffset = min([preLetterChange+(fixationOffsets(fix)-letterChange) length(fixationVectorBall)]);
                    minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                    fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                    if fixationOn == 3 % indicates fixation on display
                        fixationVectorDisplay(n,fixOnset:fixOffset) = 1;
                    elseif fixationOn == 1 % indicates fixation on ball
                        fixationVectorBall(n,fixOnset:fixOffset) = 1;
                    elseif fixationOn == 2 % indicates fixation on slot
                        fixationVectorSlot(n,fixOnset:fixOffset) = 1;
                    end
                end
            end
            % reach onset to offset
            reachOnset = currentResult(n).info.phaseStart.primaryReach - startTime;
            reachOffset = currentResult(n).info.phaseStart.ballApproach - startTime -1;
            reachOn = max([1 preLetterChange+(reachOnset-letterChange)]);
            reachOff = min([preLetterChange+(reachOffset-letterChange) length(vectorReach)]);
            if reachOff < 1
                continue
            end
            vectorReach(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            vectorReach(n,reachOn:reachOff) = 1;
            % transport onset to offset
            transportOnset = currentResult(n).info.phaseStart.transport - startTime;
            transportOffset = currentResult(n).info.phaseStart.slotApproach - startTime -1;
            transportOn = max([1 preLetterChange+(transportOnset-letterChange)]);
            transportOff = min([preLetterChange+(transportOffset-letterChange) length(vectorTrasnport)]);
            if transportOff < 1 || transportOn > transportOff
                continue
            end
            vectorTrasnport(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            vectorTrasnport(n,transportOn:transportOff) = 1;
        end
        currentFixationRateDisplay = [j i nanmean(fixationVectorDisplay)];
        currentFixationRateBall = [j i nanmean(fixationVectorBall)];
        currentFixationRateSlot = [j i nanmean(fixationVectorSlot)];
        currentReachOnset = [j i nanmean(vectorReach)];
        currentTransportOnset = [j i nanmean(vectorTrasnport)];
        fixationRateDisplay= [fixationRateDisplay; currentFixationRateDisplay];
        fixationRateBall = [fixationRateBall; currentFixationRateBall];
        fixationRateSlot = [fixationRateSlot; currentFixationRateSlot];
        reachRate = [reachRate; currentReachOnset];
        transportRate = [transportRate; currentTransportOnset];
        clear criticalLocations fixationDetect fixationOnsets fixationOffsets 
        clear minimalDistance gazeVelocity gazeXinterpolated gazeYinterpolated
        clear distanceGaze fixationOn startTime slotPosition reachOn reachOff
        clear currentFixationRateBall currentFixationRateDisplay currentReachOnset
        clear transportOn transportOff transportOnset transportOffset
        clear currentTransportOnset reachOnset reachOffset currentFixationRateSlot
    end
end

%%
blue = [49,130,189]./255;
orange = [255,127,0]./255;
green = [77,175,74]./255;
gray = [150,150,150]./255;
xLength = 400;

% plot display abd ball fixation rate and reach probability for fingertips
figure(11)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400 ], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 3, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(mean(reachRate(reachRate(:,2) == 3, 3:end-4)),'Color', 'k', 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
figure(12)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 4, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(mean(reachRate(reachRate(:,2) == 4, 3:end-4)),'Color', 'k', 'LineWidth', 2)

% plot display abd slot fixation rate and transport probability for fingertips
figure(13)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateSlot(fixationRateSlot(:,2) == 3, 3:end-4)),'Color', green, 'LineWidth', 2)
plot(mean(transportRate(transportRate(:,2) == 3, 3:end-4)),'Color', 'k', 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
figure(14)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateSlot(fixationRateSlot(:,2) == 4, 3:end-4)),'Color', green, 'LineWidth', 2)
plot(mean(transportRate(transportRate(:,2) == 4, 3:end-4)),'Color', 'k', 'LineWidth', 2)