analysisPath = pwd;
resultPath = fullfile(pwd,'results\');
savePath = fullfile(pwd,'R\');
cd(resultPath)
% load in data
load('pulledData.mat')
cd(analysisPath)

%%
numParticipants = 11;
fixationTiming = [];
figure(11)
hold on
xlim([.5 2.5])
set(gca, 'Xtick', [1 2], 'XtickLabel', {'before ball approach', 'after ball approach'})
ylim([0 5])
set(gca, 'Ytick', [0 1 2 3 4 5])
ylabel('Ball phase duration (s)')
figure(22)
hold on
xlim([.5 2.5])
set(gca, 'Xtick', [1 2], 'XtickLabel', {'before slot approach', 'after slot approach'})
ylim([0 5])
set(gca, 'Ytick', [0 1 2 3 4 5])
ylabel('Slot phase duration (s)')
for blockID = 3:4
    for i = 1:numParticipants % loop over participants
        currentResult = pulledData{i,blockID};
        currentParticipant = currentResult(1).info.subject;
        numTrials = length(currentResult);
        stopTrial = min([numTrials 30]);
        durationBallPhase_early = NaN(numTrials,1);
        durationBallPhase_late = NaN(numTrials,1);
        durationSlotPhase_early = NaN(numTrials,1);
        durationSlotPhase_late = NaN(numTrials,1);
        for n = 1:stopTrial % loop over trials for current participant & block
            if currentResult(n).info.dropped
                stopTrial = min([stopTrial+1 numTrials]);
                continue
            end
            if blockID > 3
                if isempty(currentResult(n).gaze.fixation.onsetsBall)
                    continue
                end
                onsetBallApproach = currentResult(n).info.phaseStart.ballApproach;
                if currentResult(n).gaze.fixation.onsetsBall(1) < onsetBallApproach
                    durationBallPhase_early(n) = (currentResult(n).info.phaseDuration.ballApproach + ...
                        currentResult(n).info.phaseDuration.ballGrasp)/200;
                else
                    durationBallPhase_late(n) = (currentResult(n).info.phaseDuration.ballApproach + ...
                        currentResult(n).info.phaseDuration.ballGrasp)/200;
                end
            end
            if isempty(currentResult(n).gaze.fixation.onsetsSlot)
                continue
            end
            onsetSlotApproach = currentResult(n).info.phaseStart.slotApproach;
            if currentResult(n).gaze.fixation.onsetsSlot(1) < onsetSlotApproach
                durationSlotPhase_early(n) = (currentResult(n).info.phaseDuration.slotApproach + ...
                    currentResult(n).info.phaseDuration.ballInSlot)/200;
            else
                durationSlotPhase_late(n) = (currentResult(n).info.phaseDuration.slotApproach + ...
                    currentResult(n).info.phaseDuration.ballInSlot)/200;
            end
            
        end
        if blockID > 3
            if sum(~isnan(durationBallPhase_late)) > 0
                % plot ball phase duration relative to ball fixation timing
                figure(11)
                plot(1, nanmedian(durationBallPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                plot(2, nanmedian(durationBallPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                line([1 2], [nanmedian(durationBallPhase_early) nanmedian(durationBallPhase_late)],...
                    'Color', 'k', 'LineStyle', '--')
            end
        end
        if sum(~isnan(durationSlotPhase_late)) > 0
            % plot slot phase duration relative to slot fixationg timing            
            if blockID < 4
                figure(22)
                plot(1, nanmedian(durationSlotPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
                plot(2, nanmedian(durationSlotPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
                line([1 2], [nanmedian(durationSlotPhase_early) nanmedian(durationSlotPhase_late)], 'Color', 'k')
            else
                figure(22)
                plot(1, nanmedian(durationSlotPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                plot(2, nanmedian(durationSlotPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                line([1 2], [nanmedian(durationSlotPhase_early) nanmedian(durationSlotPhase_late)],...
                    'Color', 'k', 'LineStyle', '--')
            end
        end
        
    end
end
