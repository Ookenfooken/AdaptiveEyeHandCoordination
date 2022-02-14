% I will attempt to make a trial-by-trial like plot
% first load the subject you want to look at 
analysisPath = pwd;
resultPath = fullfile(pwd,'matFiles\');
prompt = 'Enter participant ID ';
ID = input(prompt);
subjectId = ['S' num2str(ID) '.mat'];
cd(resultPath)
load(subjectId)
cd(analysisPath)

blockNo = 1;
k = 1;
%%
% open window
screenSize = get(0,'ScreenSize');
close all;
fig = figure('Position', [25 50 screenSize(3)-100, screenSize(4)-150],'Name', 'Dual task data visualization');
% prepare and plot data
prepareData;
plotData;

buttons.previousTrial = uicontrol(fig,'string','<< Previous','Position',[20,70,100,30],...
    'callback','k = max(k-1,1); prepareData; plotData;');

buttons.nextTrial = uicontrol(fig,'string','Next trial >>','Position',[20,105,100,30],...
    'callback','k = k+1;prepareData; plotData;');

buttons.nextBlock = uicontrol(fig,'string','Next block >>','Position',[20,200,100,30],...
    'callback','k = 1; blockNo = blockNo+1; prepareData; plotData;');
buttons.previousBlock = uicontrol(fig,'string','<< Previous block','Position',[20,165,100,30],...
    'callback','k = 1; blockNo = max(blockNo-1,1); prepareData; plotData;');
