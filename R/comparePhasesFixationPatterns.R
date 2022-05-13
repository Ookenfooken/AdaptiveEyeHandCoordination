library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("fixationPatternPhases.mat"))
colnames(phaseDurations) <- c("testID", "participant",
                              "type1.reach", "type1.ballApproach", "type1.ballGrasp",
                              "type1.transport", "type1.slotApproach", "type1.slotEntry",
                              "type2.reach", "type2.ballApproach", "type2.ballGrasp",
                              "type2.transport", "type2.slotApproach", "type2.slotEntry")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- as.factor(phaseDurations$testID)
# compare phase length for fingertip trials and slot phase
durations_FT <- phaseDurations[phaseDurations$testID == 3,]
t.test(durations_FT$type1.transport, durations_FT$type2.transport, paired = TRUE)
# exclude participant p10 (see paper for details)
durations_FT <- durations_FT[-c(8),]
t.test(durations_FT$type1.slotApproach, durations_FT$type2.slotApproach, paired = TRUE)
t.test(durations_FT$type1.slotEntry, durations_FT$type2.slotEntry, paired = TRUE)
# compare phase length for tweezer trials
durations_TW <- phaseDurations[phaseDurations$testID == 4,]
# ball phase
t.test(durations_TW$type1.reach, durations_TW$type2.reach, paired = TRUE)
t.test(durations_TW$type1.ballApproach, durations_TW$type2.ballApproach, paired = TRUE)
t.test(durations_TW$type1.ballGrasp, durations_TW$type2.ballGrasp, paired = TRUE)
# slot phase
t.test(durations_TW$type1.transport, durations_TW$type2.transport, paired = TRUE)
t.test(durations_TW$type1.slotApproach, durations_TW$type2.slotApproach, paired = TRUE)
t.test(durations_TW$type1.slotEntry, durations_TW$type2.slotEntry, paired = TRUE)
