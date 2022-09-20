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
Requires pullDataTrial.m, readoutTrialInfo.m, readoutGaze.m, readoutRawGaze.m, readoutEffector.m, readoutVigilanceTask.m.

- plotIndividualTrials.m
Contains info of which individual trials were used for single trial examples (Figures 1 and 2A-E).

- analyzePhaseDurations.m
Creates matrix with durations of different phase durations. Saves matlab structure to compare movement duration in different task 
conditions (comparePhaseDurations.R) and to use for normalized fixation probabilities plot (Figure 3).

-analyzeSpatioTemporalCoordination.m
Analyzes gaze shifts from ball to slot in single task and from the slot back to the display in dual task condition.
Stats are then calculated in R (compareGazeShifts.R).

- createPlotFigure2and3.m
Generates matlab plots of fixation probabilities and tool speed in a normalized time frame. Requires normalizeMovementsPhases.m

- createPlotsFigure4.m
Generates matlab plot of fixation pattern probability for different grasp modes (Figure 4B) and histograms of ball and 
slot fixations in dual task condition (4C). Histograms require histf.m.

- analyzeFixationSubGoals.m
Reads out ball and slot fixation onsets relative to reach onset and saves matlab structure for the general linear model (GLM)
GLM is then run in R (GLMmovementPhases.R).

- createPlotsFigure5.m
Generates matlab plots of fixation timing and duration relative to contact events in dual task condition separate for fingertips (5A)
and tweezers (5B). 

- createPlotsFigure6.m
Generates cumulative plots of ball and slot fixation on and offsets relative to events.

- createPlotsFigure7.m
Generates matlab plots of letter change occurance and letter detection task performance (panels A & B). 
Saves matlab structure to compare detection task performance in R (compareDetectionTask.R).
Creates the response time as a function of the last detected letter change before reach onset relative to the go signal (panels C & D)

- createPlotsFigure8.m
Generates matlab plots of the frequency of ball and slot fixations relative to the letter change for different fixation patterns. 

- createPlotsFigure9.m
Generates matlab plots of the probabilities to see or miss a letter change or be in the silent period and of 
ball and slot fixations relative to kinematicevents. Panels C-D focus on trials, in which letter changes occurred within 1 s before reach.
Panels E-F break down different fixation pattern.

- analyzePhasesFixationPattern.m
Reads out participant-wise phase lengths of each kinematic phase separated by the two most common fixation pattern for each grasp mode.
Stats are then run in R (comparePhasesFixationPatterns.R) 