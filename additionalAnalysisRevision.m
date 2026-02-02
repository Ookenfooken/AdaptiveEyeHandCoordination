analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
numParticipants = 11;

%%
%% cumulatives single task
fixationsOverview = [];
for blockID = 1:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % open variable matrices that we want to pull
        currentFixations = NaN(numTrials,11);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if n < 16
                earlyTrial = 1;
            else
                earlyTrial = 0;
            end
            % ball event and fixations
            reach = currentResult(n).info.phaseStart.primaryReach - currentResult(n).info.trialStart+1;
            ballGrasp = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart+1;
            ballIdx = find(currentResult(n).gaze.fixation.onsetsBall < ballGrasp, 1, 'last');
            if ~isempty(ballIdx)
                ballOnsetRelReach = (currentResult(n).gaze.fixation.onsetsBall(ballIdx)-reach)/.2;
                ballOffsetRelReach = (currentResult(n).gaze.fixation.offsetsBall(ballIdx)-reach)/.2;
                ballOnsetRelGrasp = (currentResult(n).gaze.fixation.onsetsBall(ballIdx)-ballGrasp)/.2;
                ballOffsetRelGrasp = (currentResult(n).gaze.fixation.offsetsBall(ballIdx)-ballGrasp)/.2;
            else
                ballOnsetRelReach = NaN;
                ballOffsetRelReach = NaN;
                ballOnsetRelGrasp = NaN;
                ballOffsetRelGrasp = NaN;
            end
            % slot fixations
            slotEntry = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart+1;
            transport = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart+1;
            slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot < slotEntry, 1, 'last');
            if ~isempty(slotIdx)
                slotOnsetRelTransport = (currentResult(n).gaze.fixation.onsetsSlot(slotIdx)-transport)/.2;
                slotOffsetRelTransport = (currentResult(n).gaze.fixation.offsetsSlot(slotIdx)-transport)/.2;
                slotOnsetRelEntry = (currentResult(n).gaze.fixation.onsetsSlot(slotIdx)-slotEntry)/.2;
                slotOffsetRelEntry = (currentResult(n).gaze.fixation.offsetsSlot(slotIdx)-slotEntry)/.2;
            else
                slotOnsetRelTransport = NaN;
                slotOffsetRelTransport = NaN;
                slotOnsetRelEntry = NaN;
                slotOffsetRelEntry = NaN;
            end

           currentFixations(n,:) = [blockID currentParticipant earlyTrial ...
               ballOnsetRelReach ballOffsetRelReach ballOnsetRelGrasp ballOffsetRelGrasp ...
               slotOnsetRelTransport slotOffsetRelTransport slotOnsetRelEntry slotOffsetRelEntry];
        end
        fixationsOverview = [fixationsOverview; currentFixations];

        clear currentFixations ballOnsetRelReach ballOffsetRelReach ballOnsetRelGrasp ballOffsetRelGrasp
        clear slotOnsetRelTransport slotOffsetRelTransport slotOnsetRelEntry slotOffsetRelEntry
        clear reach ballGrasp ballIdx slotEntry transport slotIdx
    end
end

%% Aggregate data
fixationOnOffsets = NaN(numParticipants*4*2,11);
count = 1;
for blockID = 1:4
    currentCondition = fixationsOverview(fixationsOverview(:,1) == blockID, :);
    for pat = 1:numParticipants
        currentParticipant = currentCondition(currentCondition(:,2) == pat, :);
        for i = 1:2
            currentMeans = currentParticipant(currentParticipant(:,3) == i-1, 4:end);
            fixationOnOffsets(count,:) = [blockID pat i-1 nanmedian(currentMeans,1)];
            count = count + 1;
        end
    end
end
%%
cd("R\")
csvwrite("fixationOnOffsets.csv", fixationOnOffsets)
cd(analysisPath)