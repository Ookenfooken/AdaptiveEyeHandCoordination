% Define analysis, data, and result path
analysisPath = pwd;
dataPath = [pwd '\RAW'];
resultPath = fullfile(pwd,'matFiles\');

% read in participant data that were 
numSubjects = 11;
numBlocks = 4;
 
for i = 1:numSubjects
    results = [];
    for j = 1:numBlocks
        name = ['S' num2str(i) '_T' num2str(j) '.txt'];
        cd(dataPath)
        currentData = importdata(name);
        results(j).block = currentData;
        cd(analysisPath)
    end
    cd(resultPath)
    save(['S' num2str(i)], 'results')
    cd(analysisPath)
end