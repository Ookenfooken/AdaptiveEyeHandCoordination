analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
numParticipants = 11;
numBlocks = size(pulledData,2);
variables = [];

for j = 1:numParticipants % loop over subjects
    for i = 3:numBlocks % loop over dual blocks 
        currentResult = pulledData{j,i};
        currentParticipant = currentResult(i).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % find range of reach and transport start
        reachOnsets = NaN(numTrials,1);
        transportOnsets = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            reachOnsets(n) = currentResult(n).info.phaseStart.primaryReach;
            transportOnsets(n) = currentResult(n).info.phaseStart.transport;
        end
        % exclude drast outliers
        earlyReaches = nanmean(reachOnsets) - 3*nanstd(reachOnsets);
        lateReaches = nanmean(reachOnsets) + 3*nanstd(reachOnsets);
        earlyTransports = nanmean(transportOnsets) - 3*nanstd(transportOnsets);
        lateTransports = nanmean(transportOnsets) + 3*nanstd(transportOnsets);
        % open variable matrices that we want to pull
        participant = currentParticipant*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
        reachPeakVel = NaN(numTrials,1);
        ballApproach = NaN(numTrials,1);
        ballGrasp = NaN(numTrials,1);
        transport = NaN(numTrials,1);
        transportPeakVel = NaN(numTrials,1);
        slotApproach = NaN(numTrials,1);
        ballInSlot = NaN(numTrials,1);
        ballFixations = zeros(numTrials,1);
        ballOnsets = NaN(numTrials,1);
        slotFixation = zeros(numTrials,1);
        slotOnsets = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            % phase start
            startReach = currentResult(n).info.phaseStart.primaryReach;
            toolVelocity = currentResult(n).effector.velocity;
            if startReach < earlyReaches || startReach > lateReaches
                continue
            end
            startTransport = currentResult(n).info.phaseStart.transport;
            if startTransport < earlyTransports || startTransport > lateTransports
                continue
            end
            startFrame = max([startReach-trialStart 1]);
            stopFrame = startTransport-trialStart;
            if stopFrame <= startFrame
                continue
            end
            reachPeakVel(n) = find(toolVelocity(startFrame:stopFrame) == max(toolVelocity(startFrame:stopFrame)));
            ballApproach(n) = currentResult(n).info.phaseStart.ballApproach-startReach;
            ballGrasp(n) = currentResult(n).info.phaseStart.ballGrasp-startReach;
            transport(n) = startTransport-startReach;
            transportPeakVel(n) = transport(n) + find(toolVelocity(stopFrame:currentResult(n).info.phaseStart.slotApproach-trialStart)...
                == max(toolVelocity(stopFrame:currentResult(n).info.phaseStart.slotApproach-trialStart)), 1, 'first');
            slotApproach(n) = currentResult(n).info.phaseStart.slotApproach-startReach;
            ballInSlot(n) = currentResult(n).info.phaseStart.ballInSlot-startReach;
            
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                ballFixations(n) = 1;
                ballOnsets(n) = currentResult(n).gaze.fixation.onsetsBall(1)+trialStart-startReach;
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
                        slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot(slotIndx)+trialStart-startReach;
                    else
                        slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot(1)+trialStart-startReach;
                    end
                else
                    slotOnsets(n) = currentResult(n).gaze.fixation.onsetsSlot+trialStart-startReach;
                end
            end
            clear startReach toolVelocity slotIndx startFrame stopFrame trialStart
        end
        currentVariable = [participant testID ...
            reachPeakVel ballApproach ballGrasp transport transportPeakVel slotApproach ballInSlot ...
            ballFixations ballOnsets slotFixation slotOnsets];
        
        variables = [variables; currentVariable];
        
        clear earlyReaches earlyTransports lateReaches lateTransports
    end
end

glmData_ball = [variables(:,1:2) variables(:,10) variables(:,3:9) variables(:,11)]; % paste relevant ball data
glmData_slot = [variables(:,1:2) variables(:,12) variables(:,3:9) variables(:,13)]; % paste relevatn slot data
%%
cd(fullfile(pwd,'R\'))
save('glmData_ball', 'glmData_ball')
save('glmData_slot', 'glmData_slot')
cd(analysisPath)