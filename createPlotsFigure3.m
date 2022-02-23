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
red = [228,26,28]./255;
blue = [55,126,184]./255;
numParticipants = 11;
%% First create plots for fingertip trials (Panels A & B)
sortedIndices = [];
currentID = 3; % fingertips
% first read out the order of ball and slot phases. Then plot each fixation
% in each trial
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,currentID};
    numTrials = length(currentResult);
    currentParticipant = currentResult(currentID).info.subject*ones(numTrials,1);
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
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,currentID};
    currentParticipant = currentResult(currentID).info.subject;
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
        if isempty(currentResult(n).gaze.fixation.onsetsBall)
            figure(11)
            % blue tick mark for no ball fixations
            line([-550 -550], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
        end
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
                        [trialPositionReach trialPositionReach], 'Color', red, 'LineWidth', 1.5)
                end
            end
        end
        if isempty(currentResult(n).gaze.fixation.onsetsSlot)
            figure(22)
            % blue tick mark for no slot fixations
            line([-550 -550], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
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
                        [trialPositionTransport trialPositionTransport], 'Color', red, 'LineWidth', 1.5)
                end
            end
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
        plot(currentBallIndices(reachIndx,1), trialPositionReach, 'k.', 'MarkerSize', 8)
        plot(currentSlotIndices(transportIndx,1)+50, trialPositionTransport, 'k.', 'MarkerSize', 8)
        clear startReach startTransport ballApproach ballGrasp ballInSlot slotApproach
        clear ballOffsets ballOnsets slotOnsets slotOffsets reachIndx transportIndx
        clear trialPositionReach trialPositionTransport trialStart
    end
    
end

%% Second create plots for tweezer trials (Panels D & E)
sortedIndices = [];
currentID = 4; % tweezers
% first read out the order of ball and slot phases. Then plot each fixation
% in each trial
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,currentID};
    numTrials = length(currentResult);
    currentParticipant = currentResult(currentID).info.subject*ones(numTrials,1);
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
for j = 1:numParticipants % loop over subjects
    currentResult = pulledData{j,currentID};
    currentParticipant = currentResult(currentID).info.subject;
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
        if isempty(currentResult(n).gaze.fixation.onsetsBall)
            figure(111)
            % blue tick mark for no ball fixations
            line([-550 -550], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
        end
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
                        [trialPositionReach trialPositionReach], 'Color', red, 'LineWidth', 1.5)
                end
            end
        end
        if isempty(currentResult(n).gaze.fixation.onsetsSlot)
            figure(222)
            % blue tick mark for no slot fixations
            line([-550 -550], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
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
                        [trialPositionTransport trialPositionTransport], 'Color', red, 'LineWidth', 1.5)
                end
            end
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
        plot(currentBallIndices(reachIndx,1), trialPositionReach, 'k.', 'MarkerSize', 8)
        plot(currentSlotIndices(transportIndx,1)+50, trialPositionTransport, 'k.', 'MarkerSize', 8)
        clear startReach startTransport ballApproach ballGrasp ballInSlot slotApproach
        clear ballOffsets ballOnsets slotOnsets slotOffsets reachIndx transportIndx
        clear trialPositionReach trialPositionTransport trialStart
    end
    
end

%% Now plot fixation duration histograms (Panels C & F)
fixationsBall = [];
fixationsSlot = [];
for j = 1:numParticipants% loop over subjects
    for currentID = 3:4 % two dual task blocks
        currentResult = pulledData{j,currentID};
        currentParticipant = currentResult(currentID).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = currentID;
        counterBall = 1;
        counterSlot = 1;
        trialLength = NaN(numTrials,2);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballFixations = currentResult(n).gaze.fixation.durationBall;
            numBallFixations = length(ballFixations);
            slotFixations = currentResult(n).gaze.fixation.durationSlot;
            numSlotFixations = length(slotFixations);
            currentBallFixations(counterBall:counterBall+numBallFixations-1,1:3) = [currentParticipant*ones(numBallFixations,1) ...
                testID*ones(numBallFixations,1) ballFixations'];
            counterBall = counterBall + numBallFixations;
            currentSlotFixations(counterSlot:counterSlot+numSlotFixations-1,1:3) = [currentParticipant*ones(numSlotFixations,1) ...
                testID*ones(numSlotFixations,1) slotFixations'];
            counterSlot = counterSlot + numSlotFixations;
            
        end      
        fixationsBall = [fixationsBall; currentBallFixations];
        fixationsSlot = [fixationsSlot; currentSlotFixations];
        clear currentBallFixations currentSlotFixations  
    end
end
%% fixation durations finger tips
fingertipsBall = fixationsBall(fixationsBall(:,2) == 3,end);
fingertipsSlot = fixationsSlot(fixationsSlot(:,2) == 3,end);
endFrame = max([max(fingertipsSlot) max(fingertipsBall)]);

figure(5)
xlim([0 1.5])
ylim([0 75])
set(gca, 'Ytick', [0 25 50 75])
hold on
box off
histf(fingertipsBall',0:.1:endFrame,'facecolor',orange,'edgecolor','none')
histf(fingertipsSlot',0:.1:endFrame,'facecolor','none','edgecolor',green, 'LineWidth', 2)
%% fixation durations tweezers
tweezersBall = fixationsBall(fixationsBall(:,2) == 4,end);
tweezersSlot = fixationsSlot(fixationsSlot(:,2) == 4,end);
endFrame = max([max(tweezersSlot) max(tweezersBall)]);

figure(6)
xlim([0 1.5])
ylim([0 75])
set(gca, 'Ytick', [0 25 50 75])
hold on
box off
histf(tweezersBall',0:.1:endFrame,'facecolor',orange,'edgecolor','none')
histf(tweezersSlot',0:.1:endFrame,'facecolor','none','edgecolor',green, 'LineWidth', 2)