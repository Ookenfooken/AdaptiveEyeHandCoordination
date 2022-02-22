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
%% define start and stop frame
% will do 5 phases to start with
% Phase 1: primary Reach
duration = ceil(durationNorm(blockNo,3));
if info.phaseStart.primaryReach - info.trialStart + 1 < 1
    normToolSpeed1 = NaN(duration,1);
    gazeXinterpolated1 = NaN(duration,1);
    gazeYinterpolated1 = NaN(duration,1);
else
    startFrame = info.phaseStart.primaryReach - info.trialStart +1;
    stopFrame = info.phaseStart.ballApproach - info.trialStart;
    if startFrame == stopFrame
        normToolSpeed1 = NaN(duration,1);
        gazeXinterpolated1 = NaN(duration,1);
        gazeYinterpolated1 = NaN(duration,1);
    else
        % up/downsample
        toolSpeed = effector.velocity(startFrame:stopFrame);
        normToolSpeed1 = resample(toolSpeed,duration,length(toolSpeed));
        gazeX = gaze.Xinterpolated(startFrame:stopFrame);
        gazeXinterpolated1 = resample(gazeX,duration,length(gazeX));
        gazeY = gaze.Yinterpolated(startFrame:stopFrame);
        gazeYinterpolated1 = resample(gazeY,duration,length(gazeY));
        
        clear startFrame stopFrame toolSpeed gazeX gazeY
    end
end
clear duration
%%
% Phase 2: ball approach & grasp
duration = sum(ceil(durationNorm(blockNo,4)));
if info.phaseStart.ballApproach - info.trialStart +1 < 1
    normToolSpeed2 = NaN(duration,1);
    gazeXinterpolated2 = NaN(duration,1);
    gazeYinterpolated2 = NaN(duration,1);
else
    startFrame = info.phaseStart.ballApproach - info.trialStart +1;
    stopFrame = info.phaseStart.transport - info.trialStart;
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed2 = resample(toolSpeed,duration,length(toolSpeed));
    gazeX = gaze.Xinterpolated(startFrame:stopFrame);
    gazeXinterpolated2 = resample(gazeX,duration,length(gazeX));
    gazeY = gaze.Yinterpolated(startFrame:stopFrame);
    gazeYinterpolated2 = resample(gazeY,duration,length(gazeY));
    
    clear startFrame stopFrame toolSpeed gazeX gazeY
end
clear duration
%%
% Phase 3: transport
duration = ceil(durationNorm(blockNo,5));
if info.phaseStart.ballApproach - info.trialStart +1 < 1
    normToolSpeed3 = NaN(duration,1);
    gazeXinterpolated3 = NaN(duration,1);
    gazeYinterpolated3 = NaN(duration,1);
else
    startFrame = info.phaseStart.transport - info.trialStart +1;
    stopFrame = info.phaseStart.slotApproach - info.trialStart;
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed3 = resample(toolSpeed,duration,length(toolSpeed));
    gazeX = gaze.Xinterpolated(startFrame:stopFrame);
    gazeXinterpolated3 = resample(gazeX,duration,length(gazeX));
    gazeY = gaze.Yinterpolated(startFrame:stopFrame);
    gazeYinterpolated3 = resample(gazeY,duration,length(gazeY));
    if length(normToolSpeed3) < floor(durationNorm(blockNo,5))
        normToolSpeed3 = NaN(duration,1);
        gazeXinterpolated3 = NaN(duration,1);
        gazeYinterpolated3 = NaN(duration,1);
    end
    clear startFrame stopFrame toolSpeed gazeX gazeY duration
end
clear duration

%%
% Phase 4: slot approach and deposit
duration = sum(ceil(durationNorm(blockNo,6)));
startFrame = info.phaseStart.slotApproach - info.trialStart +1;
stopFrame = info.phaseStart.return - info.trialStart;
% up/downsample
toolSpeed = effector.velocity(startFrame:stopFrame);
normToolSpeed4 = resample(toolSpeed,duration,length(toolSpeed));
gazeX = gaze.Xinterpolated(startFrame:stopFrame);
gazeXinterpolated4 = resample(gazeX,duration,length(gazeX));
gazeY = gaze.Yinterpolated(startFrame:stopFrame);
gazeYinterpolated4 = resample(gazeY,duration,length(gazeY));

clear startFrame stopFrame toolSpeed gazeX gazeY duration

%%
% Phase 5: return phase
duration = ceil(durationNorm(blockNo,7));
startFrame = info.phaseStart.return - info.trialStart +1;
stopFrame = min([info.trialEnd-info.trialStart length(effector.velocity)]);
if stopFrame < startFrame+1 
    normToolSpeed5 = NaN(duration,1);
    gazeXinterpolated5 = NaN(duration,1);
    gazeYinterpolated5 = NaN(duration,1);
else
    % up/downsample
    toolSpeed = effector.velocity(startFrame:stopFrame);
    normToolSpeed5 = resample(toolSpeed,duration,length(toolSpeed));
    gazeX = gaze.Xinterpolated(startFrame:stopFrame);
    gazeY = gaze.Yinterpolated(startFrame:stopFrame);
    if sum(isnan(gazeX)) == length(gazeX) || sum(isnan(gazeY)) == length(gazeY)
        gazeXinterpolated5 = NaN(duration,1);
        gazeYinterpolated5 = NaN(duration,1);
    else
        gazeXinterpolated5 = resample(gazeX,duration,length(gazeX));
        gazeYinterpolated5 = resample(gazeY,duration,length(gazeY));
    end
    if length(normToolSpeed5) < floor(durationNorm(blockNo,7))
        normToolSpeed5 = NaN(duration,1);
        gazeXinterpolated5 = NaN(duration,1);
        gazeYinterpolated5 = NaN(duration,1);
    end
end
clear startFrame stopFrame toolSpeed gazeX gazeY duration

%%
% paste tool speed together
normalizedData.toolSpeed = [normToolSpeed1(1:floor(durationNorm(blockNo,3))); normToolSpeed2(1:sum(floor(durationNorm(blockNo,4)))); ...
    normToolSpeed3(1:floor(durationNorm(blockNo,5))); normToolSpeed4(1:sum(floor(durationNorm(blockNo,6)))); normToolSpeed5(1:floor(durationNorm(blockNo,7)))];
% now find probability that gaze is at critical locations
gazeXinterpolated = [gazeXinterpolated1(1:floor(durationNorm(blockNo,3))); gazeXinterpolated2(1:sum(floor(durationNorm(blockNo,4)))); ...
    gazeXinterpolated3(1:floor(durationNorm(blockNo,5))); gazeXinterpolated4(1:sum(floor(durationNorm(blockNo,6)))); gazeXinterpolated5(1:floor(durationNorm(blockNo,7)))];
gazeYinterpolated = [gazeYinterpolated1(1:floor(durationNorm(blockNo,3))); gazeYinterpolated2(1:sum(floor(durationNorm(blockNo,4)))); ...
    gazeYinterpolated3(1:floor(durationNorm(blockNo,5))); gazeYinterpolated4(1:sum(floor(durationNorm(blockNo,6)))); gazeYinterpolated5(1:floor(durationNorm(blockNo,7)))];
nanIndxX = isnan(gazeXinterpolated);
nanIndxY = isnan(gazeYinterpolated);
[a,b] = butter(2,50/1000);
gazeXsmoothed = filtfilt(a,b, gazeXinterpolated(~nanIndxX));
gazeYsmoothed = filtfilt(a,b, gazeYinterpolated(~nanIndxY));
gazeXinterpolated(~nanIndxX) = gazeXsmoothed;
gazeYinterpolated(~nanIndxY) = gazeYsmoothed;

distancesGaze = NaN(length(criticalLocations), length(gazeXinterpolated));
for j = 1:length(criticalLocations)
    for i = 1:length(gazeXinterpolated)
        distancesGaze(j,i) = sqrt((gazeXinterpolated(i) - criticalLocations(j,1)).^2 ...
            +  (gazeYinterpolated(i) - criticalLocations(j,2)).^2);
    end
end
normalizedData.gazeBall = distancesGaze(1,:) < radius;
normalizedData.gazeSlot = distancesGaze(2,:) < radius;
if blockNo > 2
    normalizedData.gazeDisplay = distancesGaze(3,:) < radius;
end

end