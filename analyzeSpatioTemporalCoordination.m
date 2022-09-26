% load in data
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData.mat')
cd(analysisPath)
numSubjects = 11;
numBlocks = size(pulledData,2);
%%
spatiotemporalCoordination = [];
for j = 1:numSubjects % loop over subjects
    for i = 1:numBlocks % loop over all blcoks
        currentResult = pulledData{j,i};
        currentParticipant = currentResult(i).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        % open variable matrices that we want to pull
        participant = currentParticipant*ones(numTrials, 1);
        testID = i*ones(numTrials,1);
        dual = zeros(numTrials,1);
        gazeShiftToSlot = NaN(numTrials,1);
        gazeShiftReturn = NaN(numTrials,1);
        if testID(1) == 1 || testID(1) == 3
            tool = zeros(numTrials,1); % no tool in fingertip condition
        elseif testID(1) == 2 || testID(1) == 4
            tool = ones(numTrials,1); %tweezers
        end        
        for n = 1:numTrials % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if i < 3 % single task condition
                ballGrasp = currentResult(n).info.phaseStart.ballGrasp - currentResult(n).info.trialStart;
                if ~isempty(currentResult(n).gaze.saccades.onsets) && ...
                        ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                    % find the main slot fixation
                    slotIdx = find(currentResult(n).gaze.fixation.durationSlot == ...
                        max(currentResult(n).gaze.fixation.durationSlot));
                    slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                    % find the last saccade before slot fixation onset
                    slotSacIdx = find(currentResult(n).gaze.saccades.onsets < slotOnset, 1, 'last');
                    if ~isempty(slotSacIdx)
                        gazeShiftToSlot(n) = (currentResult(n).gaze.saccades.onsets(slotSacIdx) - ballGrasp)/.2; % in miliseconds
                    end
                end
            else % dual task condition
                dual(n) = 1;
                slotEntry = currentResult(n).info.phaseStart.ballInSlot - currentResult(n).info.trialStart;
                if ~isempty(currentResult(n).gaze.saccades.onsets) && ...
                        ~isempty(currentResult(n).gaze.fixation.onsetsDisplay)
                    % find the last saccade to the display
                    dispSacIdx = find(currentResult(n).gaze.saccades.onsets < currentResult(n).gaze.fixation.onsetsDisplay(end), 1, 'last');
                    if ~isempty(dispSacIdx)
                        gazeShiftReturn(n) = (currentResult(n).gaze.saccades.onsets(dispSacIdx) - slotEntry)/.2; % in miliseconds
                    end
                end
            end
        end
        % add two empty columns to have consitent size with dual task
        currentVariable = [participant testID tool dual ...
            gazeShiftToSlot gazeShiftReturn];
        
        spatiotemporalCoordination = [spatiotemporalCoordination; currentVariable];
        
    end
end

%%
cd(savePath)
save('spatiotemporalCoordination', 'spatiotemporalCoordination')
cd(analysisPath)