% save trial average variables per participant
% define some paths
analysisPath = pwd;
resultActionPath = fullfile(pwd,'matFiles\');
resultVigilancePath = fullfile(pwd,'displayFiles\');
savePath = fullfile(pwd,'results\');
allResults = dir(resultActionPath);

% loop over participants and read out measures
numResults = length(allResults)-2;
numBlocks = 4;
pulledData = cell(numResults,numBlocks);
criticalRadius = 2.5;
dropList = csvread('dropList.csv');
vigilanceBlocks = [3 4];

for j = 1:numResults %looping over all subjects
    % load participant's mat file first
    cd(resultActionPath)
    load(allResults(j+2).name); % this loads a structure called results containing 4 blocks
    cd(analysisPath)
    currentSubject = str2double(allResults(j+2).name(2:3));
    numBlocks = length(results);
    for i = 1:numBlocks
        currentBlock = results(i).block;
        % load vigilance data for dual task blocks
        if ismember(i, vigilanceBlocks)
            dualIdx = 1;
            % load data
            subjectName = ['S' num2str(currentSubject) '_vigilanceTask.mat'];
            cd(resultVigilancePath)
            dualData = load(subjectName); % loads structure called results
            cd(analysisPath)
        else
            dualIdx = 0;
            dualData = [];
        end
        % split the data into trials (pick up ball and put into slot)
        phase = currentBlock(:,27);
        phaseChange = [phase; NaN] - [NaN; phase];
        trialStartIdx = [1; find(phaseChange <0); length(phase)];
        numTrials = length(trialStartIdx)-1;
        droppedTrials = dropList(dropList(:,1) == currentSubject & ...
            dropList(:,2) == i, 3);
        for k = 1:numTrials
            currentTrial = currentBlock(trialStartIdx(k):trialStartIdx(k+1),:);
            trialData = pullDataTrial(currentTrial, i, k, criticalRadius, droppedTrials, dualIdx, dualData);
            blockData(:,k) = trialData;
        end
        pulledData{j,i} = blockData;
        clear blockData
    end
    
end

cd(savePath)
save('pulledData', 'pulledData')
cd(analysisPath)