%%  Load Data
clear
addpath('C:\Users\emily\Documents\MATLAB\synapse');
load Data_vocTrill_data.mat

load Data_FRA_data.mat
load bestFMratedepth_listnew.mat

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

%%  Preprocess VS which are too low
for i=1:385
    for j=1:20
        % if trilldepth.ray(i,j)<=13.6&trilldepth.mean_sus(i,j)<=2
        if trilldepth.ray(i,j)<=3&&trilldepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            trilldepth.vs(i,j)=0;
        end
        % if flatdepth.ray(i,j)<=13.6&flatdepth.mean_sus(i,j)<=2
        if flatdepth.ray(i,j)<=3&&flatdepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            flatdepth.vs(i,j)=0;
        end
    end
end

%% Calculate normalized mean rate over depth
for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        meanrate(i,j)=mean(trilldepth.mean_sus(i,(j*4-3):j*4));
        meanflat(i,j)=mean(flatdepth.mean_sus(i,(j*4-3):j*4));
    end
end

for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        norm_meanrate(i,j)=(meanrate(i,j)-min(trilldepth.mean_sus(i,1:20)))/(max(trilldepth.mean_sus(i,1:20))-min(trilldepth.mean_sus(i,1:20)));
        norm_meanflat(i,j)=(meanflat(i,j)-min(flatdepth.mean_sus(i,1:20)))/(max(flatdepth.mean_sus(i,1:20))-min(flatdepth.mean_sus(i,1:20)));
    end
end

for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        meanvs(i,j)=mean(trilldepth.vs(i,(j*4-3):j*4));
        meanflatvs(i,j)=mean(flatdepth.vs(i,(j*4-3):j*4));
    end
end

for i=1:length(okind)   %all units
    for j=1:5   %5 FMrates
        norm_meanvs(i,j)=meanvs(i,j);
        norm_meanflatvs(i,j)=meanflatvs(i,j);
    end
end

%% Find Rate best frequency
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestrate(i,1)=max(norm_meanrate(i,1:5)); %Non-inhibitory
    else
        if unitlist(i)==2
            bestrate(i,1)=min(norm_meanrate(i,1:5)); %Inhibitory, find worst rate
        end
    end
    if unitlist(i)~=0
        bestFMrate(i,1)=find(norm_meanrate(i,1:5)==bestrate(i,1),1,'first');
    else
        bestFMrate(i,1)=0;
    end
end

%% Find VS best frequency
for i=1:length(okind)   %all units
    if unitlist(i)==1
    bestratevs(i,1)=max(norm_meanvs(i,1:5)); %Non-inhibitory
    else
        if unitlist(i)==2
            bestratevs(i,1)=min(norm_meanvs(i,1:5)); %Inhibitory, find worst rate
        end
    end
    if unitlist(i)~=0
        bestFMratevs(i,1)=find(norm_meanvs(i,1:5)==bestratevs(i,1),1,'first');
    else
        bestFMratevs(i,1)=0;
    end
end

%%
[XOut1,YOut1]=prepareCurveData(norm_meanrate(okind,:),norm_meanflat(okind,:));
[XOut2,YOut2]=prepareCurveData(norm_meanvs(okind,:),norm_meanflatvs(okind,:));

Group1=[];
Group2=[];

Group1=repmat(unitlist(okind),5,1);
Group2=repmat(unitlist(okind),5,1);

figure('Position',[100 100 400 400])
scatterhist(XOut1,YOut1,...
    'Kernel','off',...
    'Location','SouthWest','LineWidth',2,...
    'Color','b',...
    'Direction','in','Marker','+x','MarkerSize',5);
hold on
plot([0 1],[0 1],'Color',[0.5 0.5 0.5])
xlim([0 1])
ylim([0 1])
xlabel("Normalized susFR (Trill)");
ylabel("Normalized susFR (Flat)");
[P1_1,S1_1] = polyfit(XOut1,YOut1,1);
f1_1 = polyval(P1_1,[0 1]);
plot([0 1],f1_1,'Color',[0.3 0.3 1])
title('Trill FR vs Flat FR');


figure('Position',[100 100 400 400])
scatterhist(XOut2,YOut2,...
    'Kernel','off',...
    'Location','SouthWest','LineWidth',2,...
    'Color','r',...
    'Direction','in','Marker','+x','MarkerSize',5);
hold on
plot([0 1],[0 1],'Color',[0.5 0.5 0.5])
xlim([0 1])
ylim([0 1])
xlabel("VS (Trill)");
ylabel("VS (Flat)");
[P2_1,S2_1] = polyfit(XOut2,YOut2,1);
f2_1 = polyval(P2_1,[0 1]);
plot([0 1],f2_1,'Color',[1 0.3 0.3])
title('Trill VS vs Flat VS');


%%  Calculate bias index
for i=1:length(XOut1)
    biasindex1(i,1)=(XOut1(i)-YOut1(i))/(XOut1(i)+YOut1(i));
    biasindex2(i,1)=(XOut2(i)-YOut2(i))/(XOut2(i)+YOut2(i));
end

biasindex0=[biasindex1;biasindex2];
Group0=[zeros(length(XOut1),1);ones(length(XOut1),1)];

figure('position',[100 100 300 300]);
subplot(1,2,1)

% violinplot(biasindex1,Group1,'ViolinColor',[1 0 0;0 0 1],'ShowData',false,'ViolinAlpha',0.5);
% xticklabels({'+','-'});
% xlabel({'Unit Type'});
% ylabel({'Bias Index'});
% ylim([-1 1]);
% txt=['NormFR'];
% title(txt);
% plot([0.2 2.8],[0 0],'Color',[0.5 0.5 0.5]);
% 
% subplot(1,2,2)
% violinplot(biasindex2,Group2,'ViolinColor',[1 0 0;0 0 1],'ShowData',false,'ViolinAlpha',0.5);
% xticklabels({'+','-'});
% xlabel({'Unit Type'});
% ylabel({'Bias Index'});
% ylim([-1 1]);
% txt=['VS'];
% title(txt);
% plot([0.2 2.8],[0 0],'Color',[0.5 0.5 0.5]);

violinplot(biasindex0,Group0,'ViolinColor',[0 0 1;1 0 0],'ShowData',false,'ViolinAlpha',0.5);
xticklabels({'FR','VS'});
xlabel({'Data Type'});
ylabel({'Bias Index'});
ylim([-1 1]);
txt=['All'];
title(txt);
plot([0.2 2.8],[0 0],'Color',[0.5 0.5 0.5]);