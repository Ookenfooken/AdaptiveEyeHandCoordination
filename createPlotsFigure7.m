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
ylim([0 2])
set(gca, 'Ytick', [0 .5 1 1.5 2])
ylabel('Slot phase duration (s)')
cBall = 1;
cSlot = 1;
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
                onsetBallApproach = currentResult(n).info.phaseStart.ballApproach-currentResult(n).info.trialStart;
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
            onsetSlotApproach = currentResult(n).info.phaseStart.slotApproach-currentResult(n).info.trialStart;
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
                % (Panel A)
                figure(11)
                plot(1, nanmean(durationBallPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                plot(2, nanmean(durationBallPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                line([1 2], [nanmean(durationBallPhase_early) nanmean(durationBallPhase_late)],...
                    'Color', 'k', 'LineStyle', '--')
                ballPhaseDuration(cBall,:) = [blockID i 1 nanmean(durationBallPhase_early) nanmean(durationBallPhase_late)];
                cBall = cBall + 1;
            end
        end
        if sum(~isnan(durationSlotPhase_late)) > 0 && sum(~isnan(durationSlotPhase_early)) > 0
            % plot slot phase duration relative to slot fixationg timing 
            % (Panel B)           
            if blockID < 4
                figure(22)
                plot(1, nanmean(durationSlotPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
                plot(2, nanmean(durationSlotPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
                line([1 2], [nanmean(durationSlotPhase_early) nanmean(durationSlotPhase_late)], 'Color', 'k')
            else
                figure(22)
                plot(1, nanmean(durationSlotPhase_early), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                plot(2, nanmean(durationSlotPhase_late), 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none')
                line([1 2], [nanmean(durationSlotPhase_early) nanmean(durationSlotPhase_late)],...
                    'Color', 'k', 'LineStyle', '--')
            end
            slotPhaseDuration(cSlot,:) = [blockID i 2 nanmean(durationSlotPhase_early) nanmean(durationSlotPhase_late)];
            cSlot = cSlot + 1;
        end
        
    end
end
clear onsetBallApproach onsetSlotApproach cBall cSlot
%%
fixationTiming = [ballPhaseDuration; slotPhaseDuration]; 
cd(savePath)
save('fixationTiming', 'fixationTiming')
cd(analysisPath)