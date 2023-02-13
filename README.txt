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
Stats are then calculated in R (compareGazeShiftsAndDurations.R).

- createPlotFigure2and3.m
Generates matlab plots of fixation probabilities and tool speed in a normalized time frame for single task condition (2A&D) and
dual task condition (3C&D). Requires normalizeMovementsPhases.m. Also plots distribution of fixation patterns (3F).

- analyzeFixationSubGoals.m
Reads out ball and slot fixation onsets relative to reach onset and saves matlab structure for the general linear model (GLM)
GLM is then run in R (GLMmovementPhases.R).

- createPlotsFigure4.m
Generates matlab plots of ball and slot fixation timing relative to ball contact and slot entry, respectively, separate for 
fingertips (4A&C) and tweezers (4B&D). Timing of all kinematic events is also indicated. 

- createPlotsFigure5.m
Generates matlab plots of fixation onset and offset relative to contact events in dual task condition (5A-H) and plots indicating
the function gaze served in fingertip and tweezer trials (5I-K). 

- createPlotsFigure6.m
Generates matlab plot of detected letter changes relative to the time of cue (6A&B), and distribution of reach onsets relative to 
last detected letter change (6C&D). Saves 'letterDetectViewTime.mat' to analyze task performance in R (compareDetectionTask.R).

- createPlotsFigure7.m
Generates matlab plots of distributions of ball and slot fixation onsets relative to last detected letter change for fingertip (7A-D)
and tweezer (7E-H) trials. Panels indicate different fixation patterns. Distributions are tested with ks-test for uniformity. 

- createPlotsFigure8.m
Generates matlab plots of distributions of fixation patterns relative to letter changes that are detected prior to slot entry (8A) or
ball contact (8B&C).  

- analyzePhasesFixationPattern.m
Reads out participant-wise phase lengths of each kinematic phase separated by the two most common fixation pattern for each grasp mode.
Stats are then run in R (comparePhasesFixationPatterns.R) 