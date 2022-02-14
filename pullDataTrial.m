function [trialData] = pullDataTrial(currentTrial, blockNo, trialNo, r, droppedTrials, dualIdx, dualData)

startTime = find(currentTrial(:,9) == 16, 1, 'first');
trialInfo = readoutTrialInfo(currentTrial, startTime, blockNo, trialNo, droppedTrials);
gazeData = readoutGaze(currentTrial, startTime, r);
effectorData = readoutEffector(currentTrial, startTime);
dualTaskData = readoutVigilanceTask(currentTrial, blockNo, dualIdx, dualData);

trialData.info = trialInfo;
trialData.gaze = gazeData;
trialData.effector = effectorData;
trialData.dualTask = dualTaskData;
end