function [dualTaskData] = readoutVigilanceTask(currentTrial, blockNo, dualIdx, dualData)
% add display info for vigilance task in dual task condition
if dualIdx
    dualTaskData.true = 1;
    currentData = dualData.results(blockNo).block;
    currentChanges = find(currentData(:,1) > currentTrial(1,1) & currentData(:,1) < currentTrial(end,1));
    if isempty(currentChanges)
        dualTaskData.tLetterChanges = NaN;
        dualTaskData.sampleLetterChange = NaN;
        dualTaskData.responseLetterChange = NaN;
        dualTaskData.changeDetected = 0;
        dualTaskData.changeMissed = 0;
    else
        dualTaskData.tLetterChanges = dualData.results(blockNo).block(currentChanges,1);
        for i = 1:length(currentChanges)
            dualTaskData.sampleLetterChange(i) = find(currentTrial(:,1) > dualTaskData.tLetterChanges(i), 1, 'first');
        end
        dualTaskData.responseLetterChange = dualData.results(blockNo).block(currentChanges,9);
        dualTaskData.changeDetected = dualTaskData.responseLetterChange == 1;
        dualTaskData.changeMissed = dualTaskData.responseLetterChange == -1;
    end
else
    dualTaskData.true = 0;
end
    
end