library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("fixationPatternPhases.mat"))
colnames(phaseDurations) <- c("testID", "participant",
                              "type1.ballPhase", "type1.transport", "type1.slotPhase",
                              "type2.ballPhase", "type2.transport", "type2.slotPhase")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- as.factor(phaseDurations$testID)
# compare phase length for fingertip trials
durations_FT <- phaseDurations[phaseDurations$testID == 3,]
t.test(durations_FT$type1.ballPhase, durations_FT$type2.ballPhase, paired = TRUE)
t.test(durations_FT$type1.transport, durations_FT$type2.transport, paired = TRUE)
# exclude participant p10 (see paper for details)
durations_FT <- durations_FT[-c(8),]
t.test(durations_FT$type1.slotPhase, durations_FT$type2.slotPhase, paired = TRUE)
# compare phase length for tweezer trials
durations_TW <- phaseDurations[phaseDurations$testID == 4,]
t.test(durations_TW$type1.ballPhase, durations_TW$type2.ballPhase, paired = TRUE)
t.test(durations_TW$type1.transport, durations_TW$type2.transport, paired = TRUE)
t.test(durations_TW$type1.slotPhase, durations_TW$type2.slotPhase, paired = TRUE)
