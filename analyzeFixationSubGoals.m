analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)

%% subtract the mean from each phase start for each participant
variables = [];
numParticipants = 11;
numBlocks = 4;
for j = 1:numParticipants % loop over subjects
    for i = 3:numBlocks % loop over dual blocks 
        currentResult = pulledData{j,i};
        currentParticipant = currentResult(i).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % open variable matrices that we want to pull
        participant = currentParticipant*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
        reachOnset = NaN(numTrials,1);
        reachPeakVel = NaN(numTrials,1);
        ballApproach = NaN(numTrials,1);
        ballGrasp = NaN(numTrials,1);
        transport = NaN(numTrials,1);
        transportPeakVel = NaN(numTrials,1);
        slotApproach = NaN(numTrials,1);
        slotEntry = NaN(numTrials,1);
        ballFixations = zeros(numTrials,1);
        ballOnsets = NaN(numTrials,1);
        ballOffsets = NaN(numTrials,1);
        ballMidpoint = NaN(numTrials,1);
        slotFixation = zeros(numTrials,1);
        slotOnsets = NaN(numTrials,1);
        slotOffsets = NaN(numTrials,1);
        slotMidpoint = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            % phase start
            toolVelocity = currentResult(n).effector.velocity;
            startTransport = currentResult(n).info.phaseStart.transport;
            startFrame = 1;
            stopFrame = startTransport-trialStart;
            if stopFrame <= startFrame
                continue
            end
            reachOnset(n) = currentResult(n).info.phaseStart.primaryReach ;
            reachPeakVel(n) = find(toolVelocity(startFrame:stopFrame) == max(toolVelocity(startFrame:stopFrame))) + trialStart;
            ballApproach(n) = currentResult(n).info.phaseStart.ballApproach;
            ballGrasp(n) = currentResult(n).info.phaseStart.ballGrasp;
            transport(n) = startTransport;
            transportPeakVel(n) = startTransport + find(toolVelocity(stopFrame:currentResult(n).info.phaseStart.slotApproach-trialStart)...
                == max(toolVelocity(stopFrame:currentResult(n).info.phaseStart.slotApproach-trialStart)), 1, 'first');
            slotApproach(n) = currentResult(n).info.phaseStart.slotApproach;
            slotEntry(n) = currentResult(n).info.phaseStart.ballInSlot;
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballFixations(n) = 1;
                ballOnsets(n) = currentResult(n).gaze.fixation.onsetsBall(1)+trialStart;
                ballOffsets(n) = currentResult(n).gaze.fixation.offsetsBall(1)+trialStart;
                ballMidpoint(n) = ballOnsets(n) + (ballOffsets(n) - ballOnsets(n))/2;
                if numel(currentResult(n).gaze.fixation.onsetsBall)>1
                    ballFixations(n) = 2;
                end
            end
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                slotFixation(n) = 1;
                if numel(currentResult(n).gaze.fixation.onsetsSlot) > 1
                    slotFixation(n) = 2;
                    slotIndx = find(currentResult(n).gaze.fixation.onsetsSlot+trialStart > startTransport, 1, 'first');
                    if ~isempty(slotIndx)
                        slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot(slotIndx)+trialStart;
                        slotOffsets(n) = currentResult(n).gaze.fixation.offsetsSlot(slotIndx)+trialStart;
                    else
                        slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot(1)+trialStart;
                        slotOffsets(n) = currentResult(n).gaze.fixation.offsetsSlot(1)+trialStart;
                    end
                else
                    slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot+trialStart;
                    slotOffsets(n) = currentResult(n).gaze.fixation.offsetsSlot+trialStart;
                end
                slotMidpoint(n) = slotOnsets(n) + (slotOffsets(n) - slotOnsets(n))/2;
            end
            clear toolVelocity slotIndx startFrame stopFrame trialStart
        end
        currentVariable = [participant testID reachOnset ...
            reachPeakVel ballApproach ballGrasp transport transportPeakVel slotApproach slotEntry ...
            ballFixations ballOnsets ballOffsets ballMidpoint ...
            slotFixation slotOnsets slotOffsets slotMidpoint];
        
        variables = [variables; currentVariable];
        
    end
end
%% separate data into conditions
ballFixations = [variables(:,1:2) variables(:,11) variables(:,3:10) variables(:,12:14)]; % paste relevant ball data
ballFixations = ballFixations(ballFixations(:,3) > 0, :);
ballFixations_adjusted = [];
for tool = 3:4
    currentTool = ballFixations(ballFixations(:,2) == tool, :);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,1) == i, :);
        currentPhases = currentParticipant(:,4:11) - mean(currentParticipant(:,4:11));
        ballFixations_adjusted = [ballFixations_adjusted; ...
            [currentParticipant(:,1:3) currentPhases currentParticipant(:,12:14)]];
    end
end

slotFixations = [variables(:,1:2) variables(:,15) variables(:,3:10) variables(:,16:18)]; % paste relevatn slot data
slotFixations = slotFixations(slotFixations(:,3) > 0, :);
slotFixations_adjusted = [];
for tool = 3:4
    currentTool = slotFixations(slotFixations(:,2) == tool, :);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,1) == i, :);
        currentPhases = currentParticipant(:,4:11) - mean(currentParticipant(:,4:11));
        slotFixations_adjusted = [slotFixations_adjusted; ...
            [currentParticipant(:,1:3) currentPhases currentParticipant(:,12:14)]];
    end
end
%%
glmData_ball = ballFixations_adjusted;
glmData_slot = slotFixations_adjusted;
cd(fullfile(pwd,'R\'))
save('glmData_ball', 'glmData_ball')
save('glmData_slot', 'glmData_slot')
cd(analysisPath)