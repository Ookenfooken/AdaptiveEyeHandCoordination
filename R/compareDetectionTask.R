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
