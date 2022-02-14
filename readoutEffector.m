function [effectorData] = readoutEffector(currentTrial, startTime)
effectorData.X = currentTrial(startTime:end, 5);
effectorData.Y = currentTrial(startTime:end, 6);
effectorData.velocity = currentTrial(startTime:end, 31);

end