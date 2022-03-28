# CoreMap Data Scientist Candidate Homework Problem by Scott Stearns

This repository is to provide documentation of the CoreMap DataScientist Candidate Homework. 

### FOLDERS

#### CoreMap_Homework
Main scripts run from this directory.

**EventDetector.m**  This script runs the detection and event qualification algorithms and outputs the results to a .csv file:
EventDetectionOutputs.csv. The file contains the results for all High or Indeterminant level candidate events.

**verifyEventDetection.m**  This script displays the signals, candidate events and their confidence levels for
candidate events. It does not output the results.

**validateEventDetection.m** This script reads the EventDetectionOutputs.csv file, plots the clean signals and displays the event times
graphically with a vertical bar.  

**StackplotSubarry.m** This scripts allow the user to select a row or column of the subarray and displays a stackplot of the signals
in that subarray. This can be used to look for patterns in the arrivals of events across neighboring elements of the array. This is
a good candidate for refactoring as a helper function to include with the +Utilities folder. 

**VisualizeInTime.m** This script displays and optionally records a video of the array response shown over time. This video shows
8 distict bursts or waves of activity across the array.

**PreprocessArrayData.m** This script take the original data, cleans the signals and saves them in ArraySignals.mat. This eliminates
the need to reprocess the signals helps ensure the results are consistent as the algorithm is being developed. 


#### Utilities 
Mission-specific utilities for scripts that provide solutions to the Homework deliverables. 

**NOTE:** Enter: `> import Utilities.*` from the prompt if you want to call these functions from the Command Window. 

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
and red respectively in the **verifyEventDetection.m** script. This was the main script for developing the event detection method. The
EventDetector.m script is the main script to implement the method and record the results.  

**NOTES:**
* In some cases, some asymmetry in the candidate waveform will shift the detection time away from the time of the third sample. For 
genuine candidates that are symmetric around zero this shift is zero. This is due to the linear interpolation that is used to determine
the event time, rather than simply taking the time of the third sample time. 

![Figure 0.](Images/AsymEvent.png?raw=true)

* Indeterminant events (see below) have a different morphology and are included in the list of detected events, although their confidence
levels are lower than the genuine events. For these, the time of the peak absolute value is used for the event time. 

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

Here we can see a significant DC component and narrowband interferent at about 50 Hz and a lower level of narrowband noise below 20 Hz.
The signals appear to be bandlimited near the Nyquist frequency indicating aliasing from out of band energy is sufficiently attenuated.  

![Figure 1.](Images/NoiseFigure1.png?raw=true)

To preprocess the signals, the mean was removed and the demeaned signal was highpass filtered with fc = 70 Hz. This provided a signal that
was clean enough for the event detection algorithm. Note, demeaning the signal before filtering reduced the ringing at the edges of the 
signal, the residuals of which are seen here. This edge effect of the filtering in the time domain leads to some false positives in the
event detection algorithm. 

![Figure 2.](Images/NoiseFigure2.png?raw=true)


**Here we see the signal after the complete detection process.** Interfering noise has been sufficiently attenuated. The color coding of
event detections described above is displayed. Note the event detections due to the ringing at the edges of the signal are rejected by
the matched filter qualification step. Also note the blue event. This is interesting and represents a distinct morphology that appears
in all the signals. Although they do not correlate as well with the wavelet template compared to the green, fully qualified as 
genuine events, they do have a strong correlation around 0.80 which is distictly higher than the clearly non-genuine red events. Also, 
these intermediate 'indeterminant' events have a clearly distinctive pattern that is clear in the spectrograms. 
Wonder if these are physiologically relevant?


![Figure 3.](Images/Figure1.png?raw=true)


### Part III: EVENT PATTERNS 

**Here are stack plots of subarrays.** One displays the signals in a vertical subarray and the other in a horizontal subarray. 
It is possible to find possible patterns in the events. For example in Column 2, Rows 5 and 6. From about t=0.25 to t=0.375, there 
appears to be a tiplet of arrivals: one genuine followed by an 'indeterminant' and genuine that are more closely space. This triplet 
appears on Row 6, but delayed by about 90-100 ms, and the 'indeterminant' event is inverted on Row 6. When inspecting the neighbors of
Column 2 on the Row 6 stack plot, the triple does not appear in Columns 1 or 3. 

Okay.. Visual inspection like this may yeild similar observances, but in general the events appear fairly randomly (Poisson) distributed 
both temporally and spatially when visualizing the entire subarray. And, these observations are not altering the degree of confidence 
that the events are genuine. 

![Figure 4.](Images/Column2.png?raw=true)  ![Figure 5.](Images/Row6.png?raw=true)


**Here is a video of the array sensor responses over time...**
The video will play in the GitHub repo README for the project. To get the most out of the video, it is best to open the Images/Video02.mp4 outside of the GitHub or MATLAB environments. For example,
QuickTimePlayer (on the Mac) allows the viewer to step forward and backward through frames using the right and left arrow keys. This 
is interesting in that individual events appear to arrive and move relative to the array geometry. For example, if the array is stationary, 
then the events appear to be propagating. Look for example, at time steps 0.561 through 0.564. Events appear in the southwest and appear
to move relative to the array northward. 

The video shows (at least) 8 distinct bursts or waves of activity across the array. The activity bursts last about 10 ms and are separated
by longer periods of quiet or individual events that are random (Poisson) arrivals in both time and space. This activity is difficult
to identify in looking at stack plots of the subarray signals. However, they jump out in the video visualization. This could be a feature
for 'ignoring' random events even when they are locally highly correlated with the wavelet template. 

To determine if these observations are physiological or artifacts of the study, a time-space processing approach that is more advanced
than what is presented here may be helpful. For example, beamforming may be useful to focus locally on near-field signals and reject
far-field events that are correlated but not of interest. And, more advanced beamformers can steer nulls at interferers - improving
detection and tracking. Also, although the spatial sampling is limited for this array, it may be useful to look at 2D Fourier transforms
in temporal and spatial frequencies (wavenumber), (w, k) space. 

https://user-images.githubusercontent.com/97293473/160130707-1f125a6d-5116-414b-b431-b9b74b4cc3ea.mp4


### Part IV: MACHINE LEARNING

**What features would be useful?**
For the detection problem, we could imagine features that provide local information about the events, as well as the relationship of
the event to other events in the measurements. For example, are the features extracted from an event that is part of a cluster in time
or spatially on the array. Local features might include correlation coefficient with a wavelet template, amplitude, symmetry, rise time,
deflection direction, and overall duration. Also, we saw the t-f spectrogram of the 'indeterminants' were characteristic and distinct 
from the 'genuine' events. 

For non-local features, we would want to have a measure of whether the events are part of a burst in time or spatially. Intermittent
random events that occur between bursts of activity across the array might be considered false positives. 
 
**What ML methods would be useful?** 
This is the realm of classification as opposed to regression. Since we are working with a labeled data set, supervised learning would
be used. Support Vector Machines (SVM) tend to have trouble with very large data sets and the basic implementation is for binary 
classification problems and not multiclass problems, and do not provide a probalistic output or confidence level. Similarly, nearest
neighbor methods like kNN may have trouble with large data sets. Decision trees tend to have problems generalizing and so validation
may be a problem. Other methods are worth looking at. For example Naive Bayes classifiers work well with low dimensionality feature
vectors (fewer features), and will provide multiclass probabilities. 

Artificial Neural Networks and Deep Learning methods are good especially for multiclass problems and in cases like
this where there is a large training set. Also, these can be computationally very fast once trained and will provide a score or 
confidence level to rank the resulting outputs. 

**Benefits relative to classical signal processing techniques?**
I think both should work together. Preprocessing, normalization, PCA, correlations, transforms, and so on are all based on traditional
signal processing and provide critical improvements in the performance of classifiers in general. 


