analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
numParticipants = 11;
numBlocks = 4;
preApproachMarker = 20; % 20 samples = 100 ms
minGuideDuration = 40; % 40 samples = 200 ms

%% assign functions to each ball fixation
ballFixFunctions = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:numBlocks % loop over dual blocks
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(blockID).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        numVariables = 9;
        currentVariable = NaN(numTrials, numVariables);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            ballApproach = currentResult(n).info.phaseStart.ballApproach - trialStart;
            transport = currentResult(n).info.phaseStart.transport - trialStart;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixReachDuration = 0;
                fixBallDuration = 0;
                fixTransportDuration = 0;
                fixOnset = currentResult(n).gaze.fixation.onsetsBall(1);
                fixOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                endGuideInterval = min([fixOffset transport]);
                fixDuration = fixOffset - fixOnset; % duration in samples
                if fixOnset < ballApproach-preApproachMarker && ...
                        fixDuration >=preApproachMarker
                    directing = 1;
                else
                    directing = 0;
                end
                if fixOnset < ballApproach
                    reachFixOn = max([fixOnset currentResult(n).info.phaseStart.primaryReach - trialStart]);
                    reachFixOff = min([fixOffset ballApproach]);
                    fixReachDuration = (reachFixOff-reachFixOn)/.2;
                end
                if fixOffset < ballApproach
                    guiding = 0;
                elseif fixOnset > ballApproach && fixOffset < transport && ...
                        fixDuration >= minGuideDuration
                    guiding = 1;
                elseif fixOnset < ballApproach && endGuideInterval-ballApproach >= minGuideDuration
                    guiding = 1;
                elseif fixOnset > ballApproach && endGuideInterval-fixOnset >=minGuideDuration
                    guiding = 1;
                else
                    guiding = 0;
                end
                if fixOnset > ballApproach && fixOffset < transport || ...
                        fixOnset < ballApproach && fixOffset > ballApproach || ...
                        fixOnset > ballApproach && fixOnset < transport
                    startGuideInterval = max([fixOnset ballApproach]);
                    fixBallDuration = (endGuideInterval - startGuideInterval)/.2;                  
                end
                if fixOffset > transport 
                    checking = 1;
                    checkFixOn = max([fixOnset transport]);
                    fixTransportDuration = (fixOffset - checkFixOn)/.2;
                else
                    checking = 0;
                end
                      
                if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                    fixOnset = currentResult(n).gaze.fixation.onsetsBall(2);
                    if fixOnset > transport + preApproachMarker
                        continue
                    end
                    fixOffset = currentResult(n).gaze.fixation.offsetsBall(2);
                    endGuideInterval = min([fixOffset transport]);
                    fixDuration = fixOffset - fixOnset; % duration in samples
                    if fixOnset < ballApproach-preApproachMarker && ...
                            fixDuration >=preApproachMarker
                        directing = 1;
                    end
                    if fixOnset < ballApproach
                        reachFixOn = max([fixOnset currentResult(n).info.phaseStart.primaryReach - trialStart]);
                        reachFixOff = min([fixOffset ballApproach]);
                        fixReachDuration = fixReachDuration + (ballApproach-reachFixOn)/.2;
                    end
                    if fixOnset > ballApproach && fixOffset < transport && ...
                            fixDuration >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset < ballApproach && endGuideInterval-ballApproach >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset > ballApproach && endGuideInterval-fixOnset >=minGuideDuration
                        guiding = 1;
                    end
                    if fixOnset > ballApproach && fixOffset < transport || ...
                            fixOnset < ballApproach && fixOffset > ballApproach || ...
                            fixOnset > ballApproach && fixOnset < transport
                        startGuideInterval = max([fixOnset ballApproach]);
                        fixBallDuration = fixBallDuration + (endGuideInterval - startGuideInterval)/.2;
                    end
                    if fixOffset > transport 
                        checking = 1;
                        checkFixOn = max([fixOnset transport]);
                        fixTransportDuration = fixTransportDuration + (fixOffset - checkFixOn)/.2;
                    end
                end
                numFunctions = directing+guiding+checking;
            else
                continue
            end
            
            currentVariable(n,:) = [currentParticipant blockID numFunctions ...
                directing guiding checking ...
                fixReachDuration fixBallDuration fixTransportDuration];
        end
        
        ballFixFunctions = [ballFixFunctions; currentVariable];
        clear currentVariable
    end
end
%% assign functions to each slot fixation
slotFixFunctions = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:numBlocks % loop over dual blocks
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(blockID).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        numVariables = 9;
        currentVariable = NaN(numTrials, numVariables);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            transport = currentResult(n).info.phaseStart.transport - trialStart;
            slotApproach = currentResult(n).info.phaseStart.slotApproach - trialStart;
            returnPhase = currentResult(n).info.phaseStart.return - trialStart;
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixTransportDuration = 0;
                fixSlotDuration = 0;
                fixReturnDuration = 0;
                fixOnset = currentResult(n).gaze.fixation.onsetsSlot(1);
                fixOffset = currentResult(n).gaze.fixation.offsetsSlot(1);
                endGuideInterval = min([fixOffset returnPhase]);
                fixDuration = fixOffset - fixOnset; % duration in samples
                if fixOnset < slotApproach-preApproachMarker && ...
                        fixDuration >=preApproachMarker
                    directing = 1;
                else
                    directing = 0;
                end
                if fixOnset < slotApproach
                    transFixOn = max([fixOnset transport]);
                    transFixOff = min([fixOffset slotApproach]);
                    fixTransportDuration = (transFixOff-transFixOn)/.2;
                end
                if fixOffset < slotApproach
                    guiding = 0;
                elseif fixOnset > slotApproach && fixOffset < returnPhase && ...
                        fixDuration >= minGuideDuration
                    guiding = 1;
                elseif fixOnset < slotApproach && endGuideInterval-slotApproach >= minGuideDuration
                    guiding = 1;
                elseif fixOnset > slotApproach && endGuideInterval-fixOnset >=minGuideDuration
                    guiding = 1;
                else
                    guiding = 0;
                end
                if fixOnset > slotApproach && fixOffset < returnPhase || ...
                        fixOnset < slotApproach && fixOffset > slotApproach || ...
                        fixOnset > slotApproach && fixOnset < returnPhase
                    startGuideInterval = max([fixOnset slotApproach]);
                    fixSlotDuration = (endGuideInterval - startGuideInterval)/.2;                  
                end
                if fixOffset > returnPhase 
                    checking = 1;
                    checkFixOn = max([fixOnset returnPhase]);
                    fixReturnDuration = (fixOffset - checkFixOn)/.2;
                else
                    checking = 0;
                end
                    
                if numel(currentResult(n).gaze.fixation.onsetsSlot) > 1
                    fixOnset = currentResult(n).gaze.fixation.onsetsSlot(2);
                    if fixOnset > returnPhase + preApproachMarker
                        continue
                    end
                    fixOffset = currentResult(n).gaze.fixation.offsetsSlot(2);
                    endGuideInterval = min([fixOffset returnPhase]);
                    fixDuration = fixOffset - fixOnset; % duration in samples
                    if fixOnset < slotApproach-preApproachMarker && ...
                            fixDuration >=preApproachMarker
                        directing = 1;
                    end
                    if fixOnset < slotApproach
                        transFixOn = min([fixOnset transport]);
                        transFixOff = max([fixOffset slotApproach]);
                        fixTransportDuration = fixTransportDuration + (transFixOn-transFixOn)/.2;
                    end
                    if fixOnset > slotApproach && fixOffset < returnPhase && ...
                            fixDuration >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset < slotApproach && endGuideInterval-slotApproach >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset > slotApproach && endGuideInterval-fixOnset >=minGuideDuration
                        guiding = 1;
                    end
                    if fixOnset > slotApproach && fixOffset < returnPhase || ...
                            fixOnset < slotApproach && fixOffset > slotApproach || ...
                            fixOnset > slotApproach && fixOnset < returnPhase
                        startGuideInterval = max([fixOnset slotApproach]);
                        fixSlotDuration = fixSlotDuration + (endGuideInterval - startGuideInterval)/.2;
                    end
                    if fixOffset > returnPhase 
                        checking = 1;
                        checkFixOn = max([fixOnset returnPhase]);
                        fixReturnDuration = fixReturnDuration + (fixOffset - checkFixOn)/.2;
                    end
                end
                numFunctions = directing+guiding+checking;
            else
                continue
            end
            
            currentVariable(n,:) = [currentParticipant blockID numFunctions ...
                directing guiding checking...
                fixTransportDuration fixSlotDuration fixReturnDuration];
        end
        
        slotFixFunctions = [slotFixFunctions; currentVariable];
        clear currentVariable
    end
end
%%
orange = [255,127,0]./255;
green = [77,175,74]./255;
lightGrey = [189,189,189]./255;
darkGrey = [100,100,100]./255;
ballFixFunctions = ballFixFunctions(~isnan(ballFixFunctions(:,1)),:);
ballFixFunctions_PG = ballFixFunctions(ballFixFunctions(:,2) == 3,:);
ballFixFunctions_TW = ballFixFunctions(ballFixFunctions(:,2) == 4,:);

figure(11)
set(gcf,'renderer','Painters')
hold on
xlim([0.5 3.5])
set(gca, 'Xtick', [1 2 3], 'Xticklabel', {'directing', 'guiding', 'checking'})
set(gca, 'Ytick', [0 .25 .5 .75 1])

participantBallDots = NaN(numParticipants,7);
for pat = 1:numParticipants
    directPG = sum(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,4))/ ...
        length(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,4));
    directTW = sum(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,4))/ ...
        length(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,4));
    guidePG = sum(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,5))/ ...
        length(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,4));
    guideTW = sum(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,5))/ ...
        length(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,4));
    checkPG = sum(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,6))/ ...
        length(ballFixFunctions_PG(ballFixFunctions_PG(:,1) == pat,4));
    checkTW = sum(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,6))/ ...
        length(ballFixFunctions_TW(ballFixFunctions_TW(:,1) == pat,4));
    plot(0.85, directPG, 'o', 'MarkerEdgeColor', orange, 'MarkerFaceColor', 'none')
    plot(1.15, directTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', orange)
    plot(1.85, guidePG, 'o', 'MarkerEdgeColor', orange, 'MarkerFaceColor', 'none')
    plot(2.15, guideTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', orange)
    plot(2.85, checkPG, 'o', 'MarkerEdgeColor', orange, 'MarkerFaceColor', 'none')
    plot(3.15, checkTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', orange)
    participantBallDots(pat,:) = [directPG directTW guidePG guideTW ...
        checkPG checkTW pat];
end

ballBarData = [nanmean(participantBallDots(:,1)) ...
    nanmean(participantBallDots(:,2)); ...
    nanmean(participantBallDots(:,3)) ...
    nanmean(participantBallDots(:,4)); ...
    nanmean(participantBallDots(:,5)) ...
    nanmean(participantBallDots(:,6))];

b = bar(ballBarData);
box off
b(1).FaceColor = 'none';
b(1).EdgeColor = orange;
b(2).FaceColor = orange;
b(2).FaceAlpha = 0.5;
b(2).EdgeColor = 'none';

ballFixFunction = [3*ones(numParticipants,1) participantBallDots(:,end) ...
    ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,1); ...
    3*ones(numParticipants,1) participantBallDots(:,end) ...
    2*ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,3); ...
    3*ones(numParticipants,1) participantBallDots(:,end) ...
    3*ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,5); ...
    4*ones(numParticipants,1) participantBallDots(:,end) ...
    ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,2); ...
    4*ones(numParticipants,1) participantBallDots(:,end) ...
    2*ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,4); ...
    4*ones(numParticipants,1) participantBallDots(:,end) ...
    3*ones(numParticipants,1) ones(numParticipants,1) participantBallDots(:,6)];
%%
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
slotFixFunctions = slotFixFunctions(~isnan(slotFixFunctions(:,1)),:);
slotFixFunctions_PG = slotFixFunctions(slotFixFunctions(:,2) == 3,:);
slotFixFunctions_TW = slotFixFunctions(slotFixFunctions(:,2) == 4,:);

figure(22)
set(gcf,'renderer','Painters')
hold on
xlim([0.5 3.5])
set(gca, 'Xtick', [1 2 3], 'Xticklabel', {'directing', 'guiding', 'checking'})
set(gca, 'Ytick', [0 .25 .5 .75 1])

participantSlotDots = NaN(numParticipants,7);
for pat = 1:numParticipants
    directPG = sum(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,4))/ ...
        length(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,4));
    directTW = sum(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,4))/ ...
        length(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,4));
    guidePG = sum(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,5))/ ...
        length(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,4));
    guideTW = sum(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,5))/ ...
        length(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,4));
    checkPG = sum(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,6))/ ...
        length(slotFixFunctions_PG(slotFixFunctions_PG(:,1) == pat,4));
    checkTW = sum(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,6))/ ...
        length(slotFixFunctions_TW(slotFixFunctions_TW(:,1) == pat,4));
    plot(0.85, directPG, 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', 'none')
    plot(1.15, directTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', green)
    plot(1.85, guidePG, 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', 'none')
    plot(2.15, guideTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', green)
    plot(2.85, checkPG, 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', 'none')
    plot(3.15, checkTW, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', green)
    participantSlotDots(pat,:) = [directPG directTW guidePG guideTW ...
        checkPG checkTW pat];
end

slotBarData = [nanmean(participantSlotDots(:,1)) ...
    nanmean(participantSlotDots(:,2)); ...
    nanmean(participantSlotDots(:,3)) ...
    nanmean(participantSlotDots(:,4)); ...
    nanmean(participantSlotDots(:,5)) ...
    nanmean(participantSlotDots(:,6))];

b = bar(slotBarData);
box off
b(1).FaceColor = 'none';
b(1).EdgeColor = green;
b(2).FaceColor = green;
b(2).FaceAlpha = 0.5;
b(2).EdgeColor = 'none';

slotFixFunction = [3*ones(numParticipants,1) participantSlotDots(:,end) ...
    ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,1); ...
    3*ones(numParticipants,1) participantSlotDots(:,end) ...
    2*ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,3); ...
    3*ones(numParticipants,1) participantSlotDots(:,end) ...
    3*ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,5); ...
    4*ones(numParticipants,1) participantSlotDots(:,end) ...
    ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,2); ...
    4*ones(numParticipants,1) participantSlotDots(:,end) ...
    2*ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,4); ...
    4*ones(numParticipants,1) participantSlotDots(:,end) ...
    3*ones(numParticipants,1) 2*ones(numParticipants,1) participantSlotDots(:,6)];
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

%%
cd(savePath)
save('ballFixFunction', 'ballFixFunction')
save('slotFixFunction', 'slotFixFunction')
cd(analysisPath)