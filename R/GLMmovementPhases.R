library("R.matlab")
library("lme4")
library("lmerTest")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

### SEPARATE BALL/SLOT PHASES ###
#################################
ballFixData = data.frame(readMat("glmData_ball.mat"))
colnames(ballFixData) <- c("participant", "testID", "ballFix", "reachOnset", "reachPeakVel", 
                           "ballApproach", "ballGrasp", "transport", "transportPeakVel", 
                           "slotApproach", "slotEntry", "fixationOnset", 
                           "fixationOffset", "fixationMidpoint")
ballFixData$participant <- as.factor(ballFixData$participant)
ballFixData$testID <- as.factor(ballFixData$testID)

ballFixData$ballFix <- NULL
ballFixations_FT <- ballFixData[ballFixData$testID == 3,] # fingertips
ballFixations_TW <- ballFixData[ballFixData$testID == 4,] # tweezers
ballFix.FT.onset <- lmer(fixationOnset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                       transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_FT)
ballFix.TW.onset <- lmer(fixationOnset ~  reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                       transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_TW)
ballFix.FT.offset <- lmer(fixationOffset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_FT)
ballFix.TW.offset <- lmer(fixationOffset ~  reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_TW)

slotFixData = data.frame(readMat("glmData_slot.mat"))
colnames(slotFixData) <- c("participant", "testID", "slotFix", "reachOnset", "reachPeakVel", 
                           "ballApproach", "ballGrasp", "transport", "transportPeakVel", 
                           "slotApproach", "slotEntry", "fixationOnset", 
                           "fixationOffset", "fixationMidpoint")
slotFixData$participant <- as.factor(slotFixData$participant)
slotFixData$testID <- as.factor(slotFixData$testID)

slotFixData$slotFix <- NULL
slotFixations_FT <- slotFixData[slotFixData$testID == 3,] # fingertips
slotFixations_TW <- slotFixData[slotFixData$testID == 4,] # tweezers
slotFix.FT.onset <- lmer(fixationOnset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                         transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_FT)
slotFix.TW.onset <- lmer(fixationOnset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                         transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_TW)
slotFix.FT.offset <- lmer(fixationOffset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_FT)
slotFix.TW.offset <- lmer(fixationOffset ~ reachOnset + reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_TW)
                          

