analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
% define some specs
orange = [255,127,0]./255;
green = [77,175,74]./255;
purple = [152,0,203]./255;
gray = [50, 50, 50]./255;
numParticipants = 11;
%% First create plots for fingertip trials (Panels A & B)
sortedIndices = [];
blockID = 3; % fingertips
% first read out the order of ball and slot phases. Then plot each fixation
% in each trial
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,blockID};
    numTrials = length(currentResult);
    currentParticipant = currentResult(1).info.subject*ones(numTrials,1);
    ballPhase = NaN(numTrials,1);
    slotPhase = NaN(numTrials,1);
    stopTrial = min([numTrials 30]);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        ballPhase(n,1) = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.phaseStart.ballApproach;
        slotPhase(n,1) = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.phaseStart.slotApproach;
    end
    currentPhaseLength = [currentParticipant (1:numTrials)' ballPhase slotPhase];
    sortedIndices = [sortedIndices; currentPhaseLength];
end

sortedBalls = [sortrows(sortedIndices, 3) (1:length(sortedIndices))'];
sortedSlots = [sortrows(sortedIndices, 4) (1:length(sortedIndices))'];

%%
figure(11) % ball fixations relative to grasp
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-550 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400 600 800], 'XtickLabel', [-2 -1 0 1 2 3])
hold on
figure(22) % slot fixations relative to slot entry
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-550 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400], 'XtickLabel', [-2 -1 0 1 2])
hold on
figure(33) % trial order effect
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
hold on
figure(44) % participant order effect
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
hold on
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,blockID};
    currentParticipant = currentResult(1).info.subject;
    numTrials = length(currentResult);
    currentBallIndices = sortedBalls(sortedBalls(:,1) == currentParticipant, 2:end); %last column in matrix indicates position
    currentSlotIndices = sortedSlots(sortedSlots(:,1) == currentParticipant, 2:end);
    stopTrial = min([numTrials 30]);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        trialStart = currentResult(n).info.trialStart;
        startReach = currentResult(n).info.phaseStart.primaryReach-trialStart;
        ballApproach = currentResult(n).info.phaseStart.ballApproach-trialStart;
        ballGrasp = currentResult(n).info.phaseStart.ballGrasp-trialStart;
        startTransport = currentResult(n).info.phaseStart.transport-trialStart;
        slotApproach = currentResult(n).info.phaseStart.slotApproach-trialStart;
        ballInSlot = currentResult(n).info.phaseStart.ballInSlot-trialStart;
        reachIndx = find(currentBallIndices(:,1) == n);
        trialPositionReach = currentBallIndices(reachIndx, end);
        transportIndx = find(currentSlotIndices(:,1) == n);
        trialPositionTransport = currentSlotIndices(transportIndx, end);
        % plot ball and slot fixations during reach and transport phase
        if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
            ballOnsets = currentResult(n).gaze.fixation.onsetsBall;
            ballOffsets = currentResult(n).gaze.fixation.offsetsBall;
            for k = 1:numel(ballOnsets)
                figure(11)
                if k == 1
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp],...
                        [trialPositionReach trialPositionReach], 'Color', orange, 'LineWidth', 1.5)
                else
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp-1],...
                        [trialPositionReach trialPositionReach], 'Color', purple, 'LineWidth', 1.5)
                end
            end
            trialColourBall = orange;
        end
        if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
            slotOnsets = currentResult(n).gaze.fixation.onsetsSlot;
            slotOffsets = currentResult(n).gaze.fixation.offsetsSlot;
            for k = 1:numel(slotOnsets)
                figure(22)
                if k == 1
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', green, 'LineWidth', 1.5)
                else
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', purple, 'LineWidth', 1.5)
                end
            end
            trialColourSlot = green;
        end
        figure(11) % zero indicates ball grasp
        plot(startReach-ballGrasp, trialPositionReach, 'k|', 'MarkerSize', 3) % start of primary reach
        plot(ballApproach-ballGrasp, trialPositionReach, 'k.', 'MarkerSize', 10) % ball grasp
        plot(startTransport-ballGrasp, trialPositionReach, 'k|', 'MarkerSize', 3) % start of transport
        figure(22)
        plot(startTransport-ballInSlot, trialPositionTransport, 'k|', 'MarkerSize', 3) %start of transport
        plot(slotApproach-ballInSlot, trialPositionTransport, 'k.', 'MarkerSize', 10) % ball in slot
        plot(currentResult(n).info.phaseStart.return-trialStart-ballInSlot, trialPositionTransport, 'k|', 'MarkerSize', 3)
        % plot trial order
        figure(33)
        plot(currentBallIndices(reachIndx,1), trialPositionReach, '.', 'Color', trialColourBall, 'MarkerSize', 8)
        plot(currentSlotIndices(transportIndx,1)+50, trialPositionTransport, '.', 'Color', trialColourSlot, 'MarkerSize', 8)
        figure(44)
        plot(currentParticipant, trialPositionReach, '.', 'Color', trialColourBall, 'MarkerSize', 8)
        plot(currentParticipant+50, trialPositionTransport, '.', 'Color', trialColourSlot, 'MarkerSize', 8)
        clear startReach startTransport ballApproach ballGrasp ballInSlot slotApproach
        clear ballOffsets ballOnsets slotOnsets slotOffsets reachIndx transportIndx
        clear trialPositionReach trialPositionTransport trialStart
    end
    
end

%% Second create plots for tweezer trials (Panels D & E)
sortedIndices = [];
blockID = 4; % tweezers
% first read out the order of ball and slot phases. Then plot each fixation
% in each trial
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,blockID};
    numTrials = length(currentResult);
    currentParticipant = currentResult(1).info.subject*ones(numTrials,1);
    ballPhase = NaN(numTrials,1);
    slotPhase = NaN(numTrials,1);
    stopTrial = min([numTrials 30]);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        ballPhase(n,1) = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.phaseStart.ballApproach;
        slotPhase(n,1) = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.phaseStart.slotApproach;
    end
    currentPhaseLength = [currentParticipant (1:numTrials)' ballPhase slotPhase];
    sortedIndices = [sortedIndices; currentPhaseLength];
end

sortedBalls = [sortrows(sortedIndices, 3) (1:length(sortedIndices))'];
sortedSlots = [sortrows(sortedIndices, 4) (1:length(sortedIndices))'];

%%
figure(111) % ball fixations relative to grasp
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-550 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400 600 800], 'XtickLabel', [-2 -1 0 1 2 3])
hold on
figure(222) % slot fixations relative to slot entry
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-550 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400], 'XtickLabel', [-2 -1 0 1 2])
hold on
figure(333) % trial order effect
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
hold on
figure(444) % participant order effect
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
hold on
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,blockID};
    currentParticipant = currentResult(1).info.subject;
    numTrials = length(currentResult);
    currentBallIndices = sortedBalls(sortedBalls(:,1) == currentParticipant, 2:end); %last column in matrix indicates position
    currentSlotIndices = sortedSlots(sortedSlots(:,1) == currentParticipant, 2:end);
    stopTrial = min([numTrials 30]);
    for n = 1:stopTrial % loop over trials for current subject & block
        if currentResult(n).info.dropped
            stopTrial = min([stopTrial+1 numTrials]);
            continue
        end
        trialStart = currentResult(n).info.trialStart;
        startReach = currentResult(n).info.phaseStart.primaryReach-trialStart;
        ballApproach = currentResult(n).info.phaseStart.ballApproach-trialStart;
        ballGrasp = currentResult(n).info.phaseStart.ballGrasp-trialStart;
        startTransport = currentResult(n).info.phaseStart.transport-trialStart;
        slotApproach = currentResult(n).info.phaseStart.slotApproach-trialStart;
        ballInSlot = currentResult(n).info.phaseStart.ballInSlot-trialStart;
        reachIndx = find(currentBallIndices(:,1) == n);
        trialPositionReach = currentBallIndices(reachIndx, end);
        transportIndx = find(currentSlotIndices(:,1) == n);
        trialPositionTransport = currentSlotIndices(transportIndx, end);
        % plot ball and slot fixations during reach and transport phase
        if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
            ballOnsets = currentResult(n).gaze.fixation.onsetsBall;
            ballOffsets = currentResult(n).gaze.fixation.offsetsBall;
            for k = 1:numel(ballOnsets)
                figure(111)
                if k == 1
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp],...
                        [trialPositionReach trialPositionReach], 'Color', orange, 'LineWidth', 1.5)
                else
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp-1],...
                        [trialPositionReach trialPositionReach], 'Color', purple, 'LineWidth', 1.5)
                end
            end
            trialColourBall = orange;
        end
        if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
            slotOnsets = currentResult(n).gaze.fixation.onsetsSlot;
            slotOffsets = currentResult(n).gaze.fixation.offsetsSlot;
            for k = 1:numel(slotOnsets)
                figure(222)
                if k == 1
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', green, 'LineWidth', 1.5)
                else
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', purple, 'LineWidth', 1.5)
                end
            end
            trialColourSlot = green;
        end
        figure(111) % zero indicates ball grasp
        plot(startReach-ballGrasp, trialPositionReach, 'k|', 'MarkerSize', 3) % start of primary reach
        plot(ballApproach-ballGrasp, trialPositionReach, 'k.', 'MarkerSize', 10) % ball grasp
        plot(startTransport-ballGrasp, trialPositionReach, 'k|', 'MarkerSize', 3) % start of transport
        figure(222)
        plot(startTransport-ballInSlot, trialPositionTransport, 'k|', 'MarkerSize', 3) %start of transport
        plot(slotApproach-ballInSlot, trialPositionTransport, 'k.', 'MarkerSize', 10) % ball in slot
        plot(currentResult(n).info.phaseStart.return-trialStart-ballInSlot, trialPositionTransport, 'k|', 'MarkerSize', 3)
        % plot trial order
        figure(333)
        plot(currentBallIndices(reachIndx,1), trialPositionReach, '.', 'Color', trialColourBall, 'MarkerSize', 8)
        plot(currentSlotIndices(transportIndx,1)+50, trialPositionTransport, '.', 'Color', trialColourSlot, 'MarkerSize', 8)
        figure(444)
        plot(currentParticipant, trialPositionReach, '.', 'Color', trialColourBall, 'MarkerSize', 8)
        plot(currentParticipant+50, trialPositionTransport, '.', 'Color', trialColourSlot, 'MarkerSize', 8)
        clear startReach startTransport ballApproach ballGrasp ballInSlot slotApproach
        clear ballOffsets ballOnsets slotOnsets slotOffsets reachIndx transportIndx
        clear trialPositionReach trialPositionTransport trialStart
    end
    
end

%% add cumulative districutions (panels E&F)

shift = 300;
vectorLength= 600;
for blockID = 3:4
    ballFixOnsets = [];
    ballFixOffsets = [];
    slotFixOnsets = [];
    slotFixOffsets = [];
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % open variable matrices that we want to pull
        cumulativeOnsetBall = NaN(numTrials,vectorLength);
        cumulativeOffsetBall = NaN(numTrials,vectorLength);
        cumulativeOnsetSlot = NaN(numTrials,vectorLength);
        cumulativeOffsetSlot = NaN(numTrials,vectorLength);
        distributionOnOff_ball = NaN(numTrials,3);
        distributionOnOff_slot = NaN(numTrials,3);
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
                        
            onsetPhase = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart+1;
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixBall - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetBall(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixBall - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetBall(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];            
        end
        currentOnsetBall = nansum(cumulativeOnsetBall);
        ballFixOnsets = [ballFixOnsets; currentOnsetBall];
        currentOffsetBall = nansum(cumulativeOffsetBall);
        ballFixOffsets = [ballFixOffsets; currentOffsetBall];
        % slot fixations
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
                                    
            onsetPhase = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart+1;
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetSlot(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            cumulativeOffsetSlot(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];        
        end
        currentOnsetSlot = nansum(cumulativeOnsetSlot);
        slotFixOnsets = [slotFixOnsets; currentOnsetSlot];
        currentOffsetSlot = nansum(cumulativeOffsetSlot);
        slotFixOffsets = [slotFixOffsets; currentOffsetSlot];
        
        clear currentOnsetBall currentOffsetBall currentOnsetSlot currentOffsetSlot
        clear fixOn fixOff onsetPhase onsetFixBall offsetFixBall phaseOffset
        clear onsetFixSlot offsetFixSlot
    end
    
    % plot
    if blockID < 4
        figure(12)
        hold on
        plot(nansum(ballFixOnsets)/max(nansum(ballFixOnsets)), 'Color', orange, 'LineWidth', 2)
        plot(nansum(ballFixOffsets)/max(nansum(ballFixOffsets)), '--', 'Color', orange, 'LineWidth',2)
        plot(nansum(slotFixOnsets)/max(nansum(slotFixOnsets)), 'Color', green, 'LineWidth', 2)
        plot(nansum(slotFixOffsets)/max(nansum(slotFixOffsets)), '--', 'Color', green, 'LineWidth',2)
        line([shift shift], [0 1], 'Color', gray)
        line([0 vectorLength], [.5 .5], 'Color', gray)
        xlim([0 vectorLength])
        xlabel('relative to contact event fingertips')
        set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
        ylim([0 1])
        set(gca, 'Ytick', [0 .25 .5 .75 1])
    else
        figure(13)
        hold on
        plot(nansum(ballFixOnsets)/max(nansum(ballFixOnsets)), 'Color', orange, 'LineWidth', 2)
        plot(nansum(ballFixOffsets)/max(nansum(ballFixOffsets)), '--', 'Color', orange, 'LineWidth',2)
        plot(nansum(slotFixOnsets)/max(nansum(slotFixOnsets)), 'Color', green, 'LineWidth', 2)
        plot(nansum(slotFixOffsets)/max(nansum(slotFixOffsets)), '--', 'Color', green, 'LineWidth',2)
        line([shift shift], [0 1], 'Color', gray)
        line([0 vectorLength], [.5 .5], 'Color', gray)
        xlim([0 vectorLength])
        xlabel('relative to contact event tweezers')
        set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
        ylim([0 1])
        set(gca, 'Ytick', [0 .25 .5 .75 1])
    end
    
    clear ballFixOnsetsReach ballFixOffsetsReach ballFixOnsetsApproach ballFixOffsetsApproach
    clear ballFixOnsets ballFixOffsets ballFixOnsetsTransport ballFixOffsetsTransport
end

%% cumulatives single task

shift = 600;
vectorLength= 1200;
for blockID = 1:4
    ballFixOnsets = [];
    ballFixOffsets = [];
    slotFixOnsets = [];
    slotFixOffsets = [];
    onOffsets = [];
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        %stopTrial = min([numTrials 30]);
        stopTrial = 15;
        % open variable matrices that we want to pull
        cumulativeOnsetBall = NaN(numTrials,vectorLength);
        cumulativeOffsetBall = NaN(numTrials,vectorLength);
        cumulativeOnsetSlot = NaN(numTrials,vectorLength);
        cumulativeOffsetSlot = NaN(numTrials,vectorLength);
        distributionOnOff_ball = [];
        count = 1;
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isempty(currentResult(n).gaze.fixation.onsetsBall)
                continue
            end
            onsetPhase = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart+1;
            ballIdx = find(currentResult(n).gaze.fixation.onsetsBall < onsetPhase, 1, 'last');
            %ballIdx = 1;
            if ~isempty(ballIdx)
                onsetFixBall = currentResult(n).gaze.fixation.onsetsBall(ballIdx);
                offsetFixBall = currentResult(n).gaze.fixation.offsetsBall(ballIdx);
            else
                continue
            end

            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixBall - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetBall(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixBall - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            distributionOnOff_ball(count,:) = [blockID currentParticipant 1 fixOn fixOff];
            count = count + 1;
            cumulativeOffsetBall(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];
        end
        onOffsets = [onOffsets; distributionOnOff_ball];
        clear distributionOnOff_ball
        currentOnsetBall = nansum(cumulativeOnsetBall);
        ballFixOnsets = [ballFixOnsets; currentOnsetBall];
        currentOffsetBall = nansum(cumulativeOffsetBall);
        ballFixOffsets = [ballFixOffsets; currentOffsetBall];
        distributionOnOff_slot = [];
        count = 1;
        % slot fixations
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isempty(currentResult(n).gaze.fixation.onsetsSlot)
                continue
            end
            onsetPhase = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart+1;
            slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot < onsetPhase, 1, 'last');
            if ~isempty(slotIdx)
                onsetFixSlot = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(slotIdx);
            else
                onsetFixSlot = currentResult(n).gaze.fixation.onsetsSlot(1);
                offsetFixSlot = currentResult(n).gaze.fixation.offsetsSlot(1);
            end
                                    
            phaseOffset = onsetPhase - shift;
            fixOn = onsetFixSlot - phaseOffset;
            if fixOn > vectorLength-1
                fixOn = vectorLength;
            elseif fixOn < 1
                fixOn = 1;
            end
            cumulativeOnsetSlot(n,:) = [zeros(1,fixOn) ones(1,vectorLength-fixOn)];
            fixOff = offsetFixSlot - phaseOffset;
            if fixOff > vectorLength-1
                fixOff = vectorLength;
            elseif fixOff < 1
                fixOff = 1;
            end
            distributionOnOff_slot(count,:) = [blockID currentParticipant 2 fixOn fixOff];
            count = count + 1;
            cumulativeOffsetSlot(n,:) = [zeros(1,fixOff) ones(1,vectorLength-fixOff)];        
        end
        onOffsets = [onOffsets; distributionOnOff_slot];
        clear distributionOnOff_slot
        currentOnsetSlot = nansum(cumulativeOnsetSlot);
        slotFixOnsets = [slotFixOnsets; currentOnsetSlot];
        currentOffsetSlot = nansum(cumulativeOffsetSlot);
        slotFixOffsets = [slotFixOffsets; currentOffsetSlot];
        
        clear currentOnsetBall currentOffsetBall currentOnsetSlot currentOffsetSlot
        clear fixOn fixOff onsetPhase onsetFixBall offsetFixBall phaseOffset
        clear onsetFixSlot offsetFixSlot
    end

    if blockID == 1
        fingertips_early = onOffsets;
        %fingertips_late = onOffsets;
        clear onOffsets
    elseif blockID == 2
        tweezers_early = onOffsets;
        %tweezers_late = onOffsets;
        clear onOffsets
    elseif blockID == 3
        fingertips_early_dual = onOffsets;
        %fingertips_late_dual = onOffsets;
        clear onOffsets
    else
        tweezers_early_dual = onOffsets;
        %tweezers_late_dual = onOffsets;
        clear onOffsets
    end
    
    %plot
    % if blockID < 2
    %     figure(10)
    %     hold on
    %     plot(nansum(ballFixOnsets)/max(nansum(ballFixOnsets)), 'Color', orange, 'LineWidth', 2)
    %     plot(nansum(ballFixOffsets)/max(nansum(ballFixOffsets)), '--', 'Color', orange, 'LineWidth',2)
    %     plot(nansum(slotFixOnsets)/max(nansum(slotFixOnsets)), 'Color', green, 'LineWidth', 2)
    %     plot(nansum(slotFixOffsets)/max(nansum(slotFixOffsets)), '--', 'Color', green, 'LineWidth',2)
    %     line([shift shift], [0 1], 'Color', gray)
    %     line([0 vectorLength], [.5 .5], 'Color', gray)
    %     xlim([0 vectorLength])
    %     xlabel('relative to contact event fingertips')
    %     %set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    %     ylim([0 1])
    %     set(gca, 'Ytick', [0 .25 .5 .75 1])
    % else
    %     figure(11)
    %     hold on
    %     plot(nansum(ballFixOnsets)/max(nansum(ballFixOnsets)), 'Color', orange, 'LineWidth', 2)
    %     plot(nansum(ballFixOffsets)/max(nansum(ballFixOffsets)), '--', 'Color', orange, 'LineWidth',2)
    %     plot(nansum(slotFixOnsets)/max(nansum(slotFixOnsets)), 'Color', green, 'LineWidth', 2)
    %     plot(nansum(slotFixOffsets)/max(nansum(slotFixOffsets)), '--', 'Color', green, 'LineWidth',2)
    %     line([shift shift], [0 1], 'Color', gray)
    %     line([0 vectorLength], [.5 .5], 'Color', gray)
    %     xlim([0 vectorLength])
    %     xlabel('relative to contact event tweezers')
    %     %set(gca, 'Xtick', [0 100 200 300 400 500 600], 'XtickLabel', [-1.5 -1 -.5 0 .5 1 1.5])
    %     ylim([0 1])
    %     set(gca, 'Ytick', [0 .25 .5 .75 1])
    % end

    clear ballFixOnsetsReach ballFixOffsetsReach ballFixOnsetsApproach ballFixOffsetsApproach
    clear ballFixOnsets ballFixOffsets ballFixOnsetsTransport ballFixOffsetsTransport
end

%%
earlyMedians = NaN(numParticipants*2*4,4);
lateMedians = NaN(numParticipants*2*4,4);
count = 1;
for blockID = 1:4
    currentBlock_early = earlyOnOffsets(earlyOnOffsets(:,1) == blockID, :);
    currentBlock_late = lateOnOffsets(lateOnOffsets(:,1) == blockID, :);
    for pat = 1:numParticipants
        currentParticipant_early = currentBlock_early(currentBlock_early(:,2) == pat, :);
        currentParticipant_late = currentBlock_late(currentBlock_late(:,2) == pat, :);
        earlyMedians(count,:) =  [blockID 1 median(currentParticipant_early(currentParticipant_early(:,3) == 1, 4:end),1)];
        earlyMedians(count+1,:) = [blockID 2 median(currentParticipant_early(currentParticipant_early(:,3) == 2, 4:end),1)];
        lateMedians(count,:) = [blockID 1 median(currentParticipant_late(currentParticipant_late(:,3) == 1, 4:end),1)];
        lateMedians(count+1,:) = [blockID 2 median(currentParticipant_late(currentParticipant_late(:,3) == 2, 4:end),1)];
        count = count + 2;
    end
end

%%
[h.ball_FT, p.ball_FT, ks2stat.ball_FT] = kstest2(fingertips_early(fingertips_early(:,1) == 1,3) - fingertips_early(fingertips_early(:,1) == 1,2) , ...
    fingertips_late(fingertips_late(:,1) == 1,3) - fingertips_late(fingertips_late(:,1) == 1,2));

[h.slot_FT, p.slot_FT, ks2stat.slot_FT] = kstest2(fingertips_early(fingertips_early(:,1) == 2,3) - fingertips_early(fingertips_early(:,1) == 2,2) , ...
    fingertips_late(fingertips_late(:,1) == 2,3) - fingertips_late(fingertips_late(:,1) == 2,2));

[h.ball_TW, p.ball_TW, ks2stat.ball_TW] = kstest2(tweezers_early(tweezers_early(:,1) == 1,3) - tweezers_early(tweezers_early(:,1) == 1,2) , ...
    tweezers_late(tweezers_late(:,1) == 1,3) - tweezers_late(tweezers_late(:,1) == 1,2));

[h.slot_TW, p.slot_TW, ks2stat.slot_TW] = kstest2(tweezers_early(tweezers_early(:,1) == 2,3) - tweezers_early(tweezers_early(:,1) == 2,2) , ...
    tweezers_late(tweezers_late(:,1) == 2,3) - tweezers_late(tweezers_late(:,1) == 2,2));

%%
[h.ball_FT, p.ball_FT, ks2stat.ball_FT] = kstest2(fingertips_early_dual(fingertips_early_dual(:,1) == 1,3) - fingertips_early_dual(fingertips_early_dual(:,1) == 1,2) , ...
    fingertips_late_dual(fingertips_late_dual(:,1) == 1,3) - fingertips_late_dual(fingertips_late_dual(:,1) == 1,2));

[h.slot_FT, p.slot_FT, ks2stat.slot_FT] = kstest2(fingertips_early_dual(fingertips_early_dual(:,1) == 2,3) - fingertips_early_dual(fingertips_early_dual(:,1) == 2,2) , ...
    fingertips_late_dual(fingertips_late_dual(:,1) == 2,3) - fingertips_late_dual(fingertips_late_dual(:,1) == 2,2));

[h.ball_TW, p.ball_TW, ks2stat.ball_TW] = kstest2(tweezers_early_dual(tweezers_early_dual(:,1) == 1,3) - tweezers_early_dual(tweezers_early_dual(:,1) == 1,2) , ...
    tweezers_late_dual(tweezers_late_dual(:,1) == 1,3) - tweezers_late_dual(tweezers_late_dual(:,1) == 1,2));

[h.slot_TW, p.slot_TW, ks2stat.slot_TW] = kstest2(tweezers_early_dual(tweezers_early_dual(:,1) == 2,3) - tweezers_early_dual(tweezers_early_dual(:,1) == 2,2) , ...
    tweezers_late_dual(tweezers_late_dual(:,1) == 2,3) - tweezers_late_dual(tweezers_late_dual(:,1) == 2,2));