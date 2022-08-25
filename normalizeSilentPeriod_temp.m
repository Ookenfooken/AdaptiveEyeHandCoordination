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

%%
numSubjects = size(pulledData,1);
numBlocks = size(pulledData,2);
radius = 2.5; % gaze on landmarks in centroid
vigilanceBlocks = [3 4];
tweezerBlocks = [2 4];

for i = 3:numBlocks % plot per block aka experimental condition
    
    slotCount = 1;
    if i == 3
        averageLength = sum(floor(phaseDurationNorm(i,3:7)))+ceil(289.8013); % normalized durations of phases are stored in columns 3-7
    else
        averageLength = sum(floor(phaseDurationNorm(i,3:7)))+ceil(305.8878);
    end
    averagedSilentPeriod = NaN(numSubjects, averageLength);
    averagedSilentChangeBeforeReach = NaN(numSubjects*3, averageLength);
    
    for j = 1:numSubjects
        
        currentBlock = pulledData{j,i};
        numTrials = length(currentBlock);
        silentPeriod = NaN(numTrials, averageLength);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial
            if currentBlock(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialInfo = currentBlock(n).info;
            dualInfo = currentBlock(n).dualTask;
            if n > 1
                dualPrevious = currentBlock(n-1).dualTask;
            else
                dualPrevious = [];
            end
            if isnan(dualInfo.tLetterChanges)
                continue
            end
            if n ==28
                x = 5;
            end
            normalizedData = normalizeSilentPeriod(phaseDurationNorm, trialInfo, dualInfo,  dualPrevious, i);
            silentPeriod(n,:) = normalizedData.silentPeriod;
        end
        % store average trace per subject per slot
        averagedSilentPeriod(j,:) = nanmean(silentPeriod);        
    end
    %%
    figure(i)
    liftoff = sum(floor(phaseDurationNorm(i,3:4)))+ceil(289.8013); % reach and ball phase
    if ismember(i, tweezerBlocks)
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300], 'XtickLabel', [-1 -.5 0 .5 1 1.5])
    else
        xlim([0 averageLength])
        set(gca, 'Xtick', [liftoff-100 liftoff liftoff+100 liftoff+200], 'XtickLabel', [-.5 0 .5 1])
    end
    yMax = 1;
    ylim([0 yMax])
    %set(gca, 'Ytick', [0 25 50 75],'YTickLabel', [0 25 50 75])
    hold on
%     % indicate phases as rectangles
%     rectangle('Position', [floor(phaseDurationNorm(i,3)) 0 floor(phaseDurationNorm(i,4)) yMax], ...
%         'FaceColor', rectGrey, 'EdgeColor', 'none')
%     rectangle('Position', [sum(floor(phaseDurationNorm(i,3:5))) 0 floor(phaseDurationNorm(i,6)) yMax], ...
%         'FaceColor', rectGrey, 'EdgeColor', 'none')
    % add time of grasp and ball in slot as vertical lines
    line([liftoff+round(phaseDurationNorm(i,8)) liftoff+round(phaseDurationNorm(i,8))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    line([liftoff+round(phaseDurationNorm(i,9)) liftoff+round(phaseDurationNorm(i,9))], [0 yMax], ...
        'Color', 'k', 'LineStyle', '--')
    % plot average tool speed
    plot(mean(averagedSilentPeriod), 'Color', grey1, 'LineWidth', 2)
    
    clear yMax liftoff
end

