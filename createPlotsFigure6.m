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
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 5;
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
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballGrasp = currentResult(n).info.timeStamp.ballGrasp;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
                % find last letter change before current ball fixation onset
                letterIdx = find(detectedChanges_ballFix <= fixBallOnset, 1, 'last');
                if ~isempty(letterIdx)
                    currentLetterChange = detectedChanges_ballFix(letterIdx);
                    if (fixBallOnset - currentLetterChange) < 6.5
                        letterChangeRelativeBallFix = fixBallOnset - currentLetterChange;
                        letterChangeRelativeGrasp = ballGrasp - currentLetterChange;
                    else
                        continue
                    end
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
             letterChangeRelativeBallFix letterChangeRelativeGrasp];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        ballFixationReLetter = [ballFixationReLetter; currentVariable];
        clear fixationPattern letterChangeRelativeBallFix currentParticipant letterChangeRelativeGrasp
        clear fixBallOnRelative fixBallOnset slotIdx slotOnset ballOffset currentLetterChange
        clear currentVariable detectedChanges detectedChanges_ballFix blockID letterIdx
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
        numMeasures = 5;
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
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
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
                    letterChangeRelativeEntry = slotEntry - currentLetterChange;
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
             letterChangeRelativeSlotFix letterChangeRelativeEntry];

        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        slotFixationReLetter = [slotFixationReLetter; currentVariable];
        clear fixationPattern letterChangeRelativeSlotFix letterChangeRelativeEntry
        clear fixSlotOnRelative fixSlotOnset slotIdx slotOnset blockID letterIdx
        clear ballOffset currentLetterChange currentVariable detectedChanges_slotFix 
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
manipulationOnsets = 5; % column with grasp / slot entry
binWidth = .25;
stepWidth = 0.01;
%% plot ball fixation, reach, and grasp onsets for different patterns in precision grip trials
figure(43) % Panel A
xymax = 20;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
fixations_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
subplot(2,2,1)
xlabel('Time of ball fix onset re: last detected LC before ball fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.ball.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.ball.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
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
[h_PG.back_ballFix, p_PG.back_ballFix, ks2statPG.back_ballFix] = kstest2(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), expectedDistribution);
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
[h_PG.tri_ballFix, p_PG.tri_ballFix, ks2statPG.tri_ballFix] = kstest2(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri
%% plot slot fixation, transport, and slot etnry for different patterns in precision grip trials
subplot(2,2,2)
xymax = 20;
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude slot-only
fixations_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
xlabel('Time of slot fix onset re: last detected LC before slot fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.slot.PGslot = histogram(fixations_PG(fixations_PG(:,3) == 2,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.slot.PGback = histogram(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.slot.PGtri = histogram(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
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
[h_PG.slot_slotFix, p_PG.slot_slotFix, ks2statPG.slot_slotFix] = kstest2(fixations_PG(fixations_PG(:,3) == 2,fixationOnsets), expectedDistribution);
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
[h_PG.back_slotFix, p_PG.back_slotFix, ks2statPG.back_slotFix] = kstest2(fixations_PG(fixations_PG(:,3) == 4,fixationOnsets), expectedDistribution);
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
[h_PG.tri_slotFix, p_PG.tri_slotFix, ks2statPG.tri_slotFix] = kstest2(fixations_PG(fixations_PG(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri
%% plot ball fixation, reach, and grasp onsets for different patterns in tweezer trials
subplot(2,2,3)
xymax = 20;
ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
fixations_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);

% plot ball fixation onsets
xlabel('Time of ball fix onset re: last detected LC before ball fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.ball.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.ball.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
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
[h_TW.back_ballFix, p_TW.back_ballFix, ks2statTW.back_ballFix] = kstest2(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), expectedDistribution);
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
[h_TW.tri_ballFix, p_TW.tri_ballFix, ks2statTW.tri_ballFix] = kstest2(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri
%% plot slot fixation, transport, and slot entry for different patterns in tweezer trials
subplot(2,2,4)
xymax = 20;
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude slot-only
fixations_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

% plot slot fixation onsets
xlabel('Time of slot fix onset re: last detected LC before slot fix (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.slot.TWslot = histogram(fixations_TW(fixations_TW(:,3) == 2,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.slot.TWback = histogram(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.slot.TWtri = histogram(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), 'BinWidth', binWidth,...
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
[h_TW.slot_slotFix, p_TW.slot_slotFix, ks2statTW.slot_slotFix] = kstest2(fixations_TW(fixations_TW(:,3) == 2,fixationOnsets), expectedDistribution);
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
[h_TW.back_slotFix, p_TW.back_slotFix, ks2statTW.back_slotFix] = kstest2(fixations_TW(fixations_TW(:,3) == 4,fixationOnsets), expectedDistribution);
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
[h_TW.tri_slotFix, p_TW.tri_slotFix, ks2statTW.tri_slotFix] = kstest2(fixations_TW(fixations_TW(:,3) == 3,fixationOnsets), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri
%% correlational plots for fingertips (panel C)
figure(87)
xymax = 5;
ballFixations_PG = ballFixationReLetter(ballFixationReLetter(:,2) == 3, :);
slotFixations_PG = slotFixationReLetter(slotFixationReLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
ballFix_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);
slotFix_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

subplot(2,2,1)
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

subplot(2,2,3)
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

ballFixations_TW = ballFixationReLetter(ballFixationReLetter(:,2) == 4, :);
slotFixations_TW = slotFixationReLetter(slotFixationReLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
ballFix_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);
slotFix_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

subplot(2,2,2)
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
s_grasp_TW = regstats(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets),...
    ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets),'linear'); 

subplot(2,2,4)
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
%% reach distributions relative to detected LCs (panel B
reachRelativeLetter = [];
detectedChanges = [];
numParticipants = 11;
eyeShift = 20;

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 4;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
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
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % now consider ball and slot fixation onsets relative to
            % approach phases
            reach = currentResult(n).info.timeStamp.reach;    
            % find last letter change before reach onset
            letterIdx = find(detectedChanges <= reach, 1, 'last');
            if ~isempty(letterIdx)
                currentLetterChange = detectedChanges(letterIdx);
                if (reach - currentLetterChange) < 6.5
                    letterChangeRelativeReach = reach - currentLetterChange;
                    %detectedChanges_reach(detectedChanges_reach < reach) = [];
                else
                    letterChangeRelativeReach = NaN;
                end
            else
                letterChangeRelativeReach = NaN;
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
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern... 
             letterChangeRelativeReach];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        reachRelativeLetter = [reachRelativeLetter; currentVariable];

        clear fixationPattern letterChangeRelativeReach
        clear reach slotIdx slotOnset ballOffset currentLetterChange
    end
end
%% plot histograms
figure(14) 
xymax = 20;
allReaches_PG = reachRelativeLetter(reachRelativeLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
reaches_PG = allReaches_PG(allReaches_PG(:,3) ~= selectedPattern,:);

% plot reach onsets
subplot(4,2,1)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGback = histogram(reaches_PG(reaches_PG(:,3) == 4,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_back = sum(h.reach.PGback.Values)*h.reach.PGback.BinWidth / 4;
line([0 1.5], [SP_PG_back SP_PG_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
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
[h_PG.back_reach, p_PG.back_reach, ks2statPG.back_reach] = kstest2(reaches_PG(reaches_PG(:,3) == 4,end), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_back

subplot(4,2,3)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGtri = histogram(reaches_PG(reaches_PG(:,3) == 3,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
SP_PG_tri = sum(h.reach.PGtri.Values)*h.reach.PGtri.BinWidth / 4;
line([0 1.5], [SP_PG_tri SP_PG_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
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
[h_PG.tri_reach, p_PG.tri_reach, ks2statPG.tri_reach] = kstest2(reaches_PG(reaches_PG(:,3) == 3,end), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_tri

subplot(4,2,5)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGslot = histogram(reaches_PG(reaches_PG(:,3) == 2,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_PG_slot = sum(h.reach.PGslot.Values)*h.reach.PGslot.BinWidth / 4;
line([0 1.5], [SP_PG_slot SP_PG_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_back
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
[h_PG.slot_reach, p_PG.slot_reach, ks2statPG.slot_reach] = kstest2(reaches_PG(reaches_PG(:,3) == 2,end), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_slot

subplot(4,2,7)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGdisp = histogram(reaches_PG(reaches_PG(:,3) == 0,end), 'BinWidth', binWidth,...
    'facecolor', 'k', 'edgecolor', 'none');
SP_PG_disp = sum(h.reach.PGdisp.Values)*h.reach.PGdisp.BinWidth / 4;
line([0 1.5], [SP_PG_disp SP_PG_disp], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_disp 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution PG_tri
slope = SP_PG_disp/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG_disp)*ones((1-SP_PG_disp+floor(SP_PG_disp))*10000,1); ...
            ceil(SP_PG_disp)*ones((1-ceil(SP_PG_disp)+SP_PG_disp)*10000,1)];
    else
        binCount = [floor(SP_PG_disp-(i-1.5)*slope)*ones((1-SP_PG_disp+floor(SP_PG_disp-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG_disp-(i-1.5)*slope)*ones((1-ceil(SP_PG_disp-(i-1.5)*slope)+SP_PG_disp)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_PG.disp_reach, p_PG.disp_reach, ks2statPG.disp_reach] = kstest2(reaches_PG(reaches_PG(:,3) == 0,end), expectedDistribution);
clear expectedDistribution binCount slope SP_PG_disp
%% tweezers
allReaches_TW = reachRelativeLetter(reachRelativeLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
reaches_TW = allReaches_TW(allReaches_TW(:,3) ~= selectedPattern,:);

% plot reach onsets
subplot(4,2,2)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWback = histogram(reaches_TW(reaches_TW(:,3) == 4,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_back = sum(h.reach.TWback.Values)*h.reach.TWback.BinWidth / 4;
line([0 1.5], [SP_TW_back SP_TW_back], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_back 0], 'Color', fixationPatternColors(5,:), 'LineStyle', '--', 'LineWidth', 1.5)
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
[h_TW.back_reach, p_TW.back_reach, ks2statTW.back_reach] = kstest2(reaches_TW(reaches_TW(:,3) == 4,end), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_back

subplot(4,2,4)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWtri = histogram(reaches_TW(reaches_TW(:,3) == 3,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
SP_TW_tri = sum(h.reach.TWtri.Values)*h.reach.TWtri.BinWidth / 4;
line([0 1.5], [SP_TW_tri SP_TW_tri], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_tri 0], 'Color', fixationPatternColors(4,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
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
[h_TW.tri_reach, p_TW.tri_reach, ks2statTW.tri_reach] = kstest2(reaches_TW(reaches_TW(:,3) == 3,end), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_tri

subplot(4,2,6)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWslot = histogram(reaches_TW(reaches_TW(:,3) == 2,end), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
% calculate expected distribution
SP_TW_slot = sum(h.reach.TWslot.Values)*h.reach.TWslot.BinWidth / 4;
line([0 1.5], [SP_TW_slot SP_TW_slot], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_slot 0], 'Color', fixationPatternColors(3,:), 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_back
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
[h_TW.slot_reach, p_TW.slot_reach, ks2statTW.slot_reach] = kstest2(reaches_TW(reaches_TW(:,3) == 2,end), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_slot

subplot(4,2,8)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWdisp = histogram(reaches_TW(reaches_TW(:,3) == 0,end), 'BinWidth', binWidth,...
    'facecolor', 'k', 'edgecolor', 'none');
SP_TW_disp = sum(h.reach.TWdisp.Values)*h.reach.TWdisp.BinWidth / 4;
line([0 1.5], [SP_TW_disp SP_TW_disp], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_disp 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5)
% add line indicating 1.5 = silent period
line([1.5 1.5], [0 xymax], 'Color', lightGrey)
% create expected distribution TW_tri
slope = SP_TW_disp/5;
expectedDistribution = [];
for i = binWidth:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW_disp)*ones((1-SP_TW_disp+floor(SP_TW_disp))*10000,1); ...
            ceil(SP_TW_disp)*ones((1-ceil(SP_TW_disp)+SP_TW_disp)*10000,1)];
    else
        binCount = [floor(SP_TW_disp-(i-1.5)*slope)*ones((1-SP_TW_disp+floor(SP_TW_disp-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW_disp-(i-1.5)*slope)*ones((1-ceil(SP_TW_disp-(i-1.5)*slope)+SP_TW_disp)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test 
[h_TW.disp_reach, p_TW.disp_reach, ks2statTW.disp_reach] = kstest2(reaches_TW(reaches_TW(:,3) == 0,end), expectedDistribution);
clear expectedDistribution binCount slope SP_TW_disp

%% plot the response time (reach onset relative to go signal) vs. the time 
% of the last detected letter change (relative to go) --> Panel D
numVariables = 5;
speedRelativeLetterChange = [];
rangeLC = 4;

for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        currentVariable = NaN(numTrials,numVariables);
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
        for n = 1:stopTrial % loop over trials for current subject & block
            currentLC_early = NaN;
            currentLC_late = NaN;
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            cueInterval = 0.5; %start looking 0.5 s before cue
            goTime = currentResult(n).info.timeStamp.go;
            reach = currentResult(n).info.timeStamp.reach;
            goToReach = reach-goTime;
            % find last letter change before current slot fixation onset
            LCbefore = find(detectedChanges <= goTime-cueInterval, 1, 'last');
            LCafter = find(detectedChanges > goTime-cueInterval, 1, 'first');
            if ~isempty(LCbefore) && ~isempty(LCafter) 
                % check which one is closer 
                currentLC_early = goTime-cueInterval - detectedChanges(LCbefore);
                currentLC_late = goTime-cueInterval - detectedChanges(LCafter);
                if abs(currentLC_early) <= abs(currentLC_late) && abs(currentLC_early) < rangeLC
                    letterChangeRelativeGo = currentLC_early;
                elseif abs(currentLC_late) < abs(currentLC_early) && abs(currentLC_late) < rangeLC
                    letterChangeRelativeGo = currentLC_late;
                else
                    continue
                end
            elseif ~isempty(LCbefore) && isempty(LCafter) 
                if abs(currentLC_early) < rangeLC
                    letterChangeRelativeGo = currentLC_early;
                else
                    continue
                end
            elseif isempty(LCbefore) && ~isempty(LCafter) 
                if abs(currentLC_late) < rangeLC
                    letterChangeRelativeGo = currentLC_late;
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

            currentVariable(n,:) = [currentParticipant blockID fixationPattern...
                letterChangeRelativeGo goToReach];
            clear currentLC_early currentLC_late letterChangeRelativeGo goToReach
            clear ballOffset slotIdx slotOnset fixationPattern
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
        clear currentParticipant blockID 
    end
end

%%
figure(21)
blue = [55,126,184]./255;
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% go signal
lowerLimit = -4;
upperLimit = 4;
binWidth = .25;
subplot(1,2,1)
axis('square')
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
set(gca, 'Xtick', [cueInterval-4 cueInterval-2 cueInterval cueInterval+2], 'XTickLabel', [-4 -2 0 2])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
line([cueInterval cueInterval], [-1 1.5], 'Color', lightGrey)
ylim([-1 1.5])
line([-cueInterval -cueInterval],[-1 2], 'Color', 'k', 'LineStyle', '--')
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 0, 4), ...
    relativeChanges_PG(relativeChanges_PG(:,3) == 0,5), '.', 'Color', 'k')
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 2, 4), ...
    relativeChanges_PG(relativeChanges_PG(:,3) == 2,5), '.', 'Color', fixationPatternColors(3,:))
plot(relativeChanges_PG(relativeChanges_PG(:,3) > 2, 4), ...
    relativeChanges_PG(relativeChanges_PG(:,3) > 2,5), '.', 'Color', blue)
%% compare within and outside "hot region"
participantReachStartPG = NaN(numParticipants*3,5);
patCount = 1;
for fixType = 0:2
    if fixType == 0
        currentAction = relativeChanges_PG(relativeChanges_PG(:,3) == 0, :);
    elseif fixType == 1
        currentAction = relativeChanges_PG(relativeChanges_PG(:,3) == 2, :);
    elseif fixType == 2
        currentAction = relativeChanges_PG(relativeChanges_PG(:,3) > 2, :);
    end
    for pat = 1:numParticipants
        inZone = currentAction(currentAction(:,4) >= -cueInterval & currentAction(:,4) <= cueInterval, :);
        outZone = currentAction(currentAction(:,4) < -cueInterval | currentAction(:,4) > cueInterval, :);
        participantReachStartPG(patCount,:) = [pat 3 fixType mean(inZone(inZone(:,1) == pat, 5)) mean(outZone(outZone(:,1) == pat, 5))];
        patCount = patCount + 1;
    end
end
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
subplot(1,2,2)
axis('square')
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
set(gca, 'Xtick', [cueInterval-4 cueInterval-2 cueInterval cueInterval+2], 'XTickLabel', [-4 -2 0 2])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
line([cueInterval cueInterval], [-1 1.5], 'Color', lightGrey)
ylim([-1 1.5])
line([-cueInterval -cueInterval],[-1 2], 'Color', 'k', 'LineStyle', '--')
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 3, 4), ...
    relativeChanges_TW(relativeChanges_TW(:,3) == 3,5), '.', 'Color', fixationPatternColors(4,:))
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 4, 4), ...
    relativeChanges_TW(relativeChanges_TW(:,3) == 4,5), '.', 'Color', fixationPatternColors(5,:))
%% compare within and outside "hot region"
participantReachStartTW = NaN(numParticipants*2,5);
patCount = 1;
%fixType = 4;
%for fixType = 3:4
    currentAction = relativeChanges_TW(relativeChanges_TW(:,3) > 2, :);
    for pat = 1:numParticipants
        inZone = currentAction(currentAction(:,4) >= -cueInterval & currentAction(:,4) <= cueInterval, :);
        outZone = currentAction(currentAction(:,4) < -cueInterval | currentAction(:,4) > cueInterval, :);
        participantReachStartTW(patCount,:) = [pat 4 fixType mean(inZone(inZone(:,1) == pat, 5)) mean(outZone(outZone(:,1) == pat, 5))];
        patCount = patCount + 1;
    end
%end

%% combine data and save
participantReachStart = [participantReachStartPG; participantReachStartTW];

cd(savePath)
save('participantReachStart','participantReachStart')
cd(analysisPath)