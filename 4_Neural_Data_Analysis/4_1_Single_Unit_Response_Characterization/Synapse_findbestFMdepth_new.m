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
    for j=1:4   %4 depths
        meanrate(i,j)=mean(trilldepth.mean_sus(i,j:4:(16+j)));
    end
end

for i=1:length(okind)   %all units
    for j=1:4   %4 depths
        norm_meanrate(i,j)=(meanrate(i,j)-min(trilldepth.mean_sus(i,1:20)))/(max(trilldepth.mean_sus(i,1:20))-min(trilldepth.mean_sus(i,1:20)));
    end
end

%% Find Rate best frequency
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestrate(i,1)=max(norm_meanrate(i,1:4)); %Non-inhibitory
    else
        if unitlist(i)==2
            % bestrate(i,1)=min(norm_meanrate(i,1:4)); %Inhibitory, find worst rate
            bestrate(i,1)=max(norm_meanrate(i,1:4)); %Don't find worst rate
        end
    end
    if unitlist(i)~=0
        bestFMdepth(i,1)=find(norm_meanrate(i,1:4)==bestrate(i,1),1,'first');
    else
        bestFMdepth(i,1)=0;
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
    for j=1:4
        norm_sus(i,j)=(trilldepth.mean_sus(i,j)-min(trilldepth.mean_sus(i,1:20)))/(max(trilldepth.mean_sus(i,1:20))-min(trilldepth.mean_sus(i,1:20)));
        norm_sus_f(i,j)=(flatdepth.mean_sus(i,j)-min(flatdepth.mean_sus(i,1:20)))/(max(flatdepth.mean_sus(i,1:20))-min(flatdepth.mean_sus(i,1:20)));
    end
    %Calculate distribution index
    unit_index_depth(i,1)=(max(norm_meanrate(i,1:4))-min(norm_meanrate(i,1:4)))/(max(norm_meanrate(i,1:4))+min(norm_meanrate(i,1:4)));
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
cats=unique(bestFMdepth(oklist));

% Count call num in each categories
for i=1:length(cats)
    callcount(1,i)=length(find(bestFMdepth(ind1)==cats(i)));
    callcount(2,i)=length(find(bestFMdepth(ind2)==cats(i)));
end