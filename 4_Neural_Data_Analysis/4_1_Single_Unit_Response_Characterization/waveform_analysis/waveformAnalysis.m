%%% waveformAnalysis - E/I waveform comparison (+ optional per-animal stratification)
%%% Loads waveform_features.mat (from extractWaveformFeats) and a unit list .mat
%%% with unitlist (385x1: 1=Excited, 2=Inhibited, 0=unresponsive).
%%%
%%% EDIT THIS SECTION for visualization:
%%%   - scatter/box colors, jitter width, point size
%%%   - add/remove statistics (currently Mann-Whitney ranksum)
%%%   - optional: provide animalID (385x1, values 1..nAnimal) to draw
%%%     per-animal stratified distributions.

clear; close all;
load Data_vocTrill_data.mat;
W = load('waveform_features.mat');          % featMean, featSD, featSE, nSpikes, featNames
B = load('bestFMratedepth_listnew.mat');    % -> your unit-list file name
unitlist = double(B.unitlist(:));

featMean = W.featMean;
featNames = W.featNames(:)';
nNeu = numel(unitlist);

% --- per-animal ID: auto from an_name if present ---
if isempty(an_name)
    fprintf('an_name not found (checked waveform_features.mat and Data_vocTrill_data.mat); per-animal panel disabled.\n');
else
    an_name = string(an_name(:));
    animalID = double(categorical(an_name));
    fprintf('Per-animal panel enabled (%s): %d animals\n', ...
        strjoin(unique(an_name), ', '), numel(unique(animalID)));
end

%% ---------------- E / I grouping ----------------
E = unitlist == 1;
I = unitlist == 2;
fprintf('Excited n=%d | Inhibited n=%d\n', sum(E), sum(I));

%% ---------------- main figure ----------------
% columns to plot: 4=ptDurMs, 5=fwhmMs, 6=asym  (1-3 are raw voltage, skip)
selFeat = [4 6];     % edit: which features to show
nShow   = numel(selFeat);

figure('Color', 'w', 'Position', [80 80 260*nShow 420]);
for jj = 1:nShow
    j  = selFeat(jj);
    xE = featMean(E, j);  xI = featMean(I, j);
    xE = xE(~isnan(xE));  xI = xI(~isnan(xI));
    p  = ranksum(xE, xI);
    subplot(1, nShow, jj); hold on;
    % --- EDIT visualization here ---
    jitterW = 0.12;  ptSize = 9;
    rng(0);
    plot(-0.18 + jitterW*(rand(size(xE))-0.5), xE, '.', 'Color', [0.12 0.47 0.71], 'MarkerSize', ptSize);
    plot( 0.18 + jitterW*(rand(size(xI))-0.5), xI, '.', 'Color', [0.84 0.15 0.16], 'MarkerSize', ptSize);
    boxplot([xE; xI], [zeros(size(xE)); ones(size(xI))], ...
        'positions', [-0.18 0.18], 'widths', 0.16, ...
        'boxstyle', 'outline', 'Colors', 'k', 'Symbol', '');
    set(gca, 'XTick', [-0.18 0.18], 'XTickLabel', ...
        {sprintf('Excited (n=%d)', numel(xE)), sprintf('Inhibited (n=%d)', numel(xI))});
    xlim([-0.55 0.55]); grid on;
    title(sprintf('%s   p=%.4f', featNames{j}, p));
    ylabel(featNames{j});
    % --- end edit ---
end

%% ---------------- optional per-animal panel ----------------
if ~isempty(animalID)
    animals = unique(animalID(:))';
    figure('Color', 'w', 'Position', [120 120 260*numel(animals) 420]);
    for aa = 1:numel(animals)
        m = animalID == animals(aa);
        subplot(1, numel(animals), aa); hold on;
        xE = featMean(m & E, 4);  xI = featMean(m & I, 4);
        xE = xE(~isnan(xE));  xI = xI(~isnan(xI));
        plot(-0.18 + 0.1*(rand(size(xE))-0.5), xE, '.', 'Color', [0.12 0.47 0.71], 'MarkerSize', 9);
        plot( 0.18 + 0.1*(rand(size(xI))-0.5), xI, '.', 'Color', [0.84 0.15 0.16], 'MarkerSize', 9);
        if numel(xE) >= 3 && numel(xI) >= 3
            p = ranksum(xE, xI);
            title(sprintf('Animal %d  (E%d/I%d)  p=%.3f', animals(aa), numel(xE), numel(xI), p));
        else
            title(sprintf('Animal %d  (E%d/I%d)', animals(aa), numel(xE), numel(xI)));
        end
        ylabel('ptDurMs'); xlim([-0.55 0.55]); ylim([0.1 0.7]); grid on;
    end
end
