library("R.matlab")
library("ez")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("phaseDurations.mat"))
colnames(phaseDurations) <- c("participant", "testID", "tool", "dual",
                              "reach", "ballPhase", "transport", "slotPhase", "return")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- NULL #redundant
phaseDurations$tool <- as.factor(phaseDurations$tool)
phaseDurations$dual <- as.factor(phaseDurations$dual)
# aggregate data per condition and participant
phases_aov <- aggregate(. ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = phaseDurations)
phases_aov <- cbind(phases_aov[,1:3], rowSums(phases_aov[,c(4:8)]))
colnames(phases_aov) <-  c("participant", "tool", "dual", "duration")
aov_all <- ezANOVA(data = phases_aov, dv=duration, wid=participant, within=.(tool, dual), type = 2)
# Anova Result
## $ANOVA
## Effect DFn DFd        F            p p<.05        ges
## 2      tool   1  10 41.94082 7.107147e-05     * 0.48344931
## 3      dual   1  10  3.63231 8.578884e-02       0.10452427
## 4 tool:dual   1  10  3.53465 8.951391e-02       0.03457213
# Because there is no effect of task load, we will compare phase duration for grasp modes separately
phases_compare <- aggregate(duration ~ participant + tool, mean, na.rm = TRUE, na.action = NULL, data = phases_aov)
duration_fingertips <- mean(phases_compare[phases_compare$tool == 0,]$duration)
sd_fingertips <- sd(phases_compare[phases_compare$tool == 0,]$duration)
duration_tweezers <- mean(phases_compare[phases_compare$tool == 1,]$duration)
sd_tweezers <- sd(phases_compare[phases_compare$tool == 1,]$duration)
