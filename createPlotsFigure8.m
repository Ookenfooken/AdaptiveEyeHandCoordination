% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
load('pulledData')
load('phaseDurationNorm')
load('phaseDurationEarlyReaches')
cd(analysisPath);

%%
% define colors --> 3 from each color to code for slots
rectGrey = [166,166,166]./255; % kinematic phase indication
grey1 = [150,150,150]./255; % tool speed
grey2 = [99,99,99]./255;
grey3 = [37,37,37]./255;
lightBlue = [116,169,207]./255;
green = [77,175,74]./255;
orange = [255,127,0]./255;
blue = [55,126,184]./255;
lightGreen = [116,196,118]./255;
lightPurple = [158,154,200]./255;
darkPurple = [77,0,75]./255;
red = [228,26,28]./255;
sampleRate = 200;
[a,b] = butter(2,20/sampleRate);

%%
numSubjects = size(pulledData,1);
numBlocks = size(pulledData,2);
radius = 2.5; % gaze on landmarks in centroid
vigilanceBlocks = [3 4];
tweezerBlocks = [2 4];

for i = 3:numBlocks % plot per block aka experimental condition
    count = 1;
    reachOnset = floor(phaseDurationNorm(i,10));
    averageLengthAll = sum(floor(phaseDurationNorm(i,3:7)))+reachOnset; % normalized durations of phases are stored in columns 3-7
    averageLengthEarly = sum(floor(phaseDurationEarlyReaches(i,3:7)))+...
        floor(phaseDurationEarlyReaches(i,10));
    % overall average silent periods and fixations
    averagedSilentPeriod = NaN(numSubjects, averageLengthAll);
    averagedTimeLC = NaN(numSubjects, averageLengthAll);
    averagedMissedChanges = NaN(numSubjects, averageLengthAll);
    averagedBallFixations = NaN(numSubjects, averageLengthAll);
    averagedSlotFixations = NaN(numSubjects, averageLengthAll);
    % averages for early reaches
    earlySilentPeriod = NaN(numSubjects, averageLengthEarly);
    earlyTimeLC = NaN(numSubjects, averageLengthEarly);
    earlyMissedChanges = NaN(numSubjects, averageLengthEarly);
    earlyBallFixations = NaN(numSubjects, averageLengthEarly);
    earlySlotFixations = NaN(numSubjects, averageLengthEarly);
    % separated by fixation pattern
    silentFixationType = NaN(numSubjects*2, averageLengthAll+1);
    timeLCFixationType = NaN(numSubjects, averageLengthAll+1);
    missFixationType = NaN(numSubjects*2, averageLengthAll+1);
    ballFixationType = NaN(numSubjects*2, averageLengthAll+1);
    slotFixationType = NaN(numSubjects*2, averageLengthAll+1);
    
    for j = 1:numSubjects
        
        currentBlock = pulledData{j,i};
        numTrials = length(currentBlock);
        % all trials
        silentPeriod = NaN(numTrials, averageLengthAll+1);
        timeLetterChange = NaN(numTrials, averageLengthAll+1);
        missedChanges = NaN(numTrials, averageLengthAll+1);
        gazeToBall = NaN(numTrials, averageLengthAll+1);
        gazeToSlot = NaN(numTrials, averageLengthAll+1);
        % early reach trials
        silentPeriod_early = NaN(numTrials, averageLengthEarly);
        timeLetterChange_early = NaN(numTrials, averageLengthEarly);
        missedChanges_early = NaN(numTrials, averageLengthEarly);
        gazeToBall_early = NaN(numTrials, averageLengthEarly);
        gazeToSlot_early = NaN(numTrials, averageLengthEarly);
        % loop over trials
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial
            if currentBlock(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            effector = currentBlock(n).effector;
            rawGaze = currentBlock(n).rawGaze;
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
            normalizedData = normalizeSilentPeriod(phaseDurationNorm, phaseDurationEarlyReaches, ...
                trialInfo, rawGaze, dualInfo, dualPrevious, i, radius);
            % all trials
            silentPeriod(n,:) = [fixationPattern normalizedData.silentPeriod];
            timeLetterChange(n,:) = [fixationPattern normalizedData.timeLC];
            missedChanges(n,:) = [fixationPattern normalizedData.missedChanges];
            gazeToBall(n,:) = [fixationPattern normalizedData.gazeBall];
            gazeToSlot(n,:) = [fixationPattern normalizedData.gazeSlot];
            % trials in which reach was initiated 1 s after LC
            silentPeriod_early(n,:) = normalizedData.silentPreReach;
            timeLetterChange_early(n,:) = normalizedData.timeLCPreReach;
            missedChanges_early(n,:) = normalizedData.missedLCPreReach;
            gazeToBall_early(n,:) = normalizedData.gazeBallPreReach;
            gazeToSlot_early(n,:) = normalizedData.gazeSlotPreReach;
        end
        % filter data for each participant and
        % store average trace per participant
        averagedSilentPeriod(j,:) = filtfilt(a,b, nanmean(silentPeriod(:,2:end)));
        averagedTimeLC(j,:) = filtfilt(a,b, nanmean(timeLetterChange(:,2:end)));
        averagedMissedChanges(j,:) = filtfilt(a,b, nanmean(missedChanges(:,2:end)));
        averagedBallFixations(j,:) = filtfilt(a,b, nanmean(gazeToBall(:,2:end)));
        averagedSlotFixations(j,:) = filtfilt(a,b, nanmean(gazeToSlot(:,2:end)));
        % for early reaches
        earlySilentPeriod(j,:) = filtfilt(a,b, nanmean(silentPeriod_early));
        earlyTimeLC(j,:) = filtfilt(a,b, nanmean(timeLetterChange_early));
        earlyMissedChanges(j,:) = filtfilt(a,b, nanmean(missedChanges_early));
        earlyBallFixations(j,:) = filtfilt(a,b, nanmean(gazeToBall_early));
        earlySlotFixations(j,:) = filtfilt(a,b, nanmean(gazeToSlot_early));
        % by fixation type
        if i == 3
            testSetDisp = nanmean(silentPeriod(silentPeriod(:,1) == 0, 2:end),1);
            testSetSlot = nanmean(silentPeriod(silentPeriod(:,1) == 2, 2:end),1);
            if isnan(testSetDisp(2))
                silentFixationType(count:count+1,:) = [[1 nanmean(silentPeriod(silentPeriod(:,1) == 0, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 2, 2:end),1))]];
                timeLCFixationType(count:count+1,:) = [[1 nanmean(timeLetterChange(timeLetterChange(:,1) == 0, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 2, 2:end)))]];
                missFixationType(count:count+1,:) = [[1 nanmean(missedChanges(missedChanges(:,1) == 0, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 2, 2:end)))]];
                ballFixationType(count:count+1,:) = [[1 nanmean(gazeToBall(gazeToBall(:,1) == 0, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 2, 2:end)))]];
                slotFixationType(count:count+1,:) = [[1 nanmean(gazeToSlot(gazeToSlot(:,1) == 0, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 2, 2:end)))]];
            elseif isnan(testSetSlot(2))
                silentFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 0, 2:end),1))]; ...
                    [2 nanmean(silentPeriod(silentPeriod(:,1) == 2, 2:end),1)]];
                timeLCFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 0, 2:end),1))]; ...
                    [2 nanmean(timeLetterChange(timeLetterChange(:,1) == 2, 2:end))]];
                missFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 0, 2:end),1))]; ...
                    [2 nanmean(missedChanges(missedChanges(:,1) == 2, 2:end))]];
                ballFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 0, 2:end),1))]; ...
                    [2 nanmean(gazeToBall(gazeToBall(:,1) == 2, 2:end))]];
                slotFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 0, 2:end),1))]; ...
                    [2 nanmean(gazeToSlot(gazeToSlot(:,1) == 2, 2:end))]];
            else
                silentFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 0, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 2, 2:end),1))]];
                timeLCFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 0, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 2, 2:end)))]];
                missFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 0, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 2, 2:end)))]];
                ballFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 0, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 2, 2:end)))]];
                slotFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 0, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 2, 2:end)))]];
            end
            clear testSetDisp testSetSlot
        else
            testSetTri = nanmean(silentPeriod(silentPeriod(:,1) == 3, 2:end),1);
            testSetBack = nanmean(silentPeriod(silentPeriod(:,1) == 4, 2:end),1);
            if isnan(testSetTri(2))
                silentFixationType(count:count+1,:) = [[1 nanmean(silentPeriod(silentPeriod(:,1) == 3, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 4, 2:end),1))]];
                timeLCFixationType(count:count+1,:) = [[1 nanmean(timeLetterChange(timeLetterChange(:,1) == 3, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 4, 2:end)))]];
                missFixationType(count:count+1,:) = [[1 nanmean(missedChanges(missedChanges(:,1) == 3, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 4, 2:end)))]];
                ballFixationType(count:count+1,:) = [[1 nanmean(gazeToBall(gazeToBall(:,1) == 3, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 4, 2:end)))]];
                slotFixationType(count:count+1,:) = [[1 nanmean(gazeToSlot(gazeToSlot(:,1) == 3, 2:end),1)]; ...
                    [2 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 4, 2:end)))]];
            elseif isnan(testSetBack(2))
                silentFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 3, 2:end),1))]; ...
                    [2 nanmean(silentPeriod(silentPeriod(:,1) == 4, 2:end),1)]];
                timeLCFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 3, 2:end),1))]; ...
                    [2 nanmean(timeLetterChange(timeLetterChange(:,1) == 4, 2:end))]];
                missFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 3, 2:end),1))]; ...
                    [2 nanmean(missedChanges(missedChanges(:,1) == 4, 2:end))]];
                ballFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 3, 2:end),1))]; ...
                    [2 nanmean(gazeToBall(gazeToBall(:,1) == 4, 2:end))]];
                slotFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 3, 2:end),1))]; ...
                    [2 nanmean(gazeToSlot(gazeToSlot(:,1) == 4, 2:end))]];
            else
                silentFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 3, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(silentPeriod(silentPeriod(:,1) == 4, 2:end),1))]];
                timeLCFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 3, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(timeLetterChange(timeLetterChange(:,1) == 4, 2:end)))]];
                missFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 3, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(missedChanges(missedChanges(:,1) == 4, 2:end)))]];
                ballFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 3, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(gazeToBall(gazeToBall(:,1) == 4, 2:end)))]];
                slotFixationType(count:count+1,:) = [[1 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 3, 2:end),1))]; ...
                    [2 filtfilt(a,b, nanmean(gazeToSlot(gazeToSlot(:,1) == 4, 2:end)))]];
            end
            clear testSetTri testSetBack
        end
        count = count + 2;
    end
    %%
    figure(i)
    liftoff = sum(floor(phaseDurationNorm(i,3:4)))+reachOnset; % reach and ball phase
    hold on
    yMax = .75;
    ylim([0 yMax])
    xlim([0 averageLengthAll])
    if ismember(i, tweezerBlocks)
        set(gca, 'Xtick', [liftoff-500 liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300],...
            'XtickLabel', [-2.5 -2 -1.5 -1 -.5 0 .5 1 1.5])
    else
        set(gca, 'Xtick', [liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200],...
            'XtickLabel', [-2 -1.5 -1 -.5 0 .5 1])
    end
    plot(mean(averagedBallFixations), 'Color', orange, 'LineWidth', 2)
    plot(mean(averagedSlotFixations), 'Color', green, 'LineWidth', 2)
    plot(mean(averagedSilentPeriod), 'Color', grey1, 'LineWidth', 2)
    line([0 averageLengthAll], [.375 .375], 'Color', grey1)
    plot(mean(averagedTimeLC), 'Color', red, 'LineWidth', 2)
    line([0 averageLengthAll], [.08 .08], 'Color', red)
    plot(mean(averagedMissedChanges), 'Color', 'k', 'LineWidth', 2)
    % reach onset
    line([reachOnset reachOnset], [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % ball approach
    line([floor(phaseDurationNorm(i,3))+reachOnset floor(phaseDurationNorm(i,3))+reachOnset], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % ball contact
    line([liftoff+floor(phaseDurationNorm(i,8)) ...
        liftoff+floor(phaseDurationNorm(i,8))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % transport
    line([liftoff liftoff], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % slot approach
    line([liftoff+sum(floor(phaseDurationNorm(i,5))) liftoff+sum(floor(phaseDurationNorm(i,5)))], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % slot entry
    line([liftoff+floor(phaseDurationNorm(i,9)) ...
        liftoff+floor(phaseDurationNorm(i,9))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % return
    line([liftoff+sum(floor(phaseDurationNorm(i,5:6))) liftoff+sum(floor(phaseDurationNorm(i,5:6)))], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')

    figure(i*100)
    hold on
    yMax = .88;
    ylim([0 yMax])
    xlim([0 averageLengthAll])
    if ismember(i, tweezerBlocks)
        set(gca, 'Xtick', [liftoff-500 liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300],...
            'XtickLabel', [-2.5 -2 -1.5 -1 -.5 0 .5 1 1.5])
    else
        set(gca, 'Xtick', [liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200],...
            'XtickLabel', [-2 -1.5 -1 -.5 0 .5 1])
    end
    if i == 3
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 1, 2:end)), 'Color', grey1, 'LineWidth', 2)
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 2, 2:end)), 'Color', grey1, 'LineStyle', '--', 'LineWidth', 2)
        plot(nanmean(timeLCFixationType(timeLCFixationType(:,1) == 1, 2:end)), 'Color', red, 'LineWidth', 2)
        plot(nanmean(timeLCFixationType(timeLCFixationType(:,1) == 2, 2:end)), 'Color', red, 'LineStyle', '--', 'LineWidth', 2)
        plot(nanmean(missFixationType(missFixationType(:,1) == 1, 2:end)), 'Color', 'k', 'LineWidth', 2)
        plot(nanmean(missFixationType(missFixationType(:,1) == 2, 2:end)), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2)
        plot(nanmean(slotFixationType(slotFixationType(:,1) == 1, 2:end)), 'Color', green, 'LineWidth', 2)
        plot(nanmean(slotFixationType(slotFixationType(:,1) == 2, 2:end)), 'Color', green, 'LineStyle', '--', 'LineWidth', 2)
    else
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 1, 2:end)), 'Color', grey1, 'LineStyle', '-.', 'LineWidth', 2)
        plot(nanmean(silentFixationType(silentFixationType(:,1) == 2, 2:end)), 'Color', grey1, 'LineStyle', ':', 'LineWidth', 2)
        plot(nanmean(timeLCFixationType(timeLCFixationType(:,1) == 1, 2:end)), 'Color', red, 'LineStyle', '-.', 'LineWidth', 2)
        plot(nanmean(timeLCFixationType(timeLCFixationType(:,1) == 2, 2:end)), 'Color', red, 'LineStyle', ':', 'LineWidth', 2)
        plot(nanmean(missFixationType(missFixationType(:,1) == 1, 2:end)), 'Color', 'k', 'LineStyle', '-.', 'LineWidth', 2)
        plot(nanmean(missFixationType(missFixationType(:,1) == 2, 2:end)), 'Color', 'k', 'LineStyle', ':', 'LineWidth', 2)
        plot(nanmean(ballFixationType(ballFixationType(:,1) == 1, 2:end)), 'Color', orange, 'LineStyle', '-.', 'LineWidth', 2)
        plot(nanmean(ballFixationType(ballFixationType(:,1) == 2, 2:end)), 'Color', orange, 'LineStyle', ':', 'LineWidth', 2)
        plot(nanmean(slotFixationType(slotFixationType(:,1) == 1, 2:end)), 'Color', green, 'LineStyle', '-.', 'LineWidth', 2)
        plot(nanmean(slotFixationType(slotFixationType(:,1) == 2, 2:end)), 'Color', green, 'LineStyle', ':', 'LineWidth', 2)
    end
    % reach onset
    line([reachOnset reachOnset], [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % ball approach
    line([floor(phaseDurationNorm(i,3))+reachOnset floor(phaseDurationNorm(i,3))+reachOnset], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % ball contact
    line([liftoff+floor(phaseDurationNorm(i,8)) ...
        liftoff+floor(phaseDurationNorm(i,8))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % transport
    line([liftoff liftoff], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % slot approach
    line([liftoff+sum(floor(phaseDurationNorm(i,5))) liftoff+sum(floor(phaseDurationNorm(i,5)))], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % slot entry
    line([liftoff+floor(phaseDurationNorm(i,9)) ...
        liftoff+floor(phaseDurationNorm(i,9))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % return
    line([liftoff+sum(floor(phaseDurationNorm(i,5:6))) liftoff+sum(floor(phaseDurationNorm(i,5:6)))], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')

    figure(i*10)
    reachOnset = floor(phaseDurationEarlyReaches(i,10));
    liftoff = sum(floor(phaseDurationEarlyReaches(i,3:4)))+reachOnset; % reach and ball phase
    hold on
    yMax = 1.01;
    ylim([0 yMax])
    xlim([0 averageLengthEarly])
    if ismember(i, tweezerBlocks)
        set(gca, 'Xtick', [liftoff-500 liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200 liftoff+300],...
            'XtickLabel', [-2.5 -2 -1.5 -1 -.5 0 .5 1 1.5])
    else
        set(gca, 'Xtick', [liftoff-400 liftoff-300 liftoff-200 liftoff-100 liftoff liftoff+100 liftoff+200],...
            'XtickLabel', [-2 -1.5 -1 -.5 0 .5 1])
    end
    plot(mean(earlyBallFixations), 'Color', orange, 'LineWidth', 2)
    plot(mean(earlySlotFixations), 'Color', green, 'LineWidth', 2)
    plot(mean(earlySilentPeriod), 'Color', grey1, 'LineWidth', 2)
    plot(mean(earlyTimeLC), 'Color', red, 'LineWidth', 2)
    plot(mean(earlyMissedChanges), 'Color', 'k', 'LineWidth', 2)
    % reach onset
    line([reachOnset reachOnset], [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % ball approach
    line([floor(phaseDurationEarlyReaches(i,3))+reachOnset floor(phaseDurationEarlyReaches(i,3))+reachOnset], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % ball contact
    line([liftoff+floor(phaseDurationEarlyReaches(i,8)) ...
        liftoff+floor(phaseDurationEarlyReaches(i,8))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % transport
    line([liftoff liftoff], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    % slot approach
    line([liftoff+sum(floor(phaseDurationEarlyReaches(i,5))) liftoff+sum(floor(phaseDurationEarlyReaches(i,5)))], ...
        [0 yMax], 'Color', grey2, 'LineStyle', '--')
    % slot entry
    line([liftoff+floor(phaseDurationEarlyReaches(i,9)) ...
        liftoff+floor(phaseDurationEarlyReaches(i,9))], ...
        [0 yMax], 'Color', 'r', 'LineStyle', '--')
    % return
    line([liftoff+sum(floor(phaseDurationEarlyReaches(i,5:6))) liftoff+sum(floor(phaseDurationEarlyReaches(i,5:6)))], ...
        [0 yMax], 'Color', 'k', 'LineStyle', '--')
    
    clear yMax liftoff
end

