% load in data
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
load('pulledData')
load('phaseStarts')
%load('phaseDurationNorm')
cd(analysisPath);

%%
% define some specs
orange = [255,127,0]./255;
green = [77,175,74]./255;
red = [228,26,28]./255;
blue = [55,126,184]./255;
%purple = [152,78,163]./255;
yellow = [254,217,118]./255;
numSubjects = 11;
eyeShift = 20;
sortedIndices = [];
i = 2; % 3:precision grip; 4:tweezers
% first read out the order of ball and slot phases. Then plot each fixation
% in each trial
for j = 1:numSubjects % loop over subjects
    %for i = 3:4 % loop over blocks/experimental conditions
    currentResult = pulledData{j,i};
    numTrials = length(currentResult);
    currentSubject = currentResult(i).info.subject*ones(numTrials,1);
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
    currentPhaseLength = [currentSubject (1:numTrials)' ballPhase slotPhase];
    sortedIndices = [sortedIndices; currentPhaseLength];%currentIndices];
end

sortedBalls = [sortrows(sortedIndices, 3) (1:length(sortedIndices))'];
sortedSlots = [sortrows(sortedIndices, 4) (1:length(sortedIndices))'];

%%
fixationTypeColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
figure(111)
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-500 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400 600 800], 'XtickLabel', [-2 -1 0 1 2 3])
hold on
figure(222)
set(gcf,'renderer','Painters', 'Position', [20 50 400 600])
xlim([-500 600])
ylim([0 350])
set(gca, 'Xtick', [-400 -200 0 200 400], 'XtickLabel', [-2 -1 0 1 2])
hold on
%figure(33)
%hold on
for j = 1:numSubjects % loop over subjects
    %for i = 3:4 % loop over blocks/experimental conditions
    currentResult = pulledData{j,i};
    currentSubject = currentResult(i).info.subject;
    numTrials = length(currentResult);
    currentBallIndices = sortedBalls(sortedBalls(:,1) == currentSubject, 2:end); %last column in matrix indicates position
    currentSlotIndices = sortedSlots(sortedSlots(:,1) == currentSubject, 2:end);
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
        % fixation type
        if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
            ballFixType = 0;
        elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
            ballFixType = 2;
        elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
            ballFixType = 1;
        else
            ballOnset = currentResult(n).gaze.fixation.onsetsBall(1);
            ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
            slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOnset, 1, 'first');
            slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
            if slotOnset-ballOffset < eyeShift
                ballFixType = 3;
            else
                ballFixType = 4;
            end
        end
        if isempty(currentResult(n).gaze.fixation.onsetsBall)%ballFixType == 0
            figure(111)
            line([0 0], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
        end
        % plot ball and slot fixations during reach and transport phase
        if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
            noFixBall = 0;
            ballOnsets = currentResult(n).gaze.fixation.onsetsBall;
            ballOffsets = currentResult(n).gaze.fixation.offsetsBall;
            for k = 1:numel(ballOnsets)
                figure(111)
                %figure(currentSubject)
                if k == 1
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp],...
                        [trialPositionReach trialPositionReach], 'Color', fixationTypeColors(ballFixType+1,:))
                else
                    line([ballOnsets(k)-ballGrasp ballOffsets(k)-ballGrasp-1],...
                        [trialPositionReach trialPositionReach], 'Color', red)
                end
            end
        %else
          %  figure(111)
          %  line([0 0], [trialPositionReach-.1 trialPositionReach+.1])
        end
        if isempty(currentResult(n).gaze.fixation.onsetsSlot)%ballFixType == 0
            figure(222)
            line([0 0], [trialPositionTransport-.1 trialPositionTransport+.1], 'Color', blue, 'LineWidth', 2)
        end
        if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
            noFixSlot = 0;
            slotOnsets = currentResult(n).gaze.fixation.onsetsSlot;
            slotOffsets = currentResult(n).gaze.fixation.offsetsSlot;
            numEarlyFix = 0;
            for k = 1:numel(slotOnsets)
%                 if slotOnsets(k) < startTransport+1
%                     numEarlyFix = numEarlyFix + 1;
%                     figure(111)
%                     line([slotOnsets(k)-ballGrasp slotOffsets(k)-ballGrasp],...
%                         [trialPositionReach trialPositionReach], 'Color', green)
%                 end
                figure(222)
                if k == 1%> numEarlyFix && k < numEarlyFix+2
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', fixationTypeColors(ballFixType+1,:))
                else %if k > numEarlyFix+1
                    line([slotOnsets(k)-ballInSlot slotOffsets(k)-ballInSlot],...
                        [trialPositionTransport trialPositionTransport], 'Color', red)
                end
            end
        %else
          %  figure(222)
           % line([0 0], [trialPositionTransport-.1 trialPositionTransport+.1])
        end
        figure(111) % zero indicates ball grasp
        plot(startReach-ballGrasp, trialPositionReach, 'k|') % start of primary reach
        plot(ballApproach-ballGrasp, trialPositionReach, '.', 'Color', yellow) % ball grasp
        plot(startTransport-ballGrasp, trialPositionReach, 'k|') % start of transport
        figure(222)
        plot(startTransport-ballInSlot, trialPositionTransport, 'k|') %start of transport
        plot(slotApproach-ballInSlot, trialPositionTransport, '.', 'Color', yellow) % ball in slot
        plot(currentResult(n).info.phaseStart.return-trialStart-ballInSlot, trialPositionTransport, 'k|')
        %figure(33)
        %         plot(currentBallIndices(reachIndx,1), trialPositionReach, 'k.')
        %         plot(currentSlotIndices(transportIndx,1)+50, trialPositionTransport, 'k.')
        %plot(currentSubject, trialPositionReach, 'r.')
        %plot(currentSubject+50, trialPositionTransport, 'r.')
    end
    
end



