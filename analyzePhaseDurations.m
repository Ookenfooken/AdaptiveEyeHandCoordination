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
numBlocks = size(pulledData,2);
vigilanceBlocks = [3 4];
tweezersBlocks = [2 4];
phaseTiming = [];

for j = 1:numParticipants % loop over subjects
    for i = 1:numBlocks % loop over blocks/experimental conditions
        currentResult = pulledData{j,i};
        currentSubject = currentResult(i).info.subject;
        numTrials = length(currentResult);
        if ismember(i, vigilanceBlocks) %single vs. dual
            dual = ones(numTrials,1);
        else
            dual = zeros(numTrials,1);
        end
        if ismember(i, tweezersBlocks) %PG vs. TW
            tool = ones(numTrials,1);
        else
            tool = zeros(numTrials,1);
        end
        participant = currentSubject*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
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
            % duration
            reachDuration(n) = currentResult(n).info.phaseDuration.primaryReach; % in secs
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
        currentVariable = [participant testID tool dual ...
            reachDuration ballApproachDuration ballGraspDuration ...
            transportDuration slotApproachDuration slotEntryDuration ...
            returnDuration graspRelLift entryRelLift];
        
        phaseTiming = [phaseTiming; currentVariable];
        
    end
end

%% save data 
% first save norms for normalization plot
numColumns = 9;
phasesParticipants = NaN(numParticipants*numBlocks,numColumns);
count = 1;
% calculate averate duration for each phase
for j = 1:numParticipants
    currentSubject = phaseTiming(phaseTiming(:,1) == j, :);
    
    for i = 1:numBlocks
        currentBlock = currentSubject(currentSubject(:,2) == i, :);
        phasesParticipants(count,:) = [i j nanmedian(currentBlock(:,5)) ...
            nanmedian(currentBlock(:,6)+currentBlock(:,7)) nanmedian(currentBlock(:,8))...
            nanmedian(currentBlock(:,9)+currentBlock(:,10)) nanmedian(currentBlock(:,11:13))];
        count = count + 1;
    end
end

phaseDurationNorm = NaN(numBlocks, numColumns);
for i = 1:numBlocks
    phaseDurationNorm(i,:) = nanmean(phasesParticipants(phasesParticipants(:,1) == i, :));
end

cd(resultPath)
save('phaseDurationNorm', 'phaseDurationNorm')
cd(analysisPath)
%% second save data for stats analysis
sampleRate = 200;
phaseDurations = [phaseTiming(:,1:4) phaseTiming(:,5:end-2)./sampleRate];
cd(savePath)
save('phaseDurations', 'phaseDurations')
cd(analysisPath)