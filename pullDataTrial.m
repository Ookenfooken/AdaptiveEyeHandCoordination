function [trialData] = pullDataTrial(currentTrial, blockNo, trialNo, r, droppedTrials, dualIdx, dualData)

startTime = find(currentTrial(:,9) == 16, 1, 'first');
trialInfo = readoutTrialInfo(currentTrial, startTime, blockNo, trialNo, droppedTrials);
gazeData = readoutGaze(currentTrial, startTime, r);
rawGaze = readoutRawGaze(currentTrial);
effectorData = readoutEffector(currentTrial, startTime);
dualTaskData = readoutVigilanceTask(currentTrial, blockNo, dualIdx, dualData);

trialData.info = trialInfo;
trialData.gaze = gazeData;
trialData.rawGaze = rawGaze;
trialData.effector = effectorData;
trialData.dualTask = dualTaskData;
end