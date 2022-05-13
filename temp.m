%% plot phase durations for most common fixation types in finger trip trials (Panel A)
blockID = 3;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
counter = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end);
    % exclude participant that has ball-slot as most common pattern
    if sum(currentParticipant(:,1) == 3) >  sum(currentParticipant(:,1) == 0)
        continue
    end
    % most common pattern
    displayOnly = currentParticipant(currentParticipant(:,1) == 0,:); % select fixation pattern
    % only include participants that have at least 3 trials in each pattern
    if size(displayOnly,1) < 3
        continue
    end
    slotOnly = currentParticipant(currentParticipant(:,1) == 2,:); % select fixation pattern
    if size(slotOnly,1) < 3
        continue
    end
    % save durations into structure for stats
    durationFT(counter,:) = [blockID i nanmedian(displayOnly(:,5)) nanmedian(displayOnly(:,6)) ...
        nanmedian(displayOnly(:,3)) nanmedian(displayOnly(:,7)) nanmedian(displayOnly(:,8))...
        nanmedian(slotOnly(:,5)) nanmedian(slotOnly(:,6)) nanmedian(slotOnly(:,3)) ...
        nanmedian(slotOnly(:,7)) nanmedian(slotOnly(:,8))];
    counter = counter+1;
end

%%
blockID = 4;
currentTool = phaseDurations(phaseDurations(:,1) == blockID,:);
counter = 1;
for i = 1:numParticipants
    currentParticipant = currentTool(currentTool(:,2) == i,3:end); % select fixation pattern
    % only include participants that have at least 3 trials in each pattern
    ballSlot = currentParticipant(currentParticipant(:,1) == 3,:);
    if size(ballSlot,1) < 3
        continue
    end
    ballDisplaySlot = currentParticipant(currentParticipant(:,1) == 4,:); % select fixation pattern
    if size(ballDisplaySlot,1) < 3
        continue
    end
    % save durations into structure for stats
    durationTW(counter,:) = [blockID i nanmedian(ballSlot(:,5)) nanmedian(ballSlot(:,6)) ...
        nanmedian(ballSlot(:,3)) nanmedian(ballSlot(:,7)) nanmedian(ballSlot(:,8))...
        nanmedian(ballDisplaySlot(:,5)) nanmedian(ballDisplaySlot(:,6)) nanmedian(ballDisplaySlot(:,3)) ...
        nanmedian(ballDisplaySlot(:,7)) nanmedian(ballDisplaySlot(:,8))];
    counter = counter+1;
end
%%
tempPhases = [durationFT; durationTW];
cd(savePath)
save('tempPhases', 'tempPhases');
cd(analysisPath)