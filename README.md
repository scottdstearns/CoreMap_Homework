# CoreMap Data Scientist Candidate Homework Problem by Scott Stearns

This repository is to provide documentation of the CoreMap DataScientist Candidate Homework. 

### FOLDERS

#### CoreMap_Homework
Main scripts run from this directory.

**verifyEventDetection.m**  This script displays the signals, candidate events and their confidence levels and the zero crossings for
events determined to be genuine. 

#### Utilities 
Mission-specific utilities for scripts that provide solutions to the Homework deliverables.

To get help enter: `> help Utilities` at the prompt for detailed help. Or help on any of these functions. 

**getSignals** - Function to return raw data structure with 12x9 array of sensors data. 

**egTemplate** - Returns a 5 sample EG waveform model for use as a matched filter.


### Part I: EVENT DETECTION

#### Summary of Method of Detection

The signals were organized into NxK matrix, where K = MxP, M is the number of rows and P is the number of colums in a sensor array. 
Each signal was preprocessed to eliminate noise and facilitate the event detections. This consisted of subtracting the mean and applying
a bandpass filter. The filter parameters were set based in a cursory review of the spectral content of some of the signals and included
as parameters in the code. 

A peak picking algorithm was applied to the cleaned up signals. Again, experimentation and visualization of the signals was done to 
select the parameters for the peak finder. The parameters include a minimum height threshold for a derived version of the signal and a
threshold for the minimum distance between peaks. These parameters are included in the code. The peak finding method was verified by 
visual inspection of all 108 signals. 

For each peak identified, a window of 5 neighboring samples was selected as a candidate event waveform. To qualify the event a matched
filter was applied. The matched filters were generated with the **egTemplate()** helper function. This function returns a 5 sample wavelet
corresponding to the waveforms described in the Problem Overview. The amplitude of the signal at the peak was used to scale the wavelet. 
The wavelet and candidate event waveform were crosscorrelated and the resulting correlation coefficient was retained as a quantitative
assessment of the confidence that the event is genuine. 

The confidence indices generally fell into three ranges: >0.9 , 0.5-0.9, and <0.5. These were qualitatively color coded as green, blue
and red respectively in the **verifyEventDetection.m** script. This is the main script for the event detection part of the homework. 

#### Description of Key Parameters

**fpass** - Bandpass filter pass band frequencies in Hz. These were set by visual inspection of the signal spectra and experimenting with 
the verifyEventDetection.m script. The lower end of the pass band was set to eliminate very large narrowband interference at around 
50 Hz. The upper end of the pass band was kept at Nyquist to help preserve the time sharpness of the event peaks for detection. 

**peakThreshold** - Threshold set by visual inspection of the entire signal set and trial and error. The signals have been manipulated
to help improve the performance of the peak finder algorithm. If the threshold is too high, the lower amplitude events would be missed. 
If the threshold is too low, too many false candidate events would be found and increase the risk of false positives. 

**minPeakDistance** - This threshold is set to define a *refractory period* in a sense between peaks. This prevents too many peaks from
being detected within a very small time window making downstream processing more difficult. It allows a minimum time between peak that
can be set based on physiological constraints or visualization and trial and error. 

**highConfidenceThreshold** - Correlation coefficients above this threshold in the matched filtering are accepted as genuine. As with other
key parameters this was set by visualization and trial and error. It was not difficult to separate the levels into three categories for
the entire signal set. 

**lowConfidenceThreshold** - Correlation coefficients below this threshold in the matched filtering are not accepted as genuine. 

**NOTE:** 
The events fell distinctly into three categories:
* Genuine events that are highly correlated with a properly scaled template
* Non-genuine, rejected events that have very low correlations with the template, and
* Indeterminant events. These have a clear morphology and have confidence values in the 0.7 or so range. These events are non-physiological
but appear consistently (with positive or negative deflections) in the signal set. 

**Summary:** Overall the detection system works very well. Without a standard or ground truth regarding where the true events are in
the signals, only a subjective assessment is provided here. The filtering, peak detection and matched filter processes appear to be very
robust and result in clean identification of these types of events. 

### Part II: WAVEFORM DESCRIPTION

The following figures display some of the noise or interference in the signals. 

![Figure 1.](Images/Figure1.png?raw=true)

**Here is a video of the array sensor responses over time...**
To get the most out of the video, it is best to open the Images/Video02.mp4 outside of the GitHub or MATLAB environments. For example,
QuickTimePlayer (on the Mac) allows the viewer to step forward and backward through frames using the right and left arrow keys. This 
is interesting in that individual events appear to arrive and move relative to the array geometry. For example, if the array is stationary, 
then the events appear to be propagating. Look for example, at time steps 0.561 through 0.564. Events appear in the southwest and appear
to move relative to the array northward. Or maybe it's star gazing and random... 

https://user-images.githubusercontent.com/97293473/160130707-1f125a6d-5116-414b-b431-b9b74b4cc3ea.mp4





