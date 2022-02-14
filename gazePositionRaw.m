function [gazePositions] = gazePositionRaw(currentTrial, startTime, saccadeOnsets, saccadeOffsets)
% define eye position and velocity
% gaze x (3), gaze y (4) and gaze velocity (30)th column
gazeX = currentTrial(startTime:end, 3);
gazeY = currentTrial(startTime:end, 4);
% remove blinks
gazeX(currentTrial(startTime:end,26) == 1) = NaN;
gazeY(currentTrial(startTime:end,26) == 1) = NaN;
% align gaze to origin
% if ~isempty(saccadeOnsets)
%     fixationStop = min([startTime+39 startTime+saccadeOnsets(1)-1]);
% else
%     fixationStop = startTime+39;
% end
%shiftX = mean(currentTrial(startTime:fixationStop, 3));
%shiftY = mean(currentTrial(startTime:fixationStop, 4));
minIdx = find(sqrt(gazeX.^2 + gazeY.^2) == min(sqrt(gazeX.^2 + gazeY.^2)));
shiftX = currentTrial(minIdx(1),3);
shiftY = currentTrial(minIdx(1),4);
if abs(shiftX) > 2.5 || shiftX < 0 
    shiftX = 0;
end
%shiftY = 1;
if abs(shiftY) > 2.5
    shiftY = 0;
end
shift = 1;
gazeX = (gazeX - shiftX)*shift;
gazeY = (gazeY - shiftY)*shift;
gazePositions.X = gazeX;
gazePositions.Y = gazeY; 
gazeXinterpolated = gazeX;
gazeYinterpolated = gazeY;
% interplolate gaze across saccades
lengthOnOff = min([length(saccadeOnsets) length(saccadeOffsets)]);
for i = 1:lengthOnOff
    offset = min([saccadeOffsets(i) length(gazeX)]);
    saccadeDuration = offset - saccadeOnsets(i);
    slopeX = (gazeX(offset) - gazeX(saccadeOnsets(i)))./saccadeDuration;
    slopeY = (gazeY(offset) - gazeY(saccadeOnsets(i)))./saccadeDuration;
    for j = 1:saccadeDuration+1
        gazeXinterpolated(saccadeOnsets(i)-1+j) = gazeX(saccadeOnsets(i)) + slopeX*j;
        gazeYinterpolated(saccadeOnsets(i)-1+j) = gazeY(saccadeOnsets(i)) + slopeY*j;
    end    
end
gazeVelInterpolated = sqrt(gazeXinterpolated.^2 + gazeYinterpolated.^2);

% define critical areas:  
criticalLocations = [0 0; ... % ball centre
                    -1.9 5.2; ... % bottom slot
                    -1.9 8.2; ... % middle slot
                    -1.9 11.2; ...% top slot
                    13.63 16.68]; % visual display
radius = 2;
distancesGaze = NaN(length(criticalLocations), length(gazeXinterpolated));
for j = 1:length(criticalLocations)
    for i = 1:length(gazeXinterpolated)        
        distancesGaze(j,i) = sqrt((gazeXinterpolated(i) - criticalLocations(j,1)).^2 ...
            +  (gazeYinterpolated(i) - criticalLocations(j,2)).^2);
    end
end
gazePositions.distanceCriticalZone = distancesGaze;
gazePositions.inCriticalZone = distancesGaze < radius;
gazePositions.Xinterpolated = gazeXinterpolated;
gazePositions.Yinterpolated = gazeYinterpolated;
gazePositions.Velinterpolated = gazeVelInterpolated;
end