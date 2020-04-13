# Cognitive-Stress-estimation

Cognitive Stress estimation from extracted features from time series like ECG,EEG,PPG,BVP. Stress or Cognitive stress/load is assumed to be proportional to the HighFrequency/LowFrequency power estimates in the power spectral density of the IBI(Inter-Beat interval) time series) geenrally extracted from PPG/BVP data-sets. 
Various time domain measures such as SDNN(Standard-deviation of the NN intervals) are also assumed to be good indicators of cognitive stress. 
This repo. describes the various methods which can be ascribed to estimation of cognitve stress from various physiological signals. 

# Generating resting Heart rate: 
Resting heart-rate is generally deemed to be the variation in heart rate under the condition of minimal variation in heart rate i.e when the subject is relaxed and under the influence of para-sympathetic nervous system. Such intervals in the time-series are indicated by very low gradient. Generating resting heart rate generally involves finding those segments in the HR time series and then interpolating them to desired lengths. 

Other methodologies have often included using accelorometer data as well. Epochs in accelorometer data with low gradient often allude to periods of "rest and relaxation" in R-R time series. 

Feature extraction and further analysis of periods of resting heart rate have been often termed as a good predecssor of vagal tone.
