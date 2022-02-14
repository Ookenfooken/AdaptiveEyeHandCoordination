function [gazeData] = readoutGaze(currentTrial, startTime, r)
% label saccade on and offsets
saccadeDetect = [currentTrial(startTime:end,7); NaN] - [NaN; currentTrial(startTime:end,7)];
saccadeOnsets = find(saccadeDetect == 16)-1;
saccadeOffsets = find(saccadeDetect == -16)+1;
% define eye position and velocity
% gaze x (3), gaze y (4) and gaze velocity (30)th column
gazeData.timeStamp = currentTrial(startTime:end, 1);
gazeX = currentTrial(startTime:end, 3);
gazeY = currentTrial(startTime:end, 4);
% remove blinks from data
gazeX(currentTrial(startTime:end,26) == 1) = NaN;
gazeY(currentTrial(startTime:end,26) == 1) = NaN;
gazeVelocity = currentTrial(startTime:end, 30);
gazeData.X = gazeX;
gazeData.Y = gazeY;
gazeData.velocity = gazeVelocity;
gazeData.blinkIdx = currentTrial(startTime:end, 26);
% align data to origin at start of trial
minIdx = find(sqrt(gazeX.^2 + gazeY.^2) == min(sqrt(gazeX.^2 + gazeY.^2)));
shiftX = currentTrial(minIdx(1),3);
shiftY = currentTrial(minIdx(1),4);
if abs(shiftX) > 2.5 || shiftX < 0
    shiftX = 0;
end
shift = 1;
if currentTrial(1,24) == 3 && currentTrial(1,25) == 4
    shift = 1.1;
elseif (currentTrial(1,24) == 3 && currentTrial(1,25) == 7) || (currentTrial(1,24) == 3 && currentTrial(1,25) == 8) || (currentTrial(1,24) == 3 && currentTrial(1,25) == 12)
    shift = 1.05;
end
if abs(shiftY) > 2.5
    shiftY = 0;
end
if currentTrial(1,24) == 11 && currentTrial(1,25) == 7
    shiftY = -1.5;
end
gazeX = (gazeX - shiftX)*shift;
gazeY = (gazeY - shiftY)*shift;
gazeAbsolute = sqrt(gazeX.^2 + gazeY.^2);
gazeXinterpolated = gazeX;
gazeYinterpolated = gazeY;
% interplolate gaze across saccades & pull some saccade measures
if ~isempty(saccadeOffsets) && ~isempty(saccadeOnsets)
    % make sure on and offsets are the same length and make sense
    if saccadeOffsets(1) < saccadeOnsets(1)
        saccadeOffsets(1) = [];
    end    
    if length(saccadeOnsets) ~= length(saccadeOffsets)
        lengthOnOff = min([length(saccadeOnsets) length(saccadeOffsets)]);
        saccadeOnsets = saccadeOnsets(1:lengthOnOff);
        saccadeOffsets = saccadeOffsets(1:lengthOnOff);
    end
    if saccadeOffsets(end) > length(gazeAbsolute)
        saccadeOffsets(end) = length(gazeAbsolute);
    end
    gazeData.saccades.onsets = saccadeOnsets;
    gazeData.saccades.offsets = saccadeOffsets;
    for i = 1:length(saccadeOnsets)
        offset = min([saccadeOffsets(i) length(gazeX)]);
        saccadeDuration = offset - saccadeOnsets(i);
        slopeX = (gazeX(offset) - gazeX(saccadeOnsets(i)))./saccadeDuration;
        slopeY = (gazeY(offset) - gazeY(saccadeOnsets(i)))./saccadeDuration;
        for j = 1:saccadeDuration+1
            gazeXinterpolated(saccadeOnsets(i)-1+j) = gazeX(saccadeOnsets(i)) + slopeX*j;
            gazeYinterpolated(saccadeOnsets(i)-1+j) = gazeY(saccadeOnsets(i)) + slopeY*j;
        end
        gazeData.saccades.peakVelocities(i) = max(gazeAbsolute(saccadeOnsets(i):saccadeOffsets(i)));
        gazeData.saccades.meanVelocities(i) = mean(gazeAbsolute(saccadeOnsets(i):saccadeOffsets(i)));
        gazeData.saccades.amplitudes(i) = abs(gazeAbsolute(saccadeOffsets(i)) - gazeAbsolute(saccadeOnsets(i)));
        gazeData.saccades.durations(i) = (saccadeOffsets(i)-saccadeOnsets(i))/200;  % in seconds
    end
    gazeData.saccades.totalNo = length(saccadeOnsets);
    gazeVelInterpolated = sqrt(gazeXinterpolated.^2 + gazeYinterpolated.^2);
else
    gazeData.saccades.onsets = [];
    gazeData.saccades.offsets = [];
    gazeData.saccades.peakVelocities = [];
    gazeData.saccades.meanVelocities = [];
    gazeData.saccades.amplitudes = [];
    gazeData.saccades.durations = [];
    gazeData.saccades.totalNo = 0;
    gazeVelInterpolated = sqrt(gazeX.^2 + gazeY.^2);
end

% define critical areas:
if currentTrial(1,22) == 1 % bottom slot
    slotPosition = [-1.9 5.2];
    otherSlots = [-1.9 8.2; -1.9 11.2];
elseif currentTrial(1,22) == 2 % middle slot
    slotPosition = [-1.9 8.2];
    otherSlots = [-1.9 5.2; -1.9 11.2];
elseif currentTrial(1,22) == 3 % top slot
    slotPosition = [-1.9 11.2];
    otherSlots = [-1.9 5.2; -1.9 8.2];
end
criticalLocations = [0 0; ... % ball centre
    slotPosition; % selected slot
    13.63 16.68; ... % visual display
    otherSlots]; % non-selected slots
radius = r;
distancesGaze = NaN(length(criticalLocations), length(gazeXinterpolated));
for j = 1:length(criticalLocations)
    for i = 1:length(gazeXinterpolated)
        distancesGaze(j,i) = sqrt((gazeXinterpolated(i) - criticalLocations(j,1)).^2 ...
            +  (gazeYinterpolated(i) - criticalLocations(j,2)).^2);
    end
end
gazeData.distanceCriticalZone = distancesGaze;
gazeData.inCriticalZone = [distancesGaze(1:3,:) < radius; ...
    any(distancesGaze(4:5,:) < radius)];
gazeData.idling = ~any(gazeData.inCriticalZone);
% calculate fixation on and offsets and durations
minFixationDuration = 20/200; % make sure fixation is at least 100 ms to be counted as a fixation
% fixation in ball zone first
gazeData.fixation.ball = double(gazeData.inCriticalZone(1,:));
fixBallIdx = [gazeData.fixation.ball NaN] - [NaN gazeData.fixation.ball];
gazeData.fixation.onsetsBall = find(fixBallIdx == 1);
gazeData.fixation.offsetsBall = find(fixBallIdx == -1);
if gazeData.fixation.ball(1) == 1
    gazeData.fixation.onsetsBall = [1 gazeData.fixation.onsetsBall];
end
if gazeData.fixation.ball(end) == 1
    gazeData.fixation.offsetsBall = [gazeData.fixation.offsetsBall length(gazeData.fixation.ball)];
end
% loop over fixations to read out duration and position
if ~isempty(gazeData.fixation.onsetsBall) && ~isempty(gazeData.fixation.offsetsBall)
    if gazeData.fixation.offsetsBall(1) < gazeData.fixation.onsetsBall(1)
        gazeData.fixation.offsetsBall(1) = [];
    end    
    if length(gazeData.fixation.onsetsBall) ~= length(gazeData.fixation.offsetsBall)
        lengthOnOff = min([length(gazeData.fixation.onsetsBall) length(gazeData.fixation.offsetsBall)]);
        gazeData.fixation.onsetsBall = gazeData.fixation.onsetsBall(1:lengthOnOff);
        gazeData.fixation.offsetsBall = gazeData.fixation.offsetsBall(1:lengthOnOff);
    end
    if gazeData.fixation.offsetsBall(end) > length(gazeAbsolute)
        gazeData.fixation.offsetsBall(end) = length(gazeAbsolute);
    end
    c = 1;
    for i = 1:length(gazeData.fixation.offsetsBall)
        gazeData.fixation.durationBall(c) = (gazeData.fixation.offsetsBall(c)-...
            gazeData.fixation.onsetsBall(c))/200;  % in seconds
        gazeData.fixation.positionXYball(c,:) = [mean(gazeXinterpolated(gazeData.fixation.onsetsBall(c):gazeData.fixation.offsetsBall(c))) ...
            mean(gazeYinterpolated(gazeData.fixation.onsetsBall(c):gazeData.fixation.offsetsBall(c)))];
        if gazeData.fixation.durationBall(c) < minFixationDuration;
            gazeData.fixation.onsetsBall(c) = [];
            gazeData.fixation.offsetsBall(c) = [];
            gazeData.fixation.durationBall(c) = [];
            gazeData.fixation.positionXYball(c,:) = [];
        end
        c = length(gazeData.fixation.durationBall) + 1;
    end
else
    gazeData.fixation.durationBall = [];
    gazeData.fixation.positionXYball = [];
end
% fixation on cued slot next
gazeData.fixation.cuedSlot = double(gazeData.inCriticalZone(2,:));
fixSlotIdx = [gazeData.fixation.cuedSlot NaN] - [NaN gazeData.fixation.cuedSlot];
gazeData.fixation.onsetsSlot = find(fixSlotIdx == 1);
gazeData.fixation.offsetsSlot = find(fixSlotIdx == -1);
if gazeData.fixation.cuedSlot(1) == 1
    gazeData.fixation.onsetsSlot = [1 gazeData.fixation.onsetsSlot];
end
if gazeData.fixation.cuedSlot(end) == 1
    gazeData.fixation.offsetsSlot = [gazeData.fixation.offsetsSlot length(gazeData.fixation.cuedSlot)];
end
% loop over fixations to read out duration and position
if ~isempty(gazeData.fixation.onsetsSlot) && ~isempty(gazeData.fixation.offsetsSlot)
    if gazeData.fixation.offsetsSlot(1) < gazeData.fixation.onsetsSlot(1)
        gazeData.fixation.offsetsSlot(1) = [];
    end    
    if length(gazeData.fixation.onsetsSlot) ~= length(gazeData.fixation.offsetsSlot)
        lengthOnOff = min([length(gazeData.fixation.onsetsSlot) length(gazeData.fixation.offsetsSlot)]);
        gazeData.fixation.onsetsSlot = gazeData.fixation.onsetsSlot(1:lengthOnOff);
        gazeData.fixation.offsetsSlot = gazeData.fixation.offsetsSlot(1:lengthOnOff);
    end
    if gazeData.fixation.offsetsSlot(end) > length(gazeAbsolute)
        gazeData.fixation.offsetsSlot(end) = length(gazeAbsolute);
    end
    c = 1;
    for i = 1:length(gazeData.fixation.offsetsSlot)
        gazeData.fixation.durationSlot(c) = (gazeData.fixation.offsetsSlot(c)-...
            gazeData.fixation.onsetsSlot(c))/200;  % in seconds
        gazeData.fixation.positionXYslot(c,:) = [mean(gazeXinterpolated(gazeData.fixation.onsetsSlot(c):gazeData.fixation.offsetsSlot(c))) ...
            mean(gazeYinterpolated(gazeData.fixation.onsetsSlot(c):gazeData.fixation.offsetsSlot(c)))];
        if gazeData.fixation.durationSlot(c) < minFixationDuration;
            gazeData.fixation.onsetsSlot(c) = [];
            gazeData.fixation.offsetsSlot(c) = [];
            gazeData.fixation.durationSlot(c) = [];
            gazeData.fixation.positionXYslot(c,:) = [];
        end
        c = length(gazeData.fixation.durationSlot) + 1;
    end
else
    gazeData.fixation.durationSlot = [];
    gazeData.fixation.positionXYslot = [];
end
% fixation on display in dual task
gazeData.fixation.display = double(gazeData.inCriticalZone(3,:));
fixDisplayIdx = [gazeData.fixation.display NaN] - [NaN gazeData.fixation.display];
gazeData.fixation.onsetsDisplay = find(fixDisplayIdx == 1);
gazeData.fixation.offsetsDisplay = find(fixDisplayIdx == -1);
if gazeData.fixation.display(1) == 1
    gazeData.fixation.onsetsDisplay = [1 gazeData.fixation.onsetsDisplay];
end
if gazeData.fixation.display(end) == 1
    gazeData.fixation.offsetsDisplay = [gazeData.fixation.offsetsDisplay length(gazeData.fixation.display)];
end
% loop over fixations to read out duration and position
if ~isempty(gazeData.fixation.onsetsDisplay) && ~isempty(gazeData.fixation.offsetsDisplay)
    if gazeData.fixation.offsetsDisplay(1) < gazeData.fixation.onsetsDisplay(1)
        gazeData.fixation.offsetsDisplay(1) = [];
    end    
    if length(gazeData.fixation.onsetsDisplay) ~= length(gazeData.fixation.offsetsDisplay)
        lengthOnOff = min([length(gazeData.fixation.onsetsDisplay) length(gazeData.fixation.offsetsDisplay)]);
        gazeData.fixation.onsetsDisplay = gazeData.fixation.onsetsDisplay(1:lengthOnOff);
        gazeData.fixation.offsetsDisplay = gazeData.fixation.offsetsDisplay(1:lengthOnOff);
    end
    if gazeData.fixation.offsetsDisplay(end) > length(gazeAbsolute)
        gazeData.fixation.offsetsDisplay(end) = length(gazeAbsolute);
    end
    c = 1;
    for i = 1:length(gazeData.fixation.offsetsDisplay)
        gazeData.fixation.durationDisplay(c) = (gazeData.fixation.offsetsDisplay(c)-...
            gazeData.fixation.onsetsDisplay(c))/200;  % in seconds
        gazeData.fixation.positionXYdisplay(c,:) = [mean(gazeXinterpolated(gazeData.fixation.onsetsDisplay(c):gazeData.fixation.offsetsDisplay(c))) ...
            mean(gazeYinterpolated(gazeData.fixation.onsetsDisplay(c):gazeData.fixation.offsetsDisplay(c)))];
        if gazeData.fixation.durationDisplay(c) < minFixationDuration;
            gazeData.fixation.onsetsDisplay(c) = [];
            gazeData.fixation.offsetsDisplay(c) = [];
            gazeData.fixation.durationDisplay(c) = [];
            gazeData.fixation.positionXYdisplay(c,:) = [];
        end
        c = length(gazeData.fixation.durationDisplay) + 1;
    end
else
    gazeData.fixation.durationDisplay = [];
    gazeData.fixation.positionXYdisplay = [];
end
% fixation on other slots
gazeData.fixation.otherSlots = double(gazeData.inCriticalZone(4,:));
fixOtherIdx = [gazeData.fixation.otherSlots NaN] - [NaN gazeData.fixation.otherSlots];
gazeData.fixation.onsetsOther = find(fixOtherIdx == 1);
gazeData.fixation.offsetsOther = find(fixOtherIdx == -1);
if gazeData.fixation.otherSlots(1) == 1
    gazeData.fixation.onsetsOther = [1 gazeData.fixation.onsetsOther];
end
if gazeData.fixation.otherSlots(end) == 1
    gazeData.fixation.offsetsOther = [gazeData.fixation.offsetsOther length(gazeData.fixation.otherSlots)];
end
% loop over fixations to read out duration and position
if ~isempty(gazeData.fixation.onsetsOther) && ~isempty(gazeData.fixation.offsetsOther)
    if gazeData.fixation.offsetsOther(1) < gazeData.fixation.onsetsOther(1)
        gazeData.fixation.offsetsOther(1) = [];
    end    
    if length(gazeData.fixation.onsetsOther) ~= length(gazeData.fixation.offsetsOther)
        lengthOnOff = min([length(gazeData.fixation.onsetsOther) length(gazeData.fixation.offsetsOther)]);
        gazeData.fixation.onsetsOther = gazeData.fixation.onsetsOther(1:lengthOnOff);
        gazeData.fixation.offsetsOther = gazeData.fixation.offsetsOther(1:lengthOnOff);
    end
    if gazeData.fixation.offsetsOther(end) > length(gazeAbsolute)
        gazeData.fixation.offsetsOther(end) = length(gazeAbsolute);
    end
    c = 1;
    for i = 1:length(gazeData.fixation.offsetsOther)
        gazeData.fixation.durationOther(c) = (gazeData.fixation.offsetsOther(c)-...
            gazeData.fixation.onsetsOther(c))/200;  % in seconds
        gazeData.fixation.positionXYother(c,:) = [mean(gazeXinterpolated(gazeData.fixation.onsetsOther(c):gazeData.fixation.offsetsOther(c))) ...
            mean(gazeYinterpolated(gazeData.fixation.onsetsOther(c):gazeData.fixation.offsetsOther(c)))];
        if gazeData.fixation.durationOther(c) < minFixationDuration
            gazeData.fixation.onsetsOther(c) = [];
            gazeData.fixation.offsetsOther(c) = [];
            gazeData.fixation.durationOther(c) = [];
            gazeData.fixation.positionXYother(c,:) = [];
        end
        c = length(gazeData.fixation.durationOther) + 1;
    end
else
    gazeData.fixation.durationOther = [];
    gazeData.fixation.positionXYother = [];
end
% save interpolated eye data
gazeData.Xinterpolated = gazeXinterpolated;
gazeData.Yinterpolated = gazeYinterpolated;
gazeData.VelXYinterpolated = gazeVelInterpolated;
end