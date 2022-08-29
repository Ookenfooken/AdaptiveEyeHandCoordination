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
lightBlue = [107,174,214]./255;
green = [77,175,74]./255;
orange = [255,127,0]./255;
blue = [55,126,184]./255;
lightGreen = [116,196,118]./255;
lightPurple = [158,154,200]./255;
darkPurple = [77,0,75]./255;

%%
numSubjects = size(pulledData,1);
numBlocks = size(pulledData,2);
radius = 2.5; % gaze on landmarks in centroid
vigilanceBlocks = [3 4];
tweezerBlocks = [2 4];

for i = 3:numBlocks % plot per block aka experimental condition
    count = 1;    
    if i == 3
        reachOnset = ceil(289.8013);
    else
        reachOnset = ceil(305.8878);
    end
    averageLength = sum(floor(phaseDurationNorm(i,3:7)))+reachOnset; % normalized durations of phases are stored in columns 3-7
    averagedSilentPeriod = NaN(numSubjects, averageLength);
    silentFixationType = NaN(numSubjects*2, averageLength+1);
    averagedEarlyReaches = NaN(numSubjects, averageLength);
    averagedMissedChanges = NaN(numSubjects, averageLength);
    averagedBallFixations = NaN(numSubjects, averageLength);
    averagedSlotFixations = NaN(numSubjects, averageLength);
    
    for j = 1:numSubjects
        
        currentBlock = pulledData{j,i};
        numTrials = length(currentBlock);
        silentPeriod = NaN(numTrials, averageLength+1);
        silentPreReach = NaN(numTrials, averageLength);
        missedChanges = NaN(numTrials, averageLength);
        gazeToBall = NaN(numTrials, averageLength);
        gazeToSlot = NaN(numTrials, averageLength);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial
            if currentBlock(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            effector = currentBlock(n).effector;
            gaze = currentBlock(n).gaze;
            trialInfo = currentBlock(n).info;
            dualInfo = currentBlock(n).dualTask;
            if n > 1
                dualPrevious = currentBlock(n-1).dualTask;
            else
                dualPrevious.tLetterChanges = NaN;
            end
            if isnan(dualInfo.tLetterChanges)
                continue
            end
            eyeShift = 20;
            if numel(gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(gaze.fixation.onsetsBall) && isempty(gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(gaze.fixation.onsetsBall) && ~isempty(gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(gaze.fixation.onsetsBall) && isempty(gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = gaze.fixation.offsetsBall(1);
                slotIdx = find(gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end
            normalizedDataLetters = normalizeSilentPeriod(phaseDurationNorm, trialInfo, dualInfo,  dualPrevious, i);
            normalizedData = normalizeMovementsPhases(phaseDurationNorm, trialInfo, effector, gaze, i, radius);
            silentPeriod(n,:) = [fixationPattern normalizedDataLetters.silentPeriod];
            silentPreReach(n,:) = normalizedDataLetters.silentPreReach;
            missedChanges(n,:) = normalizedDataLetters.missedChanges;
            gazeToBall(n,:) = [zeros(1,reachOnset) normalizedData.gazeBall];
            gazeToSlot(n,:) = [zeros(1,reachOnset) normalizedData.gazeSlot];
        end
        % store average trace per participant
        averagedSilentPeriod(j,:) = nanmean(silentPeriod(:,2:end));  
        averagedEarlyReaches(j,:) = nanmean(silentPreReach);  
        averagedMissedChanges(j,:) = nanmean(missedChanges);  
        averagedBallFixations(j,:) = nanmean(gazeToBall);  
        averagedSlotFixations(j,:) = nanmean(gazeToSlot);     
        if i == 3
            silentFixationType(count:count+1,:) = [[1 nanmean(silentPeriod(silentPeriod(:,1) == 0, 2:end),1)]; ...
            [2 nanmean(silentPeriod(silentPeriod(:,1) == 2, 2:end))]];
        else
            silentFixationType(count:count+1,:) = [[1 nanmean(silentPeriod(silentPeriod(:,1) == 3, 2:end),1)]; ...
            [2 nanmean(silentPeriod(silentPeriod(:,1) == 4, 2:end))]];
        end
        count = count + 2;
    end
    %%
    figure(i)
    hold on
    yMax = 0.75;
    ylim([0 yMax])
    plot(mean(averagedBallFixations), 'Color', orange, 'LineWidth', 2)
    plot(mean(averagedSlotFixations), 'Color', green, 'LineWidth', 2)
    plot(mean(averagedSilentPeriod), 'Color', grey2, 'LineWidth', 2)
    if i == 3
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 1, 2:end)), 'Color', blue, 'LineWidth', 2)
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 2, 2:end)), 'Color', lightGreen, 'LineWidth', 2)
    else
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 1, 2:end)), 'Color', lightPurple, 'LineWidth', 2)
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 2, 2:end)), 'Color', darkPurple, 'LineWidth', 2)
    end
    %plot(mean(averagedEarlyReaches), 'Color', lightBlue, 'LineWidth', 2)
    plot(mean(averagedMissedChanges), 'Color', 'k', 'LineWidth', 2)
    % reach onset
    line([reachOnset reachOnset], [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % ball approach
    line([floor(phaseDurationNorm(i,3))+reachOnset floor(phaseDurationNorm(i,3))+reachOnset], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % ball contact
    line([sum(floor(phaseDurationNorm(i,3:4)))+reachOnset+floor(phaseDurationNorm(i,8)) ...
          sum(floor(phaseDurationNorm(i,3:4)))+floor(phaseDurationNorm(i,8))+reachOnset], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % transport
    line([sum(floor(phaseDurationNorm(i,3:4)))+reachOnset sum(floor(phaseDurationNorm(i,3:4)))+reachOnset], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % slot approach
    line([sum(floor(phaseDurationNorm(i,3:5)))+reachOnset sum(floor(phaseDurationNorm(i,3:5)))+reachOnset], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % slot entry
    line([sum(floor(phaseDurationNorm(i,3:4)))+reachOnset+floor(phaseDurationNorm(i,9)) ...
          sum(floor(phaseDurationNorm(i,3:4)))+floor(phaseDurationNorm(i,9))+reachOnset], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % return
    line([sum(floor(phaseDurationNorm(i,3:6)))+reachOnset sum(floor(phaseDurationNorm(i,3:6)))+reachOnset], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    
    
    clear yMax liftoff
end

