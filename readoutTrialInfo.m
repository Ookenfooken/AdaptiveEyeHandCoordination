function [trialInfo] = readoutTrialInfo(currentTrial, startTime, blockNo, trialNo, droppedTrials)
% read out some trial info
trialInfo.subject = currentTrial(1,24);
trialInfo.blockID = currentTrial(1,25);
if blockNo < 3
    trialInfo.taskCondition = 1;
    trialInfo.taskConditionName = 'single';
else
    trialInfo.taskCondition = 2;
    trialInfo.taskConditionName = 'dual';
end
trialInfo.trialNumber = trialNo;
% ball drop
if ismember(trialNo, droppedTrials)
    trialInfo.dropped = 1;
else
    trialInfo.dropped = 0;
end
trialInfo.cuedSlot = currentTrial(1,22);
trialInfo.usedSlot = currentTrial(1,23);
% get phase info
phases = currentTrial(:,27);
phaseChange = [phases; NaN] - [NaN; phases];
phaseChangeIdx = find(phaseChange ~= 0);

trialInfo.phaseStart.primaryReach = phaseChangeIdx(2);
trialInfo.phaseStart.ballApproach = phaseChangeIdx(3);
trialInfo.phaseStart.ballGrasp = phaseChangeIdx(4);
trialInfo.phaseStart.transport = phaseChangeIdx(5);
trialInfo.phaseStart.slotApproach = phaseChangeIdx(6);
trialInfo.phaseStart.ballInSlot = phaseChangeIdx(7);
trialInfo.phaseStart.ballDropped = phaseChangeIdx(8);
trialInfo.phaseStart.return = phaseChangeIdx(9);

trialInfo.phaseDuration.primaryReach = phaseChangeIdx(3)-phaseChangeIdx(2);
trialInfo.phaseDuration.ballApproach = phaseChangeIdx(4)-phaseChangeIdx(3);
trialInfo.phaseDuration.ballGrasp = phaseChangeIdx(5)-phaseChangeIdx(4);
trialInfo.phaseDuration.transport = phaseChangeIdx(6)-phaseChangeIdx(5);
trialInfo.phaseDuration.slotApproach = phaseChangeIdx(7)-phaseChangeIdx(6);
trialInfo.phaseDuration.ballInSlot = phaseChangeIdx(9)-phaseChangeIdx(7);
if numel(phaseChangeIdx) < 10
    stopFrame = length(currentTrial);
else
    stopFrame = phaseChangeIdx(10);
end
trialInfo.phaseDuration.return = stopFrame-phaseChangeIdx(9);

trialInfo.trialStart = startTime;
trialInfo.trialEnd = stopFrame;
trialInfo.length = stopFrame - startTime;

% get absolute time stamps
trialInfo.timeStamp.start = currentTrial(1,1);
trialInfo.timeStamp.go = currentTrial(startTime,1);
trialInfo.timeStamp.reach = currentTrial(phaseChangeIdx(2),1);
trialInfo.timeStamp.ballApproach = currentTrial(phaseChangeIdx(3),1);
trialInfo.timeStamp.ballGrasp = currentTrial(phaseChangeIdx(4),1);
trialInfo.timeStamp.transport = currentTrial(phaseChangeIdx(5),1);
trialInfo.timeStamp.slotApproach = currentTrial(phaseChangeIdx(6),1);
trialInfo.timeStamp.ballInSlot = currentTrial(phaseChangeIdx(7),1);
trialInfo.timeStamp.ballDropped = currentTrial(phaseChangeIdx(8),1);
trialInfo.timeStamp.return = currentTrial(phaseChangeIdx(9),1);
trialInfo.timeStamp.trialEnd = currentTrial(stopFrame,1);
end