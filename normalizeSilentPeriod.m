function [normalizedData] = normalizeSilentPeriod(durationNorm, info, gaze, dualTask, dualPrevious, blockNo, radius)

% all letter changes
wBin = .3; % w was on for .3 s
silentPeriod = 1.5;
letterChangeVector = zeros(info.trialEnd,1);
timeLCVector = zeros(info.trialEnd,1);
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
    stopFrame = min([currentLetterChange+wBin*200+1 length(timeLCVector)]);
    timeLCVector(currentLetterChange+1:stopFrame) = 1;
end

% letter changes 1 s before reach
preReachBin = 1;
preReachVector = zeros(info.trialEnd,1);
if dualTask.tLetterChanges(1) < info.timeStamp.reach && ...
        dualTask.tLetterChanges(1) > info.timeStamp.reach - preReachBin
    for i = 1:numLetterChanges
        currentLetterChange = dualTask.sampleLetterChange(i);        
        stopFrame = min([currentLetterChange+251 length(preReachVector)]);
        preReachVector(currentLetterChange+1:stopFrame) = 1;       
    end
else
    preReachVector = NaN(info.trialEnd,1);
end

% misses
% first check if the last change was a miss
missedChangesVector = zeros(info.trialEnd,1);
if ~isnan(dualPrevious.tLetterChanges)
    if dualPrevious.changeMissed(end) && dualPrevious.tLetterChanges(end)+wBin > info.timeStamp.start
        hangOver = ceil((dualPrevious.tLetterChanges(end)+wBin - info.timeStamp.start)*200);
        missedChangesVector(1:hangOver) = 1;
    end
end
for i = 1:numLetterChanges
    if dualTask.changeMissed(i)
        currentMiss = dualTask.sampleLetterChange(i);
        stopFrame = min([currentMiss+wBin*200+1 length(missedChangesVector)]);
        missedChangesVector(currentMiss+1:stopFrame) = 1;
    end
end

% fixations
% define critical areas:
if info.cuedSlot == 1 % bottom slot
    slotPosition = [-1.9 5.2];
elseif info.cuedSlot == 2 % middle slot
    slotPosition = [-1.9 8.2];
elseif info.cuedSlot == 3 % top slot
    slotPosition = [-1.9 11.2];
end
criticalLocations = [0 0; ... % ball centre
    slotPosition; % selected slot
    13.63 16.68]; ... % visual display
    distancesGaze = NaN(length(criticalLocations), length(gaze.Xshifted));
for j = 1:length(criticalLocations)
    for i = 1:length(gaze.Xshifted)
        distancesGaze(j,i) = sqrt((gaze.Xshifted(i) - criticalLocations(j,1)).^2 ...
            +  (gaze.Yshifted(i) - criticalLocations(j,2)).^2);
    end
end
ballVector = zeros(info.trialEnd,1);
ballVector(distancesGaze(1,:) < radius) = 1;
slotVector = zeros(info.trialEnd,1);
slotVector(distancesGaze(2,:) < radius) = 1;


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
normTimeLCVector1 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector1 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector1 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall1 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot1 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
        
clear startFrame stopFrame duration
%%

% Phase 2: primary Reach
duration = ceil(durationNorm(blockNo,3));
startFrame = info.phaseStart.primaryReach;
stopFrame = info.phaseStart.ballApproach;

normLetterVector2 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normTimeLCVector2 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector2 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector2 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall2 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot2 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration
%%
% Phase 3: ball approach & grasp
duration = ceil(durationNorm(blockNo,4));
startFrame = info.phaseStart.ballApproach;
stopFrame = info.phaseStart.transport;

normLetterVector3 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normTimeLCVector3 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector3 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector3 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall3 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot3 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration

%%
% Phase 4: transport
duration = ceil(durationNorm(blockNo,5));
startFrame = info.phaseStart.transport;
stopFrame = info.phaseStart.slotApproach;

normLetterVector4 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normTimeLCVector4 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector4 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector4 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall4 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot4 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration
%%
% Phase 5: slot approach and deposit
duration = sum(ceil(durationNorm(blockNo,6)));
startFrame = info.phaseStart.slotApproach;
stopFrame = info.phaseStart.return;

normLetterVector5 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normTimeLCVector5 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector5 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector5 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall5 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot5 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

clear startFrame stopFrame duration

%%
% Phase 6: return phase
duration = ceil(durationNorm(blockNo,7));
startFrame = info.phaseStart.return;
stopFrame = info.trialEnd;

normLetterVector6 = resample(letterChangeVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normTimeLCVector6 = resample(timeLCVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normEarlyVector6 = resample(preReachVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normMissVector6 = resample(missedChangesVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normBall6 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot6 = resample(slotVector(startFrame:stopFrame), ...
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

timeLetterChange = [normTimeLCVector1' normTimeLCVector2(1:floor(durationNorm(blockNo,3)))' ...
   normTimeLCVector3(1:floor(durationNorm(blockNo,4)))' normTimeLCVector4(1:floor(durationNorm(blockNo,5)))' ...
   normTimeLCVector5(1:floor(durationNorm(blockNo,6)))' normTimeLCVector6(1:floor(durationNorm(blockNo,7)))'];

timeLC_smoothed = filtfilt(a,b, timeLetterChange);
normalizedData.timeLC = timeLC_smoothed;

silentPreReach = [normEarlyVector1' normEarlyVector2(1:floor(durationNorm(blockNo,3)))' ...
   normEarlyVector3(1:floor(durationNorm(blockNo,4)))' normEarlyVector4(1:floor(durationNorm(blockNo,5)))' ...
   normEarlyVector5(1:floor(durationNorm(blockNo,6)))' normEarlyVector6(1:floor(durationNorm(blockNo,7)))'];

if ~isnan(silentPreReach(1))
    silentPreReach_smoothed = filtfilt(a,b, silentPreReach);
    normalizedData.silentPreReach = silentPreReach_smoothed;
else
    normalizedData.silentPreReach = silentPreReach;
end

normalizedData.missedChanges = [normMissVector1' normMissVector2(1:floor(durationNorm(blockNo,3)))' ...
   normMissVector3(1:floor(durationNorm(blockNo,4)))' normMissVector4(1:floor(durationNorm(blockNo,5)))' ...
   normMissVector5(1:floor(durationNorm(blockNo,6)))' normMissVector6(1:floor(durationNorm(blockNo,7)))'];

ballFixations = [normBall1' normBall2(1:floor(durationNorm(blockNo,3)))' ...
   normBall3(1:floor(durationNorm(blockNo,4)))' normBall4(1:floor(durationNorm(blockNo,5)))' ...
   normBall5(1:floor(durationNorm(blockNo,6)))' normBall6(1:floor(durationNorm(blockNo,7)))'];

ballFixations_smoothed = filtfilt(a,b, ballFixations);
normalizedData.gazeBall = ballFixations_smoothed;

slotFixations = [normSlot1' normSlot2(1:floor(durationNorm(blockNo,3)))' ...
   normSlot3(1:floor(durationNorm(blockNo,4)))' normSlot4(1:floor(durationNorm(blockNo,5)))' ...
   normSlot5(1:floor(durationNorm(blockNo,6)))' normSlot6(1:floor(durationNorm(blockNo,7)))'];

slotFixations_smoothed = filtfilt(a,b, slotFixations);
normalizedData.gazeSlot = slotFixations_smoothed;

end