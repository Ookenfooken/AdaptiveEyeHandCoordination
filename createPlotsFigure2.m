analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)

%% define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
gray = [99,99,99]./255;
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

%% Plot fixation pattern for each grasp mode (Panel F)
% initiate variable to plot mean
fixationPatternAverage = NaN(numParticipants*2,6);
figure(10)
hold on
set(gcf,'renderer','Painters', 'Position', [250 250 800 400])
count = 1;
for blockID = 3:4
    currentTool = gazeSequence(gazeSequence(:,1) == blockID,:);
    for i = 1:numParticipants
        currentParticipant = currentTool(currentTool(:,2) == i,3);
        currentParticipant = currentParticipant(~isnan(currentParticipant));
        if blockID < 4
            x = [.8 1.8 2.8 3.8 4.8];
        else
            x = [1.2 2.2 3.2 4.2 5.2];
        end
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
    if blockID < 4
        x = [.8 1.8 2.8 3.8 4.8];
    else
        x = [1.2 2.2 3.2 4.2 5.2];
    end
    for n = 1:5
        currentBarData = fixationPatternAverage(fixationPatternAverage(:,1) == blockID,2:end);
        b = bar(x(n),median(currentBarData(:,n)), .3);
        if blockID < 4
            b.FaceColor = fixationPatternColors(n,:);
            b.EdgeColor = fixationPatternColors(n,:);
            b.FaceAlpha = 0.5;
        else
            b.FaceColor = 'none';
            b.EdgeColor = fixationPatternColors(n,:);
        end
    end
end
xlim([.5 5.5])
set(gca, 'Xtick', [1 2 3 4 5], 'XtickLabel', {'display-only', 'ball-only', 'slot-only', 'ball-slot', 'ball-display-slot'})
ylim([0 1])
set(gca, 'Ytick', [0 .25 .5 .75 1])