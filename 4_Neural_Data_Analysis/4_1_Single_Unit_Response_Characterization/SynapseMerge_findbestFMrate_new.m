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


%% FRA okindexer
ind1=okind==1&list_inhib'==0; %Non-inhibitory
ind2=okind==1&list_inhib'==1; %Inhibitory

unitlist=zeros([length(okind),1]);
unitlist(ind1,1)=1;
unitlist(ind2,1)=2;

%% Calculate normalized mean rate over depth
for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        meanrate(i,j)=mean(trilldepth.mean_sus(i,(j*4-3):j*4));
    end
end

for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        norm_meanrate(i,j)=(meanrate(i,j)-min(trilldepth.mean_sus(i,1:20)))/(max(trilldepth.mean_sus(i,1:20))-min(trilldepth.mean_sus(i,1:20)));
    end
end

%% Find Rate best frequency
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestrate(i,1)=max(norm_meanrate(i,1:5)); %Non-inhibitory
    else
        if unitlist(i)==2
            % bestrate(i,1)=min(norm_meanrate(i,1:5)); %Inhibitory, find worst rate
            bestrate(i,1)=max(norm_meanrate(i,1:5)); %Don't find worst rate
        end
    end
    if unitlist(i)~=0
        bestFMrate(i,1)=find(norm_meanrate(i,1:5)==bestrate(i,1),1,'first');
    else
        bestFMrate(i,1)=0;
    end
end

%% Calculate FMrate index
%Normalize FMrate
for i=1:length(okind)
    for j=1:20
        norm_sus(i,j)=(trilldepth.mean_sus(i,j)-min(trilldepth.mean_sus(i,1:20)))/(max(trilldepth.mean_sus(i,1:20))-min(trilldepth.mean_sus(i,1:20)));
        norm_sus_f(i,j)=(flatdepth.mean_sus(i,j)-min(flatdepth.mean_sus(i,1:20)))/(max(flatdepth.mean_sus(i,1:20))-min(flatdepth.mean_sus(i,1:20)));
    end
    %Calculate distribution index
    unit_index_rate(i,1)=(max(norm_meanrate(i,1:5))-min(norm_meanrate(i,1:5)))/(max(norm_meanrate(i,1:5))+min(norm_meanrate(i,1:5)));
    %Get normalize meanrate
    % norm_mean(i,1)=mean(norm_sus(i,1:4));
    % norm_mean(i,2)=mean(norm_sus(i,5:8));
    % norm_mean(i,3)=mean(norm_sus(i,9:12));
    % norm_mean(i,4)=mean(norm_sus(i,13:16));
    % norm_mean(i,5)=mean(norm_sus(i,17:20));
    % norm_max(i,1)=max(norm_sus(i,1:4));
    % norm_max(i,2)=max(norm_sus(i,5:8));
    % norm_max(i,3)=max(norm_sus(i,9:12));
    % norm_max(i,4)=max(norm_sus(i,13:16));
    % norm_max(i,5)=max(norm_sus(i,17:20));
    % norm_min(i,1)=min(norm_sus(i,1:4));
    % norm_min(i,2)=min(norm_sus(i,5:8));
    % norm_min(i,3)=min(norm_sus(i,9:12));
    % norm_min(i,4)=min(norm_sus(i,13:16));
    % norm_min(i,5)=min(norm_sus(i,17:20));
end

%% Count best unit num
cats=unique(bestFMrate(oklist));

% Count call num in each categories
% for i=1:length(cats)
%     callcount(1,i)=length(find(bestFMrate(ind1)==cats(i)));
%     callcount(2,i)=length(find(bestFMrate(ind2)==cats(i)));
% end

for i=1:length(cats)
    callcount(1,i)=length(find(bestFMrate(okind)==cats(i)));
end