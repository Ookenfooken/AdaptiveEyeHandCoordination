library("R.matlab")
library("ez")
library("lsr")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
ballFixFunction = data.frame(readMat("ballFixFunction.mat"))
colnames(ballFixFunction) <- c("testID", "patID", "functType", "fixType", "probability")
slotFixFunction = data.frame(readMat("slotFixFunction.mat"))
colnames(slotFixFunction) <- c("testID", "patID", "functType", "fixType", "probability")
slotFixFunction$testID <- as.factor(slotFixFunction$testID)
slotFixFunction$patID <- as.factor(slotFixFunction$patID)
slotFixFunction$functType <- as.factor(slotFixFunction$functType)

tweezerData <- rbind(ballFixFunction, slotFixFunction)
tweezerData <- tweezerData[tweezerData$testID == 4,]
tweezerData$testID <- NULL
tweezerData$patID <- as.factor(tweezerData$patID)
tweezerData$functType <- as.factor(tweezerData$functType)
tweezerData$fixType <- as.factor(tweezerData$fixType)

TW_aov <- ezANOVA(data = tweezerData, dv=probability, wid=patID, within=.(functType, fixType), type = 2)

slotFixFunction$fixType <- NULL
# remove participant 11
slotFixFunction <- slotFixFunction[-c(11,22,33,44, 55, 66),]
slot_aov <- ezANOVA(data = slotFixFunction, dv=probability, wid=patID, within=.(testID, functType), type = 2)
