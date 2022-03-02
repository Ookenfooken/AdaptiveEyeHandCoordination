This repository contains script to view and process data collected in a project on 
adaptive eye-hand coordination when manipulating and monitoring the environment in parallel
All data-related analyses were performed in Matlab. All statistical analyses were done in R.
Please note that figures were initially generated in Matlab and then post-processed with illustrator.

- ExperimentInfo.xlsx
Contains relevant information about variables in the raw data, coordinates of the landmarks, and how kinematic phases were classified.

- dropList.csv
Contains information in order of participant ID, block ID, and trial ID of trials, in which the ball was dropped 
(determined by visual inspection).

- createMatFiles.m
Converts raw eye and hand movement data into matlab structures that are used for all further analysis. 

- createDisplayFiles.m
Converts raw vigilance task data into matlab structures that are used for all further analysis. 

- visualizeData.m
Allows to view eye and hand movement data for each participant and trial. 
Requires prepareData.m, plotData.m, createBallVector.m, and gazePositionRaw.m

- pullExperimentInfo.m
Saves relevant trial information into more descriptive data format (pulledData.mat) that is used for further analysis
Requires pullDataTrial.m, readoutTrialInfo.m, readoutGaze.m, readoutEffector.m, readoutVigilanceTask.m.

- plotIndividualTrials.m
Contains info of which individual trials were used for single trial examples (Figure 1 and 5A).

- analyzePhaseDurations.m
Creates matrix with durations of different phase durations. Saves matlab structure to compare movement duration in different task 
conditions (comparePhaseDurations.R) and to use for normalized fixation probabilities plot (Figure 2).

-analyzeSpatioTemporalCoordination.m
Analyzes gaze shifts from ball to slot in single task and from the slot back to the display in dual task condition.
Stats are then calculated in R (compareGazeShifts.R).

- createPlotFigure2.m
Generates matlab plots of fixation probabilities and tool speed in a normalized time frame. Requires normalizeMovementsPhases.m

- analyzeFixationSubGoals.m
Reads out ball and slot fixation onsets relative to reach onset and saves matlab structure for the general linear model (GLM)
GLM is then run in R (GLMmovementPhases.R).

- createPlotsFigure3.m
Generates matlab plots of fixation timing and duration in dual task condition. Histograms require histf.m.

- createPlotsFigure4.m
Generates matlab plots of letter detection task performance and eye and hand movement adaptation relative to letter change. 
Saves matlab structure to compare detection task performance in R (compareDetectionTask.R).

- createPlotsFigure5.m
Generates matlab plots of different fixation types in grasp modes and relative to the time of letter change. 