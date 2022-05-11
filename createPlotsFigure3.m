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

%%
numSubjects = size(pulledData,1);
numBlocks = size(pulledData,2);
radius = 2.5; % gaze on landmarks in centroid
vigilanceBlocks = [3 4];
tweezerBlocks = [2 4];

for i = 1:numBlocks % plot per block aka experimental condition
    
    slotCount = 1;
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
            gaze = currentBlock(n).gaze;
            info = currentBlock(n).info;
            normalizedData = normalizeMovementsPhases(phaseDurationNorm, info, effector, gaze, i, radius);
            toolSpeed(n,:) = [info.cuedSlot normalizedData.toolSpeed'];
            gazeToBall(n,:) = [info.cuedSlot normalizedData.gazeBall];
            gazeToSlot(n,:) = [info.cuedSlot normalizedData.gazeSlot];
            if ismember(i, vigilanceBlocks)
                gazeToDisplay(n,:) = [info.cuedSlot normalizedData.gazeDisplay];
            end
        end
        % store average trace per subject per slot
        averagedToolSpeed(slotCount:slotCount+2,:) = [[1 nanmedian(toolSpeed(toolSpeed(:,1) == 1, 2:end))]; ...
            [2 nanmedian(toolSpeed(toolSpeed(:,1) == 2, 2:end))]; [3 nanmedian(toolSpeed(toolSpeed(:,1) == 3, 2:end))]];
        averagedGazeToBall(slotCount:slotCount+2,:) = [[1 nanmean(gazeToBall(gazeToBall(:,1) == 1, 2:end))]; ...
            [2 nanmean(gazeToBall(gazeToBall(:,1) == 2, 2:end))]; [3 nanmean(gazeToBall(gazeToBall(:,1) == 3, 2:end))]];
        averagedGazeToSlot(slotCount:slotCount+2,:) = [[1 nanmean(gazeToSlot(gazeToSlot(:,1) == 1, 2:end))]; ...
            [2 nanmean(gazeToSlot(gazeToSlot(:,1) == 2, 2:end))]; [3 nanmean(gazeToSlot(gazeToSlot(:,1) == 3, 2:end))]];
        if ismember(i, vigilanceBlocks)
            averagedGazeToDisplay(slotCount:slotCount+2,:) = [[1 nanmean(gazeToDisplay(gazeToDisplay(:,1) == 1, 2:end))]; ...
                [2 nanmean(gazeToDisplay(gazeToDisplay(:,1) == 2, 2:end))]; [3 nanmean(gazeToDisplay(gazeToDisplay(:,1) == 3, 2:end))]];
        end
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
    plot(mean(averagedToolSpeed(averagedToolSpeed(:,1) == 1, 2:end)), 'Color', grey1, 'LineWidth', 2)
    plot(mean(averagedToolSpeed(averagedToolSpeed(:,1) == 2, 2:end)), 'Color', grey2, 'LineWidth', 2)
    plot(mean(averagedToolSpeed(averagedToolSpeed(:,1) == 3, 2:end)), 'Color', grey3, 'LineWidth', 2)
    
    figure(i*10)
    if ismember(i, tweezerBlocks)
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
    else
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-100 liftoff liftoff+100 liftoff+200], 'XtickLabel', [-.5 0 .5 1])
    end    
    ylim([0 1])
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
    plot(mean(averagedGazeToBall(averagedGazeToBall(:,1) == 1, 2:end)), 'Color', orange1, 'LineWidth', 2)
    plot(mean(averagedGazeToBall(averagedGazeToBall(:,1) == 2, 2:end)), 'Color', orange2, 'LineWidth', 2)
    plot(mean(averagedGazeToBall(averagedGazeToBall(:,1) == 3, 2:end)), 'Color', orange3, 'LineWidth', 2)
    
    plot(mean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 1, 2:end)), 'Color', green1, 'LineWidth', 2)
    plot(mean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 2, 2:end)), 'Color', green2, 'LineWidth', 2)
    plot(mean(averagedGazeToSlot(averagedGazeToSlot(:,1) == 3, 2:end)), 'Color', green3, 'LineWidth', 2)
    
    if ismember(i, vigilanceBlocks)
        plot(mean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 1, 2:end)), 'Color', blue1, 'LineWidth', 2)
        plot(mean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 2, 2:end)), 'Color', blue2, 'LineWidth', 2)
        plot(mean(averagedGazeToDisplay(averagedGazeToDisplay(:,1) == 3, 2:end)), 'Color', blue3, 'LineWidth', 2)
    end
    clear yMax liftoff
end

