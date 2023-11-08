library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
reachData = data.frame(readMat("participantReachStart.mat"))
colnames(reachData) <- c("participant", "testID", "actionFix",
                         "inZone", "outZone")
factorCols <- c("participant", "testID", "actionFix")
reachData[factorCols] <- lapply(reachData[factorCols], as.factor)

reach_FT <- reachData[reachData$testID == 3,]
reach_TW <- reachData[reachData$testID == 4,]
# t-test action fixation fingertips
t.test(reach_FT[reach_FT$actionFix == 1,]$inZone, reach_FT[reach_FT$actionFix == 1,]$outZone, 
       na.omit = TRUE, paired = TRUE)
# t-test no action fixation fingertips
t.test(reach_FT[reach_FT$actionFix == 0,]$inZone, reach_FT[reach_FT$actionFix == 0,]$outZone, 
       na.omit = TRUE, paired = TRUE)
# t-test action fixation tweezers
t.test(reach_TW[reach_TW$actionFix == 1,]$inZone, reach_TW[reach_TW$actionFix == 1,]$outZone, 
       na.omit = TRUE, paired = TRUE)
