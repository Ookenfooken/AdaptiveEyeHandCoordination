analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
% define some specs
numParticipants = 11;
sampleRate = 200;
numBlocks = size(pulledData,2);
phaseTiming = [];

for j = 1:numParticipants % loop over subjects
    for i = 3:numBlocks % loop over dual task
        currentResult = pulledData{j,i};
        numTrials = length(currentResult);
        testID = i*ones(numTrials,1);
        participant = currentResult(i).info.subject*ones(numTrials, 1);
        preReachDuration = NaN(numTrials,1);
        reachDuration = NaN(numTrials,1);
        ballApproachDuration = NaN(numTrials,1);
        ballGraspDuration = NaN(numTrials,1);
        transportDuration = NaN(numTrials,1);
        slotApproachDuration = NaN(numTrials,1);
        slotEntryDuration = NaN(numTrials,1);
        returnDuration = NaN(numTrials,1);
        graspRelLift = NaN(numTrials,1);
        entryRelLift = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            preReachBin = 1;
            if currentResult(n).dualTask.tLetterChanges(1) > currentResult(n).info.timeStamp.reach || ...
                currentResult(n).dualTask.tLetterChanges(1) < currentResult(n).info.timeStamp.reach - preReachBin
                continue
            end
            % duration
            preReachDuration(n) = (currentResult(n).info.timeStamp.reach - currentResult(n).info.timeStamp.start)*sampleRate;
            reachDuration(n) = currentResult(n).info.phaseDuration.primaryReach; 
            ballApproachDuration(n) = currentResult(n).info.phaseDuration.ballApproach;
            ballGraspDuration(n) = currentResult(n).info.phaseDuration.ballGrasp;
            transportDuration(n) = currentResult(n).info.phaseDuration.transport;
            slotApproachDuration(n) = currentResult(n).info.phaseDuration.slotApproach;
            slotEntryDuration(n) = currentResult(n).info.phaseDuration.ballInSlot;
            returnDuration(n) = currentResult(n).info.phaseDuration.return;
            graspRelLift(n) = currentResult(n).info.phaseStart.ballGrasp - ...
                currentResult(n).info.phaseStart.transport;
            entryRelLift(n) = currentResult(n).info.phaseStart.ballInSlot - ...
                currentResult(n).info.phaseStart.transport;
        end
        currentVariable = [testID participant reachDuration ballApproachDuration ballGraspDuration ...
            transportDuration slotApproachDuration slotEntryDuration ...
            returnDuration graspRelLift entryRelLift preReachDuration];
        
        phaseTiming = [phaseTiming; currentVariable];
        
    end
end

%% save data 
% first save norms for normalization plot
numColumns = 10;
phasesParticipants = NaN(numParticipants*numBlocks,numColumns);
count = 1;
% calculate averate duration for each phase
for j = 1:numParticipants
    currentSubject = phaseTiming(phaseTiming(:,1) == j, :);
    
    for i = 1:numBlocks
        currentBlock = currentSubject(currentSubject(:,2) == i, :);
        phasesParticipants(count,:) = [i j nanmedian(currentBlock(:,3)) ...
            nanmedian(currentBlock(:,4)+currentBlock(:,5)) nanmedian(currentBlock(:,6))...
            nanmedian(currentBlock(:,7)+currentBlock(:,8)) nanmedian(currentBlock(:,9:12))];
        count = count + 1;
    end
end

phaseDurationEarlyReaches = NaN(numBlocks, numColumns);
for i = 1:numBlocks
    phaseDurationEarlyReaches(i,:) = nanmean(phasesParticipants(phasesParticipants(:,1) == i, :));
end

cd(resultPath)
save('phaseDurationEarlyReaches', 'phaseDurationEarlyReaches')
cd(analysisPath)
