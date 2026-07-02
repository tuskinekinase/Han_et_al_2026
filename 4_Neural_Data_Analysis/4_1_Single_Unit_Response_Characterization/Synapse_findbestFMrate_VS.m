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

        if trilldepth.ray(i,j)<=3&trilldepth.mean_sus(i,j)<=2
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

%% VS indexer
ind3=okind==1&mean(trilldepth.vs')<=0.2;
ind4=okind==1&mean(trilldepth.vs')>0.2&mean(trilldepth.vs')<=0.4;
ind5=okind==1&mean(trilldepth.vs')>0.4&mean(trilldepth.vs')<=0.6;
ind6=okind==1&mean(trilldepth.vs')>0.6;

vslist=zeros(385,1);
vslist(ind3,1)=1;
vslist(ind4,1)=2;
vslist(ind5,1)=3;
vslist(ind6,1)=4;

%% Calculate mean VS over depth
for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        meanvs(i,j)=mean(trilldepth.vs(i,(j*4-3):j*4));
    end
end

%% Find Rate best frequency
bestrate_vs=zeros(385,1);
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestrate_vs(i,1)=max(meanvs(i,1:5)); %Non-inhibitory
    else
        if unitlist(i)==2
            bestrate_vs(i,1)=max(meanvs(i,1:5)); %Inhibitory, also find best rate
        end
    end
    if unitlist(i)~=0
        bestFMrate_vs(i,1)=find(meanvs(i,1:5)==bestrate_vs(i,1),1,'first');
    else
        bestFMrate_vs(i,1)=0;
    end
end


% FMratelist=[1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5];
% FMdepthlist=[1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
% 
% for i=1:length(okind)
%     if unitlist(i)==1
%     bestrate(i,1)=max(trilldepth.mean_sus(i,1:20)); %Non-inhibitory
%     else
%         if unitlist(i)==2
%             bestrate(i,1)=min(trilldepth.mean_sus(i,1:20)); %Inhibitory, find worst rate
%         end
%     end
%     if unitlist(i)~=0
%         bestSGI(i,1)=find(trilldepth.mean_sus(i,1:20)==bestrate(i,1),1,'first');
%         bestFMrate(i,1)=FMratelist(bestSGI(i,1));
%         bestdepth(i,1)=FMdepthlist(bestSGI(i,1));
%     else
%         bestSGI(i,1)=0;
%         bestFMrate(i,1)=0;
%         bestdepth(i,1)=0;
%     end
% end
%% Calculate FMrate index
%Normalize FMrate
for i=1:length(okind)
    unit_index_rate(i,1)=(max(meanvs(i,1:5))-min(meanvs(i,1:5)))/(max(meanvs(i,1:5))+min(meanvs(i,1:5)));
end

%% Count best unit num
cats=unique(bestFMrate_vs(oklist));

% Count call num in each categories
for i=1:length(cats)
    callcount(1,i)=length(find(bestFMrate_vs(ind1)==cats(i)));
    callcount(2,i)=length(find(bestFMrate_vs(ind2)==cats(i)));
end