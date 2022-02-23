This repository contains script to view and process data collected in a project on 
adaptive eye-hand coordination when manipulating and monitoring the environment in parallel
All data-related analyses were performed in Matlab. All statistics were done in R.
Please note that figures were initially generated in Matlab and then post-processed in illustrator.

- ExperimentInfo.xlsx
Contains relevant information about variables in the raw data, coordinates of the landmarks, and how kinematic phases were classified

- dropList.csv
Contains information in order of participant ID, block ID, and trial ID of trials, in which the ball was dropped 
(determined by visual inspection)

- createMatFiles.m
Converts raw eye and hand movement data into matlab structures that are used for all further analysis. 

- createDisplayFiles.m
Converts raw vigilance task data into matlab structures that are used for all further analysis. 

- visualizeData.m
Allows to view eye and hand movement data for each participant and trial. 
Requires prepareData.m, plotData.m, createBallVector.m, and gazePositionRaw.m

- pullExperimentInfo.m
Saves relevant trial information into more descriptive data format (pulledData.mat) that is used for further analysis
Requires pullDataTrial.m, readoutTrialInfo.m, readoutGaze.m, readoutEffector.m, readoutVigilanceTask

- plotIndividualTrials.m
Contains info of which individual trials were used for single trial examples.

- analyzePhaseDurations.m
Creates matrix with durations of different phase durations. Creates structure to compare movement duration in different task conditions
(comparePhaseDurations.R) and to use for normalized fixation probabilities plot (Figure 2).

- createPlotFigure2.m
Generates matlab plots of fixation probabilities and tool speed in a normalized time frame. Requires normalizeMovementsPhases.m

- analyzeFixationSubGoals.m
Reads out ball and slot fixation onsets relative to reach onset and saves matlab structure for the general linear model (GLM)
GLM can then be run in R (GLMmovementPhases.R)

- createPlotsFigure3.m
Generates matlab plots of fixation timing and duration in dual task condition. Histograms require histf.m