# Han_et_al_2026
The current code repository contains MATLAB codes used for Han et al. (2026). 

## 1. Vocal Recording and Call Statistic Analysis
- Prior to analysis, we used simple MATLAB codes for basic processing of audio files, such as separating multichannel audios into mono audios, batch reading file names etc.
- Call statistics, including structural information and acoustic properties, were extracted using [DeepSqueak](https://github.com/DrCoffey/DeepSqueak) and custom MATLAB programs. It is adviced to train your own marmoset vocalization identification and labeling model in DeepSqueak.

## 2. Stimuli Generation
- To generate trill-like FM stimuli, we extracted estimated f0 from a 450 ms duration trill call (included in the folder). The result f0 was then processed smoothing it with a Gaussian kernel (σ = 5 ms), and fitting the result with a fifth-order polynomial regression.
- The core of FM stimulus generation was written based on MATLAB code by [Sarita Singh](https://github.com/sritasngh).
- Stimuli loudness control was done during auditory electrophysiology through TDT Synapse system and manually calibrated, thus it was not included in stimuli generation.

## 3. Auditory Electrophysiology
- Electrophysiological signals were collected using an RZ2 multiprocessor, RS4 data streamer, and accompanying software (Synapse, TDT). Single-unit responses were isolated offline using OpenSorter and OpenExplorer (TDT).
- A series of custom code was written to extract only sorted data from TDT tanks after processing through OpenSorter and OpenExplorer. Unit raster data were saved into a data structure together with calculated firing rates, as well as Rayleigh statistics and vector strength (for trill and flat FM responses only).
- Plotting code for unit profiles (including FRA and trill FM) used for Figure 3 is also included.
- Although trill unit extraction code is included as an example, it is adviced to write your own code extraction tool to fit your recording condition and data structure.

## 4. Neural Data Analysis
### 4.1 Single-Unit Response Characterization
- Basic calculation of firing rates at different time  window, as well as Rayleigh statsitics and vector strength, are included in the previous section.
- The current folder contains GLM codes, codes used for finding best FM rates and depths, as well as corresponding plotting codes.
- The violin plot function used in these plotters was written by [Bastian Bechtold](https://github.com/bastibe/Violinplot-Matlab)

### 4.2 Population Trajectory Analysis
