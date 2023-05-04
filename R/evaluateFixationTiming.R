library("R.matlab")
library("lme4")
library("lmerTest")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

### SEPARATE BALL/SLOT PHASES ###
#################################
phaseData = data.frame(readMat("fixationsRelativeContactEvents.mat"))
colnames(phaseData) <- c("participant", "testID",
                         "ballFix", "ballFixOnset", "ballFixOffset", 
                         "slotFix", "slotFixOnset", "slotFixOffset")
phaseData$participant <- as.factor(phaseData$participant)
phaseData$testID <- as.factor(phaseData$testID)
# split into fingertips and tweezers
phases_ballFix <- phaseData[phaseData$ballFix > 0,] # ball fixations
phases_slotFix <- phaseData[phaseData$slotFix > 0,] # slot fixations

# aggregate data
ballFix_agg <- aggregate(cbind(ballFixOnset, ballFixOffset) ~ participant + testID, median, na.rm = TRUE, data = phases_ballFix)
slotFix_agg <- aggregate(cbind(slotFixOnset, slotFixOffset) ~ participant + testID, median, na.rm = TRUE, data = phases_slotFix)
