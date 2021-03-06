library("R.matlab")
library("lme4")
library("lmerTest")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

### SEPARATE BALL/SLOT PHASES ###
#################################
ballFixData = data.frame(readMat("glmData_ball.mat"))
colnames(ballFixData) <- c("participant", "testID", "ballFix", "reachPeakVel", 
                           "ballApproach", "ballGrasp", "transport", "transportPeakVel", 
                           "slotApproach", "slotEntry", "fixationOnset", 
                           "fixationOffset", "fixationMidpoint")
ballFixData$participant <- as.factor(ballFixData$participant)
ballFixData$testID <- as.factor(ballFixData$testID)

ballFixations = ballFixData[ballFixData$ballFix > 0,]
ballFixations$ballFix <- NULL
ballFixations_FT <- ballFixations[ballFixations$testID == 3,] # fingertips
ballFixations_TW <- na.omit(ballFixations[ballFixations$testID == 4,]) # tweezers
ballFix.FT.onset <- lmer(fixationOnset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                       transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_FT)
ballFix.TW.onset <- lmer(fixationOnset ~  reachPeakVel + ballApproach + ballGrasp + transport +
                       transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_TW)
ballFix.FT.offset <- lmer(fixationOffset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_FT)
ballFix.TW.offset <- lmer(fixationOffset ~  reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_TW)
ballFix.FT.midpoint <- lmer(fixationMidpoint ~ reachPeakVel + ballApproach + ballGrasp + transport +
                            transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_FT)
ballFix.TW.midpoint <- lmer(fixationMidpoint ~  reachPeakVel + ballApproach + ballGrasp + transport +
                            transportPeakVel + slotApproach + slotEntry + (1|participant), data = ballFixations_TW)


slotFixData = data.frame(readMat("glmData_slot.mat"))
colnames(slotFixData) <- c("participant", "testID", "slotFix", "reachPeakVel", 
                           "ballApproach", "ballGrasp", "transport", "transportPeakVel", 
                           "slotApproach", "slotEntry", "fixationOnset", 
                           "fixationOffset", "fixationMidpoint")
slotFixData$participant <- as.factor(slotFixData$participant)
slotFixData$testID <- as.factor(slotFixData$testID)

slotFixations = slotFixData[slotFixData$slotFix > 0,]
slotFixations$slotFix <- NULL
slotFixations_FT <- na.omit(slotFixations[slotFixations$testID == 3,]) # fingertips
slotFixations_TW <- na.omit(slotFixations[slotFixations$testID == 4,]) # tweezers
slotFix.FT.onset <- lmer(fixationOnset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                         transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_FT)
slotFix.TW.onset <- lmer(fixationOnset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                         transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_TW)
slotFix.FT.offset <- lmer(fixationOffset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_FT)
slotFix.TW.offset <- lmer(fixationOffset ~ reachPeakVel + ballApproach + ballGrasp + transport +
                           transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_TW)
slotFix.FT.midpoint <- lmer(fixationMidpoint ~ reachPeakVel + ballApproach + ballGrasp + transport +
                            transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_FT)
slotFix.TW.midpoint <- lmer(fixationMidpoint ~ reachPeakVel + ballApproach + ballGrasp + transport +
                            transportPeakVel + slotApproach + slotEntry + (1|participant), data = slotFixations_TW)
