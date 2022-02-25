analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
gazeSequence = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentSubject = currentResult(blockID).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        currentGazeSequence = NaN(30,27);
        trialCount = 1;
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % phase start
            trialStart = currentResult(n).info.trialStart;
            reach = max([1 currentResult(n).info.phaseStart.primaryReach-trialStart]);
            ballApproach = max([2 currentResult(n).info.phaseStart.ballApproach-trialStart]);
            ballGrasp = max([3 currentResult(n).info.phaseStart.ballGrasp-trialStart]);
            transport = max([4 currentResult(n).info.phaseStart.transport-trialStart]);
            slotApproach = currentResult(n).info.phaseStart.slotApproach-trialStart;
            ballInSlot = currentResult(n).info.phaseStart.ballInSlot-trialStart;
            trialEnd = length(currentResult(n).effector.X);
            returnPhase = min([currentResult(n).info.phaseStart.return-trialStart trialEnd-1]);
            % duration
            reachDuration = (currentResult(n).info.phaseStart.ballApproach-currentResult(n).info.phaseStart.primaryReach)/200;
            ballApproachDuration = (currentResult(n).info.phaseStart.ballGrasp-currentResult(n).info.phaseStart.ballApproach)/200;
            ballGraspDuration = (currentResult(n).info.phaseStart.transport-currentResult(n).info.phaseStart.ballGrasp)/200;
            transportDuration = (currentResult(n).info.phaseStart.slotApproach-currentResult(n).info.phaseStart.transport)/200;
            slotApproachDuration = (currentResult(n).info.phaseStart.ballInSlot-currentResult(n).info.phaseStart.slotApproach)/200;
            ballInSlotDuration = (currentResult(n).info.phaseStart.return-currentResult(n).info.phaseStart.ballInSlot)/200;
            returnDuration = max([1 (currentResult(n).info.trialEnd-currentResult(n).info.phaseStart.return)/200]);
            % distance
            X = currentResult(n).effector.X;
            Y = currentResult(n).effector.Y;
            reachDistance = nansum(sqrt((X(reach+1:ballApproach)-X(reach:ballApproach-1)).^2 + ...
                (Y(reach+1:ballApproach)-Y(reach:ballApproach-1)).^2));
            ballApproachDistance = nansum(sqrt((X(ballApproach+1:ballGrasp)-X(ballApproach:ballGrasp-1)).^2 + ...
                (Y(ballApproach+1:ballGrasp)-Y(ballApproach:ballGrasp-1)).^2));
            ballGraspDistance = nansum(sqrt((X(ballGrasp+1:transport)-X(ballGrasp:transport-1)).^2 + ...
                (Y(ballGrasp+1:transport)-Y(ballGrasp:transport-1)).^2));
            transportDistance = nansum(sqrt((X(transport+1:slotApproach)-X(transport:slotApproach-1)).^2 + ...
                (Y(transport+1:slotApproach)-Y(transport:slotApproach-1)).^2));
            slotApproachDistance = nansum(sqrt((X(slotApproach+1:ballInSlot)-X(slotApproach:ballInSlot-1)).^2 + ...
                (Y(slotApproach+1:ballInSlot)-Y(slotApproach:ballInSlot-1)).^2));
            ballInSlotDistance = nansum(sqrt((X(ballInSlot+1:returnPhase)-X(ballInSlot:returnPhase-1)).^2 + ...
                (Y(ballInSlot+1:returnPhase)-Y(ballInSlot:returnPhase-1)).^2));
            returnDistance = nansum(sqrt((X(returnPhase+1:trialEnd)-X(returnPhase:trialEnd-1)).^2 + ...
                (Y(returnPhase+1:trialEnd)-Y(returnPhase:trialEnd-1)).^2));
            % plot ball and slot fixations during reach and transport phase
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                ballFixType = 0;
                ballOnset = NaN;
                ballOffset = NaN;
                slotOnset = NaN;
                slotOffset = NaN;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                ballFixType = 2;
                ballOnset = NaN;
                ballOffset = NaN;
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(1);
                slotOffset = currentResult(n).gaze.fixation.offsetsSlot(1);
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                ballFixType = 1;
                ballOnset = currentResult(n).gaze.fixation.onsetsBall(1);
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotOnset = NaN;
                slotOffset = NaN;
            else
                ballOnset = currentResult(n).gaze.fixation.onsetsBall(1);
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                slotOffset = currentResult(n).gaze.fixation.offsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    ballFixType = 3;
                else
                    ballFixType = 4;
                end
            end
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                timeSlot = currentResult(n).gaze.fixation.onsetsSlot(end);
                sacTimeSlot = find(currentResult(n).gaze.saccades.onsets < timeSlot, 1, 'last');
                if ~isempty(sacTimeSlot)
                    slotSaccade = (ballInSlot - currentResult(n).gaze.saccades.onsets(sacTimeSlot))/200; %/.2; % in mili-seconds
                else
                    slotSaccade = NaN;
                end
            end
            letterChange = currentResult(n).dualTask.sampleLetterChange(1);
            letterRelativeReach = letterChange-currentResult(n).info.phaseStart.primaryReach;
            graspDifference = letterChange-currentResult(n).info.phaseStart.ballGrasp;
            earlyChangeGrasp = 0;
            %if numel(currentResult(n).gaze.saccades.onsets) > 0
            %     intialSaccadeLatency = currentResult(n).gaze.saccades.onsets(1)+trialStart;
            if letterChange < currentResult(n).info.phaseStart.ballGrasp%intialSaccadeLatency
                earlyChangeGrasp = 1;
            end
            % end
            dropDifference = letterChange-currentResult(n).info.phaseStart.ballInSlot;
            earlyChangeDrop = 0;
            if letterChange < currentResult(n).info.phaseStart.ballInSlot%intialSaccadeLatency
                earlyChangeDrop = 1;
            end
            trialLength = currentResult(n).info.length/200;
            fixationDisplay = sum(currentResult(n).gaze.fixation.durationDisplay);
            timeOffDisplay = trialLength-fixationDisplay;
            
            currentGazeSequence(trialCount,:) = [currentSubject, ballFixType, (ballOnset-ballApproach)/200, (ballOffset-ballOnset)/200, (slotOnset-slotApproach)/200, (slotOffset-slotOnset)/200, ...
                reachDuration, ballApproachDuration, ballGraspDuration, transportDuration, slotApproachDuration, ballInSlotDuration, returnDuration, ...
                reachDistance, ballApproachDistance, ballGraspDistance, transportDistance, slotApproachDistance, ballInSlotDistance, returnDistance, ...
                letterRelativeReach/200, earlyChangeGrasp, graspDifference/200, earlyChangeDrop, dropDifference/200 slotSaccade trialCount];
            trialCount = trialCount + 1;
        end
        gazeSequence = [gazeSequence; currentGazeSequence];
    end
end
