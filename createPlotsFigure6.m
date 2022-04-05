analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%% define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
phaseDurations = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over participants
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        fixationPattern = NaN(numTrials,1);
        ballPhaseDuration = NaN(numTrials,1);
        transportDuration = NaN(numTrials,1);
        slotPhaseDuration = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current participant & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % ball and slot fixations during reach and transport phase
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern(n) = 3;
                else
                    fixationPattern(n) = 4;
                end
            end
            ballPhaseDuration(n) = (currentResult(n).info.phaseDuration.ballApproach + ...
                currentResult(n).info.phaseDuration.ballGrasp)/200; % in seconds
            transportDuration(n) = currentResult(n).info.phaseDuration.transport/200;
            slotPhaseDuration(n) = (currentResult(n).info.phaseDuration.slotApproach + ...
                currentResult(n).info.phaseDuration.ballInSlot)/200;
            
            currentDurations = [blockID*ones(numTrials,1) currentParticipant*ones(numTrials,1) ...
                fixationPattern ballPhaseDuration transportDuration slotPhaseDuration];
        end
        phaseDurations = [phaseDurations; currentDurations];
    end
end
clear ballIdx ballOffset slotIdx slotOnset ballFixType

%% plot phase durations for most common fixation types in finger trip trials (Panel A)
blockID = 3;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
figure(blockID)
hold on
counter = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end);
    % exclude participant that has ball-slot as most common pattern
    if sum(currentParticipant(:,1) == 3) >  sum(currentParticipant(:,1) == 0)
        continue
    end
    % most common pattern
    displayOnly = currentParticipant(currentParticipant(:,1) == 0,:); % select fixation pattern
    % only include participants that have at least 3 trials in each pattern
    if size(displayOnly,1) < 3
        continue
    end
    slotOnly = currentParticipant(currentParticipant(:,1) == 2,:); % select fixation pattern
    if size(slotOnly,1) < 3
        continue
    end
    for n = 1:3
        plot(n-.1, nanmedian(displayOnly(:,n+1)), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(1,:))
        plot(n+.1, nanmedian(slotOnly(:,n+1)), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(3,:))
        line([n-.1 n+.1], [nanmedian(displayOnly(:,n+1)) nanmedian(slotOnly(:,n+1))], 'Color', 'k')
    end
    % save durations into structure for stats
    durationFT(counter,:) = [blockID i nanmedian(displayOnly(:,2)) nanmedian(displayOnly(:,3)) nanmedian(displayOnly(:,4))...
        nanmedian(slotOnly(:,2)) nanmedian(slotOnly(:,3)) nanmedian(slotOnly(:,4))];
    counter = counter+1;
end
xlim([.5 3.5])
set(gca, 'Xtick', [1 2 3], 'XtickLabel', {'approach & grasp phase', 'transport', 'approach & slot phase'})
ylim([0 1.5])
set(gca, 'Ytick', [0 .25 .5 .75 1 1.25 1.5])
ylabel('phase duration (s)')
%% plot phase durations for most common fixation types in tweezer trials (Panel D)
blockID = 4;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
figure(blockID)
hold on
counter = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end); % select fixation pattern
    % only include participants that have at least 3 trials in each pattern
    ballSlot = currentParticipant(currentParticipant(:,1) == 3,:);
    if size(ballSlot,1) < 3
        continue
    end
    ballDisplaySlot = currentParticipant(currentParticipant(:,1) == 4,:); % select fixation pattern
    if size(ballDisplaySlot,1) < 3
        continue
    end
    for n = 1:3
        plot(n-.1, nanmedian(ballSlot(:,n+1)), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(4,:))
        plot(n+.1, nanmedian(ballDisplaySlot(:,n+1)), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', fixationPatternColors(5,:))
        line([n-.1 n+.1], [nanmedian(ballSlot(:,n+1)) nanmedian(ballDisplaySlot(:,n+1))], 'Color', 'k')
    end
    % save durations into structure for stats
    durationTW(counter,:) = [blockID i nanmedian(ballSlot(:,2)) nanmedian(ballSlot(:,3)) nanmedian(ballSlot(:,4))...
        nanmedian(ballDisplaySlot(:,2)) nanmedian(ballDisplaySlot(:,3)) nanmedian(ballDisplaySlot(:,4))];
    counter = counter+1;
end
xlim([.5 3.5])
set(gca, 'Xtick', [1 2 3], 'XtickLabel', {'approach & grasp phase', 'transport', 'approach & slot phase'})
ylim([0 1.25])
set(gca, 'Ytick', [0 .25 .5 .75 1 1.25])
ylabel('Phase duration')

%% save phase durations for statistical analysis in R
fixationPatternPhases = [durationFT; durationTW];
cd(savePath)
save('fixationPatternPhases', 'fixationPatternPhases');
cd(analysisPath)
clear displayOnly ballOnly ballSlot ballDisplaySlot
%% plot cumulative slot fixations relative to trannsport & slot approach (Panels B-C)
green = fixationPatternColors(3,:);
blockID = 3;
slotFixOnsetsTransport = [];
slotFixOffsetsTransport = [];
slotFixOnsetsApproach = [];
slotFixOffsetsApproach = [];
shiftTransport = 300;
vectorTransport = 900;
shiftApproach = 400;
vectorApproach = 800;
figure(12)
hold on
for i = 1:numParticipants % loop over subjects
    currentResult = pulledData{i,blockID};
    currentParticipant = currentResult(1).info.subject;
    numTrials = length(currentResult);
    stopTrial = min([numTrials 30]);
    % open variable matrices that we want to pull
    cumulativeOnsetTransport = NaN(numTrials,vectorTransport);
    cumulativeOffsetTransport = NaN(numTrials,vectorTransport);
    cumulativeOnsetsApproach = NaN(numTrials,vectorApproach);
    cumulativeOffsetApproach = NaN(numTrials,vectorApproach);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        if isempty(currentResult(n).gaze.fixation.onsetsSlot)
            continue
        end
        onsetFixSlot = currentResult(n).gaze.fixation.onsetsSlot(1);
        offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(1);
        
        onsetPhase = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shiftTransport;
        fixOn = onsetFixSlot - phaseOffset;
        cumulativeOnsetTransport(n,:) = [zeros(1,fixOn) ones(1,vectorTransport-fixOn)];
        fixOff = offsetFixSlot - phaseOffset;
        cumulativeOffsetTransport(n,:) = [zeros(1,fixOff) ones(1,vectorTransport-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.slotApproach - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shiftApproach;
        fixOn = onsetFixSlot - phaseOffset;
        cumulativeOnsetsApproach(n,:) = [zeros(1,fixOn) ones(1,vectorApproach-fixOn)];
        offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(1);
        fixOff = offsetFixSlot - phaseOffset;
        cumulativeOffsetApproach(n,:) = [zeros(1,fixOff) ones(1,vectorApproach-fixOff)];
    end
    currentOnsetApproach = nansum(cumulativeOnsetsApproach);
    currentOnsetTransport = nansum(cumulativeOnsetTransport);
    if currentParticipant == 10
        plot(currentOnsetApproach/max(currentOnsetApproach), 'Color', 'r', 'LineWidth', 0.5)
    else
        plot(currentOnsetApproach/max(currentOnsetApproach), 'Color', green,  'LineWidth', 0.5)
    end
    slotFixOnsetsTransport = [slotFixOnsetsTransport; currentOnsetTransport];
    slotFixOnsetsApproach = [slotFixOnsetsApproach; currentOnsetTransport];
    
    currentOffsetTransport = nansum(cumulativeOffsetTransport);
    currentOffsetApproach = nansum(cumulativeOffsetApproach);
    slotFixOffsetsTransport = [slotFixOffsetsTransport; currentOffsetTransport];
    slotFixOffsetsApproach = [slotFixOffsetsApproach; currentOffsetTransport];
    
end
figure(11)
hold on
slotFixOnset_sum = nansum(slotFixOnsetsTransport)/max(nansum(slotFixOnsetsTransport));
slotFixOffset_sum = nansum(slotFixOffsetsTransport)/max(nansum(slotFixOffsetsTransport));
plot(slotFixOnset_sum, 'Color', green, 'LineWidth', 2)
plot(slotFixOffset_sum, '--', 'Color', green, 'LineWidth',2)
line([shiftTransport shiftTransport], [0 1], 'Color', gray)
xlim([0 900])
set(gca, 'Xtick', [100 300 500 700 900], 'XtickLabel', [-1 0 1 2 3])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(12)
slotFixOnset_sum = nansum(slotFixOnsetsApproach)/max(nansum(slotFixOnsetsApproach));
slotFixOffset_sum = nansum(slotFixOffsetsApproach)/max(nansum(slotFixOffsetsApproach));
plot(slotFixOnset_sum, 'Color', green, 'LineWidth', 2)
plot(slotFixOffset_sum, '--', 'Color', green, 'LineWidth',2)
line([shiftApproach shiftApproach], [0 1], 'Color', gray)
xlim([0 800])
set(gca, 'Xtick', [0 200 400 600 800], 'XtickLabel', [-2 -1 0 1 2])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])
clear slotFixOnsets slotFixOffsets currentOnset offsetFixSlot onsetPhase
clear phaseOffset onsetFixSlot fixOn shiftTransport shiftApproach
clear vectorTransport vectorApproach fixOff slotFixOnset_sum slotFixOffset_sum

%% plot cumulative ball fixations relative to reach onset and ball aproach 
% cumulative slot fixations relative to trannsport & slot approach (Panels E-H)
lightPurple = fixationPatternColors(4,:);
darkPurple = fixationPatternColors(5,:);
blockID = 4;
ballFixOnsetsApproach = [];
ballFixOffsetsApproach = [];
slotFixOnsetsTransport = [];
slotFixOffsetsTransport = [];
slotFixOnsetsApproach = [];
slotFixOffsetsApproach = [];
shiftTransport = 300;
vectorTransport = 900;
shiftApproach = 400;
vectorApproach = 800;
for i = 1:numParticipants % loop over subjects
    currentResult = pulledData{i,blockID};
    currentParticipant = currentResult(1).info.subject;
    numTrials = length(currentResult);
    stopTrial = min([numTrials 30]);
    % open variable matrices that we want to pull
    cumulativeOnsetBall = NaN(numTrials,vectorTransport+1); % same shift & length as transport
    cumulativeOffsetBall = NaN(numTrials,vectorTransport+1);
    cumulativeOnsetTransport = NaN(numTrials,vectorTransport+1);
    cumulativeOffsetTransport = NaN(numTrials,vectorTransport+1);
    cumulativeOnsetsApproach = NaN(numTrials,vectorApproach+1);
    cumulativeOffsetApproach = NaN(numTrials,vectorApproach+1);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        if isempty(currentResult(n).gaze.fixation.onsetsBall) || isempty(currentResult(n).gaze.fixation.onsetsSlot)
            continue
        else
            ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
            slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
            slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
            if slotOnset-ballOffset < eyeShift
                ballFixPattern = 3;
            else
                ballFixPattern = 4;
            end
        end
        onsetFixBall = currentResult(n).gaze.fixation.onsetsBall(1);
        offsetFixBall = currentResult(n).gaze.fixation.offsetsBall(1);
        onsetFixSlot = currentResult(n).gaze.fixation.onsetsSlot(1);
        offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(1);
        
        onsetPhase = currentResult(n).info.phaseStart.ballApproach - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shiftTransport;
        fixOn = onsetFixBall - phaseOffset;
        if fixOn > vectorTransport-1
            continue
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetBall(n,:) = [ballFixPattern zeros(1,fixOn) ones(1,vectorTransport-fixOn)];
        fixOff = offsetFixBall - phaseOffset;
        if fixOff > vectorTransport-1
            continue
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetBall(n,:) = [ballFixPattern zeros(1,fixOff) ones(1,vectorTransport-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shiftTransport;
        fixOn = onsetFixSlot - phaseOffset;
        if fixOn > vectorTransport-1
            continue
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetTransport(n,:) = [ballFixPattern zeros(1,fixOn) ones(1,vectorTransport-fixOn)];
        fixOff = offsetFixSlot - phaseOffset;
        if fixOff > vectorTransport-1
            continue
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetTransport(n,:) = [ballFixPattern zeros(1,fixOff) ones(1,vectorTransport-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.slotApproach - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shiftApproach;
        fixOn = onsetFixSlot - phaseOffset;
        if fixOn > vectorApproach-1
            continue
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetsApproach(n,:) = [ballFixPattern zeros(1,fixOn) ones(1,vectorApproach-fixOn)];
        offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(1);
        fixOff = offsetFixSlot - phaseOffset;
        if fixOff > vectorApproach-1
            continue
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetApproach(n,:) = [ballFixPattern zeros(1,fixOff) ones(1,vectorApproach-fixOff)];       
        
    end
    currentOnsetBall = [3 nansum(cumulativeOnsetBall(cumulativeOnsetBall(:,1) == 3, 2:end), 1); ...
        4 nansum(cumulativeOnsetBall(cumulativeOnsetBall(:,1) == 4, 2:end), 1)];
    currentOnsetTransport = [3 nansum(cumulativeOnsetTransport(cumulativeOnsetTransport(:,1) == 3,2:end),1); ...
        4 nansum(cumulativeOnsetTransport(cumulativeOnsetTransport(:,1) == 4, 2:end), 1)];
    currentOnsetApproach = [3 nansum(cumulativeOnsetsApproach(cumulativeOnsetsApproach(:,1) == 3,2:end),1); ...
        4 nansum(cumulativeOnsetsApproach(cumulativeOnsetsApproach(:,1) == 4, 2:end), 1)];
    
    ballFixOnsetsApproach = [ballFixOnsetsApproach; currentOnsetBall];
    slotFixOnsetsTransport = [slotFixOnsetsTransport; currentOnsetTransport];
    slotFixOnsetsApproach = [slotFixOnsetsApproach; currentOnsetApproach];
    
    currentOffsetBall = [3 nansum(cumulativeOffsetBall(cumulativeOffsetBall(:,1) == 3, 2:end), 1); ...
        4 nansum(cumulativeOffsetBall(cumulativeOffsetBall(:,1) == 4, 2:end), 1)];
    currentOffsetTransport = [3 nansum(cumulativeOffsetTransport(cumulativeOffsetTransport(:,1) == 3, 2:end), 1); ...
        4 nansum(cumulativeOffsetTransport(cumulativeOffsetTransport(:,1) == 4, 2:end), 1)];
    currentOffsetApproach = [3 nansum(cumulativeOffsetApproach(cumulativeOffsetApproach(:,1) == 3, 2:end), 1); ...
        4 nansum(cumulativeOffsetApproach(cumulativeOffsetApproach(:,1) == 4, 2:end), 1)];
    
    ballFixOffsetsApproach = [ballFixOffsetsApproach; currentOffsetBall];
    slotFixOffsetsTransport = [slotFixOffsetsTransport; currentOffsetTransport];
    slotFixOffsetsApproach = [slotFixOffsetsApproach; currentOffsetApproach];
    
end

figure(13)
hold on
slotFixOnset_ballSlot = nansum(ballFixOnsetsApproach(ballFixOnsetsApproach(:,1) == 3, 2:end))/ ...
    max(nansum(ballFixOnsetsApproach(ballFixOnsetsApproach(:,1) == 3, 2:end)));
slotFixOnset_ballDisplaySlot = nansum(ballFixOnsetsApproach(ballFixOnsetsApproach(:,1) == 4, 2:end))/ ...
    max(nansum(ballFixOnsetsApproach(ballFixOnsetsApproach(:,1) == 4, 2:end)));
slotFixOffset_ballSlot = nansum(ballFixOffsetsApproach(ballFixOffsetsApproach(:,1) == 3, 2:end))/...
    max(nansum(ballFixOffsetsApproach(ballFixOffsetsApproach(:,1) == 3, 2:end)));
slotFixOffset_ballDisplaySlot = nansum(ballFixOffsetsApproach(ballFixOffsetsApproach(:,1) == 4, 2:end))/...
    max(nansum(ballFixOffsetsApproach(ballFixOffsetsApproach(:,1) == 4, 2:end)));
plot(slotFixOnset_ballSlot, 'Color', lightPurple, 'LineWidth', 2)
plot(slotFixOnset_ballDisplaySlot, 'Color', darkPurple, 'LineWidth', 2)
plot(slotFixOffset_ballSlot, '--', 'Color', lightPurple, 'LineWidth',2)
plot(slotFixOffset_ballDisplaySlot, '--', 'Color', darkPurple, 'LineWidth',2)
line([shiftTransport shiftTransport], [0 1], 'Color', gray)
xlim([0 900])
set(gca, 'Xtick', [100 300 500 700 900], 'XtickLabel', [-1 0 1 2 3])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(14)
hold on
slotFixOnset_ballSlot = nansum(slotFixOnsetsTransport(slotFixOnsetsTransport(:,1) == 3, 2:end))/ ...
    max(nansum(slotFixOnsetsTransport(slotFixOnsetsTransport(:,1) == 3, 2:end)));
slotFixOnset_ballDisplaySlot = nansum(slotFixOnsetsTransport(slotFixOnsetsTransport(:,1) == 4, 2:end))/ ...
    max(nansum(slotFixOnsetsTransport(slotFixOnsetsTransport(:,1) == 4, 2:end)));
slotFixOffset_ballSlot = nansum(slotFixOffsetsTransport(slotFixOffsetsTransport(:,1) == 3, 2:end))/...
    max(nansum(slotFixOffsetsTransport(slotFixOffsetsTransport(:,1) == 3, 2:end)));
slotFixOffset_ballDisplaySlot = nansum(slotFixOffsetsTransport(slotFixOffsetsTransport(:,1) == 4, 2:end))/...
    max(nansum(slotFixOffsetsTransport(slotFixOffsetsTransport(:,1) == 4, 2:end)));
plot(slotFixOnset_ballSlot, 'Color', lightPurple, 'LineWidth', 2)
plot(slotFixOnset_ballDisplaySlot, 'Color', darkPurple, 'LineWidth', 2)
plot(slotFixOffset_ballSlot, '--', 'Color', lightPurple, 'LineWidth',2)
plot(slotFixOffset_ballDisplaySlot, '--', 'Color', darkPurple, 'LineWidth',2)
line([shiftTransport shiftTransport], [0 1], 'Color', gray)
xlim([0 900])
set(gca, 'Xtick', [100 300 500 700 900], 'XtickLabel', [-1 0 1 2 3])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(15)
hold on
slotFixOnset_ballSlot = nansum(slotFixOnsetsApproach(slotFixOnsetsApproach(:,1) == 3, 2:end))/ ...
    max(nansum(slotFixOnsetsApproach(slotFixOnsetsApproach(:,1) == 3, 2:end)));
slotFixOnset_ballDisplaySlot = nansum(slotFixOnsetsApproach(slotFixOnsetsApproach(:,1) == 4, 2:end))/ ...
    max(nansum(slotFixOnsetsApproach(slotFixOnsetsApproach(:,1) == 4, 2:end)));
slotFixOffset_ballSlot = nansum(slotFixOffsetsApproach(slotFixOffsetsApproach(:,1) == 3, 2:end))/...
    max(nansum(slotFixOffsetsApproach(slotFixOffsetsApproach(:,1) == 3, 2:end)));
slotFixOffset_ballDisplaySlot = nansum(slotFixOffsetsApproach(slotFixOffsetsApproach(:,1) == 4, 2:end))/...
    max(nansum(slotFixOffsetsApproach(slotFixOffsetsApproach(:,1) == 4, 2:end)));
plot(slotFixOnset_ballSlot, 'Color', lightPurple, 'LineWidth', 2)
plot(slotFixOnset_ballDisplaySlot, 'Color', darkPurple, 'LineWidth', 2)
plot(slotFixOffset_ballSlot, '--', 'Color', lightPurple, 'LineWidth',2)
plot(slotFixOffset_ballDisplaySlot, '--', 'Color', darkPurple, 'LineWidth',2)
line([shiftApproach shiftApproach], [0 1], 'Color', gray)
xlim([0 800])
set(gca, 'Xtick', [0 200 400 600 800], 'XtickLabel', [-2 -1 0 1 2])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

clear slotFixOnsets slotFixOffsets currentOnset offsetFixSlot onsetPhase
clear phaseOffset onsetFixSlot fixOn shiftTransport shiftApproach onsetFixBall
clear vectorTransport vectorApproach ballOffset slotIdx slotOnset offsetFixBall
clear currentOnsetBall currentOnsetApproach currentOnsetTransport
clear currentOffsetBall currentOffsetTransport currentOffsetApproach
clear slotFixOnset_ballSlot slotFixOnset_ballDisplaySlot
clear slotFixOffset_ballSlot slotFixOffset_ballDisplaySlot