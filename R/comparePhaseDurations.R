library("R.matlab")
library("ez")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("phaseDurations.mat"))
colnames(phaseDurations) <- c("participant", "testID", "tool", "dual",
                              "reach", "ballApproach", "ballGrasp", "transport",
                              "slotApproach", "slotEntry", "return")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- NULL #redundant
phaseDurations$tool <- as.factor(phaseDurations$tool)
phaseDurations$dual <- as.factor(phaseDurations$dual)
# aggregate data per condition and participant
phases_aov <- aggregate(. ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = phaseDurations)
phases_aov <- cbind(phases_aov[,1:3], rowSums(phases_aov[,c(4:10)]))
colnames(phases_aov) <-  c("participant", "tool", "dual", "duration")
aov_all <- ezANOVA(data = phases_aov, dv=duration, wid=participant, within=.(tool, dual), type = 3)
# Anova Result
## $ANOVA
## Effect DFn DFd         F            p p<.05        ges
## 2      tool   1  10 41.345849 7.537003e-05     * 0.46528096
## 3      dual   1  10  1.763796 2.136658e-01       0.05934917
## 4 tool:dual   1  10  2.145116 1.737421e-01       0.02119980
# Because there is no effect of task load, we will compare phase duration for grasp modes separately
phases_compare <- aggregate(duration ~ participant + tool, mean, na.rm = TRUE, na.action = NULL, data = phases_aov)
duration_fingertips <- mean(phases_compare[phases_compare$tool == 0,]$duration)
sd_fingertips <- sd(phases_compare[phases_compare$tool == 0,]$duration)
duration_tweezers <- mean(phases_compare[phases_compare$tool == 1,]$duration)
sd_tweezers <- sd(phases_compare[phases_compare$tool == 1,]$duration)

# test which phases drive the difference in timing
phases_compare <- aggregate(. ~ participant + tool, median, na.rm = TRUE, na.action = NULL, data = phaseDurations)
t.test(phases_compare[phases_compare$tool == 0,]$reach, phases_compare[phases_compare$tool == 1,]$reach, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$ballApproach, phases_compare[phases_compare$tool == 1,]$ballApproach, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$ballGrasp, phases_compare[phases_compare$tool == 1,]$ballGrasp, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$transport, phases_compare[phases_compare$tool == 1,]$transport, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$slotApproach, phases_compare[phases_compare$tool == 1,]$slotApproach, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$slotEntry, phases_compare[phases_compare$tool == 1,]$slotEntry, paired = TRUE)
t.test(phases_compare[phases_compare$tool == 0,]$return, phases_compare[phases_compare$tool == 1,]$return, paired = TRUE)

# try mancova approach which may be better
# aggregate data per condition and participant
phases_mancova <- aggregate(. ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = phaseDurations)
phases_mancova$dual <- NULL
# run mancova
mancovaDuration <- manova(cbind(reach, ballApproach, ballGrasp, transport, slotApproach, slotEntry) ~ 
                      tool, data = phases_mancova)
