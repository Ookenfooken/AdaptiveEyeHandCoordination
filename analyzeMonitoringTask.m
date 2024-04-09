% read in mean gaze data and phase duration to use for normalization
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);

%% readout monitoring task performance
numParticipants = 11;
criticalRadius = 2.5;
display = [13.63 16.68];
tPreMiss = 5; % 10 = 50 ms
tPostMiss = 5;
dualTaskPerformance = [];
letterTaskAll = [];
cAll = 1;
for j = 1:numParticipants % loop over subjects
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
            for miss = 1:length(currentResult(n).dualTask.tLetterChanges)
                if currentResult(n).dualTask.changeMissed(miss)
                    timeOfMiss = currentResult(n).dualTask.sampleLetterChange(miss) - currentResult(n).info.trialStart;
                    if timeOfMiss > 0
                        startFrame = max([1 timeOfMiss-tPreMiss]);
                        stopFrame = min([timeOfMiss+tPostMiss length(currentResult(n).gaze.inCriticalZone)]);
                        eyeAtDisplay = currentResult(n).gaze.inCriticalZone(3,startFrame:stopFrame);
                        if sum(eyeAtDisplay) < (tPreMiss+tPostMiss)/2
                            currentEyeOnDisplay(miss) = 0;
                        else
                            currentEyeOnDisplay(miss) = 1;
                        end
                    else
                        currentEyeOnDisplay(miss) = 99;
                    end
                else
                    currentEyeOnDisplay(miss) = NaN;
                end
            end
            eyeOnDisplay(c) = currentEyeOnDisplay;
            clear currentEyeOnDisplay
                        
            c = c(end) + 1;
        end
        currentPerformance = [currentParticipant blockID c-1 sum(changeDetected) sum(changeMissed) sum(eyeOnDisplay)];
        currentLetters = [currentParticipant*ones(c-1,1) blockID*ones(c-1,1) changeDetected' changeMissed' eyeOnDisplay'];
        
        dualTaskPerformance = [dualTaskPerformance; currentPerformance];
        letterTaskAll = [letterTaskAll; currentLetters];
        clear letterChangePhase changeDetected changeMissed currentPerformance eyeOnDisplay
    end
end
clear c 

%% save letter change performance
letterDetectAverage = NaN(numParticipants*2,3);
patCount = 1;
for taskId = 3:4
    currentTask = dualTaskPerformance(dualTaskPerformance(:,2) == taskId, :);
    for i = 1:numParticipants
        currentDataset = currentTask(currentTask(:,1) == i, :);
        letterDetectAverage(patCount,:) = [taskId i ...
            sum(currentTask(currentTask(:,1) == i,4))/sum(currentTask(currentTask(:,1) == i,3))];
        patCount = patCount + 1;
    end
end

cd(savePath)
save('letterDetectAverage', 'letterDetectAverage')
cd(analysisPath)

%% count how many times they looked at the display when missing the LC
misses = letterTaskAll(letterTaskAll(:,4) == 1, :);
missInterTrial = length(misses(misses(:,5) == 99, :))/length(misses);
missesWhileAct = misses(misses(:,5) ~= 99, :);

numLooks = 1-sum(missesWhileAct(:,5))/length(missesWhileAct);