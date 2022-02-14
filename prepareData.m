currentBlock = results(blockNo).block;
if blockNo == 1 
    condition = 'hand single';
elseif blockNo == 2 
    condition = 'tweezers single';
elseif blockNo == 3 
    condition = 'hand dual';
else
    condition = 'tweezers dual';
end
% split the data into trials (pick up ball and put into slot)
phase = currentBlock(:,27);
phaseChange = [phase; NaN] - [NaN; phase];
trialStartIdx = [1; find(phaseChange <0); length(phase)];
numTrials = length(trialStartIdx)-1;
currentTrial = currentBlock(trialStartIdx(k):trialStartIdx(k+1),:);
startTime = find(currentTrial(:,9) == 16, 1, 'first');
phaseChangeIdx = find(phaseChange(trialStartIdx(k):trialStartIdx(k+1)) ~= 0);
ballVector = createBallVector(currentTrial, phaseChangeIdx, startTime);
saccadeDetect = [currentTrial(startTime:end,7); NaN] - [NaN; currentTrial(startTime:end,7)];
saccadeOnsets = find(saccadeDetect == 16)-1;
saccadeOffsets = find(saccadeDetect == -16)+1;
gazePositions = gazePositionRaw(currentTrial, startTime, saccadeOnsets, saccadeOffsets); 