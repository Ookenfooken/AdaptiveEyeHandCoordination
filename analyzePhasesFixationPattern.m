analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
%% define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
phaseDurations = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over participants
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        fixationPattern = NaN(numTrials,1);
        reachDuration = NaN(numTrials,1);
        ballApproach = NaN(numTrials,1);
        ballGrasp = NaN(numTrials, 1);
        transportDuration = NaN(numTrials,1);
        slotApproach = NaN(numTrials,1);
        slotEntry = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current participant & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % we are only interested in fixations that occur before ball
            % grasp/slot entry
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                if currentResult(n).gaze.fixation.onsetsBall(1)+currentResult(n).info.trialStart ...
                        >= currentResult(n).info.phaseStart.ballGrasp
                    continue
                end
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                if currentResult(n).gaze.fixation.onsetsSlot(1)+currentResult(n).info.trialStart...
                        >= currentResult(n).info.phaseStart.ballInSlot
                    continue
                end
            end
            % ball and slot fixations during reach and transport phase
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern(n) = 1;
            else
                % more than one ball fixation cannot be calssified
                if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                    continue
                end
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift 
                    fixationPattern(n) = 3;
                else
                    fixationPattern(n) = 4;
                end
            end
            reachDuration(n) = currentResult(n).info.phaseDuration.primaryReach/200; % in seconds
            ballApproach(n) = currentResult(n).info.phaseDuration.ballApproach/200; 
            ballGrasp(n) = currentResult(n).info.phaseDuration.ballGrasp/200; 
            transportDuration(n) = currentResult(n).info.phaseDuration.transport/200;
            slotApproach(n) = currentResult(n).info.phaseDuration.slotApproach/200;
            slotEntry(n) = currentResult(n).info.phaseDuration.ballInSlot/200;
            
            currentDurations = [blockID*ones(numTrials,1) currentParticipant*ones(numTrials,1) ...
                fixationPattern reachDuration ballApproach ballGrasp transportDuration  ...
                slotApproach slotEntry];
        end
        phaseDurations = [phaseDurations; currentDurations];
    end
end
clear ballIdx ballOffset slotIdx slotOnset ballFixType
%% read out fingertip trials
blockID = 3;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
count = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end);
    % most common pattern
    displayOnly = currentParticipant(currentParticipant(:,1) == 0,:); % select fixation pattern
    slotOnly = currentParticipant(currentParticipant(:,1) == 2,:); % select fixation pattern
    % only include participants that have at least 1 trials in each pattern
    if size(displayOnly,1) < 1 || size(slotOnly,1) < 1
        continue
    end
    % save durations into structure for stats
    durationFT(count,:) = [blockID i 0 nanmedian(displayOnly(:,2:end),1)]; 
    durationFT(count+1,:) = [blockID i 2 nanmedian(slotOnly(:,2:end),1)];
    count = count+2;
end
%% read out tweezer trials
blockID = 4;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
counter = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end); % select fixation pattern
    % only include participants that have at least 1 trial in each pattern
    ballSlot = currentParticipant(currentParticipant(:,1) == 3,:);
    ballDisplaySlot = currentParticipant(currentParticipant(:,1) == 4,:); % select fixation pattern
    if size(ballSlot,1) < 1 || size(ballDisplaySlot,1) < 1
        continue
    end
    % save durations into structure for stats
    durationTW(counter,:) = [blockID i 3 nanmedian(ballSlot(:,2:end),1)];
    durationTW(counter+1,:) = [blockID i 4 nanmedian(ballDisplaySlot(:,2:end),1)];
    counter = counter+2;
end
%% save phase durations for statistical analysis in R
fixationPatternPhases = [durationFT; durationTW];
cd(savePath)
save('fixationPatternPhases', 'fixationPatternPhases');
cd(analysisPath)