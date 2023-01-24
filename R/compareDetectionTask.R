library("R.matlab")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
detectionTask = data.frame(readMat("letterDetectAverage.mat"))
colnames(detectionTask) <- c("participant", "testID", "letterDetected")
detectionTask$participant <- as.factor(detectionTask$participant)
detectionTask$testID <- as.factor(detectionTask$testID)
# compare detection task performance
# fingertips
mean(detectionTask[detectionTask$testID == 3,]$letterDetected)
sd(detectionTask[detectionTask$testID == 3,]$letterDetected)
# tweezers
mean(detectionTask[detectionTask$testID == 4,]$letterDetected)
sd(detectionTask[detectionTask$testID == 4,]$letterDetected) 
# t-test
t.test(detectionTask[detectionTask$testID == 3,]$letterDetected, detectionTask[detectionTask$testID == 4,]$letterDetected, paired = TRUE)
