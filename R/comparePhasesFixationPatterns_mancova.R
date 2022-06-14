library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("fixationPatternPhases_new.mat"))
colnames(phaseDurations) <- c("testID", "participant", "fixationType",
                              "reach", "ballApproach", "ballGrasp",
                              "transport", "slotApproach", "slotEntry")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- as.factor(phaseDurations$testID)
phaseDurations$fixationType <- as.factor(phaseDurations$fixationType)
# look at fingertips first
phaseDurations_FT <- phaseDurations[phaseDurations$testID == 3,]
phaseDurations_FT$testID <- NULL
# exclude participant p10 (see paper for details)
phaseDurations_FT <- phaseDurations_FT[-c(17:18),]
# run mancova
mancovaFT <- manova(cbind(transport, slotApproach, slotEntry) ~ fixationType, data = phaseDurations_FT)
# look at tool trials
phaseDurations_TW <- phaseDurations[phaseDurations$testID == 4,]
phaseDurations_TW$testID <- NULL
# run mancova
mancovaTW <- manova(cbind(reach, ballApproach, ballGrasp, transport, slotApproach, slotEntry) ~ 
                      fixationType, data = phaseDurations_TW)
