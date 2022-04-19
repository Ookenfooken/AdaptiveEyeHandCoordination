%% plot display fixation probability relative to letter change (Panel D)
preLetterChange = 100;
postLetterChange = 300;
fixationRateDisplayEarly = [];
fixationRateDisplayLate = [];
fixationRateBall = [];
fixationRateSlot = [];
reachRate = [];
transportRate = [];
for j = 1:numParticipants % loop over subjects
    for i = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        fixationVectorDisplayEarly = NaN(numTrials,preLetterChange+postLetterChange);
        fixationVectorDisplayLate = NaN(numTrials,preLetterChange+postLetterChange);
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
            if isnan(letterChange) || currentResult(n).dualTask.sampleLetterChange(1) > currentResult(n).info.phaseStart.return
                continue
            end
            % if letter change before grasp plot ball fixations
            if currentResult(n).dualTask.sampleLetterChange(1) < currentResult(n).info.phaseStart.ballGrasp
                % determine fixation vector
                relativeOnset = 1;
                if letterChange < preLetterChange
                    relativeOnset = preLetterChange - letterChange;
                end
                relativeOffset = preLetterChange+postLetterChange;
                if relativeOffset > length(currentResult(n).gaze.Xinterpolated)
                    relativeOffset = length(currentResult(n).gaze.Xinterpolated);
                end
                fixationVectorDisplayEarly(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
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
                        fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-letterChange)]);
                        fixOffset = min([preLetterChange+(fixationOffsets(fix)-letterChange) length(fixationVectorBall)]);
                        minimalDistance = min(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2));
                        fixationOn = find(mean(distancesGaze(:,fixationOnsets(fix):fixationOffsets(fix)),2) == minimalDistance);
                        if fixationOn == 3 % indicates fixation on display
                            fixationVectorDisplayEarly(n,fixOnset:fixOffset) = 1;
                        elseif fixationOn == 1 % indicates fixation on ball
                            fixationVectorBall(n,fixOnset:fixOffset) = 1;
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
            else
                % determine fixation vector
                relativeOnset = 1;
                if letterChange < preLetterChange
                    relativeOnset = preLetterChange - letterChange;
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
                        fixOnset = max([1 preLetterChange+(fixationOnsets(fix)-letterChange)]);
                        fixOffset = min([preLetterChange+(fixationOffsets(fix)-letterChange) length(fixationVectorBall)]);
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
                transportOffset = currentResult(n).info.phaseStart.slotApproach - startTime -1;
                transportOn = max([1 preLetterChange+(transportOnset-letterChange)]);
                transportOff = min([preLetterChange+(transportOffset-letterChange) length(vectorTrasnport)]);
                if transportOff < 1 || transportOn > transportOff
                    continue
                end
                vectorTrasnport(n,relativeOnset:relativeOffset) = zeros(1,relativeOffset-relativeOnset+1);
                vectorTrasnport(n,transportOn:transportOff) = 1;
            end
        end
        currentFixationRateDisplayEarly = [j i nanmean(fixationVectorDisplayEarly)];
        currentFixationRateDisplayLate = [j i nanmean(fixationVectorDisplayLate)];
        currentFixationRateBall = [j i nanmean(fixationVectorBall)];
        currentFixationRateSlot = [j i nanmean(fixationVectorSlot)];
        currentReachOnset = [j i nanmean(vectorReach)];
        currentTransportOnset = [j i nanmean(vectorTrasnport)];
        fixationRateDisplayEarly= [fixationRateDisplayEarly; currentFixationRateDisplayEarly];
        fixationRateDisplayLate= [fixationRateDisplayLate; currentFixationRateDisplayLate];
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
set(gca, 'Xtick', [0 100 200 300 400], 'XtickLabel', [-.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
line([preLetterChange preLetterChange], [0 1], 'Color', gray, 'LineStyle', '--')
plot(mean(fixationRateDisplayEarly(fixationRateDisplayEarly(:,2) == 3, 3:end-4)),'Color', blue, 'LineWidth', 2)
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
plot(mean(fixationRateDisplayEarly(fixationRateDisplayEarly(:,2) == 4, 3:end-4)),'Color', blue, 'LineWidth', 2)
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