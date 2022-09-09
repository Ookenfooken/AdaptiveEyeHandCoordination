function [normalizedData] = normalizeMovementsPhases(durationNorm, info, effector, gaze, blockNo, radius)
% define critical areas:
if info.cuedSlot == 1 % bottom slot
    slotPosition = [-1.9 5.2];
    otherSlots = [-1.9 8.2; -1.9 11.2];
elseif info.cuedSlot == 2 % middle slot
    slotPosition = [-1.9 8.2];
    otherSlots = [-1.9 5.2; -1.9 11.2];
elseif info.cuedSlot == 3 % top slot
    slotPosition = [-1.9 11.2];
    otherSlots = [-1.9 5.2; -1.9 8.2];
end
criticalLocations = [0 0; ... % ball centre
    slotPosition; % selected slot
    13.63 16.68; ... % visual display
    otherSlots]; % non-selected slots

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
displayVector = zeros(info.trialEnd,1);
displayVector(distancesGaze(3,:) < radius) = 1;

%% define start and stop frame
% will do 5 phases to start with
% Phase 1: primary Reach
duration = ceil(durationNorm(blockNo,3));
startFrame = info.phaseStart.primaryReach;
stopFrame = info.phaseStart.ballApproach;

normBall1 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot1 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normDisplay1 = resample(displayVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

if info.phaseStart.primaryReach - info.trialStart + 1 < 1
    normToolSpeed1 = NaN(duration,1);
else
    startFrame = info.phaseStart.primaryReach - info.trialStart +1;
    stopFrame = info.phaseStart.ballApproach - info.trialStart;
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed1 = resample(toolSpeed,duration,length(toolSpeed));
end

clear startFrame stopFrame duration toolSpeed
%%
% Phase 2: ball approach & grasp
duration = sum(ceil(durationNorm(blockNo,4)));
startFrame = info.phaseStart.ballApproach;
stopFrame = info.phaseStart.transport;

normBall2 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot2 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normDisplay2 = resample(displayVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

if info.phaseStart.ballApproach - info.trialStart +1 < 1
    normToolSpeed2 = NaN(duration,1);
else
    startFrame = info.phaseStart.ballApproach - info.trialStart +1;
    stopFrame = info.phaseStart.transport - info.trialStart;
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed2 = resample(toolSpeed,duration,length(toolSpeed));
end

clear startFrame stopFrame duration toolSpeed
%%
% Phase 3: transport
duration = ceil(durationNorm(blockNo,5));
startFrame = info.phaseStart.transport;
stopFrame = info.phaseStart.slotApproach;

normBall3 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot3 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normDisplay3 = resample(displayVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

startFrame = info.phaseStart.transport - info.trialStart +1;
stopFrame = info.phaseStart.slotApproach - info.trialStart;
% up/downsample
toolSpeed = effector.velocity(startFrame:stopFrame);
normToolSpeed3 = resample(toolSpeed,duration,length(toolSpeed));

clear startFrame stopFrame duration toolSpeed
%%
% Phase 4: slot approach and deposit
duration = sum(ceil(durationNorm(blockNo,6)));
startFrame = info.phaseStart.slotApproach;
stopFrame = info.phaseStart.return;

normBall4 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot4 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normDisplay4 = resample(displayVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

startFrame = info.phaseStart.slotApproach - info.trialStart +1;
stopFrame = info.phaseStart.return - info.trialStart;
% up/downsample
toolSpeed = effector.velocity(startFrame:stopFrame);
normToolSpeed4 = resample(toolSpeed,duration,length(toolSpeed));

clear startFrame stopFrame duration toolSpeed
%%
% Phase 5: return phase
duration = ceil(durationNorm(blockNo,7));
startFrame = info.phaseStart.return;
stopFrame = info.trialEnd;

normBall5 = resample(ballVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normSlot5 = resample(slotVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);
normDisplay5 = resample(displayVector(startFrame:stopFrame), ...
    duration, stopFrame-startFrame+1);

startFrame = info.phaseStart.return - info.trialStart +1;
stopFrame = min([info.trialEnd-info.trialStart length(effector.velocity)]);
if stopFrame < startFrame+1 
    normToolSpeed5 = NaN(duration,1);
else
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed5 = resample(toolSpeed,duration,length(toolSpeed));
end

clear startFrame stopFrame duration
%%
% paste tool speed together
normalizedData.toolSpeed = [normToolSpeed1(1:floor(durationNorm(blockNo,3))); normToolSpeed2(1:sum(floor(durationNorm(blockNo,4)))); ...
    normToolSpeed3(1:floor(durationNorm(blockNo,5))); normToolSpeed4(1:sum(floor(durationNorm(blockNo,6)))); normToolSpeed5(1:floor(durationNorm(blockNo,7)))];

% filter data to smooth between phases
ballFixations = [normBall1(1:floor(durationNorm(blockNo,3)))' ...
   normBall2(1:floor(durationNorm(blockNo,4)))' normBall3(1:floor(durationNorm(blockNo,5)))' ...
   normBall4(1:floor(durationNorm(blockNo,6)))' normBall5(1:floor(durationNorm(blockNo,7)))'];
normalizedData.gazeBall = ballFixations;

slotFixations = [normSlot1(1:floor(durationNorm(blockNo,3)))' ...
   normSlot2(1:floor(durationNorm(blockNo,4)))' normSlot3(1:floor(durationNorm(blockNo,5)))' ...
   normSlot4(1:floor(durationNorm(blockNo,6)))' normSlot5(1:floor(durationNorm(blockNo,7)))'];
normalizedData.gazeSlot = slotFixations;


displayFixations = [normDisplay1(1:floor(durationNorm(blockNo,3)))' ...
   normDisplay2(1:floor(durationNorm(blockNo,4)))' normDisplay3(1:floor(durationNorm(blockNo,5)))' ...
   normDisplay4(1:floor(durationNorm(blockNo,6)))' normDisplay5(1:floor(durationNorm(blockNo,7)))'];
if blockNo > 2
    normalizedData.gazeDisplay = displayFixations;
end

end