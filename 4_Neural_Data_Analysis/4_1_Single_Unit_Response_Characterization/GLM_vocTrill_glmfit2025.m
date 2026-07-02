%   Perform GLMfit for Contour, ModFreq and ModDepth.
%   Requires Statistics and Machine Learning Toolbox
clear all;

try
    v = ver;
any(strcmp('Statistics and Machine Learning Toolbox', {v.Name}));
catch
    warning('Statistics and Machine Learning Toolbox not found')
end

%%  Load Trill Data
addpath('C:\Users\emily\Documents\MATLAB\synapse');
load Data_vocTrill_data.mat

%%  Preprocess VS which are too low
for i=1:385
    for j=1:20
        % if trilldepth.ray(i,j)<=13.6&&trilldepth.mean_sus(i,j)<=2
        if trilldepth.ray(i,j)<=3&&trilldepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            trilldepth.vs(i,j)=0;
        end
        % if flatdepth.ray(i,j)<=13.6&&flatdepth.mean_sus(i,j)<=2
        if flatdepth.ray(i,j)<=3&&flatdepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            flatdepth.vs(i,j)=0;
        end
    end
end

%%  Load normalized condition matrix
addpath('C:\Users\emily\Documents\MATLAB\synapse\GLMfit');
load GLM_x_matrix.mat

%   First column of x is Carrier Type. Correspond to corr(2).
%   Second column of x is normalized FM frequency. Correspond to corr(3).
%   Third column of x is normalized FM depth.  Correspond to corr(4).

%%  Normalize rate
NormSusRateflat=[];
NormSusRatetrill=[];

for i=1:length(chan)
    if max(flatdepth.mean_sus(i,:))==0
        NormSusRateflat(i,:)=0;
    else 
        NormSusRateflat(i,:)=flatdepth.mean_sus(i,:)./(max(flatdepth.mean_sus(i,:)));
    end
end

for i=1:length(chan)
    if max(trilldepth.mean_sus(i,:))==0
        NormSusRatetrill(i,:)=0;
    else 
        NormSusRatetrill(i,:)=trilldepth.mean_sus(i,:)./(max(trilldepth.mean_sus(i,:)));
    end
end

%%  Perform GLM

coef_rate=[];
p_rate=[];

for i=1:length(chan)
    y_temp=[NormSusRateflat(i,:)'; NormSusRatetrill(i,:)'];
    [b,dev,stat]=glmfit(x_mat,y_temp,'normal');
    coef_rate(i,:)=b';
    p_rate(i,:)=stat.p';
end

coef_vs=[];
p_vs=[];

for i=1:length(chan)
    y_temp=[flatdepth.vs(i,:)'; trilldepth.vs(i,:)'];
    [b,dev,stat]=glmfit(x_mat,y_temp,'normal');
    coef_vs(i,:)=b';
    p_vs(i,:)=stat.p';
end

%% Rate okindexer (VS indexer for Rate)
okind=max(trilldepth.mean_spont')>5|max(trilldepth.mean_on')>=6;
oklist=find(okind==1);

ind1=okind==1&mean(trilldepth.vs')<=0.2;
ind2=okind==1&mean(trilldepth.vs')>0.2&mean(trilldepth.vs')<=0.4;
ind3=okind==1&mean(trilldepth.vs')>0.4&mean(trilldepth.vs')<=0.6;
ind4=okind==1&mean(trilldepth.vs')>0.6;

vslist=zeros([length(okind),1]);
vslist(ind1,1)=1;
vslist(ind2,1)=2;
vslist(ind3,1)=3;
vslist(ind4,1)=4;

%% FRA okindexer (Load Data_FRA_data.mat)
load Data_FRA_data.mat

ind0=okind==1&isnan(best_tone');
ind5=okind==1&best_tone'<=5000&list_inhib'==0;
ind6=okind==1&best_tone'>5000&best_tone'<=10000&list_inhib'==0;
ind7=okind==1&best_tone'>10000&list_inhib'==0;
ind8=okind==1&best_tone'<=5000&list_inhib'==1;
ind9=okind==1&best_tone'>5000&best_tone'<=10000&list_inhib'==1;
ind10=okind==1&best_tone'>10000&list_inhib'==1;

bflist=zeros([length(okind),1]);
bflist(ind5,1)=1;
bflist(ind6,1)=2;
bflist(ind7,1)=3;
bflist(ind8,1)=4;
bflist(ind9,1)=5;
bflist(ind10,1)=6;
bflist(ind0,1)=0;


% %% Plot scatterhist by Tone Best Frequency
% h=figure;
% h=scatterhist(coef_vs(okind,3),coef_vs(okind,4),...
%     'Group',bflist(okind), ...
%     'Kernel','on',...
%     'Location','SouthWest','LineWidth',2,...
%     'Direction','in','Marker','+ox+ox','MarkerSize',5,'Color','rrrbbb',...
%     'LineStyle',{'-','-.',':','-','-.',':'})
% hold on
% ax = gca;
% ax.XAxisLocation = 'origin'
% ax.YAxisLocation = 'origin'
% axis tight
% title("VS Coefficients");
% xlabel("FM Rate");
% ylabel("FM Depth");
% legend('BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -');
% 
% g=figure;
% g=scatterhist(coef_rate(okind,3),coef_rate(okind,4),...
%     'Group',bflist(okind), ...
%     'Kernel','on',...
%     'Location','SouthWest','LineWidth',2,...
%     'Direction','in','Marker','+ox+ox','MarkerSize',5,'Color','rrrbbb',...
%     'LineStyle',{'-','-.',':','-','-.',':'})
% hold on
% ax = gca;
% ax.XAxisLocation = 'origin'
% ax.YAxisLocation = 'origin'
% axis tight
% title("Normalized Rate Coefficients");
% xlabel("FM Rate");
% ylabel("FM Depth");
% legend('BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -');

% %%
% m=figure('position',[300 0 1200 350]);
% subplot(1,3,1)
% boxplot(coef_vs(okind,2),bflist(okind),'orientation','vertical',...
%      'label',{'BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -'},'color','rrrbbb');
% title("VS Coefficient (Carrier Type)");
% subplot(1,3,2)
% boxplot(coef_vs(okind,3),bflist(okind),'orientation','vertical',...
%      'label',{'BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -'},'color','rrrbbb');
% title("VS Coefficient (FM Rate)");
% subplot(1,3,3)
% boxplot(coef_vs(okind,4),bflist(okind),'orientation','vertical',...
%      'label', {'BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -'},'color','rrrbbb');
% title("VS Coefficient (FM Depth)");
% 
