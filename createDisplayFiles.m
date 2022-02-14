% Define analysis, data, and result path
analysisPath = pwd;
dataPath = [pwd '\displayFilesRaw'];
resultPath = fullfile(pwd,'displayFiles\');

% read in subject data
displayFiles = dir(dataPath);
numSubjects = 11;
currentBlock = 0;
nameCounter = 3;
subjectList = [1 5 10 7 6 9 4 11 2 3 8]; % this is sorthing the initials


for i = 1:numSubjects
    results = [];
    resultName = ['S' num2str(subjectList(i)) '_vigilanceTask.mat'];
    for j = 1:2 % readout each block that had the vigilance task 
        fileName = displayFiles(nameCounter).name;      
        if strcmp(displayFiles(nameCounter).name(4:6), 'RHE')
            currentBlock = 3;
        elseif strcmp(displayFiles(nameCounter).name(4:6), 'RTE')
            currentBlock = 4;
        end       
        cd(dataPath)
        currentData = importdata(fileName);
        results(currentBlock).block = currentData;
        cd(analysisPath)    
        nameCounter = nameCounter+1;    
    end
    cd(resultPath)
    save(resultName, 'results')
    cd(analysisPath)
    currentBlock = 0;
end