library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
detectionTask = data.frame(readMat("letterDetectViewTime.mat"))
colnames(detectionTask) <- c("participant", "testID", "displayViewTime", "letterDetected")
detectionTask$participant <- as.factor(detectionTask$participant)
detectionTask$testID <- as.factor(detectionTask$testID)
# compare detection task performance
detection_mean <- mean(detectionTask$letterDetected) 
detection_sd <- sd(detectionTask$letterDetected) 
t.test(detectionTask[detectionTask$testID == 3,]$letterDetected, detectionTask[detectionTask$testID == 4,]$letterDetected, paired = TRUE)
# correlation between detection task and display viewing time
# for fingertips
detection_FT <- detectionTask[detectionTask$testID == 3,]
summary(lm(detection_FT$letterDetected~detection_FT$displayViewTime))
cor(detection_FT$letterDetected,detection_FT$displayViewTime)
# for tweezers
detection_TW <- detectionTask[detectionTask$testID == 4,]
summary(lm(detection_TW$letterDetected~detection_TW$displayViewTime))
cor(detection_TW$letterDetected,detection_TW$displayViewTime)
