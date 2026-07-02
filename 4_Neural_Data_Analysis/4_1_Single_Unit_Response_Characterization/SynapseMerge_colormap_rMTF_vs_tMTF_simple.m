%% Load data
clear;
addpath('C:\Users\emily\Documents\MATLAB\synapse');
load Data_vocTrill_data.mat
load bestFMratedepth_listnew.mat
load Data_FRA_data.mat

%% Define data
data_type=input('Select data type, 1=Trill, 0=Flat: ');

if data_type==1
    data_FR=bestFMrate;
    data_FR2=bestFMdepth;
    data_VS=bestFMrate_VS;
    data_VS2=bestFMdepth_VS;
end

if data_type==0
    data_FR=bestFMrate_flat;
    data_FR2=bestFMdepth_flat;
    data_VS=bestFMrate_VS_flat;
    data_VS2=bestFMdepth_VS_flat;
end

%% Plot
for i=1:5 % For each rMTF best FMrate
    for j=1:5 % For each tMTF best FM rate
        distmap1(j,i)=length(find(unitlist~=0&data_FR==i&data_VS==j));
    end
end

for i=1:4 % For each rMTF best FMrate
    for j=1:4 % For each tMTF best FM rate
        distmap3(j,i)=length(find(unitlist~=0&data_FR2==i&data_VS2==j));
    end
end

distmap1_flip=flip(distmap1);
distmap3_flip=flip(distmap3);

%%
h1=figure('Position',[100 100 240 200]);
h1 = heatmap([16 22.5 32 45 64],flip([16 22.5 32 45 64]),distmap1_flip,'ColorMethod','mean');
colormap sky
h1.Title={'Best FM rate (Frequency)'};
xlabel('rBMF (Hz)');
ylabel('tBMF (Hz)');

h5=figure('Position',[100 300 240 150]);
h5=tiledlayout(2,1);
nexttile
histogram(data_FR(unitlist~=0),5);
box off;
nexttile
histogram(data_VS(unitlist~=0),5);
set(gca, 'XDir', 'reverse');
box off;

% h2=figure('Position',[300 100 240 200]);
% h2 = heatmap([16 22.5 32 45 64],flip([16 22.5 32 45 64]),distmap2_flip,'ColorMethod','mean');
% colormap sky
% h2.Title={'Inhibited'};
% xlabel('rBMF (Hz)');
% ylabel('tBMF (Hz)');
% 
% h6=figure('Position',[300 300 240 150]);
% h6=tiledlayout(2,1);
% nexttile
% histogram(data_FR(unitlist==2),5);
% box off;
% nexttile
% histogram(data_VS(unitlist==2),5);
% set(gca, 'XDir', 'reverse');
% box off;

%%
h3=figure('Position',[500 100 240 200]);
h3 = heatmap([125 250 500 1000],flip([125 250 500 1000]),distmap3_flip,'ColorMethod','mean');
colormap sky
h3.Title={'Best FM Depth'};
xlabel('rBMD (Hz)');
ylabel('tBMD (Hz)');

h7=figure('Position',[500 300 240 150]);
h7=tiledlayout(2,1);
nexttile
histogram(data_FR2(unitlist~=0),4);
box off;
nexttile
histogram(data_VS2(unitlist~=0),4);
set(gca, 'XDir', 'reverse');
box off;

% h4=figure('Position',[700 100 240 200]);
% h4 = heatmap([125 250 500 1000],flip([125 250 500 1000]),distmap4_flip,'ColorMethod','mean');
% colormap sky
% h4.Title={'Inhibited'};
% xlabel('rBMD (Hz)');
% ylabel('tBMD (Hz)');
% 
% h8=figure('Position',[700 300 240 150]);
% h8=tiledlayout(2,1);
% nexttile
% histogram(data_FR2(unitlist==2),4);
% box off;
% nexttile
% histogram(data_VS2(unitlist==2),4);
% set(gca, 'XDir', 'reverse');
% box off;