%% plot display fixation probability relative to letter change (Panel D)
preLetterChange = 200;
postLetterChange = 300;
fixationRateDisplay = [];
fixationRateDisplayLate = [];
fixationRateBall = [];
fixationRateSlot = [];
reachRate = [];
transportRate = [];
cumTrialCount = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        fixationVectorDisplay = NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorDisplayLate = NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorBall= NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorSlot = NaN(numTrials,preLetterChange+postLetterChange);
        vectorReach = NaN(numTrials,preLetterChange+postLetterChange);
        vectorTrasnport = NaN(numTrials,preLetterChange+postLetterChange);
        trialCount = 0;
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
            firstLetterChange = currentResult(n).dualTask.sampleLetterChange(1)-startTime;
            if isnan(firstLetterChange) || currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.trialEnd
                continue
            end
            % if letter change before grasp plot ball fixations
            if currentResult(n).dualTask.sampleLetterChange(1) < currentResult(n).info.phaseStart.ballGrasp
                % determine fixation vector
                trialCount = trialCount + 1;
                relativeOnset = 1;
                if firstLetterChange < preLetterChange
                    relativeOnset = preLetterChange - firstLetterChange;
                end
                relativeOffset = preLetterChange+postLetterChange;
                if relativeOffset > length(currentResult(n).gaze.Xinterpolated)
                    relativeOffset = length(currentResult(n).gaze.Xinterpolated);
                end
                fixationVectorDisplay(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
                fixationVectorBall(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
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
                        fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-firstLetterChange)]);
                        fixOffset = min([preLetterChange+(fixationOffsets(fix)-firstLetterChange) length(fixationVectorBall)]);
                        minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                        fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                        if fixationOn == 3 % indicates fixation on display
                            fixationVectorDisplay(n,fixOnset:fixOffset) = 1;
                        elseif fixationOn == 1 % indicates fixation on ball
                            fixationVectorBall(n,fixOnset:fixOffset) = 1;
                        end
                    end
                end
                % reach onset to offset
                ballGrasp = currentResult(n).info.phaseStart.primaryReach - startTime;
                reachOffset = length(vectorReach); %currentResult(n).info.phaseStart.ballApproach - startTime -1;
                reachOn = max([1 preLetterChange+(ballGrasp-firstLetterChange)]);
                reachOff = reachOffset; %min([preLetterChange+(reachOffset-letterChange) length(vectorReach)]);
                if reachOff < 1
                    continue
                end
                vectorReach(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
                vectorReach(n,reachOn:reachOff) = 1;
            elseif currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.phaseStart.primaryReach
                % determine fixation vector
                relativeOnset = 1;
                if firstLetterChange < preLetterChange
                    relativeOnset = preLetterChange - firstLetterChange;
                end
                relativeOffset = preLetterChange+postLetterChange;
                if relativeOffset > length(currentResult(n).gaze.Xinterpolated)
                    relativeOffset = length(currentResult(n).gaze.Xinterpolated);
                end
                fixationVectorDisplayLate(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
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
                        fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-firstLetterChange)]);
                        fixOffset = min([preLetterChange+(fixationOffsets(fix)-firstLetterChange) length(fixationVectorBall)]);
                        minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                        fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                        if fixationOn == 3 % indicates fixation on display
                            fixationVectorDisplayLate(n,fixOnset:fixOffset) = 1;
                        elseif fixationOn == 2 % indicates fixation on slot
                            fixationVectorSlot(n,fixOnset:fixOffset) = 1;
                        end
                    end
                end
                % transport onset to offset
                transportOnset = currentResult(n).info.phaseStart.transport - startTime;
                transportOffset = transportOnset+20; %currentResult(n).info.phaseStart.slotApproach - startTime -1;
                transportOn = max([1 preLetterChange+(transportOnset-firstLetterChange)]);
                transportOff = min([preLetterChange+(transportOffset-firstLetterChange) length(vectorTrasnport)]);
                if transportOff < 1 || transportOn > transportOff
                    continue
                end
                vectorTrasnport(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
                vectorTrasnport(n,transportOn:transportOff) = 1;
            end
        end
        currentFixationRateDisplayEarly = [j i nanmean(fixationVectorDisplay)];
        currentFixationRateDisplayLate = [j i nanmean(fixationVectorDisplayLate)];
        currentFixationRateBall = [j i nanmean(fixationVectorBall)];
        currentFixationRateSlot = [j i nanmean(fixationVectorSlot)];
        currentReachOnset = [j i nansum(vectorReach)];
        currentTransportOnset = [j i nanmean(vectorTrasnport)];
        fixationRateDisplay= [fixationRateDisplay; currentFixationRateDisplayEarly];
        fixationRateDisplayLate= [fixationRateDisplayLate; currentFixationRateDisplayLate];
        fixationRateBall = [fixationRateBall; currentFixationRateBall];
        fixationRateSlot = [fixationRateSlot; currentFixationRateSlot];
        reachRate = [reachRate; currentReachOnset];
        transportRate = [transportRate; currentTransportOnset];
        cumTrialCount = [cumTrialCount; j i trialCount];
        clear criticalLocations fixationDetect fixationOnsets fixationOffsets
        clear minimalDistance gazeVelocity gazeXinterpolated gazeYinterpolated
        clear distanceGaze fixationOn startTime slotPosition reachOn reachOff
        clear currentFixationRateBall currentFixationRateDisplay currentReachOnset
        clear transportOn transportOff transportOnset transportOffset
        clear currentTransportOnset ballGrasp reachOffset currentFixationRateSlot
    end
end

%%
blue = [49,130,189]./255;
orange = [255,127,0]./255;
green = [77,175,74]./255;
gray = [150,150,150]./255;
xLength = 500;

% plot display abd ball fixation rate and reach probability for fingertips
figure(11)
hold on
xlim([100 xLength])
set(gca, 'Xtick', [100 200 300 400 500], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 3, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(sum(reachRate(reachRate(:,2) == 3, 3:end-4))/sum(cumTrialCount(cumTrialCount(:,2) == 3, end)),'Color', 'k', 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
figure(12)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400 500], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 4, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(sum(reachRate(reachRate(:,2) == 4, 3:end-4))/sum(cumTrialCount(cumTrialCount(:,2) == 4, end)),'Color', 'k', 'LineWidth', 2)
%%
% plot display abd slot fixation rate and transport probability for fingertips
figure(13)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplayLate(fixationRateDisplayLate(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
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
plot(mean(fixationRateDisplayLate(fixationRateDisplayLate(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateSlot(fixationRateSlot(:,2) == 4, 3:end-4)),'Color', green, 'LineWidth', 2)
plot(mean(transportRate(transportRate(:,2) == 4, 3:end-4)),'Color', 'k', 'LineWidth', 2)
%%
lengthVector = 1400;
cumFirstLetterChange = [];
cumSecondLetterChange = [];
cumGoSignal = [];
cumReachOnsetEarly = [];
cumReachOnsetLate = [];
cumGraspOnset = [];
cumTrialEnd = [];
twoChangeTrials = [];
trialEndCount = [];
letterToReach = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        firstLetterChangeVector = NaN(numTrials,lengthVector);
        secondLetterChangeVector = NaN(numTrials,lengthVector);
        goSignalVector = NaN(numTrials,lengthVector);
        reachOnsetEarlyVector = NaN(numTrials,lengthVector);
        reachOnsetLateVector = NaN(numTrials,lengthVector);
        graspOnsetVector = NaN(numTrials,lengthVector);
        trialEndVector = NaN(numTrials,lengthVector);
        letterToReachCor = NaN(numTrials,5);
        twoChangeNo = 0;
        trialCount = 0;
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialCount = trialCount + 1;
            goSignalVector(n,:) = [zeros(1,currentResult(n).info.trialStart-1) ...
                ones(1,lengthVector-currentResult(n).info.trialStart+1)];
            if ~isnan(currentResult(n).dualTask.sampleLetterChange)
                firstLetterChangeVector(n,:) = [zeros(1,currentResult(n).dualTask.sampleLetterChange(1)-1) ...
                    ones(1,lengthVector-currentResult(n).dualTask.sampleLetterChange(1)+1)];
            end
            if numel(currentResult(n).dualTask.sampleLetterChange) > 1
                twoChangeNo = twoChangeNo + 1;
                if currentResult(n).dualTask.sampleLetterChange(2) < lengthVector
                    secondLetterChangeVector(n,:) = [zeros(1,currentResult(n).dualTask.sampleLetterChange(2)-1) ...
                        ones(1,lengthVector-currentResult(n).dualTask.sampleLetterChange(2)+1)];
                end
            end
            if currentResult(n).dualTask.sampleLetterChange(1) < currentResult(n).info.trialStart+1
                letterToReachCor(n,:) = [i j 1 currentResult(n).info.phaseStart.primaryReach currentResult(n).dualTask.sampleLetterChange(1)];
                reachOnsetEarlyVector(n,:) = [zeros(1,currentResult(n).info.phaseStart.primaryReach-1)...
                    ones(1,lengthVector-currentResult(n).info.phaseStart.primaryReach+1)];
            else
                letterToReachCor(n,:) = [i j 2 currentResult(n).info.phaseStart.primaryReach currentResult(n).dualTask.sampleLetterChange(1)];
                reachOnsetLateVector(n,:) = [zeros(1,currentResult(n).info.phaseStart.primaryReach-1)...
                    ones(1,lengthVector-currentResult(n).info.phaseStart.primaryReach+1)];
            end
            graspOnsetVector(n,:) = [zeros(1,currentResult(n).info.phaseStart.ballGrasp-1)...
                ones(1,lengthVector-currentResult(n).info.phaseStart.ballGrasp+1)];
            if currentResult(n).info.trialEnd < lengthVector
                trialEndVector(n,:) = [zeros(1,currentResult(n).info.trialEnd-1)...
                ones(1,lengthVector-currentResult(n).info.trialEnd+1)];
            end
        end
        cumFirstLetterChange = [cumFirstLetterChange; i nansum(firstLetterChangeVector)];
        cumSecondLetterChange = [cumSecondLetterChange; i nansum(secondLetterChangeVector)];
        cumGoSignal = [cumGoSignal; i nansum(goSignalVector)];
        cumReachOnsetEarly = [cumReachOnsetEarly; i nansum(reachOnsetEarlyVector)];
        cumReachOnsetLate = [cumReachOnsetLate; i nansum(reachOnsetLateVector)];
        cumGraspOnset = [cumGraspOnset; i nansum(graspOnsetVector)];
        cumTrialEnd = [cumTrialEnd; i nansum(trialEndVector)];
        twoChangeTrials = [twoChangeTrials; i twoChangeNo];
        trialEndCount = [trialEndCount; i trialCount];
        letterToReach = [letterToReach; letterToReachCor];
    end
end

%%
red = [228,26,28]./255;
purple = [152,78,163]./255;
green = [77,175,74]./255;
orange = [255,127,0]./255;
gray = [150,150,150]./255;

for j = 3:4
    figure(30 + j)
    hold on
    plot(sum(cumFirstLetterChange(cumFirstLetterChange(:,1) == j, 2:end))/sum(cumFirstLetterChange(cumFirstLetterChange(:,1) == j, end)), ...
        'Color', red, 'LineWidth', 1.5)
    plot(sum(cumSecondLetterChange(cumSecondLetterChange(:,1) == j, 2:end))/sum(twoChangeTrials(twoChangeTrials(:,1) == j, end)), ...
        'Color', purple, 'LineWidth', 1.5)
    plot(sum(cumGoSignal(cumGoSignal(:,1) == j, 2:end))/sum(cumGoSignal(cumGoSignal(:,1) == j, end)), ...
        'Color', green, 'LineWidth', 1.5)
    plot(sum(cumReachOnsetEarly(cumReachOnsetEarly(:,1) == j, 2:end))/sum(cumReachOnsetEarly(cumReachOnsetEarly(:,1) == j, end)), ...
        'Color', 'k', 'LineWidth', 1.5)
    plot(sum(cumGraspOnset(cumGraspOnset(:,1) == j, 2:end))/sum(cumGraspOnset(cumGraspOnset(:,1) == j, end)), ...
        'Color', orange, 'LineWidth', 1.5)
    plot(sum(cumTrialEnd(cumTrialEnd(:,1) == j, 2:end))/sum(trialEndCount(trialEndCount(:,1) == j, end)), ...
        'Color', gray, 'LineWidth', 1.5)
    set(gca, 'Xtick', [0 200 400 600 800 1000 1200 1400], 'XtickLabel', [0 1 2 3 4 5 6 7])
    lgd = legend('first letter change', 'second letter change', 'go signal', 'reach onset', 'ball grasp', 'trial end');
    lgd.Location = 'southeast';
end

%%
for j = 3:4
    figure(40 + j)
    hold on    
    plot(sum(cumReachOnsetEarly(cumReachOnsetEarly(:,1) == j, 2:end))/sum(cumReachOnsetEarly(cumReachOnsetEarly(:,1) == j, end)), ...
        'Color', 'k', 'LineWidth', 1.5)
    plot(sum(cumReachOnsetLate(cumReachOnsetLate(:,1) == j, 2:end))/sum(cumReachOnsetLate(cumReachOnsetLate(:,1) == j, end)), ...
        'Color', gray, 'LineWidth', 1.5)
    xlim([0 800])
    set(gca, 'Xtick', [0 200 400 600 800], 'XtickLabel', [0 1 2 3 4])
    lgd = legend('letter change before go signal', 'letter change after go signal');
    lgd.Location = 'southeast';
end

%%
blue = [49,130,189]./255;
orange = [255,127,0]./255;
green = [77,175,74]./255;
gray = [150,150,150]./255;
xLength = 500;

% plot display abd ball fixation rate and reach probability for fingertips
figure(11)
hold on
xlim([100 xLength])
set(gca, 'Xtick', [100 200 300 400 500], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 3, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(sum(reachRate(reachRate(:,2) == 3, 3:end-4))/sum(cumTrialCount(cumTrialCount(:,2) == 3, end)),'Color', 'k', 'LineWidth', 2)

% plot display abd ball fixation rate and reach probability for tweezers
figure(12)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400 500], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplay(fixationRateDisplay(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateBall(fixationRateBall(:,2) == 4, 3:end-4)),'Color', orange, 'LineWidth', 2)
plot(sum(reachRate(reachRate(:,2) == 4, 3:end-4))/sum(cumTrialCount(cumTrialCount(:,2) == 4, end)),'Color', 'k', 'LineWidth', 2)
%%
% plot display abd slot fixation rate and transport probability for fingertips
figure(13)
hold on
xlim([0 xLength])
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplayLate(fixationRateDisplayLate(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
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
plot(mean(fixationRateDisplayLate(fixationRateDisplayLate(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
plot(mean(fixationRateSlot(fixationRateSlot(:,2) == 4, 3:end-4)),'Color', green, 'LineWidth', 2)
plot(mean(transportRate(transportRate(:,2) == 4, 3:end-4)),'Color', 'k', 'LineWidth', 2)

%% plot frequency of first letter change relative to stuff
%%
numParticipants = 11;
histogramData = [];
cumulativeReach = [];
vectorLength = 600;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        subject = currentParticipant*ones(numTrials, 1);
        testID = blockID*ones(numTrials,1);
        firstLetterChange = NaN(numTrials,1);
        numLetterChange = NaN(numTrials,1);
        ballGrasp = NaN(numTrials,1);
        ballOnset = NaN(numTrials,1);
        slotOnset = NaN(numTrials,1);
        trialEnd = NaN(numTrials,1);
        reachOnset = NaN(numTrials,vectorLength);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            startTime = currentResult(n).info.trialStart;
            firstLetterChange(n) = currentResult(n).dualTask.sampleLetterChange(1);
            if isnan(currentResult(n).dualTask.sampleLetterChange)
                numLetterChange(n) = 0;
            else
                numLetterChange(n) = numel(currentResult(n).dualTask.sampleLetterChange);
            end
            ballGrasp(n) = currentResult(n).info.phaseStart.ballGrasp; 
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballOnset(n) = currentResult(n).gaze.fixation.onsetsBall(1) + currentResult(n).info.trialStart;
            end
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                slotOnset(n) = currentResult(n).gaze.fixation.onsetsSlot(1) + currentResult(n).info.trialStart;
            end  
            reachToGrasp = currentResult(n).info.phaseStart.ballGrasp-currentResult(n).info.phaseStart.primaryReach;
            if reachToGrasp > vectorLength
                continue
            end
            reachOnset(n,:) = [zeros(1,vectorLength-reachToGrasp) ones(1,reachToGrasp)];
            trialEnd(n) = currentResult(n).info.trialEnd;
        end
        currentVariable = [subject testID numLetterChange firstLetterChange ...
                           ballGrasp ballOnset slotOnset trialEnd];
        cumulativeReach = [cumulativeReach; [blockID nansum(reachOnset)]];
        histogramData = [histogramData; currentVariable];
        clear startTime trialLength
    end
end

randomGrasp = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = blockID*ones(numTrials,1);
        firstLetterChange = NaN(numTrials,1);
        currentGrasp = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            firstLetterChange(n) = currentResult(n).dualTask.sampleLetterChange(1);
            currentGrasp(n) = normrnd(nanmean(histogramData(:,5)),nanstd(histogramData(:,5)));
        end
        randomGrasp = [randomGrasp; [testID firstLetterChange currentGrasp]];
    end
end
 
%% count trials for PG and TW
count = 1;
j = 3;
cutOffVector = [500 400 300 200 100 0 100 200 300 400];
graspTimes = histogramData(histogramData(:,2) == j,5);
graspToEnd = histogramData(histogramData(:,2) == j,end) - histogramData(histogramData(:,2) == j,5);
for i = 1:10
    minGrasp = min(graspTimes);
    if i < 6
        trialCount(count) = sum(graspTimes > cutOffVector(i));        
    else
        trialCount(count) = sum(graspToEnd > cutOffVector(i)); 
    end
    count = count + 1;
end

%%
figure(13)
set(gcf,'renderer','Painters', 'Position', [250 200 400 500])
hold on
box off
xlim([-2 2])
ylim([0 180])
figure(14)
set(gcf,'renderer','Painters', 'Position', [700 200 500 500])
hold on
box off
xlim([-2.5 2.5])
set(gca, 'Xtick', [-2 -1 0 1 2])
ylim([0 180])
for j= 3:4
    letterChangeRelativeGrasp = (histogramData(histogramData(:,2) == j,4) - ...
        histogramData(histogramData(:,2) == j,5))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeGrasp) - 3*nanstd(letterChangeRelativeGrasp);
    upperBound = nanmean(letterChangeRelativeGrasp) + 3*nanstd(letterChangeRelativeGrasp);
    letterChangeRelativeGrasp(letterChangeRelativeGrasp < lowerBound) = [];
    letterChangeRelativeGrasp(letterChangeRelativeGrasp > upperBound) = [];
%     letterChangeRelativeRandomGrasp = (randomGrasp(randomGrasp(:,1) == j,2) - ...
%         randomGrasp(randomGrasp(:,1) == j,3))/200; % in seconds
%     lowerBound = nanmean(letterChangeRelativeRandomGrasp) - 3*nanstd(letterChangeRelativeRandomGrasp);
%     upperBound = nanmean(letterChangeRelativeRandomGrasp) + 3*nanstd(letterChangeRelativeRandomGrasp);
%     letterChangeRelativeRandomGrasp(letterChangeRelativeRandomGrasp < lowerBound) = [];
%     letterChangeRelativeRandomGrasp(letterChangeRelativeRandomGrasp > upperBound) = [];
    ballOnsetRelativelGrasp = (histogramData(histogramData(:,2) == j,6) - ...
        histogramData(histogramData(:,2) == j,5))/200; % in seconds
    lowerBound = nanmean(ballOnsetRelativelGrasp) - 3*nanstd(ballOnsetRelativelGrasp);
    upperBound = nanmean(ballOnsetRelativelGrasp) + 3*nanstd(ballOnsetRelativelGrasp);
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp < lowerBound) = [];
    ballOnsetRelativelGrasp(ballOnsetRelativelGrasp > upperBound) = [];
    slotOnsetRelativeGrasp = (histogramData(histogramData(:,2) == j,7) - ...
        histogramData(histogramData(:,2) == j,5))/200; % in seconds
    lowerBound = nanmean(slotOnsetRelativeGrasp) - 3*nanstd(slotOnsetRelativeGrasp);
    upperBound = nanmean(slotOnsetRelativeGrasp) + 3*nanstd(slotOnsetRelativeGrasp);
    slotOnsetRelativeGrasp(slotOnsetRelativeGrasp < lowerBound) = [];
    slotOnsetRelativeGrasp(slotOnsetRelativeGrasp > upperBound) = [];
    xVector = -3:.005:-0.0009;
    if j == 3
        figure(13)
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', .5, 'facecolor', orange, 'edgecolor', 'none')
        histogram(slotOnsetRelativeGrasp, 'BinWidth', .5, 'facecolor', green, 'edgecolor', 'none')
        plot(xVector,(sum(cumulativeReach(cumulativeReach(:,1) == j, 2:end))/...
            sum(cumulativeReach(cumulativeReach(:,1) == j,end))*100), 'k', 'LineWidth', 1.5)
        b = bar([-1.75 -1.25 -.75 -.25 .25 .75 1.25 1.75], trialCount_FT/3.29);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
        %         histogram(letterChangeRelativeRandomGrasp, 'BinWidth', .5, 'facecolor', 'none', 'edgecolor', 'k', 'LineWidth', 1)
        %         [h,p] = kstest2(letterChangeRelativeGrasp, letterChangeRelativeRandomGrasp)
    else
        figure(14)
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
        histogram(ballOnsetRelativelGrasp, 'BinWidth', .5, 'facecolor', orange, 'edgecolor', 'none')
        histogram(slotOnsetRelativeGrasp, 'BinWidth', .5, 'facecolor', green, 'edgecolor', 'none')
        plot(xVector,(sum(cumulativeReach(cumulativeReach(:,1) == j, 2:end))/...
            sum(cumulativeReach(cumulativeReach(:,1) == j,end))*100), 'k', 'LineWidth', 1.5)
        b = bar([-2.25 -1.75 -1.25 -.75 -.25 .25 .75 1.25 1.75 2.25], trialCount_TW/2.94);
        b.FaceColor = 'none';
        b.EdgeColor = 'k';
        b.BarWidth = 1;
%         histogram(letterChangeRelativeRandomGrasp, 'BinWidth', .5, 'facecolor', 'none', 'edgecolor', 'k', 'LineWidth', 1)
%         [h,p] = kstest2(letterChangeRelativeGrasp, letterChangeRelativeRandomGrasp)
    end
    clear lowerBound upperBound
end


%%
figure(3)
hold on
xlim([.5 2.5])
set(gca, 'Xtick', [1 2], 'XtickLabel', {'letter change before go signal', 'letter change after go signal'})
ylim([0 400])
set(gca, 'Ytick', [0 100 200 300 400], 'YtickLabel', [0 .5 1 1.5 2])
ylabel('reach onset')
figure(4)
hold on
xlim([.5 2.5])
set(gca, 'Xtick', [1 2], 'XtickLabel', {'letter change before go signal', 'letter change after go signal'})
ylim([0 400])
set(gca, 'Ytick', [0 100 200 300 400], 'YtickLabel', [0 .5 1 1.5 2])
ylabel('reach onset')
for i =1:numParticipants
    currentParticipant = letterToReach(letterToReach(:,2) == i, :);
    for j = 3:4
        currentData = currentParticipant(currentParticipant(:,1) == j, :);
        figure(j)
        plot(1, mean(currentData(currentData(:,3) == 1, 4)), 'ko')
        plot(2, mean(currentData(currentData(:,3) == 2, 4)), 'ko')
        line([1 2], [mean(currentData(currentData(:,3) == 1, 4)) mean(currentData(currentData(:,3) == 2, 4))], 'Color', 'k')
    end
end

%% Old panels Figure 4 C & D
% plot display fixation probability relative to letter change
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
            firstLetterChange = currentResult(n).dualTask.sampleLetterChange(1)-startTime;           
            if isnan(firstLetterChange) || currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.trialEnd 
                continue
            end
            % determine fixation vector
            relativeOnset = 1;
            if firstLetterChange < preLetterChange
                relativeOnset = preLetterChange - firstLetterChange;
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
                    fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-firstLetterChange)]);
                    fixOffset = min([preLetterChange+(fixationOffsets(fix)-firstLetterChange) length(fixationVectorBall)]);
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
            reachOn = max([1 preLetterChange+(reachOnset-firstLetterChange)]);
            reachOff = min([preLetterChange+(reachOffset-firstLetterChange) length(vectorReach)]);
            if reachOff < 1
                continue
            end
            vectorReach(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
            vectorReach(n,reachOn:reachOff) = 1;
            % transport onset to offset
            transportOnset = currentResult(n).info.phaseStart.transport - startTime;
            transportOffset = currentResult(n).info.phaseStart.slotApproach - startTime -1;
            transportOn = max([1 preLetterChange+(transportOnset-firstLetterChange)]);
            transportOff = min([preLetterChange+(transportOffset-firstLetterChange) length(vectorTrasnport)]);
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

%% try any letter change
histogramAll = [];
vectorLength = 600;
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
                currentResult(n).dualTask.sampleLetterChange' ...
                ballGrasp*ones(length(c),1)];
            c = c(end) + 1;
        end
        
        histogramAll = [histogramAll; letterChangeVector];
        clear startTime trialLength letterChangeVector
    end
end

%%
for j = 3:4
    letterChangeRelativeGrasp = (histogramAll(histogramAll(:,1) == j,2) - ...
        histogramAll(histogramAll(:,1) == j,3))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeGrasp) - 3*nanstd(letterChangeRelativeGrasp);
    upperBound = nanmean(letterChangeRelativeGrasp) + 3*nanstd(letterChangeRelativeGrasp);
    letterChangeRelativeGrasp(letterChangeRelativeGrasp < lowerBound) = [];
    letterChangeRelativeGrasp(letterChangeRelativeGrasp > upperBound) = [];
    if j == 3
        figure(13)
        numLetterChanges_FT = sum(~isnan(letterChangeRelativeGrasp));
        N_FT = histcounts(letterChangeRelativeGrasp);
        N_FT = N_FT(N_FT>5); % only counts > 5
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
    else
        figure(14)
        numLetterChanges_TW = sum(~isnan(letterChangeRelativeGrasp));
        N_TW = histcounts(letterChangeRelativeGrasp);
        N_TW = N_TW(N_TW>5); % only counts > 5
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
    end
end