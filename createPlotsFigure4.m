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

%% Now plot fixation duration histograms (Panels C)
fixationsBall = [];
fixationsSlot = [];
for j = 1:numParticipants% loop over subjects
    for blockID = 3:4 % two dual task blocks
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        % open variable matrices that we want to pull
        testID = blockID;
        counterBall = 1;
        counterSlot = 1;
        trialLength = NaN(numTrials,2);
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballFixations = currentResult(n).gaze.fixation.durationBall;
            numBallFixations = length(ballFixations);
            slotFixations = currentResult(n).gaze.fixation.durationSlot;
            numSlotFixations = length(slotFixations);
            currentBallFixations(counterBall:counterBall+numBallFixations-1,1:3) = [currentParticipant*ones(numBallFixations,1) ...
                testID*ones(numBallFixations,1) ballFixations'];
            counterBall = counterBall + numBallFixations;
            currentSlotFixations(counterSlot:counterSlot+numSlotFixations-1,1:3) = [currentParticipant*ones(numSlotFixations,1) ...
                testID*ones(numSlotFixations,1) slotFixations'];
            counterSlot = counterSlot + numSlotFixations;
            
        end      
        fixationsBall = [fixationsBall; currentBallFixations];
        fixationsSlot = [fixationsSlot; currentSlotFixations];
        clear currentBallFixations currentSlotFixations  
    end
end
%% fixation durations finger tips
fingertipsBall = fixationsBall(fixationsBall(:,2) == 3,end);
fingertipsSlot = fixationsSlot(fixationsSlot(:,2) == 3,end);
endFrame = max([max(fingertipsSlot) max(fingertipsBall)]);

figure(5)
xlim([0 1.5])
ylim([0 75])
set(gca, 'Ytick', [0 25 50 75])
hold on
box off
histf(fingertipsBall',0:.1:endFrame,'facecolor',fixationPatternColors(2,:),'edgecolor','none')
histf(fingertipsSlot',0:.1:endFrame,'facecolor','none','edgecolor',fixationPatternColors(3,:), 'LineWidth', 2)
%% fixation durations tweezers
tweezersBall = fixationsBall(fixationsBall(:,2) == 4,end);
tweezersSlot = fixationsSlot(fixationsSlot(:,2) == 4,end);
endFrame = max([max(tweezersSlot) max(tweezersBall)]);

figure(6)
xlim([0 1.5])
ylim([0 75])
set(gca, 'Ytick', [0 25 50 75])
hold on
box off
histf(tweezersBall',0:.1:endFrame,'facecolor',fixationPatternColors(2,:),'edgecolor','none')
histf(tweezersSlot',0:.1:endFrame,'facecolor','none','edgecolor',fixationPatternColors(3,:), 'LineWidth', 2)