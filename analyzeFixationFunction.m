analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)
numParticipants = 11;
numBlocks = 4;
preApproachMarker = 20; % 20 samples = 100 ms
minGuideDuration = 40; % 40 samples = 200 ms

%% assign functions to each ball fixation
ballFixFunctions = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:numBlocks % loop over dual blocks
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(blockID).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        numVariables = 9;
        currentVariable = NaN(numTrials, numVariables);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            ballApproach = currentResult(n).info.phaseStart.ballApproach - trialStart;
            transport = currentResult(n).info.phaseStart.transport - trialStart;
            % ball fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsBall)
                fixOnset = currentResult(n).gaze.fixation.onsetsBall(1);
                fixOffset = currentResult(n).gaze.fixation.offsetsBall(1);
                endGuideInterval = min([fixOffset transport]);
                fixDuration = fixOffset - fixOnset; % duration in samples
                if fixOnset < ballApproach-preApproachMarker && ...
                        fixDuration >=preApproachMarker
                    directing = 1;
                    fixReachDuration = (ballApproach-fixOnset)/.2;
                else
                    directing = 0;
                    fixReachDuration = 0;
                end
                if fixOffset < ballApproach
                    guiding = 0;
                    fixBallDuration = 0;
                elseif fixOnset > ballApproach && fixOffset < transport && ...
                        fixDuration >= minGuideDuration
                    guiding = 1;
                    fixBallDuration = (fixOffset - fixOnset)/.2;
                elseif fixOnset < ballApproach && endGuideInterval-ballApproach >= minGuideDuration
                    guiding = 1;
                    fixBallDuration = (endGuideInterval - ballApproach)/.2;
                elseif fixOnset > ballApproach && endGuideInterval-fixOnset >=minGuideDuration
                    guiding = 1;
                    fixBallDuration = (endGuideInterval - fixOnset)/.2;
                else
                    guiding = 0;
                    fixBallDuration = 0;
                end
                if fixOffset > transport 
                    checking = 1;
                    fixTransportDuration = (fixOffset - transport)/.2;
                else
                    checking = 0;
                    fixTransportDuration = 0;
                end
                      
                if numel(currentResult(n).gaze.fixation.onsetsBall) > 1
                    fixOnset = currentResult(n).gaze.fixation.onsetsBall(2);
                    if fixOnset > transport + preApproachMarker
                        continue
                    end
                    fixOffset = currentResult(n).gaze.fixation.offsetsBall(2);
                    endGuideInterval = min([fixOffset transport]);
                    fixDuration = fixOffset - fixOnset; % duration in samples
                    if fixOnset < ballApproach-preApproachMarker && ...
                            fixDuration >=preApproachMarker
                        directing = 1;
                    end
                    if fixOnset > ballApproach && fixOffset < transport && ...
                            fixDuration >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset < ballApproach && endGuideInterval-ballApproach >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset > ballApproach && endGuideInterval-fixOnset >=minGuideDuration
                        guiding = 1;
                    end
                    if fixOffset > transport 
                        checking = 1;
                    end
                end
                numFunctions = directing+guiding+checking;
            else
                continue
            end
            
            currentVariable(n,:) = [currentParticipant blockID numFunctions ...
                directing guiding checking ...
                fixReachDuration fixBallDuration fixTransportDuration];
        end
        
        ballFixFunctions = [ballFixFunctions; currentVariable];
        clear currentVariable
    end
end
%% assign functions to each slot fixation
slotFixFunctions = [];
for j = 1:numParticipants % loop over subjects
    for blockID = 3:numBlocks % loop over dual blocks
        currentResult = pulledData{j,blockID};
        currentParticipant = currentResult(blockID).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        numVariables = 6;
        currentVariable = NaN(numTrials, numVariables);
        for n = 1:stopTrial % loop over trials for current subject & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            trialStart = currentResult(n).info.trialStart;
            slotApproach = currentResult(n).info.phaseStart.slotApproach - trialStart;
            returnPhase = currentResult(n).info.phaseStart.return - trialStart;
            % slot fixations
            if ~isempty(currentResult(n).gaze.fixation.onsetsSlot)
                fixOnset = currentResult(n).gaze.fixation.onsetsSlot(1);
                fixOffset = currentResult(n).gaze.fixation.offsetsSlot(1);
                endGuideInterval = min([fixOffset returnPhase]);
                fixDuration = fixOffset - fixOnset; % duration in samples
                if fixOnset < slotApproach-preApproachMarker && ...
                        fixDuration >=preApproachMarker
                    directing = 1;
                else
                    directing = 0;
                end
                if fixOffset < slotApproach
                    guiding = 0;
                elseif fixOnset > slotApproach && fixOffset < returnPhase && ...
                        fixDuration >= minGuideDuration
                    guiding = 1;
                elseif fixOnset < slotApproach && endGuideInterval-slotApproach >= minGuideDuration
                    guiding = 1;
                elseif fixOnset > slotApproach && endGuideInterval-fixOnset >=minGuideDuration
                    guiding = 1;
                else
                    guiding = 0;
                end
                if fixOffset > returnPhase 
                    checking = 1;
                else
                    checking = 0;
                end
                    
                if numel(currentResult(n).gaze.fixation.onsetsSlot) > 1
                    fixOnset = currentResult(n).gaze.fixation.onsetsSlot(2);
                    if fixOnset > returnPhase + preApproachMarker
                        continue
                    end
                    fixOffset = currentResult(n).gaze.fixation.offsetsSlot(2);
                    endGuideInterval = min([fixOffset returnPhase]);
                    fixDuration = fixOffset - fixOnset; % duration in samples
                    if fixOnset < slotApproach-preApproachMarker && ...
                            fixDuration >=preApproachMarker
                        directing = 1;
                    end
                    if fixOnset > slotApproach && fixOffset < returnPhase && ...
                            fixDuration >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset < slotApproach && endGuideInterval-slotApproach >= minGuideDuration
                        guiding = 1;
                    elseif fixOnset > slotApproach && endGuideInterval-fixOnset >=minGuideDuration
                        guiding = 1;
                    end
                    if fixOffset > returnPhase 
                        checking = 1;
                    end
                end
                numFunctions = directing+guiding+checking;
            else
                continue
            end
            
            currentVariable(n,:) = [currentParticipant blockID numFunctions ...
                directing guiding checking];
        end
        
        slotFixFunctions = [slotFixFunctions; currentVariable];
        clear currentVariable
    end
end
%%
ballFixFunctions = ballFixFunctions(~isnan(ballFixFunctions(:,1)),:);
ballFixFunctions_PG = ballFixFunctions(ballFixFunctions(:,2) == 3,:);
ballFixFunctions_TW = ballFixFunctions(ballFixFunctions(:,2) == 4,:);

X = categorical({'directing','guiding','checking'});
X = reordercats(X,{'directing','guiding','checking'});
ballBarData = [sum(ballFixFunctions_PG(:,4))/length(ballFixFunctions_PG) ...
    sum(ballFixFunctions_TW(:,4))/length(ballFixFunctions_TW); ...
    sum(ballFixFunctions_PG(:,5))/length(ballFixFunctions_PG) ...
    sum(ballFixFunctions_TW(:,5))/length(ballFixFunctions_TW); ...
    sum(ballFixFunctions_PG(:,6))/length(ballFixFunctions_PG) ...
    sum(ballFixFunctions_TW(:,6))/length(ballFixFunctions_TW)];

figure(2)
b = bar(X,ballBarData);
box off
b(1).FaceColor = 'none';
b(1).EdgeColor = [255,127,0]./255;
b(2).FaceColor = [255,127,0]./255;
b(2).EdgeColor = 'none';
%%
slotFixFunctions = slotFixFunctions(~isnan(slotFixFunctions(:,1)),:);
slotFixFunctions_PG = slotFixFunctions(slotFixFunctions(:,1) == 3,:);
slotFixFunctions_TW = slotFixFunctions(slotFixFunctions(:,1) == 4,:);

X = categorical({'directing','guiding','checking'});
X = reordercats(X,{'directing','guiding','checking'});
slotBarData = [sum(ballFixFunctions_PG(:,4))/length(ballFixFunctions_PG) ...
    sum(slotFixFunctions_TW(:,4))/length(slotFixFunctions_TW); ...
    sum(slotFixFunctions_PG(:,5))/length(slotFixFunctions_PG) ...
    sum(slotFixFunctions_TW(:,5))/length(slotFixFunctions_TW); ...
    sum(slotFixFunctions_PG(:,6))/length(slotFixFunctions_PG) ...
    sum(slotFixFunctions_TW(:,6))/length(slotFixFunctions_TW)];

figure(3)
b = bar(X,slotBarData);
box off
b(1).FaceColor = 'none';
b(1).EdgeColor = [77,175,74]./255;
b(2).FaceColor = [77,175,74]./255;
b(2).EdgeColor = 'none';