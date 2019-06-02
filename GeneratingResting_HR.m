%%% Extracting segments where the derivative of the HR series is close
%%to zero %%
%%% A zero derivative would indicate that the rate of change of the %%%
%%% signal is very close to zero in those segments %%%
close all
clearvars -except ACC BVP TEMP EDA ProcessedIBI

%Time Signal%
TimeSig=ProcessedIBI;

%Computing the gradient of the signal%
DeltaTimeSig=...
    gradient(TimeSig);

%Maximam value in the gradient of the signal%
[M,~]= max(DeltaTimeSig);

%Bound calculated as the percent factor%
PercentFact=1;

%Bound is PercentFact of the maximam value %
%of the highest derivative in the signal%
%that is the bound some percentage value of%
%the maximam rate of change in the signal%
UpBound=(PercentFact/100)*M;

%Finding the segments of the derivative%
%within the bound%
Idx=find(abs(DeltaTimeSig)<UpBound);

Count=1;
for i=1:length(Idx)-1
    
    if(Idx(i+1)-Idx(i)>1)
        
       enPos(Count)=Idx(i);
       
       stPos(Count)=Idx(i+1);
       
       Count=Count+1;
    
    end
    
end
        
%Making the segments 
for i=1:length(stPos)-1
 
    RestingSegments{i}=stPos(i):enPos(i+1);
    
end

%Making the segment into vector
RestingIndices=cell2mat(RestingSegments);

%Getting the HR series from the resting indices 
RestingHR=ProcessedIBI(RestingIndices);

%Passing the Resting IBI series 
%to calcualte the frequency domain features..
[tempPowerRatio,tempNormalizedPowerRatio,...
    tempHFnu,tempLFnu]=...
    ExtractingFreqnDomainFeatures(RestingHR);

  PowerRatio.Resting=tempPowerRatio;
  NormalizedPowerRatio.Resting=...
      tempNormalizedPowerRatio;
   HFnu.Resting=tempHFnu;
   LFnu.Resting=tempLFnu;
  
%Passing the current IBI series to get the 
%freq domain features

[tempPowerRatio,tempNormalizedPowerRatio,...
    tempHFnu,tempLFnu]=...
    ExtractingFreqnDomainFeatures(ProcessedIBI);

   PowerRatio.Steady=...
       tempPowerRatio;
   NormalizedPowerRatio.Steady=...
       tempNormalizedPowerRatio;
   HFnu.Steady=tempHFnu;
   LFnu.Steady=tempLFnu;
   
%Groups for doing ANOVA...
GroupMat(:,1)=[PowerRatio.Steady;NormalizedPowerRatio.Steady;...
    HFnu.Steady;LFnu.Steady];

GroupMat(:,2)=[PowerRatio.Resting;NormalizedPowerRatio.Resting;...
    HFnu.Resting;LFnu.Resting]

anova1(GroupMat);

   
% %Passing the resting IBI series
% %to calculate the time domain series 
% [SDNN,AVNN,CV,SDSD,RMSSDD,SDRR] = ...
%      ExtractingTimeDomainFeatures(TimeSig);




%% Plotting the results 

% Inerpolating the resting HR to the same length
% as the IBI series
% Sinc interpolation
InterpRestingHR=...
interp(RestingHR,round(length(ProcessedIBI)/length(RestingHR)));


%Plotting the two time series
figure;
plot(InterpRestingHR)
hold
plot(ProcessedIBI)
legend('IBI during resting Periods',...
    'Live IBI');


figure;
% without interpolation 
% HR in BPM

RestingHR=(1./RestingHR)*60
plot(RestingHR)
ylabel('beats per minute');
xlabel('Samples')



% %% Using SGolay filter...
% 
% dt = 0.25;
% t = (0:dt:length(ProcessedIBI')-1)';
% 
% x = ProcessedIBI';
% 
% Order=2;
% FrameLen=25;
% [b,g] = sgolay(Order,FrameLen);
