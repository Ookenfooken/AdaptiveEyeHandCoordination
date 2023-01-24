library("R.matlab")
library("ez")
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
gazeShifts <- aggregate(gazeShift.ballSlot ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = coordination)
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

# ball fixation duration 
ballFixations <- aggregate(fixations.ball ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = coordination)
# remove participants that didn't look at the ball in dual condition
ballFixations <- ballFixations[-c(4,10,11,15,21,22,26,32,33,37,43,44),]
aov_ball_fix <- ezANOVA(data = ballFixations, dv=fixations.ball, wid=participant, within=.(dual, tool), type = 2)
# calculate means
# single vs. dual
mean(ballFixations[ballFixations$dual == 1,]$fixations.ball)
sd(ballFixations[ballFixations$dual == 1,]$fixations.ball)
mean(ballFixations[ballFixations$dual == 0,]$fixations.ball)
sd(ballFixations[ballFixations$dual == 0,]$fixations.ball)
# FT vs. TW
mean(ballFixations[ballFixations$tool == 0,]$fixations.ball)
sd(ballFixations[ballFixations$tool == 0,]$fixations.ball)
mean(ballFixations[ballFixations$tool == 1,]$fixations.ball)
sd(ballFixations[ballFixations$tool == 1,]$fixations.ball)

# slot fixation duration 
slotFixations <- aggregate(fixations.slot ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = coordination)
# remove participants that didn't look at the ball in dual condition
slotFixations <- slotFixations[-c(11,22,33,44),]
aov_slot_fix <- ezANOVA(data = slotFixations, dv=fixations.slot, wid=participant, within=.(dual, tool), type = 2)
# calculate means
# single vs. dual
mean(slotFixations[slotFixations$dual == 1,]$fixations.slot)
sd(slotFixations[slotFixations$dual == 1,]$fixations.slot)
mean(slotFixations[slotFixations$dual == 0,]$fixations.slot)
sd(slotFixations[slotFixations$dual == 0,]$fixations.slot)



