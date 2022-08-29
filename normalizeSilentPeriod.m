function [normalizedData] = normalizeSilentPeriod(durationNorm, info, dualTask, dualPrevious, blockNo)

% all letter changes
silentPeriod = 1.5;
letterChangeVector = zeros(info.trialEnd,1);
% find relevant letter changes and check if the first relevant change is affecting trial start
if ~isnan(dualPrevious.tLetterChanges)
    if dualPrevious.tLetterChanges(end)+silentPeriod > info.timeStamp.start
        hangOver = ceil((dualPrevious.tLetterChanges(end)+silentPeriod - info.timeStamp.start)*200);
        letterChangeVector(1:hangOver) = 1;
    end
end
numLetterChanges = length(dualTask.tLetterChanges);
for i = 1:numLetterChanges
    currentLetterChange = dualTask.sampleLetterChange(i);
    stopFrame = min([currentLetterChange+251 length(letterChangeVector)]);
    letterChangeVector(currentLetterChange+1:stopFrame) = 1;
end

% letter changes 1 s before reach
preReachBin = 1;
preReachVector = zeros(info.trialEnd,1);
for i = 1:numLetterChanges
    currentLetterChange = dualTask.sampleLetterChange(i);
    if dualTask.tLetterChanges(i) < info.timeStamp.reach && ...
            dualTask.tLetterChanges(i) > info.timeStamp.reach - preReachBin
        stopFrame = min([currentLetterChange+251 length(preReachVector)]);
        preReachVector(currentLetterChange+1:stopFrame) = 1;
    end
end

% misses
% first check if the last change was a miss
missBin = .3; % w was on for .3 s
missedChangesVector = zeros(info.trialEnd,1);
if ~isnan(dualPrevious.tLetterChanges)
    if dualPrevious.changeMissed(end) && dualPrevious.tLetterChanges(end)+missBin > info.timeStamp.start
        hangOver = ceil((dualPrevious.tLetterChanges(end)+missBin - info.timeStamp.start)*200);
        missedChangesVector(1:hangOver) = 1;
    end
end
for i = 1:numLetterChanges
    if dualTask.changeMissed(i)
        currentMiss = dualTask.sampleLetterChange(i);
        stopFrame = min([currentMiss+missBin*200+1 length(missedChangesVector)]);
        missedChangesVector(currentMiss+1:stopFrame) = 1;
    end
end

%% define start and stop frame
% will do 6 phases 
% Phase 1: trial start to reach onset
if blockNo == 3
    duration = ceil(289.8013);
else
    duration = ceil(305.8878);
end
startFrame = 1;
stopFrame = info.phaseStart.primaryReach;

normLetterVector1 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector1 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector1 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
        
clear startFrame stopFrame duration
%%

% Phase 2: primary Reach
duration = ceil(durationNorm(blockNo,3));
startFrame = info.phaseStart.primaryReach;
stopFrame = info.phaseStart.ballApproach;

normLetterVector2 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector2 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector2 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration
%%
% Phase 3: ball approach & grasp
duration = ceil(durationNorm(blockNo,4));
startFrame = info.phaseStart.ballApproach;
stopFrame = info.phaseStart.transport;

normLetterVector3 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector3 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector3 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration

%%
% Phase 4: transport
duration = ceil(durationNorm(blockNo,5));
startFrame = info.phaseStart.transport;
stopFrame = info.phaseStart.slotApproach;

normLetterVector4 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector4 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector4 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration
%%
% Phase 5: slot approach and deposit
duration = sum(ceil(durationNorm(blockNo,6)));
startFrame = info.phaseStart.slotApproach;
stopFrame = info.phaseStart.return;

normLetterVector5 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector5 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector5 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration

%%
% Phase 6: return phase
duration = ceil(durationNorm(blockNo,7));
startFrame = info.phaseStart.return;
stopFrame = info.trialEnd;

normLetterVector6 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector6 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector6 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration

%%
% paste tool speed together
% normalizedData.silentPeriod = [normLetterVector1' normLetterVector2' normLetterVector3' ...
%     normLetterVector4' normLetterVector5' normLetterVector6'];
[a,b] = butter(2,20/200);

silentPeriod = [normLetterVector1' normLetterVector2(1:floor(durationNorm(blockNo,3)))' ...
   normLetterVector3(1:floor(durationNorm(blockNo,4)))' normLetterVector4(1:floor(durationNorm(blockNo,5)))' ...
   normLetterVector5(1:floor(durationNorm(blockNo,6)))' normLetterVector6(1:floor(durationNorm(blockNo,7)))'];

silentPeriod_smoothed = filtfilt(a,b, silentPeriod);
normalizedData.silentPeriod = silentPeriod_smoothed;

silentPreReach = [normEarlyVector1' normEarlyVector2(1:floor(durationNorm(blockNo,3)))' ...
   normEarlyVector3(1:floor(durationNorm(blockNo,4)))' normEarlyVector4(1:floor(durationNorm(blockNo,5)))' ...
   normEarlyVector5(1:floor(durationNorm(blockNo,6)))' normEarlyVector6(1:floor(durationNorm(blockNo,7)))'];

silentPreReach_smoothed = filtfilt(a,b, silentPreReach);
normalizedData.silentPreReach = silentPreReach_smoothed;

normalizedData.missedChanges = [normMissVector1' normMissVector2(1:floor(durationNorm(blockNo,3)))' ...
   normMissVector3(1:floor(durationNorm(blockNo,4)))' normMissVector4(1:floor(durationNorm(blockNo,5)))' ...
   normMissVector5(1:floor(durationNorm(blockNo,6)))' normMissVector6(1:floor(durationNorm(blockNo,7)))'];

end