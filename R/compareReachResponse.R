library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
reachData = data.frame(readMat("participantReachStart.mat"))
colnames(reachData) <- c("participant", "testID", "fixType",
                         "inZone", "outZone")
factorCols <- c("participant", "testID", "fixType")
reachData[factorCols] <- lapply(reachData[factorCols], as.factor)

reach_FT <- reachData[reachData$testID == 3,]
reach_TW <- reachData[reachData$testID == 4,]
# t-test display only fingertips
t.test(reach_FT[reach_FT$fixType == 0,]$inZone, reach_FT[reach_FT$fixType == 0,]$outZone, 
       na.omit = TRUE, paired = TRUE)
reach_FT_disp <- na.omit(reach_FT[reach_FT$fixType == 0,])
mean(reach_FT_disp$inZone)
sd(reach_FT_disp$inZone)/sqrt(nrow(reach_FT_disp))
mean(reach_FT_disp$outZone)
sd(reach_FT_disp$outZone)/sqrt(nrow(reach_FT_disp))
# t-test slot fixation fingertips
t.test(reach_FT[reach_FT$fixType == 1,]$inZone, reach_FT[reach_FT$fixType == 1,]$outZone, 
       na.omit = TRUE, paired = TRUE)
reach_FT_slot <- na.omit(reach_FT[reach_FT$fixType == 1,])
mean(reach_FT_slot$inZone)
sd(reach_FT_slot$inZone)/sqrt(nrow(reach_FT_slot))
mean(reach_FT_slot$outZone)
sd(reach_FT_slot$outZone)/sqrt(nrow(reach_FT_slot))
# t-test ball-slot and ball-display-slot fingertips
t.test(reach_FT[reach_FT$fixType == 2,]$inZone, reach_FT[reach_FT$fixType == 2,]$outZone, 
       na.omit = TRUE, paired = TRUE)
# t-test ball-slot fixation tweezers
t.test(reach_TW[reach_TW$fixType == 3,]$inZone, reach_TW[reach_TW$fixType == 3,]$outZone, 
       na.omit = TRUE, paired = TRUE)
# t-test ball-disp-slot fixation tweezers
t.test(reach_TW[reach_TW$fixType == 4,]$inZone, reach_TW[reach_TW$fixType == 4,]$outZone, 
       na.omit = TRUE, paired = TRUE)
reach_TW_purple <- na.omit(reach_TW[reach_TW$fixType == 4,])
mean(reach_TW_purple$inZone)
sd(reach_TW_purple$inZone)/sqrt(nrow(reach_TW_purple))
mean(reach_TW_purple$outZone)
sd(reach_TW_purple$outZone)/sqrt(nrow(reach_TW_purple))
