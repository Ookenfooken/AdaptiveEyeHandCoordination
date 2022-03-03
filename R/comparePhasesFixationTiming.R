library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("fixationTiming.mat"))
colnames(phaseDurations) <- c("testID", "participant", "fixType", "earlyFixations", "lateFixations")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- as.factor(phaseDurations$testID)
phaseDurations$fixType <- as.factor(phaseDurations$fixType)
# compare ball phase length for tweezer trials
ball_durations <- phaseDurations[phaseDurations$fixType == 1,]
t.test(ball_durations$earlyFixations, ball_durations$lateFixations, paired = TRUE)
# compare slot phase length for fingertip and tweezer trials
ball_durations <- phaseDurations[phaseDurations$fixType == 2,]
t.test(ball_durations[ball_durations$testID == 3,]$earlyFixations, 
       ball_durations[ball_durations$testID == 3,]$lateFixations, paired = TRUE)
t.test(ball_durations[ball_durations$testID == 4,]$earlyFixations, 
       ball_durations[ball_durations$testID == 4,]$lateFixations, paired = TRUE)
