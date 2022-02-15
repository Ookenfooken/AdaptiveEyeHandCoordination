% load in data
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData.mat')
cd(analysisPath)
numSubjects = 11;
%%
singleTask = [];
for j = 1:numSubjects % loop over subjects
    for i = 1:2 % loop over blocks/experimental conditions
        currentResult = pulledData{j,i};
        currentParticipant = currentResult(i).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        subject = currentParticipant*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
        dual = zeros(numTrials,1);
        gazeShiftToSlot = NaN(numTrials,1);
        gazeShiftReturn = NaN(numTrials,1);
        if testID == 1
            tool = zeros(numTrials,1); % no tool in fingertip condition
        elseif testID == 2
            tool = ones(numTrials,1); %tweezers
        end
        dropped = zeros(numTrials,1);
        
        for n = 1:numTrials % loop over trials for current subject & block
            if currentResult(n).info.dropped
                dropped(n) = 1;
                continue
            end
            ballLiftoff = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart;
            if ~isempty(currentResult(n).gaze.saccades.onsets) && ...
                    ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                %                 % find first slot fixation after movement onset
                %                 slotIdx = max([1 find(currentResult(n).gaze.fixation.onsetsSlot > ...
                %                     (currentResult(n).info.phaseStart.primaryReach - currentResult(n).info.trialStart), 1, 'first')]);
                slotIdx = find(currentResult(n).gaze.fixation.durationSlot == ...
                    max(currentResult(n).gaze.fixation.durationSlot));
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                % find the last ball fixation offset before slot fixation onset
                ballOffsetIdx = find(currentResult(n).gaze.fixation.offsetsBall < slotOnset, 1, 'last');
                if ~isempty(ballOffsetIdx)
                    gazeShiftToSlot(n) = (currentResult(n).gaze.fixation.offsetsBall(ballOffsetIdx)+1 - ballLiftoff)/.2; % in miliseconds
                end
            end
            ballDropped = currentResult(n).info.phaseStart.ballDropped - currentResult(n).info.trialStart;
            if ~isempty(currentResult(n).gaze.saccades.onsets) && ...
                    ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                % find first ball fixation after liftoff (anticipatory)
                ballFixIdx = find(currentResult(n).gaze.fixation.onsetsBall > ballLiftoff, 1, 'first');
                if ~isempty(ballFixIdx)
                    onsetFinalFix = currentResult(n).gaze.fixation.onsetsBall(ballFixIdx);
                end
                % find last slot fixation offset before final ball fixation onset
                slotOffsetIdx = find(currentResult(n).gaze.fixation.offsetsSlot < onsetFinalFix, 1, 'last');
                if ~isempty(slotOffsetIdx)
                    gazeShiftReturn(n) = (currentResult(n).gaze.fixation.offsetsSlot(slotOffsetIdx)+1-ballDropped)/.2;
                end
            end
        end
        % add two empty columns to have consitent size with dual task
        currentVariable = [subject testID tool dual NaN(numTrials,1) NaN(numTrials,1) ...
            gazeShiftToSlot gazeShiftReturn];
        
        singleTask = [singleTask; currentVariable];
        
    end
end

%%
dualTask = [];
for j = 1:numSubjects % loop over subjects
    for i = 3:4 % loop over blocks/experimental conditions
        currentResult = pulledData{j,i};
        currentParticipant = currentResult(i).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        subject = currentParticipant*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
        dual = ones(numTrials,1);
        gazeShiftDispBall = NaN(numTrials,1);
        gazeShiftballDisp = NaN(numTrials,1);
        gazeShiftDispSlot = NaN(numTrials,1);
        gazeShiftSlotDisp = NaN(numTrials,1);
        if testID == 3
            tool = zeros(numTrials,1); % no tool in fingertip condition
        elseif testID == 4
            tool = ones(numTrials,1); %tweezers
        end
        dropped = zeros(numTrials,1);
        
        for n = 1:numTrials % loop over trials for current subject & block
            if currentResult(n).info.dropped
                dropped(n) = 1;
                continue
            end
            ballGrasp = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart;
            ballLiftoff = currentResult(n).info.phaseStart.transport - currentResult(n).info.trialStart;
            if ~isempty(currentResult(n).gaze.saccades.onsets) && ...
                    ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                % find first ball fixation after movement onset
                ballIdx = max([1 find(currentResult(n).gaze.fixation.onsetsBall > ...
                    (currentResult(n).info.phaseStart.primaryReach - currentResult(n).info.trialStart), 1, 'first')]);
                ballOnset = currentResult(n).gaze.fixation.onsetsBall(ballIdx);
                % find last display fixation offset before ball fixation
                dispOffset1 = find(currentResult(n).gaze.fixation.offsetsDisplay < ballOnset, 1, 'last');
                if ~isempty(dispOffset1)
                    % gaze shift from display to ball relative to grasp
                    gazeShiftDispBall(n) = (currentResult(n).gaze.fixation.offsetsDisplay(dispOffset1)+1 - ballGrasp)/.2;
                    % gaze shfit from ball back to display relative to liftoff
                    gazeShiftballDisp(n) = (currentResult(n).gaze.fixation.offsetsBall(ballIdx)+1 - ballLiftoff)/.2;
                end
            end
            slotEntry = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart;
            ballDropped = currentResult(n).info.phaseStart.ballDropped - currentResult(n).info.trialStart;
            if ~isempty(currentResult(n).gaze.fixation.offsetsDisplay) && ...
                    ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                % find first slot fixation after movement onset
                slotIdx = find(currentResult(n).gaze.fixation.durationSlot == ...
                    max(currentResult(n).gaze.fixation.durationSlot));
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                % find last either display or ball fixation offset before slot fixation
                dispOffset2 = find(currentResult(n).gaze.fixation.offsetsDisplay < slotOnset(1), 1, 'last');
                ballOffset = find(currentResult(n).gaze.fixation.offsetsBall < slotOnset(1), 1, 'last');
                if isempty(ballOffset) && ~isempty(dispOffset2)
                    % gaze shift from display to slot
                    gazeShiftDispSlot(n) = (currentResult(n).gaze.fixation.offsetsDisplay(dispOffset2)+1-slotEntry)/.2;
                elseif ~isempty(ballOffset) && isempty(dispOffset2)
                    % gaze shift from ball to slot
                    gazeShiftDispSlot(n) = (currentResult(n).gaze.fixation.offsetsBall(ballOffset)+1-slotEntry)/.2;
                elseif currentResult(n).gaze.fixation.offsetsDisplay(dispOffset2) > ...
                        currentResult(n).gaze.fixation.offsetsBall(ballOffset)
                    % gaze shift from display to slot
                    gazeShiftDispSlot(n) = (currentResult(n).gaze.fixation.offsetsDisplay(dispOffset2)+1-slotEntry)/.2;
                elseif currentResult(n).gaze.fixation.offsetsBall(ballOffset) > ...
                        currentResult(n).gaze.fixation.offsetsDisplay(dispOffset2)
                    % gaze shift from ball to slot
                    gazeShiftDispSlot(n) = (currentResult(n).gaze.fixation.offsetsBall(ballOffset)+1-slotEntry)/.2;
                end
                % gaze shift from slot back to display
                gazeShiftSlotDisp(n) = (currentResult(n).gaze.fixation.offsetsSlot(slotIdx(1))+1-ballDropped)/.2;
            end
        end        
        currentVariable = [subject testID tool dual gazeShiftDispBall gazeShiftballDisp ...
            gazeShiftDispSlot gazeShiftSlotDisp];
        
        dualTask = [dualTask; currentVariable];
    end
    
end

%%
spatiotemporalCoordination = [singleTask; dualTask];
cd(savePath)
save('spatiotemporalCoordination', 'spatiotemporalCoordination')
cd(analysisPath)