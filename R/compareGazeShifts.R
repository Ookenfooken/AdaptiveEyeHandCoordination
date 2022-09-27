library("R.matlab")
library("lsr")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
coordination = data.frame(readMat("spatiotemporalCoordination.mat"))
colnames(coordination) <- c("participant", "testID", "tool", "dual",
                              "gazeShift.ballSlot", "fixations.ball", "fixations.slot")
coordination$participant <- as.factor(coordination$participant)
coordination$testID <- NULL #redundant
coordination$tool <- as.factor(coordination$tool)
coordination$dual <- as.factor(coordination$dual)
# aggregate data per condition and participant
gazeShifts <- aggregate(. ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = coordination)
# t-test for single task condition
gazeShifts_single <- gazeShifts[gazeShifts$dual == 0,]
t.test(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot, gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot,
       paired = TRUE)
cohensD(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot, gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot,
        method = 'paired')
# mean and sd fingertips in ms
mean(gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot)
sd(gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot)
# mean & sd tweezers in ms
mean(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot)
sd(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot)

# t-test for dual task condition 
fixations_dual <- gazeShifts[gazeShifts$dual == 1,]
# ball fixations
t.test(fixations_dual[fixations_dual$tool == 1,]$fixations.ball, 
       fixations_dual[fixations_dual$tool == 0,]$fixations.ball,
       paired = TRUE)
cohensD(fixations_dual[fixations_dual$tool == 1,]$fixations.ball, 
        fixations_dual[fixations_dual$tool == 0,]$fixations.ball,
        method = 'paired')
# report mean and sds
mean(fixations_dual[fixations_dual$tool == 1,]$fixations.ball)
sd(fixations_dual[fixations_dual$tool == 1,]$fixations.ball)

mean(fixations_dual[fixations_dual$tool == 0,]$fixations.ball, na.rm = TRUE)
sd(fixations_dual[fixations_dual$tool == 0,]$fixations.ball, na.rm = TRUE)

# slot fixations
t.test(fixations_dual[fixations_dual$tool == 1,]$fixations.slot, 
       fixations_dual[fixations_dual$tool == 0,]$fixations.slot,
       paired = TRUE)
cohensD(fixations_dual[fixations_dual$tool == 1,]$fixations.slot, 
        fixations_dual[fixations_dual$tool == 0,]$fixations.slot,
        method = 'paired')
# report mean and sds
mean(fixations_dual[fixations_dual$tool == 1,]$fixations.slot)
sd(fixations_dual[fixations_dual$tool == 1,]$fixations.slot)

mean(fixations_dual[fixations_dual$tool == 0,]$fixations.slot, na.rm = TRUE)
sd(fixations_dual[fixations_dual$tool == 0,]$fixations.slot, na.rm = TRUE)
