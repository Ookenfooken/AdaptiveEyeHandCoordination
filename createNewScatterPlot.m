% read in saved gaze data structure
analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
load('pulledData')
cd(analysisPath);
%% Before plotting define some colours
fixationPatternColors = [[55,126,184]./255;
    [255,127,0]./255;
    [77,175,74]./255
    [158,154,200]./255
    [77,0,75]./255];
lightGrey = [189,189,189]./255;
upperBound = 6.5;
fixationOnsets = 4; % column with fixation onsets
manipulationOnsets = 5; % column with grasp / slot entry
%% Calculate ball fixation onsets relative to reach onset
ballFixationReReach = [];
numParticipants = 11;
eyeShift = 20;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 5;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            ballGrasp = currentResult(n).info.timeStamp.ballGrasp;
            reachOnset = currentResult(n).info.timeStamp.reach;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixBallOnRelative = currentResult(n).gaze.fixation.onsetsBall(1)/200;
                fixBallOnset = currentResult(n).info.timeStamp.go + fixBallOnRelative;
                if (fixBallOnset - reachOnset) < 6.5
                    reachRelativeBallFix = fixBallOnset - reachOnset;
                    reachRelativeGrasp = ballGrasp - reachOnset;
                else
                    continue
                end
            else
                continue
            end
                        
            % classify trial type
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end 
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             reachRelativeBallFix reachRelativeGrasp];
        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        ballFixationReReach = [ballFixationReReach; currentVariable];
        clear fixationPattern reachRelativeBallFix currentParticipant reachRelativeGrasp
        clear fixBallOnRelative fixBallOnset slotIdx slotOnset ballOffset currentLetterChange
        clear currentVariable detectedChanges detectedChanges_ballFix blockID letterIdx
    end
end

%% calculate slot fixation onsets relative to letter changes
slotFixationReTransport = [];
numParticipants = 11;
eyeShift = 20;
for j = 1:numParticipants % loop over subjects
    for blockID = 3:4 % loop over dual task conditions
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        numMeasures = 5;
        currentVariable = NaN(numTrials,numMeasures);
        % open variable matrices that we want to pull
        stopTrial = min([numTrials 30]);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            slotEntry = currentResult(n).info.timeStamp.ballInSlot;
            transportOn = currentResult(n).info.timeStamp.transport;
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                if ~isempty(currentResult(n).gaze.fixation.offsetsBall)
                    slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > currentResult(n).gaze.fixation.offsetsBall(1), 1, 'first');
                else
                    slotIdx = 1;
                end
                fixSlotOnRelative = currentResult(n).gaze.fixation.onsetsSlot(slotIdx)/200;
                fixSlotOnset = currentResult(n).info.timeStamp.go + fixSlotOnRelative;
            else
                continue
            end
            if (fixSlotOnset - transportOn) < 6.5
                transportRelativeSlotFix = fixSlotOnset - transportOn;
                transportRelativeEntry = slotEntry - transportOn;
            else
                continue
            end
           
            % classify trial type
            if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                % cannot classify trials in which the ball is fixated multiple times
                fixationPattern = 99;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 0;
            elseif isempty(currentResult(n).gaze.fixation.onsetsBall) && ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 2;
            elseif ~isempty(currentResult(n).gaze.fixation.onsetsBall) && isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixationPattern = 1;
            else
                ballOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                slotIdx = find(currentResult(n).gaze.fixation.onsetsSlot > ballOffset, 1, 'first');
                slotOnset = currentResult(n).gaze.fixation.onsetsSlot(slotIdx);
                if slotOnset-ballOffset < eyeShift
                    fixationPattern = 3;
                else
                    fixationPattern = 4;
                end
            end 
            
        currentVariable(n,:) = [currentParticipant blockID fixationPattern ... 
             transportRelativeSlotFix transportRelativeEntry];

        end
        currentVariable = currentVariable(~isnan(currentVariable(:,1)),:);
        slotFixationReTransport = [slotFixationReTransport; currentVariable];
        clear fixationPattern transportRelativeSlotFix transportRelativeEntry
        clear fixSlotOnRelative fixSlotOnset slotIdx slotOnset blockID letterIdx
        clear ballOffset currentLetterChange currentVariable detectedChanges_slotFix 
    end
end


%% correlational plots for fingertips (panel C)
figure(87)
xymax = 3.5;
xymin = -1;
ballFixations_PG = ballFixationReReach(ballFixationReReach(:,2) == 3, :);
slotFixations_PG = slotFixationReTransport(slotFixationReTransport(:,2) == 3, :);
selectedPattern = 1; % exclude ball-only
ballFix_PG = ballFixations_PG(ballFixations_PG(:,3) ~= selectedPattern,:);
slotFix_PG = slotFixations_PG(slotFixations_PG(:,3) ~= selectedPattern,:);

subplot(2,2,1)
set(gcf,'renderer','Painters')
xlim([xymin xymax])
xlabel('grasp rel. reach (FT)')
ylim([xymin xymax])
ylabel('ball fix onset rel. reach (FT)')
axis('square')
hold on
plot(ballFix_PG(ballFix_PG(:,3) == 4,manipulationOnsets), ballFix_PG(ballFix_PG(:,3) == 4,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_PG(ballFix_PG(:,3) == 3,manipulationOnsets), ballFix_PG(ballFix_PG(:,3) == 3,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([xymin xymax], [xymin xymax], 'Color', 'k')
fit_ball_FT = polyfit(ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,manipulationOnsets),...
    ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,fixationOnsets),1);
s_grasp_PG = regstats(ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,manipulationOnsets),...
    ballFix_PG(ballFix_PG(:,3) == 3 | ballFix_PG(:,3) == 4,fixationOnsets),'linear'); 

subplot(2,2,3)
set(gcf,'renderer','Painters')
xlim([xymin xymax])
xlabel('slot entry rel. transport (FT)')
ylim([xymin xymax])
ylabel('slot fix onset rel.  transport (FT')
axis('square')
hold on
plot(slotFix_PG(slotFix_PG(:,3) == 2,manipulationOnsets), slotFix_PG(slotFix_PG(:,3) == 2,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_PG(slotFix_PG(:,3) == 4,manipulationOnsets), slotFix_PG(slotFix_PG(:,3) == 4,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_PG(slotFix_PG(:,3) == 3,manipulationOnsets), slotFix_PG(slotFix_PG(:,3) == 3,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([xymin xymax], [xymin xymax], 'Color', 'k')
fit_slot_FT = polyfit(slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,manipulationOnsets),...
    slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,fixationOnsets),1);
s_slotEntry_PG = regstats(slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,manipulationOnsets),...
    slotFix_PG(slotFix_PG(:,3) == 2 | slotFix_PG(:,3) == 4 | slotFix_PG(:,3) == 4,fixationOnsets),'linear');

%%
ballFixations_TW = ballFixationReReach(ballFixationReReach(:,2) == 4, :);
slotFixations_TW = slotFixationReTransport(slotFixationReTransport(:,2) == 4, :);
selectedPattern = 1; % exclude ball-only
ballFix_TW = ballFixations_TW(ballFixations_TW(:,3) ~= selectedPattern,:);
slotFix_TW = slotFixations_TW(slotFixations_TW(:,3) ~= selectedPattern,:);

subplot(2,2,2)
set(gcf,'renderer','Painters')
%xlim([xymin xymax])
xlabel('grasp rel. reach (TW)')
%ylim([xymin xymax])
ylabel('ball fix onset rel. reach (TW)')
axis('square')
hold on
plot(ballFix_TW(ballFix_TW(:,3) == 4,manipulationOnsets), ballFix_TW(ballFix_TW(:,3) == 4,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(ballFix_TW(ballFix_TW(:,3) == 3,manipulationOnsets), ballFix_TW(ballFix_TW(:,3) == 3,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([xymin xymax], [xymin xymax], 'Color', 'k')
fit_ball_TW = polyfit(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets),...
    ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets),1);
s_grasp_TW = regstats(ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,manipulationOnsets),...
    ballFix_TW(ballFix_TW(:,3) == 3 | ballFix_TW(:,3) == 4,fixationOnsets),'linear'); 

subplot(2,2,4)
set(gcf,'renderer','Painters')
%xlim([xymin xymax])
xlabel('slot entry rel. transport (TW)')
%ylim([xymin xymax])
ylabel('slot fix onset rel.  transport (TW)')
axis('square')
hold on
plot(slotFix_TW(slotFix_TW(:,3) == 2,manipulationOnsets), slotFix_TW(slotFix_TW(:,3) == 2,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(3,:))
plot(slotFix_TW(slotFix_TW(:,3) == 4,manipulationOnsets), slotFix_TW(slotFix_TW(:,3) == 4,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(5,:))
plot(slotFix_TW(slotFix_TW(:,3) == 3,manipulationOnsets), slotFix_TW(slotFix_TW(:,3) == 3,fixationOnsets), ...
    '.', 'Color', fixationPatternColors(4,:))
line([xymin xymax], [xymin xymax], 'Color', 'k')
fit_slot_TW = polyfit(slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,manipulationOnsets),...
    slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,fixationOnsets),1);
s_slotEntry_TW = regstats(slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,manipulationOnsets),...
    slotFix_TW(slotFix_TW(:,3) == 2 | slotFix_TW(:,3) == 4 | slotFix_TW(:,3) == 4,fixationOnsets),'linear'); 

