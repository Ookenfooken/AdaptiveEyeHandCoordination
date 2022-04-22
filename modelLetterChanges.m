% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
resultVigilancePath = fullfile(pwd,'displayFiles\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);
numParticipants = size(pulledData,1);

%% Step 1: readout average durations of trial phases
averagePhases = [];
for i = 1:numParticipants
    for blockID = 3:4
        currentResult = pulledData{i,blockID};
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = blockID*ones(numTrials,1);
        startToGrasp = NaN(numTrials,1);
        graspToEnd = NaN(numTrials,1);
        endToStart = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            startToGrasp(n) = currentResult(n).info.phaseStart.ballGrasp;
            graspToEnd(n) = currentResult(n).info.trialEnd - ...
                currentResult(n).info.phaseStart.ballGrasp;
            if n < stopTrial
                betweenTrialTime = currentResult(n+1).gaze.timeStamp(1) - ...
                    currentResult(n).gaze.timeStamp(end);
            else
                betweenTrialTime = NaN;
            end
            endToStart(n) = betweenTrialTime*200; % in frames
        end
        averagePhases = [averagePhases; [testID startToGrasp graspToEnd endToStart]];
    end
end

%% Step 2: find the first letter change in a given "artificial" trial
simulatedChanges = [];
for i = 1:numParticipants
    for blockID = 3:4
        % load data
        currentParticipant = ['S' num2str(i) '_vigilanceTask.mat'];
        cd(resultVigilancePath)
        dualData = load(currentParticipant); % loads structure called results
        cd(analysisPath)
        numTrials = size(dualData.results(3).block,1);
        % open variable matrices that we want to pull
        testID = blockID*ones(numTrials,1);
        graspOnset = NaN(numTrials,1);
        letterChange = NaN(numTrials,1);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            currentPhases = averagePhases(averagePhases(:,1) == blockID,:);
            if n < 2
                startFrame = 1/200; % in seconds
                graspOnset(n) = round(normrnd(nanmean(currentPhases(:,2)),nanstd(currentPhases(:,2))));
                stopFrame =  startFrame + (graspOnset(n) + ...
                    normrnd(nanmean(currentPhases(:,3)),nanstd(currentPhases(:,3))))/200;
                letterChangeIdx = find(dualData.results(blockID).block(:,1) > startFrame & ...
                    dualData.results(blockID).block(:,1) < stopFrame);
                if ~isempty(letterChangeIdx)
                    letterChange(n) = round(dualData.results(blockID).block(letterChangeIdx(1),1)*200);
                end
            else
                startFrame = stopFrame + normrnd(nanmean(currentPhases(:,4)),nanstd(currentPhases(:,4)))/200; % in seconds
                graspOnset(n) = round(normrnd(nanmean(currentPhases(:,2)),nanstd(currentPhases(:,2))));
                stopFrame = startFrame + (graspOnset(n) + ...
                    normrnd(nanmean(currentPhases(:,3)),nanstd(currentPhases(:,3))))/200;
                letterChangeIdx = find(dualData.results(blockID).block(:,1) > startFrame & ...
                    dualData.results(blockID).block(:,1) < stopFrame);
                if ~isempty(letterChangeIdx)
                    letterChange(n) = round((dualData.results(blockID).block(letterChangeIdx(1),1) - ...
                        startFrame)*200);
                end
            end
        end
        simulatedChanges = [simulatedChanges; [testID letterChange graspOnset]];
    end
end

%%
gray = [150,150,150]./255;
figure(13)
%set(gcf,'renderer','Painters', 'Position', [250 200 400 500])
hold on
box off
xlim([-3 3])
ylim([0 50])
figure(14)
%set(gcf,'renderer','Painters', 'Position', [700 200 500 500])
hold on
box off
xlim([-3 3])
%set(gca, 'Xtick', [-2 -1 0 1 2])
ylim([0 50])
for j= 3:4
    letterChangeRelativeGrasp = (simulatedChanges(simulatedChanges(:,1) == j,2) - ...
        simulatedChanges(simulatedChanges(:,1) == j,3))/200; % in seconds
    lowerBound = nanmean(letterChangeRelativeGrasp) - 3*nanstd(letterChangeRelativeGrasp);
    upperBound = nanmean(letterChangeRelativeGrasp) + 3*nanstd(letterChangeRelativeGrasp);
    letterChangeRelativeGrasp(letterChangeRelativeGrasp < lowerBound) = [];
    letterChangeRelativeGrasp(letterChangeRelativeGrasp > upperBound) = [];
    if j == 3
        figure(13)
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
    else
        figure(14)
        histogram(letterChangeRelativeGrasp, 'BinWidth', .5, 'facecolor', gray, 'edgecolor', 'none')
    end
end