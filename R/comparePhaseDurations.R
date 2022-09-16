library("R.matlab")
library("ez")
library("lsr")
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
phases_ttest <- aggregate(. ~ participant + tool + dual, median, na.rm = TRUE, na.action = NULL, data = phaseDurations)
phases_ttest <- cbind(phases_ttest[,1:3], rowSums(phases_ttest[,c(4:10)]))
colnames(phases_ttest) <- c('participant', 'tool', 'dual','actionLength')
phases_single <- phases_ttest[phases_ttest$dual == 0,]
phases_dual <- phases_ttest[phases_ttest$dual == 1,]
# first calculate results for single task condition
# test the overall effect of phase length
t.test(phases_single[phases_single$tool == 1,]$actionLength, phases_single[phases_single$tool == 0,]$actionLength, paired = TRUE)
cohensD(phases_single[phases_single$tool == 1,]$actionLength, phases_single[phases_single$tool == 0,]$actionLength, method = 'paired')
# mean and sd fingertips
mean(phases_single[phases_single$tool == 0,]$actionLength)
sd(phases_single[phases_single$tool == 0,]$actionLength)
# mean and sd tweezers
mean(phases_single[phases_single$tool == 1,]$actionLength)
sd(phases_single[phases_single$tool == 1,]$actionLength)
# test the effect of each duration in separate t-tests
singlePhases <- phaseDurations[phaseDurations$dual == 0,]
single_t <- aggregate(. ~ participant + tool, median, na.rm = TRUE, na.action = NULL, data = singlePhases)
reach <- t.test(single_t[single_t$tool == 1,]$reach, single_t[single_t$tool == 0,]$reach, paired = TRUE)
reach$d <- cohensD(single_t[single_t$tool == 1,]$reach, single_t[single_t$tool == 0,]$reach, method = 'paired')
ballApproach <- t.test(single_t[single_t$tool == 1,]$ballApproach, single_t[single_t$tool == 0,]$ballApproach, paired = TRUE)
ballApproach$d <- cohensD(single_t[single_t$tool == 1,]$ballApproach, single_t[single_t$tool == 0,]$ballApproach, method = 'paired')
ballGrasp <- t.test(single_t[single_t$tool == 1,]$ballGrasp, single_t[single_t$tool == 0,]$ballGrasp, paired = TRUE)
ballGrasp$d <- cohensD(single_t[single_t$tool == 1,]$ballGrasp, single_t[single_t$tool == 0,]$ballGrasp, method = 'paired')
transport <- t.test(single_t[single_t$tool == 1,]$transport, single_t[single_t$tool == 0,]$transport, paired = TRUE)
transport$d <- cohensD(single_t[single_t$tool == 1,]$transport, single_t[single_t$tool == 0,]$transport, method = 'paired')
slotApproach <- t.test(single_t[single_t$tool == 1,]$slotApproach, single_t[single_t$tool == 0,]$slotApproach, paired = TRUE)
slotApproach$d <- cohensD(single_t[single_t$tool == 1,]$slotApproach, single_t[single_t$tool == 0,]$slotApproach, method = 'paired')
slotEntry <- t.test(single_t[single_t$tool == 1,]$slotEntry, single_t[single_t$tool == 0,]$slotEntry, paired = TRUE)
slotEntry$d <- cohensD(single_t[single_t$tool == 1,]$slotEntry, single_t[single_t$tool == 0,]$slotEntry, method = 'paired')
return <- t.test(single_t[single_t$tool == 1,]$return, single_t[single_t$tool == 0,]$return, paired = TRUE)
return$d <- cohensD(single_t[single_t$tool == 1,]$return, single_t[single_t$tool == 0,]$return, method = 'paired')
# write results in a table
ttestTable_single <- data.frame(c(reach$estimate, reach$parameter, reach$statistic, reach[3], reach$conf.int[1:2], reach$d))
ttestTable_single[2,1:7] <- data.frame(c(ballApproach$estimate, ballApproach$parameter, ballApproach$statistic, ballApproach[3], ballApproach$conf.int[1:2], ballApproach$d))
ttestTable_single[3,1:7] <- data.frame(c(ballGrasp$estimate, ballGrasp$parameter, ballGrasp$statistic, ballGrasp[3], ballGrasp$conf.int[1:2], ballGrasp$d))
ttestTable_single[4,1:7] <- data.frame(c(transport$estimate, transport$parameter, transport$statistic, transport[3], transport$conf.int[1:2], transport$d))
ttestTable_single[5,1:7] <- data.frame(c(slotApproach$estimate, slotApproach$parameter, slotApproach$statistic, slotApproach[3], slotApproach$conf.int[1:2], slotApproach$d))
ttestTable_single[6,1:7] <- data.frame(c(slotEntry$estimate, slotEntry$parameter, slotEntry$statistic, slotEntry[3], slotEntry$conf.int[1:2], slotEntry$d))
ttestTable_single[7,1:7] <- data.frame(c(return$estimate, return$parameter, return$statistic, return[3], return$conf.int[1:2], return$d))
ttestTable_single$pBonf = p.adjust(ttestTable_single$p.value, method = "bonferroni")
ttestTable_single$pHolm = p.adjust(ttestTable_single$p.value, method = "holm")
names(ttestTable_single) <- c("meanDiff", "df", "t", "pUncorr", "ciLower", "ciUpper", "cohensD", "pBonf", "pHolm")

# now calculate results for dual task condition
# test the overall effect of phase length
t.test(phases_dual[phases_dual$tool == 1,]$actionLength, phases_dual[phases_dual$tool == 0,]$actionLength, paired = TRUE)
cohensD(phases_dual[phases_dual$tool == 1,]$actionLength, phases_dual[phases_dual$tool == 0,]$actionLength, method = 'paired')
# mean and sd fingertips
mean(phases_dual[phases_dual$tool == 0,]$actionLength)
sd(phases_dual[phases_dual$tool == 0,]$actionLength)
# mean and sd tweezers
mean(phases_dual[phases_dual$tool == 1,]$actionLength)
sd(phases_dual[phases_dual$tool == 1,]$actionLength)
# test the effect of each duration in separate t-tests
dualPhases <- phaseDurations[phaseDurations$dual == 1,]
dual_t <- aggregate(. ~ participant + tool, median, na.rm = TRUE, na.action = NULL, data = dualPhases)
reach <- t.test(dual_t[dual_t$tool == 1,]$reach, dual_t[dual_t$tool == 0,]$reach, paired = TRUE)
reach$d <- cohensD(dual_t[dual_t$tool == 1,]$reach, dual_t[dual_t$tool == 0,]$reach, method = 'paired')
ballApproach <- t.test(dual_t[dual_t$tool == 1,]$ballApproach, dual_t[dual_t$tool == 0,]$ballApproach, paired = TRUE)
ballApproach$d <- cohensD(dual_t[dual_t$tool == 1,]$ballApproach, dual_t[dual_t$tool == 0,]$ballApproach, method = 'paired')
ballGrasp <- t.test(dual_t[dual_t$tool == 1,]$ballGrasp, dual_t[dual_t$tool == 0,]$ballGrasp, paired = TRUE)
ballGrasp$d <- cohensD(dual_t[dual_t$tool == 1,]$ballGrasp, dual_t[dual_t$tool == 0,]$ballGrasp, method = 'paired')
transport <- t.test(dual_t[dual_t$tool == 1,]$transport, dual_t[dual_t$tool == 0,]$transport, paired = TRUE)
transport$d <- cohensD(dual_t[dual_t$tool == 1,]$transport, dual_t[dual_t$tool == 0,]$transport, method = 'paired')
slotApproach <- t.test(dual_t[dual_t$tool == 1,]$slotApproach, dual_t[dual_t$tool == 0,]$slotApproach, paired = TRUE)
slotApproach$d <- cohensD(dual_t[dual_t$tool == 1,]$slotApproach, dual_t[dual_t$tool == 0,]$slotApproach, method = 'paired')
slotEntry <- t.test(dual_t[dual_t$tool == 1,]$slotEntry, dual_t[dual_t$tool == 0,]$slotEntry, paired = TRUE)
slotEntry$d <- cohensD(dual_t[dual_t$tool == 1,]$slotEntry, dual_t[dual_t$tool == 0,]$slotEntry, method = 'paired')
return <- t.test(dual_t[dual_t$tool == 1,]$return, dual_t[dual_t$tool == 0,]$return, paired = TRUE)
return$d <- cohensD(dual_t[dual_t$tool == 1,]$return, dual_t[dual_t$tool == 0,]$return, method = 'paired')
# write results in a table
ttestTable_dual <- data.frame(c(reach$estimate, reach$parameter, reach$statistic, reach[3], reach$conf.int[1:2], reach$d))
ttestTable_dual[2,1:7] <- data.frame(c(ballApproach$estimate, ballApproach$parameter, ballApproach$statistic, ballApproach[3], ballApproach$conf.int[1:2], ballApproach$d))
ttestTable_dual[3,1:7] <- data.frame(c(ballGrasp$estimate, ballGrasp$parameter, ballGrasp$statistic, ballGrasp[3], ballGrasp$conf.int[1:2], ballGrasp$d))
ttestTable_dual[4,1:7] <- data.frame(c(transport$estimate, transport$parameter, transport$statistic, transport[3], transport$conf.int[1:2], transport$d))
ttestTable_dual[5,1:7] <- data.frame(c(slotApproach$estimate, slotApproach$parameter, slotApproach$statistic, slotApproach[3], slotApproach$conf.int[1:2], slotApproach$d))
ttestTable_dual[6,1:7] <- data.frame(c(slotEntry$estimate, slotEntry$parameter, slotEntry$statistic, slotEntry[3], slotEntry$conf.int[1:2], slotEntry$d))
ttestTable_dual[7,1:7] <- data.frame(c(return$estimate, return$parameter, return$statistic, return[3], return$conf.int[1:2], return$d))
ttestTable_dual$pBonf = p.adjust(ttestTable_dual$p.value, method = "bonferroni")
ttestTable_dual$pHolm = p.adjust(ttestTable_dual$p.value, method = "holm")
names(ttestTable_dual) <- c("meanDiff", "df", "t", "pUncorr", "ciLower", "ciUpper", "cohensD", "pBonf", "pHolm")
