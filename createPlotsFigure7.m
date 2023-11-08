% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% calculate letter changes per trial
numParticipants = 11;
letterChanges = [];

for j = 1:numParticipants % loop over participants
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        participant = currentParticipant*ones(numTrials, 1);
        testID = blockID*ones(numTrials,1);
        letterChange = NaN(numTrials,1);
        numLetterChange = NaN(numTrials,1);
        reachOnset = NaN(numTrials,1);
        displayFixationTime = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            startTime = currentResult(n).info.trialStart;
            letterChange(n) = currentResult(n).dualTask.sampleLetterChange(1);
            if isnan(currentResult(n).dualTask.sampleLetterChange)
                numLetterChange(n) = 0;
            else
                numLetterChange(n) = numel(currentResult(n).dualTask.sampleLetterChange);
            end
            reachOnset(n) = currentResult(n).info.phaseStart.primaryReach; 
            displayFixationTime(n) = sum(currentResult(n).gaze.fixation.durationDisplay)./...
                                     (sum(currentResult(n).gaze.fixation.durationBall) + ...
                                     sum(currentResult(n).gaze.fixation.durationSlot) + ...
                                     sum(currentResult(n).gaze.fixation.durationDisplay));          
        end
        currentVariable = [participant testID numLetterChange letterChange ...
                           reachOnset displayFixationTime];
        
        letterChanges = [letterChanges; currentVariable];
        clear startTime trialLength
    end
end

letterChanges_FT = letterChanges(letterChanges(:,2) == 3,:);
letterChanges_TW = letterChanges(letterChanges(:,2) == 4,:);
% to calculate mean number of changes run:
% nanmean(letterChanges_FT(:,3))
% nanmean(letterChanges_TW(:,3))

clear currentVariable displayFixationTime letterChange numLetterChange reachOnset participant testID
%% readout vigilance task performance
numParticipants = 11;
dualTaskPerformance = [];
for j = 1:numParticipants % loop over participants
    for blockID = 3:4 % loop over blocks/experimental conditions
        c = 1;
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if isnan(currentResult(n).dualTask.tLetterChanges)
                continue
            end
            c = c:c+length(currentResult(n).dualTask.tLetterChanges)-1;
            changeDetected(c) = currentResult(n).dualTask.changeDetected;
            changeMissed(c) = currentResult(n).dualTask.changeMissed;
                        
            c = c(end) + 1;
        end
        currentPerformance = [currentParticipant blockID c-1 sum(changeDetected) sum(changeMissed)];
        
        dualTaskPerformance = [dualTaskPerformance; currentPerformance];
        clear letterChangePhase changeDetected changeMissed currentPerformance
    end
end
clear c  

%% average and save vigilance task performance 
letterDetectAverage_FT = NaN(numParticipants,3);
selectedData = dualTaskPerformance(dualTaskPerformance(:,2) == 3,:);
for i = 1:numParticipants
    letterDetectAverage_FT(i,:) = [i 3 sum(selectedData(selectedData(:,1) == i,4))/...
        sum(selectedData(selectedData(:,1) == i,3))];
end
letterDetectAverage_TW = NaN(numParticipants,3);
selectedData = dualTaskPerformance(dualTaskPerformance(:,2) == 4,:);
for i = 1:numParticipants
    letterDetectAverage_TW(i,:) = [i 4 sum(selectedData(selectedData(:,1) == i,4))/...
        sum(selectedData(selectedData(:,1) == i,3))];
end

letterDetectAverage = [letterDetectAverage_FT; letterDetectAverage_TW];

cd(savePath)
save('letterDetectAverage', 'letterDetectAverage')
cd(analysisPath)

clear selectedData
%% Histograms in Panel C & D
reachRelativeLetter = [];
detectedChanges = [];
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
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                landmarkFixation = 0;
            else
                landmarkFixation = 1;
            end        
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
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern landmarkFixation... 
             letterChangeRelativeReach];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        reachRelativeLetter = [reachRelativeLetter; currentVariable];

        clear fixationPattern landmarkFixation  letterChangeRelativeReach
        clear reach slotIdx slotOnset ballOffset currentLetterChange
    end
end
%%
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
upperBound = 6.5;
xymax = 20;
binWidth = .25;
%% new plot all fixation patterns
reachData_PG = reachRelativeLetter(reachRelativeLetter(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
selectedColumn = 5;
reaches_PG = reachData_PG(reachData_PG(:,3) ~= selectedPattern,:);
figure(8377)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.PGback = histogram(reaches_PG(reaches_PG(:,3) == 4,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.PGtri = histogram(reaches_PG(reaches_PG(:,3) == 3,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.reach.PGslot = histogram(reaches_PG(reaches_PG(:,3) == 2,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.reach.PGdisp = histogram(reaches_PG(reaches_PG(:,3) == 0,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(1,:), 'edgecolor', 'none');
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
SP_PG_disp = sum(h.reach.PGdisp.Values)*h.reach.PGdisp.BinWidth / 4;
line([0 1.5], [SP_PG_disp SP_PG_disp], 'Color', fixationPatternColors(1,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG_disp 0], 'Color', fixationPatternColors(1,:), 'LineStyle', '--', 'LineWidth', 1.5)
%%
reachData_TW = reachRelativeLetter(reachRelativeLetter(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
selectedColumn = 5;
reaches_TW = reachData_TW(reachData_TW(:,3) ~= selectedPattern,:);
figure(8477)
xlabel('Time of reach onset re: last detected LC before reach (s)')
ylabel('Frequency of trials')
set(gcf,'renderer','Painters')
xlim([0 upperBound])
ylim([0 xymax])
set(gca, 'Ytick', [0 5 10 15 20])
hold on
h.reach.TWback = histogram(reaches_TW(reaches_TW(:,3) == 4,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(5,:), 'edgecolor', 'none');
h.reach.TWtri = histogram(reaches_TW(reaches_TW(:,3) == 3,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(4,:), 'edgecolor', 'none');
h.reach.TWslot = histogram(reaches_TW(reaches_TW(:,3) == 2,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(3,:), 'edgecolor', 'none');
h.reach.TWdisp = histogram(reaches_TW(reaches_TW(:,3) == 0,selectedColumn), 'BinWidth', binWidth,...
    'facecolor', fixationPatternColors(1,:), 'edgecolor', 'none');
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
SP_TW_disp = sum(h.reach.TWdisp.Values)*h.reach.TWdisp.BinWidth / 4;
line([0 1.5], [SP_TW_disp SP_TW_disp], 'Color', fixationPatternColors(1,:), 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW_disp 0], 'Color', fixationPatternColors(1,:), 'LineStyle', '--', 'LineWidth', 1.5)
%% plot reach onset relative to letter change for PG and TW
lightGrey = [189,189,189]./255;
blue = [55,126,184]./255; % display only

fixations_PG_all = reachRelativeLetter( reachRelativeLetter(:,1) == 3,:);
fixations_PG_detected = fixations_PG_all(~isnan(fixations_PG_all(:,3)),:);

fixations_TW_all = reachRelativeLetter( reachRelativeLetter(:,1) == 4,:);
fixations_TW_detected = fixations_TW_all(~isnan(fixations_TW_all(:,3)),:);

selectedColumn = 3; % reach onset
upperBound = 6.5;
reaches_PG = fixations_PG_detected(fixations_PG_detected(:,selectedColumn) < upperBound, :);
reaches_TW = fixations_TW_detected(fixations_TW_detected(:,selectedColumn) < upperBound, :);
figure(selectedColumn)
hold on
set(gcf,'renderer','Painters')
h.PG1 = histogram(reaches_PG(reaches_PG(:,2) == 1, selectedColumn), 'BinWidth', .25, 'facecolor', blue, 'edgecolor', 'none');
h.PG2 = histogram(reaches_PG(reaches_PG(:,2) == 0, selectedColumn), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none');
xlim([0 upperBound])
ylim([0 50])
box off
figure(selectedColumn*10)
hold on
set(gcf,'renderer','Painters')
h.TW1 = histogram(reaches_TW(reaches_TW(:,2) == 1, selectedColumn), 'BinWidth', .25, 'facecolor', blue, 'edgecolor', 'none');
h.TW2 = histogram(reaches_TW(reaches_TW(:,2) == 0, selectedColumn), 'BinWidth', .25, 'facecolor', lightGrey, 'edgecolor', 'none'); 
xlim([0 upperBound])
ylim([0 50])
box off

% generate expected distribution
% solve for silent period value
SP_PG1 = sum(h.PG1.Values)*h.PG1.BinWidth / 4;
SP_PG2 = sum(h.PG2.Values)*h.PG2.BinWidth / 4;
figure(selectedColumn)
line([0 1.5], [SP_PG1 SP_PG1], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG1 0], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([0 1.5], [SP_PG2 SP_PG2], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_PG2 0], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)

SP_TW1 = sum(h.TW1.Values)*h.TW1.BinWidth / 4;
SP_TW2 = sum(h.TW2.Values)*h.TW2.BinWidth / 4;
figure(selectedColumn*10)
line([0 1.5], [SP_TW1 SP_TW1], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW1 0], 'Color', blue, 'LineStyle', '--', 'LineWidth', 1.5)
line([0 1.5], [SP_TW2 SP_TW2], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
line([1.5 6.5], [SP_TW2 0], 'Color', lightGrey, 'LineStyle', '--', 'LineWidth', 1.5)
%% test distribution against expected distribution
% generate mock distribution
binWidth = .25;
expectedDistribution = [];
slope = SP_PG1/5;
% landmark fixation
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG1)*ones((1-SP_PG1+floor(SP_PG1))*10000,1); ...
            ceil(SP_PG1)*ones((1-ceil(SP_PG1)+SP_PG1)*10000,1)];
    else
        binCount = [floor(SP_PG1-(i-1.5)*slope)*ones((1-SP_PG1+floor(SP_PG1-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG1-(i-1.5)*slope)*ones((1-ceil(SP_PG1-(i-1.5)*slope)+SP_PG1)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test landmark fixation
[h_PG1, p_PG1, ks2statPG1] = kstest2(reaches_PG(reaches_PG(:,2) == 1, selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope

expectedDistribution = [];
slope = SP_PG2/5;
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_PG2)*ones((1-SP_PG2+floor(SP_PG2))*10000,1); ...
            ceil(SP_PG2)*ones((1-ceil(SP_PG2)+SP_PG2)*10000,1)];
    else
        binCount = [floor(SP_PG2-(i-1.5)*slope)*ones((1-SP_PG2+floor(SP_PG2-(i-1.5)*slope))*10000,1); ...
            ceil(SP_PG2-(i-1.5)*slope)*ones((1-ceil(SP_PG2-(i-1.5)*slope)+SP_PG2)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test all fixations
[h_PG2, p_PG2, ks2statPG2] = kstest2(reaches_PG(:,selectedColumn), expectedDistribution);


expectedDistribution = [];
slope = SP_TW1/5;
% landmark fixation
for i = 0:binWidth:6.5+binWidth
    if i <= 1.5
        binCount = [floor(SP_TW1)*ones((1-SP_TW1+floor(SP_TW1))*10000,1); ...
            ceil(SP_TW1)*ones((1-ceil(SP_TW1)+SP_TW1)*10000,1)];
    else
        binCount = [floor(SP_TW1-(i-1.5)*slope)*ones((1-SP_TW1+floor(SP_TW1-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW1-(i-1.5)*slope)*ones((1-ceil(SP_TW1-(i-1.5)*slope)+SP_TW1)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binCount))),1)];
end
% ks test landmark fixation
[h_TW1, p_TW1, ks2statTW1] = kstest2(reaches_TW(reaches_TW(:,2) == 1, selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope

expectedDistribution = [];
slope = SP_TW2/5;
for i = 0:binWidth:6.5
    if i <= 1.5
        binCount = [floor(SP_TW2)*ones((1-SP_TW2+floor(SP_TW2))*10000,1); ...
            ceil(SP_TW2)*ones((1-ceil(SP_TW2)+SP_TW2)*10000,1)];
    else
        binCount = [floor(SP_TW2-(i-1.5)*slope)*ones((1-SP_TW2+floor(SP_TW2-(i-1.5)*slope))*10000,1); ...
            ceil(SP_TW2-(i-1.5)*slope)*ones((1-ceil(SP_TW2-(i-1.5)*slope)+SP_TW2)*10000,1)];
    end
    expectedDistribution = [expectedDistribution; i*ones(binCount(randi(numel(binWidth))),1)];
end
% ks test all fixations
%[h_TW2, p_TW2, ks2statTW2] = kstest2(reaches_TW(:,selectedColumn), expectedDistribution);
clear expectedDistribution binCount slope

%% plot the response time (reach onset relative to go signal) vs. the time 
% of the last detected letter change (relative to go) --> Panels C & D
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
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                landmarkFixation = 0;
            else
                landmarkFixation = 1;
            end
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

            currentVariable(n,:) = [currentParticipant blockID landmarkFixation...
                letterChangeRelativeGo goToReach];
            clear currentLC_early currentLC_late 
        end

        speedRelativeLetterChange = [speedRelativeLetterChange; currentVariable];
    end
end

%%
relativeChanges_PG = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 3,:);
% plot time of last detected letter change (before reach onset) relative to
% go signal
lowerLimit = -4;
upperLimit = 4;
binWidth = .25;
figure(33)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
set(gca, 'Xtick', [cueInterval-4 cueInterval-2 cueInterval cueInterval+2], 'XTickLabel', [-4 -2 0 2])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
line([cueInterval cueInterval], [-1 1.5], 'Color', lightGrey)
ylim([-1 1.5])
line([-cueInterval -cueInterval],[-1 2], 'Color', 'k', 'LineStyle', '--')
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 0, 4), relativeChanges_PG(relativeChanges_PG(:,3) == 0,5), '.', 'Color', 'k')
plot(relativeChanges_PG(relativeChanges_PG(:,3) == 1, 4), relativeChanges_PG(relativeChanges_PG(:,3) == 1,5), '.', 'Color', blue)

%% compare within and outside "hot region"
participantReachStartPG = NaN(numParticipants*2,5);
patCount = 1;
for act = 0:1
    currentAction = relativeChanges_PG(relativeChanges_PG(:,3) == act, :);
    for pat = 1:numParticipants
        inZone = currentAction(currentAction(:,4) >= -cueInterval & currentAction(:,4) <= cueInterval, :);
        outZone = currentAction(currentAction(:,4) < -cueInterval | currentAction(:,4) > cueInterval, :);
        participantReachStartPG(patCount,:) = [pat 3 act mean(inZone(inZone(:,1) == pat, 5)) mean(outZone(outZone(:,1) == pat, 5))];
        patCount = patCount + 1;
    end
end
%%
relativeChanges_TW = speedRelativeLetterChange(speedRelativeLetterChange(:,2) == 4,:);
% plot time of last detected letter change (before reach onset) relative to
% reach onset and movement time in red
figure(44)
set(gcf,'renderer','Painters', 'Position', [50 100 436 364])
hold on
xlim([lowerLimit upperLimit])
set(gca, 'Xtick', [cueInterval-4 cueInterval-2 cueInterval cueInterval+2], 'XTickLabel', [-4 -2 0 2])
line([lowerLimit upperLimit],[0 0], 'Color', lightGrey)
line([cueInterval cueInterval], [-1 1.5], 'Color', lightGrey)
ylim([-1 1.5])
line([-cueInterval -cueInterval],[-1 2], 'Color', 'k', 'LineStyle', '--')
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 0, 4), relativeChanges_TW(relativeChanges_TW(:,3) == 0,5), '.', 'Color', lightGrey)
plot(relativeChanges_TW(relativeChanges_TW(:,3) == 1, 4), relativeChanges_TW(relativeChanges_TW(:,3) == 1,5), '.', 'Color', blue)

%% compare within and outside "hot region"
participantReachStartTW = NaN(numParticipants*2,5);
patCount = 1;
for act = 0:1
    currentAction = relativeChanges_TW(relativeChanges_TW(:,3) == act, :);
    for pat = 1:numParticipants
        inZone = currentAction(currentAction(:,4) >= -cueInterval & currentAction(:,4) <= cueInterval, :);
        outZone = currentAction(currentAction(:,4) < -cueInterval | currentAction(:,4) > cueInterval, :);
        participantReachStartTW(patCount,:) = [pat 4 act mean(inZone(inZone(:,1) == pat, 5)) mean(outZone(outZone(:,1) == pat, 5))];
        patCount = patCount + 1;
    end
end

%% combine data and save
participantReachStart = [participantReachStartPG; participantReachStartTW];

cd(savePath)
save('participantReachStart','participantReachStart')
cd(analysisPath)