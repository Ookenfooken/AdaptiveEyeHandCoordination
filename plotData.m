% define some pretty colours
red = [228,26,28]./255;
blue = [55,126,184]./255;
darkBlue = [8,81,156]./255;
green = [77,175,74]./255;
lightGreen = [116,196,118]./255;
darkGreen = [0,90,50]./255;
purple = [152,78,163]./255;
orange = [255,127,0]./255;
gray = [115,115,115]./255;

% plot structure - add as we know what to look at
subplot(2,2,1,'replace');
axis([-5 20 -2.5 20]);
hold on
% Draw slot position and size, colour in selected
if currentTrial(1,22) == 1
    rectangle('Position',[-2.9 4.5 2 1.4], 'LineWidth', 2, 'FaceColor', red)
    rectangle('Position',[-2.9 7.5 2 1.4], 'LineWidth', 2)
    rectangle('Position',[-2.9 10.5 2 1.4], 'LineWidth', 2)
elseif currentTrial(1,22) == 2
    rectangle('Position',[-2.9 4.5 2 1.4], 'LineWidth', 2)
    rectangle('Position',[-2.9 7.5 2 1.4], 'LineWidth', 2, 'FaceColor', red)
    rectangle('Position',[-2.9 10.5 2 1.4], 'LineWidth', 2)
else
    rectangle('Position',[-2.9 4.5 2 1.4], 'LineWidth', 2)
    rectangle('Position',[-2.9 7.5 2 1.4], 'LineWidth', 2)
    rectangle('Position',[-2.9 10.5 2 1.4], 'LineWidth', 2, 'FaceColor', red)    
end

% Draw display
rectangle('Position',[13.6 15.7 4 2], 'LineWidth', 1)
% horizontal vs. vertical eye position
plot(gazePositions.X, gazePositions.Y, '*', 'Color', lightGreen)
xlabel('Horizontal position (cm)')
ylabel('Vertical position (cm)')
% plot saccades
lengthOnOff = min([length(saccadeOnsets) length(saccadeOffsets)]);
for i = 1:lengthOnOff
   offsetAbs = min([saccadeOffsets(i) length(gazePositions.X)]);
   plot(gazePositions.X(saccadeOnsets(i):offsetAbs), ...
        gazePositions.Y(saccadeOnsets(i):offsetAbs), ...
       'Color', darkGreen, 'LineWidth', 1)
end
% add horizontal and vertical finger tip
plot(currentTrial(startTime:end,5), currentTrial(startTime:end,6), 'Color', blue, 'LineWidth', 1)
% add approximate ball postion
plot(ballVector(:,1), ballVector(:,2), 'Color', orange)

%%
% plot eye speed over time
subplot(2,2,2,'replace');
yMax = 400;
axis([0 length(currentTrial)-startTime 0 yMax]);
hold on
p1 = plot(currentTrial(startTime:end,30), 'Color', green);
p2 = plot(currentTrial(startTime:end,31), 'Color', blue, 'LineWidth', 2);
xlabel('Frames')
ylabel('Velocity')
% add saccade on and offsets
lengthOnOff = min([length(saccadeOnsets) length(saccadeOffsets)]);
for i = 1:lengthOnOff
   offsetAbs = min([saccadeOffsets(i) length(currentTrial)]);
   offsetRel = min([saccadeOffsets(i)+startTime-1 length(currentTrial)]);
   plot(saccadeOnsets(i), currentTrial(saccadeOnsets(i)+startTime-1,30), '*', 'Color', purple)
   plot(offsetAbs, currentTrial(offsetRel,30), '*', 'Color', purple)
end
% add phase changes
line([phaseChangeIdx(2)-startTime phaseChangeIdx(2)-startTime], [0 yMax], 'Color', gray, 'LineStyle', '--') % start reach
line([phaseChangeIdx(3)-startTime phaseChangeIdx(3)-startTime], [0 yMax], 'Color', red, 'LineStyle', '--') % ball approach
line([phaseChangeIdx(4)-startTime phaseChangeIdx(4)-startTime], [0 yMax], 'Color', gray, 'LineStyle', '--') % ball grasp
line([phaseChangeIdx(5)-startTime phaseChangeIdx(5)-startTime], [0 yMax], 'Color', gray, 'LineStyle', '--') % transport
line([phaseChangeIdx(6)-startTime phaseChangeIdx(6)-startTime], [0 yMax], 'Color', red, 'LineStyle', '--') % slot approach
line([phaseChangeIdx(7)-startTime phaseChangeIdx(7)-startTime], [0 yMax], 'Color', gray, 'LineStyle', '--') % slot entry
line([phaseChangeIdx(8)-startTime phaseChangeIdx(8)-startTime], [0 yMax], 'Color', red, 'LineStyle', '--') % ball dropped
line([phaseChangeIdx(9)-startTime phaseChangeIdx(9)-startTime], [0 yMax], 'Color', gray, 'LineStyle', '--') % return
legend([p1 p2], 'eye', 'hand')
%%
top = [152,0,67]./255;
mid = [221,28,119]./255;
low = [223,101,176]./255;
% plot eye position as function of zone over time
subplot(2,2,[3,4], 'replace');
axis([0 length(currentTrial)-startTime 0 20]);
xlabel('Frames')
ylabel('Distance from gaze (cm)')
hold on
plot(gazePositions.distanceCriticalZone(1,:), 'Color', orange)
plot(gazePositions.distanceCriticalZone(4,:), 'Color', top)
plot(gazePositions.distanceCriticalZone(3,:), 'Color', mid)
plot(gazePositions.distanceCriticalZone(2,:), 'Color', low)
plot(gazePositions.distanceCriticalZone(5,:), 'Color', darkBlue)
line([0 length(currentTrial)-startTime], [2.5 2.5], 'Color', [0 0 0], 'LineStyle', ':')
legend('ball', 'top', 'middle', 'bottom', 'display')

%%
% some trial info

xPosition = 20;
yPosition = 700;
verticalDistance = 20;
width = 130;
height = 20;
textblock = 0;

textblock = textblock+1;
subjectText = uicontrol(fig,'Style','text',...
    'String', ['Subject: ' subjectId(1:end-4)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
conditionText = uicontrol(fig,'Style','text',...
    'String', ['Condition: ' condition],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
blockText = uicontrol(fig,'Style','text',...
    'String', ['Block Number: ' num2str(blockNo)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
trialText = uicontrol(fig,'Style','text',...
    'String', ['Trial: ' num2str(k)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

