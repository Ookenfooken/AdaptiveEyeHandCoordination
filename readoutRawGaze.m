function [rawGaze] = readoutRawGaze(currentTrial)
% define eye position and velocity
% gaze x (3), gaze y (4) and gaze velocity (30)th column
rawGaze.timeStamp = currentTrial(:, 1);
gazeX = currentTrial(:, 3);
gazeY = currentTrial(:, 4);
% remove blinks from data
gazeX(currentTrial(:,26) == 1) = NaN;
gazeY(currentTrial(:,26) == 1) = NaN;
gazeVelocity = currentTrial(:, 30);
rawGaze.X = gazeX;
rawGaze.Y = gazeY;
rawGaze.velocity = gazeVelocity;
rawGaze.blinkIdx = currentTrial(:, 26);
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
rawGaze.Xshifted = gazeX;
rawGaze.Yshifted = gazeY;
end