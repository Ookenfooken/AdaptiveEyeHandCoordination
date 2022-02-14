function [ballVector] = createBallVector(currentTrial, phaseIdx, startTime)
% the ball is at start position in phase 0 (initial hand position), 1
% (primary reach) and 2 (ball aproach)
initialLength = phaseIdx(4)-startTime;
initialBallVector = zeros(initialLength-1, 2);
dropFrameFirst = min([find(currentTrial(:,10)~=0, 1, 'first') ...
    find(currentTrial(:,11)~=0, 1, 'first')...
    find(currentTrial(:,12)~=0, 1, 'first')]);
dropFrameLast = min([find(currentTrial(:,10)~=0, 1, 'last') ...
    find(currentTrial(:,11)~=0, 1, 'last')...
    find(currentTrial(:,12)~=0, 1, 'last')]);
% sort out which slot the ball was put into and define ball position
if currentTrial(1,23) == 1
    dropPosition = [-1.9 5.2];
elseif currentTrial(1,23) == 2
    dropPosition = [-1.9 8.2];
else
    dropPosition = [-1.9 11.2];    
end
% interpolate ball position fron initial position to drop Position
liftInterval = 1:(dropFrameFirst - initialLength-1);
stepSizeLiftX = dropPosition(1)/length(liftInterval);
stepSizeLiftY = dropPosition(2)/length(liftInterval);
liftBallVector = [(0:stepSizeLiftX:dropPosition(1))' (0:stepSizeLiftY:dropPosition(2))'];
dropInterval = 1:(dropFrameLast - dropFrameFirst-1);
stepSizeDrop = dropPosition(2)/length(dropInterval);
dropBallVector = [dropPosition(1)*ones(length(dropInterval)+1,1) (dropPosition(2):-stepSizeDrop:0)'];
finalLength = length(currentTrial) - (initialLength + length(liftInterval) + length(dropInterval))-2;
stepSizeFinal = -dropPosition(1)/finalLength;
finalBallVector = [(dropPosition(1):stepSizeFinal:0)' zeros(finalLength+1, 1)];
ballVector = [initialBallVector; liftBallVector; dropBallVector; finalBallVector];
end