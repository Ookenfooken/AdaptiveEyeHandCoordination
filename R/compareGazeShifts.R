library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
coordination = data.frame(readMat("spatiotemporalCoordination.mat"))
colnames(coordination) <- c("participant", "testID", "tool", "dual",
                              "gazeShift.ballSlot", "gazeshift.slotDisplay")
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
# mean and sd fingertips in ms
mean(gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot)
sd(gazeShifts_single[gazeShifts_single$tool == 0,]$gazeShift.ballSlot)
# mean & sd tweezers in ms
mean(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot)
sd(gazeShifts_single[gazeShifts_single$tool == 1,]$gazeShift.ballSlot)

# t-test for dual task condition 
gazeShifts_dual <- gazeShifts[gazeShifts$dual == 1,]
t.test(gazeShifts_dual[gazeShifts_dual$tool == 1,]$gazeshift.slotDisplay, gazeShifts_dual[gazeShifts_dual$tool == 0,]$gazeshift.slotDisplay,
       paired = TRUE)
# mean and sd fingertips in ms
lastShifts <- aggregate(. ~ participant + dual, median, na.rm = TRUE, na.action = NULL, data = coordination)
mean(lastShifts[lastShifts$dual == 1,]$gazeshift.slotDisplay, na.rm = TRUE)
sd(lastShifts[lastShifts$dual == 1,]$gazeshift.slotDisplay, na.rm = TRUE)
