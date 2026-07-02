%%  Load Data
clear;
addpath('C:\Users\emily\Documents\MATLAB\synapse');
load Data_vocTrill_data.mat

load Data_FRA_data.mat

%% okindexer
okind=max(trilldepth.mean_spont')>5|max(trilldepth.mean_on')>=6; % All tone_BFs

% This here is for 5000<best_tone<=10000
% okind=(max(trilldepth.mean_spont')>5|max(trilldepth.mean_on')>=6)&(best_tone>5000&best_tone<=10000)';
oklist=find(okind==1);

%%  Preprocess VS which are too low
for i=1:385
    for j=1:20
        % if trilldepth.ray(i,j)<=13.6&trilldepth.mean_sus(i,j)<=2

        if trilldepth.ray<=3&flatFM.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            trilldepth.vs(i,j)=0;
        end
        % if flatdepth.ray(i,j)<=13.6&flatdepth.mean_sus(i,j)<=2

        if flatdepth.ray(i,j)<=3&flatdepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            flatdepth.vs(i,j)=0;
        end
    end
end

%% FRA okindexer
ind1=okind==1&list_inhib'==0; %Non-inhibitory
ind2=okind==1&list_inhib'==1; %Inhibitory

unitlist=zeros([length(okind),1]);
unitlist(ind1,1)=1;
unitlist(ind2,1)=2;

%% Calculate normalized mean rate over depth
for i=1:length(okind)   %all units
    for j=1:4   %4 depths
        meanvs(i,j)=mean(trilldepth.vs(i,j:4:(16+j)));
    end
end

% for i=1:length(okind)   %all units
%     for j=1:4   %4 depths
%         norm_meanrate(i,j)=(meanvs(i,j)-min(trilldepth.vs(i,1:20)))/(max(trilldepth.vs(i,1:20))-min(trilldepth.vs(i,1:20)));
%     end
% end

%% Find Rate best frequency
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestrate(i,1)=max(meanvs(i,1:4)); %Non-inhibitory
    else
        if unitlist(i)==2
            bestrate(i,1)=max(meanvs(i,1:4)); %Inhibitory, also find best rate
        end
    end
    if unitlist(i)~=0
        bestFMdepth_vs(i,1)=find(meanvs(i,1:4)==bestrate(i,1),1,'first');
    else
        bestFMdepth_vs(i,1)=0;
    end
end

%% Calculate FMrate index
%Normalize FMrate
for i=1:length(okind)
    unit_index_rate(i,1)=(max(meanvs(i,1:4))-min(meanvs(i,1:4)))/(max(meanvs(i,1:4))+min(meanvs(i,1:4)));
end

%% Count best unit num
cats=unique(bestFMdepth_vs(oklist));

% Count call num in each categories
% for i=1:length(cats)
%     callcount(1,i)=length(find(bestFMdepth_vs(ind1)==cats(i)));
%     callcount(2,i)=length(find(bestFMdepth_vs(ind2)==cats(i)));
% end

for i=1:length(cats)
    callcount(1,i)=length(find(bestFMdepth_vs(okind)==cats(i)));
end