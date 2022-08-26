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
    averagedMissedChanges = NaN(numSubjects, averageLength);
    
    for j = 1:numSubjects
        
        currentBlock = pulledData{j,i};
        numTrials = length(currentBlock);
        silentPeriod = NaN(numTrials, averageLength);
        missedChanges = NaN(numTrials, averageLength);
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
                dualPrevious.tLetterChanges = NaN;
            end
            if isnan(dualInfo.tLetterChanges)
                continue
            end
            normalizedData = normalizeSilentPeriod(phaseDurationNorm, trialInfo, dualInfo,  dualPrevious, i);
            silentPeriod(n,:) = normalizedData.silentPeriod;
            missedChanges(n,:) = normalizedData.missedChanges;
        end
        % store average trace per participant
        averagedSilentPeriod(j,:) = nanmean(silentPeriod);  
        averagedMissedChanges(j,:) = nanmean(missedChanges);        
    end
    %%
    figure(i)
    hold on
    yMax = 0.6;
    ylim([0 yMax])
    plot(mean(averagedSilentPeriod), 'Color', grey1, 'LineWidth', 2)
    plot(mean(averagedMissedChanges), 'Color', 'b', 'LineWidth', 2)
    if i == 3
        reachOnset = ceil(289.8013);
    else
        reachOnset = ceil(305.8878);
    end
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

