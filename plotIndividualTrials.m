% This script contains information on which trials were used for the single
% trial example. For each participant visualizeData.m was used and then
% trials were plotted in separate figures as defined below
% define colours
orange = [255,127,0]./255;
green = [77,175,74]./255;
blue = [55,126,184]./255;
red = [228,26,28]./255;
gray = [115,115,115]./255;
%%
% single trial examples
% 1. chose single task hand trial. We'll go with participant 8 trial 6 for now
% We have 2 saccades: first from ball to slot and then back to ball
figure(8)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(2)), gazePositions.Y(1:saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(toolX(1:saccadeOnsets(2)), toolY(1:saccadeOnsets(2)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(2):saccadeOnsets(3)), gazePositions.Y(saccadeOffsets(2):saccadeOnsets(3)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(toolX(saccadeOffsets(2):saccadeOnsets(3)), toolY(saccadeOffsets(2):saccadeOnsets(3)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(3):end), gazePositions.Y(saccadeOffsets(3):end), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(toolX(saccadeOffsets(3):end), toolY(saccadeOffsets(3):end),'Color', gray, 'LineWidth', .5)
% plot saccades
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(2):saccadeOffsets(2)), toolY(saccadeOnsets(2):saccadeOffsets(2)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(3):saccadeOffsets(3)), ...
        gazePositions.Y(saccadeOnsets(3):saccadeOffsets(3)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(3):saccadeOffsets(3)), toolY(saccadeOnsets(3):saccadeOffsets(3)),...
    'Color', gray, 'LineWidth', 3)

%%
% 2. chose single task tweezers trial. participant 8 trial 7 for now
% We have 2 saccades: first from ball to slot and then back to ball
figure(7)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(2)), gazePositions.Y(1:saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(toolX(1:saccadeOnsets(2)), toolY(1:saccadeOnsets(2)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(2):saccadeOnsets(3)), gazePositions.Y(saccadeOffsets(2):saccadeOnsets(3)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(toolX(saccadeOffsets(2):saccadeOnsets(3)), toolY(saccadeOffsets(2):saccadeOnsets(3)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(3):end), gazePositions.Y(saccadeOffsets(3):end), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(toolX(saccadeOffsets(3):end), toolY(saccadeOffsets(3):end),'Color', gray, 'LineWidth', .5)
% plot saccades
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(2):saccadeOffsets(2)), toolY(saccadeOnsets(2):saccadeOffsets(2)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(3):saccadeOffsets(3)), ...
        gazePositions.Y(saccadeOnsets(3):saccadeOffsets(3)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(3):saccadeOffsets(3)), toolY(saccadeOnsets(3):saccadeOffsets(3)),...
    'Color', gray, 'LineWidth', 3)

%%
% 3. chose dual task hand trial. We'll go with participant 8 trial 10 for now
% We have 2 saccades: first from ball to slot and then back to ball
figure(8)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(1)), gazePositions.Y(1:saccadeOnsets(1)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(toolX(1:saccadeOnsets(1)), toolY(1:saccadeOnsets(1)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(1):saccadeOnsets(2)), gazePositions.Y(saccadeOffsets(1):saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(toolX(saccadeOffsets(1):saccadeOnsets(2)), toolY(saccadeOffsets(1):saccadeOnsets(2)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(2):end), gazePositions.Y(saccadeOffsets(2):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(toolX(saccadeOffsets(2):end), toolY(saccadeOffsets(2):end),'Color', gray, 'LineWidth', .5)
% plot saccades
plot(gazePositions.X(saccadeOnsets(1):saccadeOffsets(1)), ...
        gazePositions.Y(saccadeOnsets(1):saccadeOffsets(1)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(1):saccadeOffsets(1)), toolY(saccadeOnsets(1):saccadeOffsets(1)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(2):saccadeOffsets(2)), toolY(saccadeOnsets(2):saccadeOffsets(2)),...
    'Color', gray, 'LineWidth', 3)

%%
% 3. chose dual task hand trial. We'll go with participant 8 trial 14 for now
% We have 2 saccades: first from ball to slot and then back to ball
figure(8)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(3)), gazePositions.Y(1:saccadeOnsets(3)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(toolX(1:saccadeOnsets(3)), toolY(1:saccadeOnsets(3)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(3):saccadeOnsets(4)), gazePositions.Y(saccadeOffsets(3):saccadeOnsets(4)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(toolX(saccadeOffsets(3):saccadeOnsets(4)), toolY(saccadeOffsets(3):saccadeOnsets(4)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(4):saccadeOnsets(5)), gazePositions.Y(saccadeOffsets(4):saccadeOnsets(5)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(toolX(saccadeOffsets(4):saccadeOnsets(5)), toolY(saccadeOffsets(4):saccadeOnsets(5)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(5):saccadeOnsets(6)), gazePositions.Y(saccadeOffsets(5):saccadeOnsets(6)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(toolX(saccadeOffsets(5):saccadeOnsets(6)), toolY(saccadeOffsets(5):saccadeOnsets(6)),'Color', gray, 'LineWidth', .5)
plot(gazePositions.X(saccadeOffsets(6):end), gazePositions.Y(saccadeOffsets(6):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(toolX(saccadeOffsets(6):end), toolY(saccadeOffsets(6):end),'Color', gray, 'LineWidth', .5)
% plot saccades
plot(gazePositions.X(saccadeOnsets(3):saccadeOffsets(3)), ...
        gazePositions.Y(saccadeOnsets(3):saccadeOffsets(3)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(3):saccadeOffsets(3)), toolY(saccadeOnsets(3):saccadeOffsets(3)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(4):saccadeOffsets(4)), ...
        gazePositions.Y(saccadeOnsets(4):saccadeOffsets(4)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(4):saccadeOffsets(4)), toolY(saccadeOnsets(4):saccadeOffsets(4)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(5):saccadeOffsets(5)), ...
        gazePositions.Y(saccadeOnsets(5):saccadeOffsets(5)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(5):saccadeOffsets(5)), toolY(saccadeOnsets(5):saccadeOffsets(5)),...
    'Color', gray, 'LineWidth', 3)
plot(gazePositions.X(saccadeOnsets(6):saccadeOffsets(6)), ...
        gazePositions.Y(saccadeOnsets(6):saccadeOffsets(6)),'k', 'LineWidth', 1)
plot(toolX(saccadeOnsets(6):saccadeOffsets(6)), toolY(saccadeOnsets(6):saccadeOffsets(6)),...
    'Color', gray, 'LineWidth', 3)

%% Example trials for fixation patterns (Figure 5)
% 1. display only use participant 11 dual hand any trial
figure(11)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
% plot fixations in colors of their appearance
plot(toolX, toolY,'Color', gray, 'LineWidth', .5)
% plot fixations in colors of their appearance
plot(gazePositions.X, gazePositions.Y, 'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
%% 2. ball only
% use participant 7 dual tweezers trial 7
figure(7)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
plot(toolX, toolY,'Color', gray, 'LineWidth', .5)
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(1)), gazePositions.Y(1:saccadeOnsets(1)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(gazePositions.X(saccadeOffsets(1):saccadeOnsets(2)), gazePositions.Y(saccadeOffsets(1):saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(gazePositions.X(saccadeOffsets(2):end), gazePositions.Y(saccadeOffsets(2):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
% plot saccades
plot(gazePositions.X(saccadeOnsets(1):saccadeOffsets(1)), ...
        gazePositions.Y(saccadeOnsets(1):saccadeOffsets(1)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'Color', red, 'LineWidth', 1)
    
%% 3. slot only
% use participant 2 dual hand trial 15
figure(2)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
plot(toolX, toolY,'Color', gray, 'LineWidth', .5)
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(1)), gazePositions.Y(1:saccadeOnsets(1)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(gazePositions.X(saccadeOffsets(1):saccadeOnsets(2)), gazePositions.Y(saccadeOffsets(1):saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(gazePositions.X(saccadeOffsets(2):end), gazePositions.Y(saccadeOffsets(2):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
% plot saccades
plot(gazePositions.X(saccadeOnsets(1):saccadeOffsets(1)), ...
        gazePositions.Y(saccadeOnsets(1):saccadeOffsets(1)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'Color', red, 'LineWidth', 1)
    
%% 4. ball-slot
% use participant 1 dual tweezers trial 6
figure(11)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
plot(toolX, toolY,'Color', gray, 'LineWidth', .5)
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(3)), gazePositions.Y(1:saccadeOnsets(3)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(gazePositions.X(saccadeOffsets(3):saccadeOnsets(4)), gazePositions.Y(saccadeOffsets(3):saccadeOnsets(4)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(gazePositions.X(saccadeOffsets(4):saccadeOnsets(6)), gazePositions.Y(saccadeOffsets(4):saccadeOnsets(6)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(gazePositions.X(saccadeOffsets(6):end), gazePositions.Y(saccadeOffsets(6):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
% plot saccades
plot(gazePositions.X(saccadeOnsets(3):saccadeOffsets(3)), ...
        gazePositions.Y(saccadeOnsets(3):saccadeOffsets(3)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(4):saccadeOffsets(4)), ...
        gazePositions.Y(saccadeOnsets(4):saccadeOffsets(4)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(6):saccadeOffsets(6)), ...
        gazePositions.Y(saccadeOnsets(6):saccadeOffsets(6)),'Color', red, 'LineWidth', 1)
    
%% 5. ball-slot
% use participant 10 dual tweezers trial 12
figure(10)
hold on
axis([-5 20 -2.5 20]);
% finger tip position
toolX = currentTrial(startTime:end, 5);
toolY = currentTrial(startTime:end, 6);
plot(toolX, toolY,'Color', gray, 'LineWidth', .5)
% plot fixations in colors of their appearance
plot(gazePositions.X(1:saccadeOnsets(2)), gazePositions.Y(1:saccadeOnsets(2)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(gazePositions.X(saccadeOffsets(2):saccadeOnsets(3)), gazePositions.Y(saccadeOffsets(2):saccadeOnsets(3)), ...
    'o', 'MarkerFaceColor', orange,'MarkerEdgeColor', orange)
plot(gazePositions.X(saccadeOffsets(3):saccadeOnsets(5)), gazePositions.Y(saccadeOffsets(3):saccadeOnsets(5)), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
plot(gazePositions.X(saccadeOffsets(5):saccadeOnsets(6)), gazePositions.Y(saccadeOffsets(5):saccadeOnsets(6)), ...
    'o', 'MarkerFaceColor', green,'MarkerEdgeColor', green)
plot(gazePositions.X(saccadeOffsets(6):end), gazePositions.Y(saccadeOffsets(6):end), ...
    'o', 'MarkerFaceColor', blue,'MarkerEdgeColor', blue)
% plot saccades
plot(gazePositions.X(saccadeOnsets(2):saccadeOffsets(2)), ...
        gazePositions.Y(saccadeOnsets(2):saccadeOffsets(2)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(3):saccadeOffsets(3)), ...
        gazePositions.Y(saccadeOnsets(3):saccadeOffsets(3)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(5):saccadeOffsets(5)), ...
        gazePositions.Y(saccadeOnsets(5):saccadeOffsets(5)),'Color', red, 'LineWidth', 1)
plot(gazePositions.X(saccadeOnsets(6):saccadeOffsets(6)), ...
        gazePositions.Y(saccadeOnsets(6):saccadeOffsets(6)),'Color', red, 'LineWidth', 1)