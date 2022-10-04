% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
load('pulledData')
load('phaseDurationNorm')
cd(analysisPath);

%%
% define colors --> 3 from each color to code for slots
rectGrey = [166,166,166]./255; % kinematic phase indication
grey1 = [150,150,150]./255; % tool speed
grey2 = [99,99,99]./255;
grey3 = [37,37,37]./255;
orange1 = [253,141,60]./255; % ball
orange2 = [230,85,13]./255;
orange3 = [166,54,3]./255;
green1 = [116,196,118]./255; % slot
green2 = [49,163,84]./255;
green3 = [0,109,44]./255;
blue1 = [107,174,214]./255; % display
blue2 = [49,130,189]./255;
blue3 = [8,81,156]./255;
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;

%%
numSubjects = size(pulledData,1);
numBlocks = size(pulledData,2);
radius = 2.5; % gaze on landmarks in centroid
vigilanceBlocks = [3 4];
tweezerBlocks = [2 4];
sampleRate = 200;
[a,b] = butter(2,20/sampleRate);

for i = 1:numBlocks % plot per block aka experimental condition
    
    slotCount = 0;
    averageLength = sum(floor(phaseDurationNorm(i,3:7))); % normalized durations of phases are stored in columns 3-7
    averagedToolSpeed = NaN(numSubjects*3, averageLength+1);
    averagedGazeToBall = NaN(numSubjects*3, averageLength+1);
    averagedGazeToSlot = NaN(numSubjects*3, averageLength+1);
    if ismember(i, vigilanceBlocks)
        averagedGazeToDisplay = NaN(numSubjects*3, averageLength+1);
    end
    
    for j = 1:numSubjects
        
        currentBlock = pulledData{j,i};
        numTrials = length(currentBlock);
        toolSpeed = NaN(numTrials, averageLength+1);
        gazeToBall = NaN(numTrials, averageLength+1);
        gazeToSlot = NaN(numTrials, averageLength+1);
        if ismember(i, vigilanceBlocks)
            gazeToDisplay = NaN(numTrials, averageLength+1);
        end
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial
            if currentBlock(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            effector = currentBlock(n).effector;
            gaze = currentBlock(n).rawGaze;
            info = currentBlock(n).info;
            normalizedData = normalizeMovementsPhases(phaseDurationNorm, info, effector, gaze, i, radius);
            toolSpeed(n,:) = [info.cuedSlot normalizedData.toolSpeed'];
            gazeToBall(n,:) = [info.cuedSlot normalizedData.gazeBall];
            gazeToSlot(n,:) = [info.cuedSlot normalizedData.gazeSlot];
            if ismember(i, vigilanceBlocks)
                gazeToDisplay(n,:) = [info.cuedSlot normalizedData.gazeDisplay];
            end
        end
        % filter data for each participant and
        % store average trace per subject per slot
        for slotID = 1:3
            currentBallProbability = nanmean(gazeToBall(gazeToBall(:,1) == slotID, 2:end));
            smoothedBallProbability = filtfilt(a,b, currentBallProbability);
            averagedGazeToBall(slotCount+slotID,:) = [slotID smoothedBallProbability];
            currentSlotProbability = nanmean(gazeToSlot(gazeToSlot(:,1) == slotID, 2:end));
            smoothedSlotProbability = filtfilt(a,b, currentSlotProbability);
            averagedGazeToSlot(slotCount+slotID,:) = [slotID smoothedSlotProbability];
            if ismember(i, vigilanceBlocks)
                currentDisplayProbability = nanmean(gazeToDisplay(gazeToDisplay(:,1) == slotID, 2:end));
                smoothedDisplayProbability = filtfilt(a,b, currentDisplayProbability);
                averagedGazeToDisplay(slotCount+slotID,:) = [slotID smoothedDisplayProbability];
            end
        end
        averagedToolSpeed(slotCount+1:slotCount+3,:) = [[1 nanmedian(toolSpeed(toolSpeed(:,1) == 1, 2:end))]; ...
            [2 nanmedian(toolSpeed(toolSpeed(:,1) == 2, 2:end))]; [3 nanmedian(toolSpeed(toolSpeed(:,1) == 3, 2:end))]];
        slotCount = slotCount + 3;
    end
    %%
    figure(i)
    liftoff = sum(floor(phaseDurationNorm(i,3:4))); % reach and ball phase
    if ismember(i, tweezerBlocks)
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
    else
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-100 liftoff liftoff+100 liftoff+200], 'XtickLabel', [-.5 0 .5 1])
    end
    yMax = 75;
    ylim([0 yMax])
    set(gca, 'Ytick', [0 25 50 75],'YTickLabel', [0 25 50 75])
    hold on
    % indicate phases as rectangles
    rectangle('Position', [floor(phaseDurationNorm(i,3)) 0 floor(phaseDurationNorm(i,4)) yMax], ...
        'FaceColor', rectGrey, 'EdgeColor', 'none')
    rectangle('Position', [sum(floor(phaseDurationNorm(i,3:5))) 0 floor(phaseDurationNorm(i,6)) yMax], ...
        'FaceColor', rectGrey, 'EdgeColor', 'none')
    % add time of grasp and ball in slot as vertical lines
    line([liftoff+round(phaseDurationNorm(i,8)) liftoff+round(phaseDurationNorm(i,8))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    line([liftoff+round(phaseDurationNorm(i,9)) liftoff+round(phaseDurationNorm(i,9))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    % plot average tool speed
    plot(nanmean(averagedToolSpeed(averagedToolSpeed(:,1) == 1, 2:end)), 'Color', grey1, 'LineWidth', 2)
    plot(nanmean(averagedToolSpeed(averagedToolSpeed(:,1) == 2, 2:end)), 'Color', grey2, 'LineWidth', 2)
    plot(nanmean(averagedToolSpeed(averagedToolSpeed(:,1) == 3, 2:end)), 'Color', grey3, 'LineWidth', 2)
    
    figure(i*10)
    if ismember(i, tweezerBlocks)
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
    else
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-100 liftoff liftoff+100 liftoff+200], 'XtickLabel', [-.5 0 .5 1])
    end    
    ylim([0 1.02])
    set(gca, 'Ytick', [0 .25 .50 .75 1],'YTickLabel', [0 .25 .50 .75 1])
    hold on
    % indicate phases as rectangles
    rectangle('Position', [floor(phaseDurationNorm(i,3)) 0 floor(phaseDurationNorm(i,4)) yMax], ...
        'FaceColor', rectGrey, 'EdgeColor', 'none')
    rectangle('Position', [sum(floor(phaseDurationNorm(i,3:5))) 0 floor(phaseDurationNorm(i,6)) yMax], ...
        'FaceColor', rectGrey, 'EdgeColor', 'none')
    % add time of grasp and ball in slot as vertical lines
    line([liftoff+round(phaseDurationNorm(i,8)) liftoff+round(phaseDurationNorm(i,8))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    line([liftoff+round(phaseDurationNorm(i,9)) liftoff+round(phaseDurationNorm(i,9))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    % plot fixation probabilities
    plot(nanmean(averagedGazeToBall(averagedGazeToBall(:,1) == 1, 2:end)), 'Color', orange1, 'LineWidth', 2)
    plot(nanmean(averagedGazeToBall(averagedGazeToBall(:,1) == 2, 2:end)), 'Color', orange2, 'LineWidth', 2)
    plot(nanmean(averagedGazeToBall(averagedGazeToBall(:,1) == 3, 2:end)), 'Color', orange3, 'LineWidth', 2)
    
    plot(nanmean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 1, 2:end)), 'Color', green1, 'LineWidth', 2)
    plot(nanmean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 2, 2:end)), 'Color', green2, 'LineWidth', 2)
    plot(nanmean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 3, 2:end)), 'Color', green3, 'LineWidth', 2)
    
    if ismember(i, vigilanceBlocks)
        plot(nanmean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 1, 2:end)), 'Color', blue1, 'LineWidth', 2)
        plot(nanmean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 2, 2:end)), 'Color', blue2, 'LineWidth', 2)
        plot(nanmean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 3, 2:end)), 'Color', blue3, 'LineWidth', 2)
    end
    clear yMax liftoff
end

%% plot panel F
%%
numParticipants = 11;
eyeShift = 20; % samples between fixations determined by visual inspection; works with longer value as well
gazeSequence = [];
for blockID = 3:4
    for i = 1:numParticipants % loop over subjects
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        currentGazeSequence = NaN(numTrials,5);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            % cannot classify trials in which the ball is fixated multiple times
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                continue
            end
            % ball and slot fixations during reach and transport phase
            if isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
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
            letterChange = currentResult(n).dualTask.sampleLetterChange(1);
            graspDifference = (letterChange-currentResult(n).info.phaseStart.ballGrasp)/200; % in seconds
            dropDifference = (letterChange-currentResult(n).info.phaseStart.ballInSlot)/200; % in seconds
            
            currentGazeSequence(n,:) = [blockID currentParticipant fixationPattern ...
                graspDifference dropDifference];
        end
        gazeSequence = [gazeSequence; currentGazeSequence];
    end
end
clear ballIdx ballOffset slotIdx slotOnset ballFixType 
clear letterChange graspDifference dropDifference

%% Plot fixation pattern for each grasp mode (Panel B)
% initiate variable to plot mean
fixationPatternAverage = NaN(numParticipants*2,6);
count = 1;
x = [1 2 3 4 5];
for blockID = 3:4
    currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,2) == i,3);
        currentParticipant = currentParticipant(~isnan(currentParticipant));
        figure(blockID)
        if blockID < 4
            title('Fingertips')
        else
            title('Tweezers')
        end
        hold on
        set(gcf,'renderer','Painters')
        xlim([.5 5.5])
        set(gca, 'Xtick', [1 2 3 4 5], 'XtickLabel', {'display-only', 'ball-only', 'slot-only', 'ball-slot', 'ball-display-slot'})
        ylim([0 1])
        set(gca, 'Ytick', [0 .25 .5 .75 1])
        for n = 1:5
            plot(x(n), sum(currentParticipant(:,1) == n-1)/length(currentParticipant), ...
                'o', 'MarkerEdgeColor', fixationPatternColors(n,:), 'MarkerFaceColor', fixationPatternColors(n,:))
        end
        fixationPatternAverage(count,:) = [blockID sum(currentParticipant == 0)/length(currentParticipant) ...
            sum(currentParticipant == 1)/length(currentParticipant) sum(currentParticipant == 2)/length(currentParticipant)...
            sum(currentParticipant == 3)/length(currentParticipant) sum(currentParticipant == 4)/length(currentParticipant)];
        count = count + 1;
    end
end
for blockID = 3:4
    figure(blockID)
    for n = 1:5
        currentBarData = fixationPatternAverage(fixationPatternAverage(:,1) == blockID,2:end);
        b = bar(x(n),median(currentBarData(:,n)), .6);
        b.FaceColor = fixationPatternColors(n,:);
        b.EdgeColor = fixationPatternColors(n,:);
        b.FaceAlpha = 0.5;
    end
end