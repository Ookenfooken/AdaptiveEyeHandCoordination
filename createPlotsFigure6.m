% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% Calculate ball fixation onsets relative to letter changes
ballFixationReLetter = [];
numParticipants = 11;
eyeShift = 20;
sameCount = 0;
diffCount = 0;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 6;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        % first make a vector of all detected letter changes
        currentLetterChanges = [];
        detectedChanges = [];
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if ~isnan(currentResult(n).dualTask.tLetterChanges(1))
                currentLetterChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                if ~isempty(currentLetterChanges)
                    detectedChanges = [detectedChanges; currentLetterChanges];
                end
            end
        end
        detectedChanges_ballFix = detectedChanges;
        detectedChanges_reach = detectedChanges;
        detectedChanges_grasp = detectedChanges;
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % now consider ball and slot fixation onsets relative to
            % approach phases
            reach = currentResult(n).info.timeStamp.reach;
            ballGrasp = currentResult(n).info.timeStamp.ballGrasp;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
                % find last letter change before current ball fixation onset
                letterIdxB = find(detectedChanges_ballFix <= fixBallOnset, 1, 'last');
                if ~isempty(letterIdxB)
                    currentLetterChange = detectedChanges_ballFix(letterIdxB);
                    if (fixBallOnset - currentLetterChange) < 6.5
                        letterChangeRelativeBallFix = fixBallOnset - currentLetterChange;
                        %detectedChanges_ballFix(detectedChanges_ballFix < fixBallOnset) = [];
                    else
                        letterChangeRelativeBallFix = NaN;
                    end
                else
                    letterChangeRelativeBallFix = NaN;
                end
            else
                letterChangeRelativeBallFix = NaN;
            end
            
            % find last letter change before reach onset
            letterIdx = find(detectedChanges_reach <= reach, 1, 'last');
            if ~isempty(letterIdx)
                currentLetterChange = detectedChanges_reach(letterIdx);
                if (reach - currentLetterChange) < 6.5
                    letterChangeRelativeReach = reach - currentLetterChange;
                    %detectedChanges_reach(detectedChanges_reach < reach) = [];
                else
                    letterChangeRelativeReach = NaN;
                end
            else
                letterChangeRelativeReach = NaN;
            end
            % find last letter change before grasp onset
            letterIdxC = find(detectedChanges_grasp <= ballGrasp, 1, 'last');
            if ~isempty(letterIdxC)
                currentLetterChange = detectedChanges_grasp(letterIdxC);
                if (ballGrasp - currentLetterChange) < 6.5
                    letterChangeRelativeGrasp = ballGrasp - currentLetterChange;
                    %detectedChanges_grasp(detectedChanges_grasp < ballGrasp) = [];
                else
                    letterChangeRelativeGrasp = NaN;
                end
            else
                letterChangeRelativeGrasp = NaN;
            end
            if letterIdxB == letterIdxC
                sameCount = sameCount + 1;
            else
                diffCount = diffCount + 1;
            end
            % classify trial type
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end 
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             letterChangeRelativeBallFix letterChangeRelativeReach letterChangeRelativeGrasp];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        ballFixationReLetter = [ballFixationReLetter; currentVariable];
        clear fixationPattern letterChangeRelativeBallFix letterChangeRelativeGrasp letterChangeRelativeReach
        clear fixBallOnRelative fixBallOnset cutoff ballGrasp slotIdx slotOnset ballOffset currentLetterChange
        clear currentVariable detectedChanges reach detectedChanges_ballFix detectedChanges_reach detectedChanges_grasp
    end
end
%% calculate slot fixation onsets relative to letter changes
slotFixationReLetter = [];
numParticipants = 11;
eyeShift = 20;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 6;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        % first make a vector of all detected letter changes
        currentLetterChanges = [];
        detectedChanges = [];
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if ~isnan(currentResult(n).dualTask.tLetterChanges(1))
                currentLetterChanges = currentResult(n).dualTask.tLetterChanges(currentResult(n).dualTask.changeDetected);
                if ~isempty(currentLetterChanges)
                    detectedChanges = [detectedChanges; currentLetterChanges];
                end
            end
        end
        detectedChanges_slotFix = detectedChanges;
        detectedChanges_transport = detectedChanges;
        detectedChanges_slotEntry = detectedChanges;
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % now consider ball and slot fixation onsets relative to
            % approach phases
            reach = currentResult(n).info.timeStamp.reach;
            transport = currentResult(n).info.timeStamp.transport;
            slotEntry = currentResult(n).info.timeStamp.ballInSlot;
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                if ~isempty(currentResult(n).gaze.fixation.offsetsBall)
                    slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > currentResult(n).gaze.fixation.offsetsBall(1), 1, 'first');
                else
                    slotIdx = 1;
                end
                fixSlotOnRelative = currentResult(n).gaze.fixation.onsetsSlot(slotIdx)/200;
                fixSlotOnset = currentResult(n).info.timeStamp.go + fixSlotOnRelative;
            else
                continue
            end
             % find last letter change before current slot fixation onset
            letterIdx = find(detectedChanges_slotFix <= fixSlotOnset, 1, 'last');
            if ~isempty(letterIdx)
                currentLetterChange = detectedChanges_slotFix(letterIdx);
                if (fixSlotOnset - currentLetterChange) < 6.5
                    letterChangeRelativeSlotFix = fixSlotOnset - currentLetterChange;
                    %detectedChanges_slotFix(detectedChanges_slotFix < fixSlotOnset) = [];
                else
                    continue
                end
            else
                continue
            end
             % find last letter change before transport onset
            letterIdx = find(detectedChanges_transport <= transport, 1, 'last');
            if ~isempty(letterIdx)
                currentLetterChange = detectedChanges_transport(letterIdx);
                if (transport - currentLetterChange) < 6.5
                    letterChangeRelativeTransport = transport - currentLetterChange;
                    %detectedChanges_transport(detectedChanges_transport < transport) = [];
                else
                    continue
                end
            else
                continue
            end
             % find last letter change before slot entry onset
            letterIdx = find(detectedChanges_slotEntry <= slotEntry, 1, 'last');
            if ~isempty(letterIdx)
                currentLetterChange = detectedChanges_slotEntry(letterIdx);
                if (slotEntry - currentLetterChange) < 6.5
                    letterChangeRelativeSlotEntry = slotEntry - currentLetterChange;
                    %detectedChanges_slotEntry(detectedChanges_slotEntry < slotEntry) = [];
                else
                    continue
                end
            else
                continue
            end
                
            % classify trial type
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end 
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             letterChangeRelativeSlotFix letterChangeRelativeTransport letterChangeRelativeSlotEntry];

        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        slotFixationReLetter = [slotFixationReLetter; currentVariable];
        clear fixationPattern changeDetected letterChangeRelativeSlotFix letterChangeRelativeSlotEntry
        clear fixSlotOnRelative fixSlotOnset slotIdx slotOnset cutoff slotEntry letterChangeRelativeTransport
        clear ballOffset currentLetterChange currentVariable clear transport detectedChanges_slotFix 
        clear detectedChanges_transport detectedChanges_slotEntry
    end
end

%% Before plotting define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
upperBound = 6.5;
fixationOnsets = 4; % column with fixation onsets
movementOnsets = 5; % column with reach / transport onsets
manipulationOnsets = 6; % column with grasp / slot entry
binWidth = .25;
stepWidth = 0.01;

%% plot ball fixation, reach, and grasp onsets for different patterns in precision grip trials
figure(fixationOnsets)
xymax = 20;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
fixations_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
subplot(3,1,1)
xlabel('Time of ball fix onset re: last detected LC before ball fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
fixOnsets_PG = fixations_PG; %fixations_PG(fixations_PG(:,fixationOnsets) >= 0 & fixations_PG(:,fixationOnsets) < 6.5+binWidth,:);
h.ball.PGback = histogram(fixOnsets_PG(fixOnsets_PG(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.ball.PGtri = histogram(fixOnsets_PG(fixOnsets_PG(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_back = sum(h.ball.PGback.Values)*h.ball.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.ball.PGtri.Values)*h.ball.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
% x_silent = stepWidth:stepWidth:1.5;
% y_silent = SP_PG_back*ones(1, length(x_silent));
% x_slope = 1.5:stepWidth:6.5;
% y_slope = -slope*(x_slope-1.5) + SP_PG_back;
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_ballFix, p_PG_back_ballFix, ks2statPG_back_ballFix] = kstest2(fixOnsets_PG(fixOnsets_PG(:,3) == 4,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_ballFix, p_PG_tri_ballFix, ks2statPG_tri_ballFix] = kstest2(fixOnsets_PG(fixOnsets_PG(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri

% plot reach onsets
subplot(3,1,2)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
moveOnsets_PG = fixations_PG; %fixations_PG(fixations_PG(:,movementOnsets) >= 0 & fixations_PG(:,movementOnsets) < 6.5+binWidth,:);
h.reach.PGback = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 4,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.PGtri = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 3,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.reach.PGslot = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 2,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_back = sum(h.reach.PGback.Values)*h.reach.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.reach.PGtri.Values)*h.reach.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_slot = sum(h.reach.PGslot.Values)*h.reach.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_reach, p_PG_back_reach, ks2statPG_back_reach] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 4,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_reach, p_PG_tri_reach, ks2statPG_tri_reach] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 3,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri
% create expected distribution PG_slot
slope = SP_PG_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_slot)*ones((1-SP_PG_slot+floor(SP_PG_slot))*10000,1); ...
            ceil(SP_PG_slot)*ones((1-ceil(SP_PG_slot)+SP_PG_slot)*10000,1)];
    else
        binCount = [floor(SP_PG_slot-(i-1.5)*slope)*ones((1-SP_PG_slot+floor(SP_PG_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_slot-(i-1.5)*slope)*ones((1-ceil(SP_PG_slot-(i-1.5)*slope)+SP_PG_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_slot_reach, p_PG_slot_reach, ks2statPG_slot_reach] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 2,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot

% plot ball grasp onsets
subplot(3,1,3)
xlabel('Time of ball grasp re: last detected LC before ball grasp (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
manipOnsets_PG = fixations_PG; %fixations_PG(fixations_PG(:,manipulationOnsets) >= 0 & fixations_PG(:,manipulationOnsets) < 6.5+binWidth,:);
h.grasp.PGback = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 4,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.grasp.PGtri = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 3,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.grasp.PGslot = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 2,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_back = sum(h.grasp.PGback.Values)*h.grasp.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.grasp.PGtri.Values)*h.grasp.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_slot = sum(h.grasp.PGslot.Values)*h.grasp.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_grasp, p_PG_back_grasp, ks2statPG_back_grasp] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 4,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_grasp, p_PG_tri_grasp, ks2statPG_tri_grasp] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 3,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri
% create expected distribution PG_slot
slope = SP_PG_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_slot)*ones((1-SP_PG_slot+floor(SP_PG_slot))*10000,1); ...
            ceil(SP_PG_slot)*ones((1-ceil(SP_PG_slot)+SP_PG_slot)*10000,1)];
    else
        binCount = [floor(SP_PG_slot-(i-1.5)*slope)*ones((1-SP_PG_slot+floor(SP_PG_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_slot-(i-1.5)*slope)*ones((1-ceil(SP_PG_slot-(i-1.5)*slope)+SP_PG_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_slot_grasp, p_PG_slot_grasp, ks2statPG_slot_grasp] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 2,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot

clear ballFixations_PG fixations_PG fixOnsets_PG moveOnsets_PG manipOnsets_PG

%% plot slot fixation, transport, and slot etnry for different patterns in precision grip trials
figure(movementOnsets)
xymax = 20;
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude slot-only
fixations_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
subplot(3,1,1)
xlabel('Time of slot fix onset re: last detected LC before slot fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
%rangeIdx = fixations_PG(:,fixationOnsets) >= 0 & fixations_PG(:,fixationOnsets) < 6.5+binWidth;
fixOnsets_PG = fixations_PG; %fixations_PG(rangeIdx,:);
h.slot.PGslot = histogram(fixOnsets_PG(fixOnsets_PG(:,3) == 2,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.slot.PGback = histogram(fixOnsets_PG(fixOnsets_PG(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.slot.PGtri = histogram(fixOnsets_PG(fixOnsets_PG(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_slot = sum(h.slot.PGslot.Values)*h.slot.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.slot.PGback.Values)*h.slot.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.slot.PGtri.Values)*h.slot.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_slot
slope = SP_PG_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_slot)*ones((1-SP_PG_slot+floor(SP_PG_slot))*10000,1); ...
            ceil(SP_PG_slot)*ones((1-ceil(SP_PG_slot)+SP_PG_slot)*10000,1)];
    else
        binCount = [floor(SP_PG_slot-(i-1.5)*slope)*ones((1-SP_PG_slot+floor(SP_PG_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_slot-(i-1.5)*slope)*ones((1-ceil(SP_PG_slot-(i-1.5)*slope)+SP_PG_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_slot_slotFix, p_PG_slot_slotFix, ks2statPG_slot_slotFix] = kstest2(fixOnsets_PG(fixOnsets_PG(:,3) == 2,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_slotFix, p_PG_back_slotFix, ks2statPG_back_slotFix] = kstest2(fixOnsets_PG(fixOnsets_PG(:,3) == 4,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_slotFix, p_PG_tri_slotFix, ks2statPG_tri_slotFix] = kstest2(fixOnsets_PG(fixOnsets_PG(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri

% plot transport onsets
subplot(3,1,2)
xlabel('Time of transport onset re: last detected LC before transport (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
moveOnsets_PG = fixations_PG; %fixations_PG(fixations_PG(:,movementOnsets) >= 0 & fixations_PG(:,movementOnsets) < 6.5+binWidth,:);
h.reach.PGslot = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 2,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.reach.PGback = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 4,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.PGtri = histogram(moveOnsets_PG(moveOnsets_PG(:,3) == 3,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_slot = sum(h.reach.PGslot.Values)*h.reach.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.reach.PGback.Values)*h.reach.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.reach.PGtri.Values)*h.reach.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_slot
slope = SP_PG_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_slot)*ones((1-SP_PG_slot+floor(SP_PG_slot))*10000,1); ...
            ceil(SP_PG_slot)*ones((1-ceil(SP_PG_slot)+SP_PG_slot)*10000,1)];
    else
        binCount = [floor(SP_PG_slot-(i-1.5)*slope)*ones((1-SP_PG_slot+floor(SP_PG_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_slot-(i-1.5)*slope)*ones((1-ceil(SP_PG_slot-(i-1.5)*slope)+SP_PG_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_slot_transport, p_PG_slot_transport, ks2statPG_slot_transport] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 2,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_transport, p_PG_back_transport, ks2statPG_back_transport] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 4,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_transport, p_PG_tri_transport, ks2statPG_tri_transport] = kstest2(moveOnsets_PG(moveOnsets_PG(:,3) == 3,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri

% plot slot slot entry
subplot(3,1,3)
xlabel('Time of slot entry re: last detected LC before slot entry (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
manipOnsets_PG = fixations_PG; %fixations_PG(fixations_PG(:,manipulationOnsets) >= 0 & fixations_PG(:,manipulationOnsets) < 6.5+binWidth,:);
h.grasp.PGslot = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 2,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.grasp.PGback = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 4,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.grasp.PGtri = histogram(manipOnsets_PG(manipOnsets_PG(:,3) == 3,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_slot = sum(h.grasp.PGslot.Values)*h.grasp.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_back = sum(h.grasp.PGback.Values)*h.grasp.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_PG_tri = sum(h.grasp.PGtri.Values)*h.grasp.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_slot
slope = SP_PG_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_slot)*ones((1-SP_PG_slot+floor(SP_PG_slot))*10000,1); ...
            ceil(SP_PG_slot)*ones((1-ceil(SP_PG_slot)+SP_PG_slot)*10000,1)];
    else
        binCount = [floor(SP_PG_slot-(i-1.5)*slope)*ones((1-SP_PG_slot+floor(SP_PG_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_slot-(i-1.5)*slope)*ones((1-ceil(SP_PG_slot-(i-1.5)*slope)+SP_PG_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_slot_slotEntry, p_PG_slot_slotEntry, ks2statPG_slot_slotEntry] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 2,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot
% create expected distribution PG_back
slope = SP_PG_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_back)*ones((1-SP_PG_back+floor(SP_PG_back))*10000,1); ...
            ceil(SP_PG_back)*ones((1-ceil(SP_PG_back)+SP_PG_back)*10000,1)];
    else
        binCount = [floor(SP_PG_back-(i-1.5)*slope)*ones((1-SP_PG_back+floor(SP_PG_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_back-(i-1.5)*slope)*ones((1-ceil(SP_PG_back-(i-1.5)*slope)+SP_PG_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_back_slotEntry, p_PG_back_slotEntry, ks2statPG_back_slotEntry] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 4,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back
% create expected distribution PG_tri
slope = SP_PG_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_tri)*ones((1-SP_PG_tri+floor(SP_PG_tri))*10000,1); ...
            ceil(SP_PG_tri)*ones((1-ceil(SP_PG_tri)+SP_PG_tri)*10000,1)];
    else
        binCount = [floor(SP_PG_tri-(i-1.5)*slope)*ones((1-SP_PG_tri+floor(SP_PG_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_tri-(i-1.5)*slope)*ones((1-ceil(SP_PG_tri-(i-1.5)*slope)+SP_PG_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG_tri_slotEntry, p_PG_tri_slotEntry, ks2statPG_tri_slotEntry] = kstest2(manipOnsets_PG(manipOnsets_PG(:,3) == 3,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri

clear slotFixations_PG fixations_PG fixOnsets_PG moveOnsets_PG manipOnsets_PG

%% plot ball fixation, reach, and grasp onsets for different patterns in tweezer trials
figure(fixationOnsets*10)
xymax = 20;
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
fixations_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
subplot(3,1,1)
xlabel('Time of ball fix onset re: last detected LC before ball fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
fixOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,fixationOnsets) >= 0 & fixations_TW(:,fixationOnsets) < 6.5+binWidth,:);
h.ball.TWback = histogram(fixOnsets_TW(fixOnsets_TW(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.ball.TWtri = histogram(fixOnsets_TW(fixOnsets_TW(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_back = sum(h.ball.TWback.Values)*h.ball.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.ball.TWtri.Values)*h.ball.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_ballFix, p_TW_back_ballFix, ks2statTW_back_ballFix] = kstest2(fixOnsets_TW(fixOnsets_TW(:,3) == 4,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_ballFix, p_TW_tri_ballFix, ks2statTW_tri_ballFix] = kstest2(fixOnsets_TW(fixOnsets_TW(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri

% plot reach onsets
subplot(3,1,2)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
moveOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,movementOnsets) >= 0 & fixations_TW(:,movementOnsets) < 6.5+binWidth,:);
h.reach.TWback = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 4,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.TWtri = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 3,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.reach.TWslot = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 2,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_back = sum(h.reach.TWback.Values)*h.reach.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.reach.TWtri.Values)*h.reach.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_slot = sum(h.reach.TWslot.Values)*h.reach.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_reach, p_TW_back_reach, ks2statTW_back_reach] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 4,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_reach, p_TW_tri_reach, ks2statTW_tri_reach] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 3,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri
% create expected distribution TW_slot
slope = SP_TW_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_slot)*ones((1-SP_TW_slot+floor(SP_TW_slot))*10000,1); ...
            ceil(SP_TW_slot)*ones((1-ceil(SP_TW_slot)+SP_TW_slot)*10000,1)];
    else
        binCount = [floor(SP_TW_slot-(i-1.5)*slope)*ones((1-SP_TW_slot+floor(SP_TW_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_slot-(i-1.5)*slope)*ones((1-ceil(SP_TW_slot-(i-1.5)*slope)+SP_TW_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_slot_reach, p_TW_slot_reach, ks2statTW_slot_reach] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 2,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot

% plot ball grasp onsets
subplot(3,1,3)
xlabel('Time of ball grasp re: last detected LC before ball grasp (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
manipOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,manipulationOnsets) >= 0 & fixations_TW(:,manipulationOnsets) < 6.5+binWidth,:);
h.grasp.TWback = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 4,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.grasp.TWtri = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 3,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.grasp.TWslot = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 2,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_back = sum(h.grasp.TWback.Values)*h.grasp.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.grasp.TWtri.Values)*h.grasp.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_slot = sum(h.grasp.TWslot.Values)*h.grasp.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_grasp, p_TW_back_grasp, ks2statTW_back_grasp] = kstest2(manipOnsets_TW(manipOnsets_TW(:,3) == 4,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_grasp, p_TW_tri_grasp, ks2statTW_tri_grasp] = kstest2(manipOnsets_TW(manipOnsets_TW(:,3) == 3,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri
% create expected distribution TW_slot
slope = SP_TW_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_slot)*ones((1-SP_TW_slot+floor(SP_TW_slot))*10000,1); ...
            ceil(SP_TW_slot)*ones((1-ceil(SP_TW_slot)+SP_TW_slot)*10000,1)];
    else
        binCount = [floor(SP_TW_slot-(i-1.5)*slope)*ones((1-SP_TW_slot+floor(SP_TW_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_slot-(i-1.5)*slope)*ones((1-ceil(SP_TW_slot-(i-1.5)*slope)+SP_TW_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_slot_grasp, p_TW_slot_grasp, ks2statTW_slot_grasp] = kstest2(manipOnsets_TW(manipOnsets_TW(:,3) == 2,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot

clear ballFixations_TW fixations_TW fixOnsets_TW moveOnsets_TW manipOnsets_TW
%% plot slot fixation, transport, and slot entry for different patterns in tweezer trials
figure(movementOnsets*10)
xymax = 20;
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude slot-only
fixations_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
subplot(3,1,1)
xlabel('Time of slot fix onset re: last detected LC before slot fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
fixOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,fixationOnsets) >= 0 & fixations_TW(:,fixationOnsets) < 6.5+binWidth,:);
h.slot.TWslot = histogram(fixOnsets_TW(fixOnsets_TW(:,3) == 2,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.slot.TWback = histogram(fixOnsets_TW(fixOnsets_TW(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.slot.TWtri = histogram(fixOnsets_TW(fixOnsets_TW(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_slot = sum(h.slot.TWslot.Values)*h.slot.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.slot.TWback.Values)*h.slot.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.slot.TWtri.Values)*h.slot.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_slot
slope = SP_TW_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_slot)*ones((1-SP_TW_slot+floor(SP_TW_slot))*10000,1); ...
            ceil(SP_TW_slot)*ones((1-ceil(SP_TW_slot)+SP_TW_slot)*10000,1)];
    else
        binCount = [floor(SP_TW_slot-(i-1.5)*slope)*ones((1-SP_TW_slot+floor(SP_TW_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_slot-(i-1.5)*slope)*ones((1-ceil(SP_TW_slot-(i-1.5)*slope)+SP_TW_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_slot_slotFix, p_TW_slot_slotFix, ks2statTW_slot_slotFix] = kstest2(fixOnsets_TW(fixOnsets_TW(:,3) == 2,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_slotFix, p_TW_back_slotFix, ks2statTW_back_slotFix] = kstest2(fixOnsets_TW(fixOnsets_TW(:,3) == 4,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_slotFix, p_TW_tri_slotFix, ks2statTW_tri_slotFix] = kstest2(fixOnsets_TW(fixOnsets_TW(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri

% plot transport onsets
subplot(3,1,2)
xlabel('Time of transport onset re: last detected LC before transport (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
moveOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,movementOnsets) >= 0 & fixations_TW(:,movementOnsets) < 6.5+binWidth,:);
h.reach.TWslot = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 2,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.reach.TWback = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 4,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.TWtri = histogram(moveOnsets_TW(moveOnsets_TW(:,3) == 3,movementOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_slot = sum(h.reach.TWslot.Values)*h.reach.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.reach.TWback.Values)*h.reach.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.reach.TWtri.Values)*h.reach.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_slot
slope = SP_TW_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_slot)*ones((1-SP_TW_slot+floor(SP_TW_slot))*10000,1); ...
            ceil(SP_TW_slot)*ones((1-ceil(SP_TW_slot)+SP_TW_slot)*10000,1)];
    else
        binCount = [floor(SP_TW_slot-(i-1.5)*slope)*ones((1-SP_TW_slot+floor(SP_TW_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_slot-(i-1.5)*slope)*ones((1-ceil(SP_TW_slot-(i-1.5)*slope)+SP_TW_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_slot_transport, p_TW_slot_transport, ks2statTW_slot_transport] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 2,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_transport, p_TW_back_transport, ks2statTW_back_transport] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 4,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_transport, p_TW_tri_transport, ks2statTW_tri_transport] = kstest2(moveOnsets_TW(moveOnsets_TW(:,3) == 3,movementOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri

% plot slot entry
subplot(3,1,3)
xlabel('Time of slot entry re: last detected LC before slot entry (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
manipOnsets_TW = fixations_TW; %fixations_TW(fixations_TW(:,manipulationOnsets) >= 0 & fixations_TW(:,manipulationOnsets) < 6.5+binWidth,:);
h.grasp.TWslot = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 2,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.grasp.TWback = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 4,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.grasp.TWtri = histogram(manipOnsets_TW(manipOnsets_TW(:,3) == 3,manipulationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_slot = sum(h.grasp.TWslot.Values)*h.grasp.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_back = sum(h.grasp.TWback.Values)*h.grasp.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
SP_TW_tri = sum(h.grasp.TWtri.Values)*h.grasp.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_slot
slope = SP_TW_slot/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_slot)*ones((1-SP_TW_slot+floor(SP_TW_slot))*10000,1); ...
            ceil(SP_TW_slot)*ones((1-ceil(SP_TW_slot)+SP_TW_slot)*10000,1)];
    else
        binCount = [floor(SP_TW_slot-(i-1.5)*slope)*ones((1-SP_TW_slot+floor(SP_TW_slot-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_slot-(i-1.5)*slope)*ones((1-ceil(SP_TW_slot-(i-1.5)*slope)+SP_TW_slot)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_slot_slotEntry, p_TW_slot_slotEntry, ks2statTW_slot_slotEntry] = kstest2(manipOnsets_TW(manipOnsets_TW(:,3) == 2,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot
% create expected distribution TW_back
slope = SP_TW_back/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_back)*ones((1-SP_TW_back+floor(SP_TW_back))*10000,1); ...
            ceil(SP_TW_back)*ones((1-ceil(SP_TW_back)+SP_TW_back)*10000,1)];
    else
        binCount = [floor(SP_TW_back-(i-1.5)*slope)*ones((1-SP_TW_back+floor(SP_TW_back-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_back-(i-1.5)*slope)*ones((1-ceil(SP_TW_back-(i-1.5)*slope)+SP_TW_back)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_back_slotEntry, p_TW_back_slotEntry, ks2statTW_back_slotEntry] = kstest2(manipOnsets_TW(manipOnsets_TW(:,3) == 4,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back
% create expected distribution TW_tri
slope = SP_TW_tri/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_tri)*ones((1-SP_TW_tri+floor(SP_TW_tri))*10000,1); ...
            ceil(SP_TW_tri)*ones((1-ceil(SP_TW_tri)+SP_TW_tri)*10000,1)];
    else
        binCount = [floor(SP_TW_tri-(i-1.5)*slope)*ones((1-SP_TW_tri+floor(SP_TW_tri-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_tri-(i-1.5)*slope)*ones((1-ceil(SP_TW_tri-(i-1.5)*slope)+SP_TW_tri)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW_tri_slotEntry, p_TW_tri_slotEntry, ks2statTW_tri_slotEntry] = kstest2(fixations_TW(fixations_TW(:,3) == 3,manipulationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri

clear slotFixations_TW fixations_TW fixOnsets_TW moveOnsets_TW manipOnsets_TW

%% correlational plots for fingertips
figure(manipulationOnsets)
xymax = 5;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
ballFix_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);
slotFix_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

% make a scatter plot of fixation onset vs. kinematic phases
% subplot(2,2,1)
% set(gcf,'renderer','Painters')
% xlim([0 xymax])
% xlabel('ball fixation onset rel. to detected LC')
% ylim([0 xymax])
% ylabel('reach onset rel. to detected LC')
% axis('square')
% hold on
% plot(ballFix_PG(ballFix_PG(:,3) == 4,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 4,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(5,:))
% plot(ballFix_PG(ballFix_PG(:,3) == 3,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 3,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(4,:))
% line([0 xymax], [0 xymax], 'Color', 'k')

subplot(1,2,1)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('ball grasp rel. to detected LC')
axis('square')
hold on
plot(ballFix_PG(ballFix_PG(:,3) == 4,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_PG(ballFix_PG(:,3) == 3,fixationOnsets), ballFix_PG(ballFix_PG(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')
s_grasp_PG = regstats(ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,manipulationOnsets),...
    ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,fixationOnsets),'linear'); 

% subplot(2,2,2)
% set(gcf,'renderer','Painters')
% xlim([0 xymax])
% xlabel('slot fixation onset rel. to detected LC')
% ylim([0 xymax])
% ylabel('transport onset rel. to detected LC')
% axis('square')
% hold on
% plot(slotFix_PG(slotFix_PG(:,3) == 2,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 2,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(3,:))
% plot(slotFix_PG(slotFix_PG(:,3) == 4,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 4,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(5,:))
% plot(slotFix_PG(slotFix_PG(:,3) == 3,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 3,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(4,:))
% line([0 xymax], [0 xymax], 'Color', 'k')

subplot(1,2,2)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('slot entry rel. to detected LC')
axis('square')
hold on
plot(slotFix_PG(slotFix_PG(:,3) == 2,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 2,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_PG(slotFix_PG(:,3) == 4,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_PG(slotFix_PG(:,3) == 3,fixationOnsets), slotFix_PG(slotFix_PG(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')
s_slotEntry_PG = regstats(slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,manipulationOnsets),...
    slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,fixationOnsets),'linear');

%% correlational plots for tweezers
figure(manipulationOnsets*10)
xymax = 5;
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
ballFix_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);
slotFix_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

% make a scatter plot of fixation onset vs. kinematic phases
% subplot(2,2,1)
% set(gcf,'renderer','Painters')
% xlim([0 xymax])
% xlabel('ball fixation onset rel. to detected LC')
% ylim([0 xymax])
% ylabel('reach onset rel. to detected LC')
% axis('square')
% hold on
% plot(ballFix_TW(ballFix_TW(:,3) == 4,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 4,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(5,:))
% plot(ballFix_TW(ballFix_TW(:,3) == 3,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 3,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(4,:))
% line([0 xymax], [0 xymax], 'Color', 'k')

subplot(1,2,1)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('ball fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('ball grasp rel. to detected LC')
axis('square')
hold on
plot(ballFix_TW(ballFix_TW(:,3) == 4,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_TW(ballFix_TW(:,3) == 3,fixationOnsets), ballFix_TW(ballFix_TW(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')
% linear regression
% reg_grasp_TW = polyfit(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets), ...
%     ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets), 1);
% yfit_grasp_TW = polyval(reg_grasp_TW, ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets));
% SSresid = sum((ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets)...
%     - yfit_grasp_TW).^2);
% SStotal = (length(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets))-1)...
%     * var(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets));
% rsq_grasp_TW = 1 - SSresid/SStotal;
% clear SSresid SStotal
s_grasp_TW = regstats(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets),...
    ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets),'linear'); 

% subplot(2,2,2)
% set(gcf,'renderer','Painters')
% xlim([0 xymax])
% xlabel('slot fixation onset rel. to detected LC')
% ylim([0 xymax])
% ylabel('transport onset rel. to detected LC')
% axis('square')
% hold on
% plot(slotFix_TW(slotFix_TW(:,3) == 2,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 2,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(3,:))
% plot(slotFix_TW(slotFix_TW(:,3) == 4,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 4,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(5,:))
% plot(slotFix_TW(slotFix_TW(:,3) == 3,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 3,movementOnsets), ...
%     '.', 'Color', fixationPatternColors(4,:))
% line([0 xymax], [0 xymax], 'Color', 'k')

subplot(1,2,2)
set(gcf,'renderer','Painters')
xlim([0 xymax])
xlabel('slot fixation onset rel. to detected LC')
ylim([0 xymax])
ylabel('slot entry rel. to detected LC')
axis('square')
hold on
plot(slotFix_TW(slotFix_TW(:,3) == 2,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 2,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_TW(slotFix_TW(:,3) == 4,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 4,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_TW(slotFix_TW(:,3) == 3,fixationOnsets), slotFix_TW(slotFix_TW(:,3) == 3,manipulationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([0 xymax], [0 xymax], 'Color', 'k')
s_slotEntry_TW = regstats(slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,manipulationOnsets),...
    slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,fixationOnsets),'linear'); 