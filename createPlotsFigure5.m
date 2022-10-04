analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%% define some colours
orange = [255,127,0]./255;
greenFT = [116,196,118]./255;
greenTW = [0,109,44]./255;
gray = [99,99,99]./255;
numParticipants = 11;
shift = 300;
vectorLength= 600;

%% plot cumulative ball fixations relative to reach onset, ball aproach,
% ball grasp, and transport
blockID = 4; % ball fixations only make sense for tweezer trials
ballFixOnsetsReach = [];
ballFixOffsetsReach = [];
ballFixOnsetsApproach = [];
ballFixOffsetsApproach = [];
ballFixOnsetsGrasp = [];
ballFixOffsetsGrasp = [];
ballFixOnsetsTransport = [];
ballFixOffsetsTransport = [];
for i = 1:numParticipants % loop over subjects
    currentResult = pulledData{i,blockID};
    currentParticipant = currentResult(1).info.subject;
    numTrials = length(currentResult);
    stopTrial = min([numTrials 30]);
    % open variable matrices that we want to pull
    cumulativeOnsetReach = NaN(numTrials,vectorLength);
    cumulativeOffsetReach = NaN(numTrials,vectorLength);
    cumulativeOnsetApproach = NaN(numTrials,vectorLength);
    cumulativeOffsetApproach = NaN(numTrials,vectorLength);
    cumulativeOnsetGrasp = NaN(numTrials,vectorLength);
    cumulativeOffsetGrasp = NaN(numTrials,vectorLength);
    cumulativeOnsetTransport = NaN(numTrials,vectorLength);
    cumulativeOffsetTransport = NaN(numTrials,vectorLength);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        if isempty(currentResult(n).gaze.fixation.onsetsBall)
            continue
        end
        onsetFixBall = currentResult(n).gaze.fixation.onsetsBall(1);
        offsetFixBall = currentResult(n).gaze.fixation.offsetsBall(1);
        
        onsetPhase = currentResult(n).info.phaseStart.primaryReach - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shift;
        fixOn = onsetFixBall - phaseOffset;
        if fixOn > vectorLength-1
            fixOn = vectorLength;
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetReach(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
        fixOff = offsetFixBall - phaseOffset;
        if fixOff > vectorLength-1
            fixOff = vectorLength;
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetReach(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.ballApproach - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shift;
        fixOn = onsetFixBall - phaseOffset;
        if fixOn > vectorLength-1
            fixOn = vectorLength;
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetApproach(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
        fixOff = offsetFixBall - phaseOffset;
        if fixOff > vectorLength-1
            fixOff = vectorLength;
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetApproach(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shift;
        fixOn = onsetFixBall - phaseOffset;
        if fixOn > vectorLength-1
            fixOn = vectorLength;
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetGrasp(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
        fixOff = offsetFixBall - phaseOffset;
        if fixOff > vectorLength-1
            fixOff = vectorLength;
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetGrasp(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
        
        onsetPhase = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart+1;
        phaseOffset = onsetPhase - shift;
        fixOn = onsetFixBall - phaseOffset;
        if fixOn > vectorLength-1
            fixOn = vectorLength;
        elseif fixOn < 1
            fixOn = 1;
        end
        cumulativeOnsetTransport(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
        fixOff = offsetFixBall - phaseOffset;
        if fixOff > vectorLength-1
            continue
        elseif fixOff < 1
            fixOff = 1;
        end
        cumulativeOffsetTransport(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
        
    end
    currentOnsetReach = nansum(cumulativeOnsetReach);
    currentOnsetApproach = nansum(cumulativeOnsetApproach);
    currentOnsetGrasp = nansum(cumulativeOnsetGrasp);
    currentOnsetTransport = nansum(cumulativeOnsetTransport);
    
    ballFixOnsetsReach = [ballFixOnsetsReach; currentOnsetReach];
    ballFixOnsetsApproach = [ballFixOnsetsApproach; currentOnsetApproach];
    ballFixOnsetsGrasp = [ballFixOnsetsGrasp; currentOnsetGrasp];
    ballFixOnsetsTransport = [ballFixOnsetsTransport; currentOnsetTransport];
    
    currentOffsetReach = nansum(cumulativeOffsetReach);
    currentOffsetApproach = nansum(cumulativeOffsetApproach);
    currentOffsetGrasp = nansum(cumulativeOffsetGrasp);
    currentOffsetTransport = nansum(cumulativeOffsetTransport);
    
    ballFixOffsetsReach = [ballFixOffsetsReach; currentOffsetReach];
    ballFixOffsetsApproach = [ballFixOffsetsApproach; currentOffsetApproach];
    ballFixOffsetsGrasp = [ballFixOffsetsGrasp; currentOffsetGrasp];
    ballFixOffsetsTransport = [ballFixOffsetsTransport; currentOffsetTransport];
    
    clear currentOnsetReach currentOffsetReach currentOnsetApproach currentOffsetApproach
    clear currentOnsetGrasp currentOffsetGrasp currentOnsetTransport currentOffsetTransport
    clear fixOn fixOff onsetPhase onsetFixBall offsetFixBall phaseOffset
end

%% plot
figure(10)
hold on
plot(nansum(ballFixOnsetsReach)/max(nansum(ballFixOnsetsReach)), 'Color', orange, 'LineWidth', 2)
plot(nansum(ballFixOffsetsReach)/max(nansum(ballFixOffsetsReach)), '--', 'Color', orange, 'LineWidth',2)
line([shift shift], [0 1], 'Color', gray)
line([0 vectorLength], [.5 .5], 'Color', gray)
xlim([0 vectorLength])
xlabel('relative to reach')
set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(11)
hold on
plot(nansum(ballFixOnsetsApproach)/max(nansum(ballFixOnsetsApproach)), 'Color', orange, 'LineWidth', 2)
plot(nansum(ballFixOffsetsApproach)/max(nansum(ballFixOffsetsApproach)), '--', 'Color', orange, 'LineWidth',2)
line([shift shift], [0 1], 'Color', gray)
line([0 vectorLength], [.5 .5], 'Color', gray)
xlim([0 vectorLength])
xlabel('relative to ball-approach')
set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(12)
hold on
plot(nansum(ballFixOnsetsGrasp)/max(nansum(ballFixOnsetsGrasp)), 'Color', orange, 'LineWidth', 2)
plot(nansum(ballFixOffsetsGrasp)/max(nansum(ballFixOffsetsGrasp)), '--', 'Color', orange, 'LineWidth',2)
line([shift shift], [0 1], 'Color', gray)
line([0 vectorLength], [.5 .5], 'Color', gray)
xlim([0 vectorLength])
xlabel('relative to ball-grasp')
set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

figure(13)
hold on
plot(nansum(ballFixOnsetsTransport)/max(nansum(ballFixOnsetsTransport)), 'Color', orange, 'LineWidth', 2)
plot(nansum(ballFixOffsetsTransport)/max(nansum(ballFixOffsetsTransport)), '--', 'Color', orange, 'LineWidth',2)
line([shift shift], [0 1], 'Color', gray)
line([0 vectorLength], [.5 .5], 'Color', gray)
xlim([0 vectorLength])
xlabel('relative transport')
set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])

clear ballFixOnsetsReach ballFixOffsetsReach ballFixOnsetsApproach ballFixOffsetsApproach
clear ballFixOnsetsGrasp ballFixOffsetsGrasp ballFixOnsetsTransport ballFixOffsetsTransport

%% plot cumulative slot fixations relative to trannsport & slot approach (Panels B-C)
for j = 3:4
    blockID = j; % ball fixations only make sense for tweezer trials
    slotFixOnsetsTransport = [];
    slotFixOffsetsTransport = [];
    slotFixOnsetsApproach = [];
    slotFixOffsetsApproach = [];
    slotFixOnsetsEntry = [];
    slotFixOffsetsEntry = [];
    slotFixOnsetsDrop = [];
    slotFixOffsetsDrop = [];
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % open variable matrices that we want to pull
        cumulativeOnsetTransport = NaN(numTrials,vectorLength);
        cumulativeOffsetTransport = NaN(numTrials,vectorLength);
        cumulativeOnsetApproach = NaN(numTrials,vectorLength);
        cumulativeOffsetApproach = NaN(numTrials,vectorLength);
        cumulativeOnsetEntry = NaN(numTrials,vectorLength);
        cumulativeOffsetEntry = NaN(numTrials,vectorLength);
        cumulativeOnsetDrop = NaN(numTrials,vectorLength);
        cumulativeOffsetDrop = NaN(numTrials,vectorLength);
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
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetTransport(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetTransport(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
            
            onsetPhase = currentResult(n).info.phaseStart.slotApproach - currentResult(n).info.trialStart+1;
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetApproach(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetApproach(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
            
            onsetPhase = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart+1;
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetEntry(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetEntry(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
            
            onsetPhase = currentResult(n).info.phaseStart.ballDropped - currentResult(n).info.trialStart+1;
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetDrop(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                continue
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetDrop(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
            
        end
        currentOnsetTransport = nansum(cumulativeOnsetTransport);
        currentOnsetApproach = nansum(cumulativeOnsetApproach);
        currentOnsetEntry = nansum(cumulativeOnsetEntry);
        currentOnsetDrop = nansum(cumulativeOnsetDrop);
        
        slotFixOnsetsTransport = [slotFixOnsetsTransport; currentOnsetTransport];
        slotFixOnsetsApproach = [slotFixOnsetsApproach; currentOnsetApproach];
        slotFixOnsetsEntry = [slotFixOnsetsEntry; currentOnsetEntry];
        slotFixOnsetsDrop = [slotFixOnsetsDrop; currentOnsetDrop];
        
        currentOffsetTransport = nansum(cumulativeOffsetTransport);
        currentOffsetApproach = nansum(cumulativeOffsetApproach);
        currentOffsetEntry = nansum(cumulativeOffsetEntry);
        currentOffsetDrop = nansum(cumulativeOffsetDrop);
        
        slotFixOffsetsTransport = [slotFixOffsetsTransport; currentOffsetTransport];
        slotFixOffsetsApproach = [slotFixOffsetsApproach; currentOffsetApproach];
        slotFixOffsetsEntry = [slotFixOffsetsEntry; currentOffsetEntry];
        slotFixOffsetsDrop = [slotFixOffsetsDrop; currentOffsetDrop];
        
        clear currentOnsetTransport currentOffsetTransport currentOnsetApproach currentOffsetApproach
        clear currentOnsetEntry currentOffsetEntry currentOnsetDrop currentOffsetDrop
        clear fixOn fixOff onsetPhase onsetFixSlot offsetFixSlot phaseOffset
    end
    % plot
    if j < 4
        selectedColour = greenFT;
    else
        selectedColour = greenTW;
    end
    figure(100)
    hold on
    plot(nansum(slotFixOnsetsTransport)/max(nansum(slotFixOnsetsTransport)), 'Color', selectedColour, 'LineWidth', 2)
    plot(nansum(slotFixOffsetsTransport)/max(nansum(slotFixOffsetsTransport)), '--', 'Color', selectedColour, 'LineWidth',2)
    line([shift shift], [0 1], 'Color', gray)
    line([0 vectorLength], [.5 .5], 'Color', gray)
    xlim([0 vectorLength])
    xlabel('relative to transport')
    set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    ylim([0 1])
    set(gca, 'Ytick', [0 .25 .5 .75 1])
    
    figure(110)
    hold on
    plot(nansum(slotFixOnsetsApproach)/max(nansum(slotFixOnsetsApproach)), 'Color', selectedColour, 'LineWidth', 2)
    plot(nansum(slotFixOffsetsApproach)/max(nansum(slotFixOffsetsApproach)), '--', 'Color', selectedColour, 'LineWidth',2)
    line([shift shift], [0 1], 'Color', gray)
    line([0 vectorLength], [.5 .5], 'Color', gray)
    xlim([0 vectorLength])
    xlabel('relative to slot-approach')
    set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    ylim([0 1])
    set(gca, 'Ytick', [0 .25 .5 .75 1])
    
    figure(120)
    hold on
    plot(nansum(slotFixOnsetsEntry)/max(nansum(slotFixOnsetsEntry)), 'Color', selectedColour, 'LineWidth', 2)
    plot(nansum(slotFixOffsetsEntry)/max(nansum(slotFixOffsetsEntry)), '--', 'Color', selectedColour, 'LineWidth',2)
    line([shift shift], [0 1], 'Color', gray)
    line([0 vectorLength], [.5 .5], 'Color', gray)
    xlim([0 vectorLength])
    xlabel('relative to slot-entry')
    set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    ylim([0 1])
    set(gca, 'Ytick', [0 .25 .5 .75 1])
    
    figure(130)
    hold on
    plot(nansum(slotFixOnsetsDrop)/max(nansum(slotFixOnsetsDrop)), 'Color', selectedColour, 'LineWidth', 2)
    plot(nansum(slotFixOffsetsDrop)/max(nansum(slotFixOffsetsDrop)), '--', 'Color', selectedColour, 'LineWidth',2)
    line([shift shift], [0 1], 'Color', gray)
    line([0 vectorLength], [.5 .5], 'Color', gray)
    xlim([0 vectorLength])
    xlabel('relative ball drop')
    set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    ylim([0 1])
    set(gca, 'Ytick', [0 .25 .5 .75 1])
    
    clear slotFixOnsetsReach slotFixOffsetsReach slotFixOnsetsApproach slotFixOffsetsApproach
    clear slotFixOnsetsGrasp slotFixOffsetsGrasp slotFixOnsetsTransport slotFixOffsetsTransport
end