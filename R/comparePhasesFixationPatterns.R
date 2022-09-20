library("R.matlab")
library("lsr")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
phaseDurations = data.frame(readMat("fixationPatternPhases.mat"))
colnames(phaseDurations) <- c("testID", "participant", "fixationType",
                              "reach", "ballApproach", "ballGrasp",
                              "transport", "slotApproach", "slotEntry")
phaseDurations$participant <- as.factor(phaseDurations$participant)
phaseDurations$testID <- as.factor(phaseDurations$testID)
phaseDurations$fixationType <- as.factor(phaseDurations$fixationType)
# look at fingertips first
phaseDurations_FT <- phaseDurations[phaseDurations$testID == 3,]
phaseDurations_FT$testID <- NULL
# run t-tests
reach <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$reach, 
                phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$reach, paired = TRUE)
reach$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$reach, 
                   phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$reach, method = 'paired')
ballApproach <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$ballApproach, 
                       phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$ballApproach, paired = TRUE)
ballApproach$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$ballApproach, 
                          phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$ballApproach, method = 'paired')
ballGrasp <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$ballGrasp, 
                    phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$ballGrasp, paired = TRUE)
ballGrasp$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$ballGrasp, 
                       phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$ballGrasp, method = 'paired')
transport <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$transport, 
                    phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$transport, paired = TRUE)
transport$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$transport, 
                       phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$transport, method = 'paired')
slotApproach <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotApproach, 
                       phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotApproach, paired = TRUE)
slotApproach$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotApproach, 
                          phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotApproach, method = 'paired')
slotEntry <- t.test(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotEntry, 
                    phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotEntry, paired = TRUE)
mean(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotEntry)
sd(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotEntry)
mean(phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotEntry)
sd(phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotEntry)
slotEntry$d <- cohensD(phaseDurations_FT[phaseDurations_FT$fixationType == 0,]$slotEntry, 
                       phaseDurations_FT[phaseDurations_FT$fixationType == 2,]$slotEntry, method = 'paired')
# write results in a table
ttestTable_FT <- data.frame(c(reach$estimate, reach$parameter, reach$statistic, reach[3], reach$conf.int[1:2], reach$d))
ttestTable_FT[2,1:7] <- data.frame(c(ballApproach$estimate, ballApproach$parameter, ballApproach$statistic, ballApproach[3], ballApproach$conf.int[1:2], ballApproach$d))
ttestTable_FT[3,1:7] <- data.frame(c(ballGrasp$estimate, ballGrasp$parameter, ballGrasp$statistic, ballGrasp[3], ballGrasp$conf.int[1:2], ballGrasp$d))
ttestTable_FT[4,1:7] <- data.frame(c(transport$estimate, transport$parameter, transport$statistic, transport[3], transport$conf.int[1:2], transport$d))
ttestTable_FT[5,1:7] <- data.frame(c(slotApproach$estimate, slotApproach$parameter, slotApproach$statistic, slotApproach[3], slotApproach$conf.int[1:2], slotApproach$d))
ttestTable_FT[6,1:7] <- data.frame(c(slotEntry$estimate, slotEntry$parameter, slotEntry$statistic, slotEntry[3], slotEntry$conf.int[1:2], slotEntry$d))
ttestTable_FT$pBonf = p.adjust(ttestTable_FT$p.value, method = "bonferroni")
ttestTable_FT$pHolm = p.adjust(ttestTable_FT$p.value, method = "holm")
names(ttestTable_FT) <- c("meanDiff", "df", "t", "pUncorr", "ciLower", "ciUpper", "cohensD", "pBonf", "pHolm")

# look at tool trials
phaseDurations_TW <- phaseDurations[phaseDurations$testID == 4,]
phaseDurations_TW$testID <- NULL
# run t-tests
reach <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$reach, 
                phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$reach, paired = TRUE)
reach$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$reach, 
                   phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$reach, method = 'paired')
ballApproach <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$ballApproach, 
                       phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$ballApproach, paired = TRUE)
ballApproach$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$ballApproach, 
                          phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$ballApproach, method = 'paired')
ballGrasp <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$ballGrasp, 
                    phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$ballGrasp, paired = TRUE)
ballGrasp$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$ballGrasp, 
                       phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$ballGrasp, method = 'paired')
transport <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$transport, 
                    phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$transport, paired = TRUE)
mean(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$transport)
sd(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$transport)
mean(phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$transport)
sd(phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$transport)
transport$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$transport, 
                       phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$transport, method = 'paired')
slotApproach <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$slotApproach, 
                       phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$slotApproach, paired = TRUE)
slotApproach$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$slotApproach, 
                          phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$slotApproach, method = 'paired')
slotEntry <- t.test(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$slotEntry, 
                    phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$slotEntry, paired = TRUE)
slotEntry$d <- cohensD(phaseDurations_TW[phaseDurations_TW$fixationType == 3,]$slotEntry, 
                       phaseDurations_TW[phaseDurations_TW$fixationType == 4,]$slotEntry, method = 'paired')

# write results in a table
ttestTable_TW <- data.frame(c(reach$estimate, reach$parameter, reach$statistic, reach[3], reach$conf.int[1:2], reach$d))
ttestTable_TW[2,1:7] <- data.frame(c(ballApproach$estimate, ballApproach$parameter, ballApproach$statistic, ballApproach[3], ballApproach$conf.int[1:2], ballApproach$d))
ttestTable_TW[3,1:7] <- data.frame(c(ballGrasp$estimate, ballGrasp$parameter, ballGrasp$statistic, ballGrasp[3], ballGrasp$conf.int[1:2], ballGrasp$d))
ttestTable_TW[4,1:7] <- data.frame(c(transport$estimate, transport$parameter, transport$statistic, transport[3], transport$conf.int[1:2], transport$d))
ttestTable_TW[5,1:7] <- data.frame(c(slotApproach$estimate, slotApproach$parameter, slotApproach$statistic, slotApproach[3], slotApproach$conf.int[1:2], slotApproach$d))
ttestTable_TW[6,1:7] <- data.frame(c(slotEntry$estimate, slotEntry$parameter, slotEntry$statistic, slotEntry[3], slotEntry$conf.int[1:2], slotEntry$d))
ttestTable_TW$pBonf = p.adjust(ttestTable_TW$p.value, method = "bonferroni")
ttestTable_TW$pHolm = p.adjust(ttestTable_TW$p.value, method = "holm")
names(ttestTable_TW) <- c("meanDiff", "df", "t", "pUncorr", "ciLower", "ciUpper", "cohensD", "pBonf", "pHolm")

