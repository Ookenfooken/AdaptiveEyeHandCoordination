library("R.matlab")
library("ez")
library("lsr")
# set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# load in data
ballFixFunction = data.frame(readMat("ballFixFunction.mat"))
colnames(ballFixFunction) <- c("testID", "function", "ballProbability")
slotFixFunction = data.frame(readMat("slotFixFunction.mat"))
colnames(slotFixFunction) <- c("testID", "function", "slotProbability")