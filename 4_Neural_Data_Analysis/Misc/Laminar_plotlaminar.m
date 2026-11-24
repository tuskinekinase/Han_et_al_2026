load Data_vocTrill_data.mat;
load Laminar_Thomas.mat;

%%
f1 = figure('Position', [100 100 300 600]);
t1=tiledlayout(8,1,"TileSpacing","compact");
for i=1:8
    nexttile
    histogram(bestFMrate(layerlist==i&unitlist~=0));
    xlim([0.5 5.5]);
end
title(t1,'rBMF across channel depth');

%
f2 = figure('Position', [400 100 300 600]);
t2=tiledlayout(8,1,"TileSpacing","compact");
set(gcf, 'Position', [400 100 300 600]);
for i=1:8
    nexttile
    histogram(bestFMrate_VS(layerlist==i&unitlist~=0));
    xlim([0.5 5.5]);
end
title(t2,'tBMF across channel depth');

%
f3 = figure('Position', [700 100 300 600]);
t3=tiledlayout(8,1,"TileSpacing","compact");
for i=1:8
    nexttile
    histogram(bestFMdepth(layerlist==i&unitlist~=0));
    xlim([0.5 4.5]);
end
title(t3,'rBMD across channel depth');

%
f4 = figure('Position', [1000 100 300 600]);
t4=tiledlayout(8,1,"TileSpacing","compact");
for i=1:8
    nexttile
    histogram(bestFMdepth_VS(layerlist==i&unitlist~=0));
    xlim([0.5 4.5]);
end
title(t4,'tBMD across channel depth');

%%
% mean_mean_spont=mean(trilldepth.mean_spont(:,1:20),2);
tiledlayout(8,1,"TileSpacing","compact");
for i=1:8
    nexttile
    histogram(mean(trilldepth.mean_spont(layerlist==i&unitlist~=0,:),2),'BinEdges',0:2:30);
    
end

%%
tiledlayout(8,1,"TileSpacing","compact");
for i=1:8
    nexttile
    histogram(mean(trilldepth.mean_sus(layerlist==i&unitlist~=0,:),2),'BinEdges',0:2:54);
    
end