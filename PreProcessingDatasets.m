%%% This function combines the pre-processing steps to create a MA free
%%% HR time series resampled to 2 Hz.

 function [WindowedSignals,ProcessedIBI]= ...
  PreProcessingDatasets(BVP,ACC,EDA,TEMP); 

%%% pre-processing PPG/BVP data

tempBVP=(BVP(3:length(BVP),1));
tempPrimeACC=ACC(2:length(ACC),3);

%%% For Sinc interpolation
tempACC=interp(tempPrimeACC,round(length(tempBVP)/length(tempPrimeACC)));

%%% Making the time series of equal length(ACC,BVP)
if(length(tempACC)>length(tempBVP))
    
    tempACC=tempACC(1:length(tempBVP));
    
else
    
    tempBVP=tempBVP(1:length(tempACC));
    
end

%%% Making Time Windows for the PPG/BVP Data  

WindowDuration=10;  %Window time duration in seconds.
SamplingFreqn=64;   %SamplingFreqn of the PPG series.
OverlapDuration=0;  % in seconds

%Concatenating the two signals(ACC,BVP)
TempSignals={tempBVP,tempACC};

for i=1:size(TempSignals,2)

WindowedSignals{i}=...
MakingTimeWindows(TempSignals{i},WindowDuration,OverlapDuration,...
SamplingFreqn)

end
%% Removing MA's...

mu = 0.1; %step size

% defining the filter characteristics
lms = dsp.LMSFilter(70,'StepSize',mu,'Method',...
'Normalized LMS','WeightsOutputPort',true); 

% bandpass range
fpass=[0.3,4]; 

% BVP Windows
BVPWindow=WindowedSignals{1};

%ACC Windows
ACCWindow=WindowedSignals{2};

%Num of BVP windows
NumWindows=size(BVPWindow,2); 

for iPrime=1:NumWindows
    
% BVP signal is used as the reference signal d(n)
dTemp(:,iPrime)=BVPWindow(:,iPrime); 
    
% ACC signal is used as the input 
x(:,iPrime)=ACCWindow(:,iPrime); 
    
% % performing Bandpass filtering
% d(:,iPrime)=bandpass(dTemp(:,iPrime),fpass,SamplingFreqn,...
%        'ImpulseResponse','iir');
   
d(:,iPrime)=dTemp(:,iPrime); 
   
% performing LMS filtering   
[y(:,iPrime),e(:,iPrime),w(:,iPrime)]=lms(x(:,iPrime),d(:,iPrime));
   
% The error signal e(n) is the MA free PPG(BVP) signal according to 
% Fallet et al. 
 Window(:,iPrime)=e(:,iPrime);
 
% Locating the Peaks in the PPG signal
% 25 samples choosen as the minimum peak distance
% keeping in mind a sampling Frequency of 64Hz.
[~,Idx]=findpeaks(Window(:,iPrime),'MinPeakdistance',25);

% difference in between the peaks of the PPG 
 for i=1:length(Idx)-1
   diff(i)=Idx(i+1)-Idx(i);
 end
IBIinterval{iPrime}=diff./SamplingFreqn;
   
% Average IBI for every window    
AvgIBIinterval(iPrime)=mean(IBIinterval{iPrime});
   
end 
tempFact=round(length(BVP)/length(AvgIBIinterval));
   
%Sampling frequency of the Average IBI intervals.
AvgSamFreqn=SamplingFreqn/tempFact; 

%Resampling the RR intervals to 2 Hz 
ResamFreqn=2; 

%The factor by which the AvgIBIinterval needs to be resampled   
ResamplingFact=ResamFreqn/AvgSamFreqn; 

if(ResamplingFact>1)
   %Processed IBI  
   ProcessedIBI=interp(AvgIBIinterval,round(ResamplingFact));
else
   %Processed IBI 
   ProcessedIBI=downsample(AvgIBIinterval,ResamplingFact);
end

%% Windowing the processed signal

tempIBI=ProcessedIBI';
tempEDA=EDA(:,1); % Extracting the EDA signal
tempTemperature=TEMP(:,1);

%%% Making the time series of equal length

if (size(tempTemperature,1)>size(tempEDA,1))
    
  %%% Sinc interpolation  
  tempIBI=interp(tempIBI,round(size(tempTemperature,1)/...
      size(tempIBI,1)));  % For IBI
  tempEDA=interp(tempEDA,round(size(tempTemperature,1)/...
      size(tempEDA,1)));  % For EDA
  
else
    
  %%% For Sinc interpolation  
  tempIBI=interp(tempIBI,round(size(tempEDA,1)/...
      size(tempIBI,1)));  % For IBI
  tempTemperature=interp(tempTemperature,round(size(tempEDA,1)/...
      size(tempTemperature,1)));  % For Temperature
  
end

%%% Making Time Windows for IBI,EDA,Temperature... 

clear TempSignals WindowedSignals;

TempSignals={tempIBI,tempEDA,tempTemperature};

WindowDuration=10; %Window time duration in seconds
SamplingFreqn=64;
OverlapDuration=8;  % in seconds

for i=1:size(TempSignals,2)
    
%IBI,EDA,Temperature

WindowedSignals{i}= ...
MakingTimeWindows(TempSignals{i},WindowDuration,OverlapDuration,...
SamplingFreqn)

end


end


