analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%%
% define some specs
numSubjects = 11;
numBlocks = size(pulledData,2);
vigilanceBlocks = [3 4];
tweezersBlocks = [2 4];
phaseTiming = [];

for j = 1:numSubjects % loop over subjects
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
        ballPhaseDuration = NaN(numTrials,1);
        transportDuration = NaN(numTrials,1);
        slotPhaseDuration = NaN(numTrials,1);
        returnDuration = NaN(numTrials,1);
        graspRelLift = NaN(numTrials,1);
        entryRelLift = NaN(numTrials,1);
        for n = 1:numTrials % loop over trials for current subject & block
            if currentResult(n).info.dropped
                continue
            end
            % duration
            reachDuration(n) = currentResult(n).info.phaseDuration.primaryReach; % in secs
            ballPhaseDuration(n) = currentResult(n).info.phaseDuration.ballApproach + ...
                currentResult(n).info.phaseDuration.ballGrasp;
            transportDuration(n) = currentResult(n).info.phaseDuration.transport;
            slotPhaseDuration(n) = currentResult(n).info.phaseDuration.slotApproach + ...
                currentResult(n).info.phaseDuration.ballInSlot;
            returnDuration(n) = currentResult(n).info.phaseDuration.return;
            graspRelLift(n) = currentResult(n).info.phaseStart.ballGrasp - ...
                currentResult(n).info.phaseStart.transport;
            entryRelLift(n) = currentResult(n).info.phaseStart.ballInSlot - ...
                currentResult(n).info.phaseStart.transport;
        end
        currentVariable = [participant testID tool dual ...
            reachDuration ballPhaseDuration transportDuration slotPhaseDuration ...
            returnDuration graspRelLift entryRelLift];
        
        phaseTiming = [phaseTiming; currentVariable];
        
    end
end

%% save data 
% first save norms for normalization plot
numColumns = 9;
phasesParticipants = NaN(numSubjects*numBlocks,numColumns);
count = 1;
% calculate averate duration for each phase
for j = 1:numSubjects
    currentSubject = phaseTiming(phaseTiming(:,1) == j, :);
    
    for i = 1:numBlocks
        currentBlock = currentSubject(currentSubject(:,2) == i, :);
        phasesParticipants(count,:) = [i j nanmedian(currentBlock(:,5:end))];
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