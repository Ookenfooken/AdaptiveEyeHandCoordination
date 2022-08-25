function [normalizedData] = normalizeSilentPeriod(durationNorm, info, dualTask, dualPrevious, blockNo)

numLetterChanges = length(dualTask.tLetterChanges);
hangOver = 0;
%% define start and stop frame
% will do 6 phases 
% Phase 1: trial start to reach onset
if blockNo == 3
    duration = ceil(289.8013);
else
    duration = ceil(305.8878);
end
startFrame = 1;
stopFrame = info.phaseStart.primaryReach;
letterChangeVector = zeros(stopFrame-startFrame,1);
if ~isempty(dualPrevious)
    if ~isnan(dualPrevious.tLetterChanges)
        wrappedChanges = [(dualPrevious.tLetterChanges-info.timeStamp.start)*200; ...
            (dualTask.tLetterChanges-info.timeStamp.start)*200];
    else
        wrappedChanges = (dualTask.tLetterChanges-info.timeStamp.start)*200;
    end
else
    wrappedChanges = (dualTask.tLetterChanges-info.timeStamp.start)*200;
end
for i = 1:length(wrappedChanges)
    currentLetterChange = floor(wrappedChanges(i));
    if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
        lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
        letterChangeVector(currentLetterChange+1:lastFrame) = 1;
        if currentLetterChange+251 > length(letterChangeVector)
            hangOver = currentLetterChange+251-length(letterChangeVector);
        else
            hangOver = 0;
        end
    end
end

normLetterVector1 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration
%%

% Phase 2: primary Reach
duration = ceil(durationNorm(blockNo,3));
startFrame = info.phaseStart.primaryReach;
stopFrame = info.phaseStart.ballApproach;
letterChangeVector = zeros(stopFrame-startFrame,1);
if hangOver > 0
    if hangOver > length(letterChangeVector)
        letterChangeVector(1:end) = 1;
        hangOver = hangOver - length(letterChangeVector);
    else
        letterChangeVector(1:hangOver) = 1;
    end
else
    for i = 1:numLetterChanges
        currentLetterChange = floor((dualTask.tLetterChanges(i)-info.timeStamp.reach)*200);
        if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
            lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
            letterChangeVector(currentLetterChange+1:lastFrame) = 1;
            if currentLetterChange+251 > length(letterChangeVector)
                hangOver = currentLetterChange+251-length(letterChangeVector);
            else
                hangOver = 0;
            end
        end
    end
end


normLetterVector2 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration
%%
% Phase 3: ball approach & grasp
duration = ceil(durationNorm(blockNo,4));
startFrame = info.phaseStart.ballApproach;
stopFrame = info.phaseStart.transport;
letterChangeVector = zeros(stopFrame-startFrame,1);
if hangOver > 0
    if hangOver > length(letterChangeVector)
        letterChangeVector(1:end) = 1;
        hangOver = hangOver - length(letterChangeVector);
    else
        letterChangeVector(1:hangOver) = 1;
    end
else
    for i = 1:numLetterChanges
        currentLetterChange = floor((dualTask.tLetterChanges(i)-info.timeStamp.ballApproach)*200);
        if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
            lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
            letterChangeVector(currentLetterChange+1:lastFrame) = 1;
            if currentLetterChange+251 > length(letterChangeVector)
                hangOver = currentLetterChange+251-length(letterChangeVector);
            else
                hangOver = 0;
            end
        end
    end
end

normLetterVector3 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration

%%
% Phase 4: transport
duration = ceil(durationNorm(blockNo,5));
startFrame = info.phaseStart.transport;
stopFrame = info.phaseStart.slotApproach;
letterChangeVector = zeros(stopFrame-startFrame,1);
if hangOver > 0
    if hangOver > length(letterChangeVector)
        letterChangeVector(1:end) = 1;
        hangOver = hangOver - length(letterChangeVector);
    else
        letterChangeVector(1:hangOver) = 1;
    end
else
    for i = 1:numLetterChanges
        currentLetterChange = floor((dualTask.tLetterChanges(i)-info.timeStamp.transport)*200);
        if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
            lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
            letterChangeVector(currentLetterChange+1:lastFrame) = 1;
            if currentLetterChange+251 > length(letterChangeVector)
                hangOver = currentLetterChange+251-length(letterChangeVector);
            else
                hangOver = 0;
            end
        end
    end
end

normLetterVector4 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration

%%
% Phase 5: slot approach and deposit
duration = sum(ceil(durationNorm(blockNo,6)));
startFrame = info.phaseStart.slotApproach;
stopFrame = info.phaseStart.return;
letterChangeVector = zeros(stopFrame-startFrame,1);
if hangOver > 0
    if hangOver > length(letterChangeVector)
        letterChangeVector(1:end) = 1;
        hangOver = hangOver - length(letterChangeVector);
    else
        letterChangeVector(1:hangOver) = 1;
    end
else
    for i = 1:numLetterChanges
        currentLetterChange = floor((dualTask.tLetterChanges(i)-info.timeStamp.slotApproach)*200);
        if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
            lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
            letterChangeVector(currentLetterChange+1:lastFrame) = 1;
            if currentLetterChange+251 > length(letterChangeVector)
                hangOver = currentLetterChange+251-length(letterChangeVector);
            else
                hangOver = 0;
            end
        end
    end
end

normLetterVector5 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration

%%
% Phase 6: return phase
duration = ceil(durationNorm(blockNo,7));
startFrame = info.phaseStart.return;
stopFrame = info.trialEnd;
letterChangeVector = zeros(stopFrame-startFrame,1);
if hangOver > 0
    if hangOver > length(letterChangeVector)
        letterChangeVector(1:end) = 1;
        hangOver = hangOver - length(letterChangeVector);
    else
        letterChangeVector(1:hangOver) = 1;
    end
else
    for i = 1:numLetterChanges
        currentLetterChange = floor((dualTask.tLetterChanges(i)-info.timeStamp.return)*200);
        if currentLetterChange < length(letterChangeVector) && currentLetterChange > 0
            lastFrame = min([length(letterChangeVector) currentLetterChange+251]);
            letterChangeVector(currentLetterChange+1:lastFrame) = 1;
            if currentLetterChange+251 > length(letterChangeVector)
                hangOver = currentLetterChange+251-length(letterChangeVector);
            else
                hangOver = 0;
            end
        end
    end
end

normLetterVector6 = resample(letterChangeVector, duration, length(letterChangeVector));
        
clear startFrame stopFrame letterChangeVector
clear duration

%%
% paste tool speed together
% normalizedData.silentPeriod = [normLetterVector1' normLetterVector2' normLetterVector3' ...
%     normLetterVector4' normLetterVector5' normLetterVector6'];

normalizedData.silentPeriod = [normLetterVector1' normLetterVector2(1:floor(durationNorm(blockNo,3)))' ...
   normLetterVector3(1:floor(durationNorm(blockNo,4)))' normLetterVector4(1:floor(durationNorm(blockNo,5)))' ...
   normLetterVector5(1:floor(durationNorm(blockNo,6)))' normLetterVector6(1:floor(durationNorm(blockNo,7)))'];

end