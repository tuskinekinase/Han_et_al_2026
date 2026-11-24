%% celltype_classify.m
% Perform unsupervised classification of units using waveform features and trill depth, then compare the results against E/I response types.
% v2026-10-14b: Added 2D/3D distribution analysis and a comparison of non-linear classifiers (QDA / SVM-RBF).
% Dependencies (located in the same directory as the script; otherwise, adjust the paths accordingly):
%   Data_vocTrill_data.mat         -> trilldepth struct (waveform/mean_spont/mean_on/mean_sus/mean_off/an_name)
%   waveform_features*.mat         -> featMean/featNames/featSD/featSE/fs/nSpikes
%   bestFMratedepth_listnew*.mat   -> unitlist(1=E,2=I,0=no resp)/bestFMrate/bestFMdepth
% Requires Statistics and Machine Learning Toolbox
% Output: Command line + celltype_EI_analysis.png + celltype_distribution_2d3d.png

clear; clc; close all;
rng(42);

%% 1. Load
D = load('Data_vocTrill_data.mat');
tr = D.trilldepth;

wf = dir('waveform_features*.mat');
assert(~isempty(wf), '找不到 waveform_features*.mat');
W = load(wf(1).name);

bf = dir('bestFMratedepth_listnew*.mat');
assert(~isempty(bf), '找不到 bestFMratedepth_listnew*.mat');
B = load(bf(1).name);

unitlist = double(B.unitlist(:));
n = numel(unitlist);
assert(n == 385, 'unitlist 应为 385x1，实际 %d', n);

%% 2. Features
% waveform features
ptDur = W.featMean(:, 4);   % peak-to-trough duration (ms), 4th column
asym  = W.featMean(:, 6);   % |peak/trough|, 6th column
% FWHM (5th column) — window truncation leads to many NaNs, so it is excluded by default;
% if you wish to use it, uncomment the line below and add handling for NaN values.
% fwhm  = W.featMean(:, 5);

% Unit parameters: Each of the 20 conditions is summarized into a single scalar value.
% Only the spontaneous firing rate ('spont') is used; 
% 'mean_on', 'mean_sus', and 'mean_off' are excluded from the classification because they are defining characteristics of E/I responses 
% (which would lead to circular reasoning).
spont    = median(tr.mean_spont, 2);  % Spontaneous rate, median
rateFeat = spont;                     % 
% Extra code for on/sus/off
% on = mean(tr.mean_on, 2); sus = mean(tr.mean_sus, 2); off = mean(tr.mean_off, 2);
% rateFeat = [spont, on, sus, off];

%% 3. Unsupervised classification (ptDur + asym; comparison of two methods: GMM-2 vs. k-means-2)
X = [ptDur, asym];
E = (unitlist == 1); I = (unitlist == 2);

methods = {'GMM-2', 'kmeans-2'};
for m = 1:2
    switch methods{m}
        case 'GMM-2'
            gm = fitgmdist(X, 2, 'SharedCov', false, 'Replicates', 20);
            cl = cluster(gm, X);
        case 'kmeans-2'
            cl = kmeans(X, 2, 'Replicates', 50, 'Start', 'plus');   % K=2
    end
    md = [median(ptDur(cl==1)), median(ptDur(cl==2))];
    [~, narrowId] = min(md);            % smaller ptDur
    narrow = (cl == narrowId);
    nN = sum(narrow);
    fprintf('%s: narrow n=%d (ptDur med=%.3f ms), broad n=%d (ptDur med=%.3f ms)\n', ...
        methods{m}, nN, median(ptDur(narrow)), n-nN, median(ptDur(~narrow)));

    % E/I table
    tbl_m = [sum(E & narrow),  sum(E & ~narrow);
             sum(I & narrow),  sum(I & ~narrow)];
    % Standard two-sided Fisher's exact test 
    % (computed via enumeration using the hypergeometric probability density function, as an alternative to the potentially problematic `fishertest` function)
    R1t = sum(tbl_m(1,:)); R2t = sum(tbl_m(2,:)); C1t = sum(tbl_m(:,1)); Nt = sum(tbl_m(:));
    p0 = hygepdf(tbl_m(1,1), Nt, C1t, R1t);
    ks = 0:C1t;
    ps = hygepdf(ks, Nt, C1t, R1t);
    pFish_m = sum(ps(ps <= p0 + 1e-15));
    fprintf('  [%s] E/I x narrow/broad:\n', methods{m}); disp(tbl_m);
    fprintf('  [%s] Fisher exact p = %.4f; I narrow = %.1f%% (%d/%d); E narrow = %.1f%% (%d/%d)\n', ...
        methods{m}, pFish_m, ...
        100*tbl_m(2,1)/sum(I), tbl_m(2,1), sum(I), ...
        100*tbl_m(1,1)/sum(E), tbl_m(1,1), sum(E));
    if m == 1
        % Not used for analysis; just for figure
        tbl = tbl_m; pFish = pFish_m; narrowGMM = narrow;
    else
        narrowKM = narrow; tblKM = tbl_m; pFishKM = pFish_m;
    end
end

%% 4. Determining a Threshold via 1D GMM (Objective Approach, Replacing Manual Threshold Selection)
% Objective: Identify the intersection point of two components within the 1D distribution of `ptDur` to serve as the boundary between "narrow" and "broad" categories.
% Note: Unlike the 2D GMM clustering described in Section 3, this method is used solely for "threshold determination" rather than for classification.
%       The paper includes only this step, not the 2D clustering approach.
gm1 = fitgmdist(ptDur, 2, 'Replicates', 100);
mu1 = gm1.mu(:);
sg1 = sqrt(squeeze(gm1.Sigma)); sg1 = sg1(:);

xx = linspace(min(ptDur), max(ptDur), 2000)';
dd = normpdf(xx, mu1(1), sg1(1)) - normpdf(xx, mu1(2), sg1(2));
ix = find(dd(1:end-1) .* dd(2:end) < 0);
thrCand = xx(ix);
% Select only the intersection point that falls between the two means (when variances are unequal, the equation may have two solutions).
thr_gmm = thrCand(thrCand > min(mu1) & thrCand < max(mu1));
if isempty(thr_gmm)
    warning('未找到两峰间交点，退回均值中点');
    thr_gmm = mean(mu1);
else
    thr_gmm = thr_gmm(1);
end

fprintf('\n[1D-GMM] mu = %.4f / %.4f ms, sigma = %.4f / %.4f ms\n', ...
    mu1(1), mu1(2), sg1(1), sg1(2));
fprintf('[1D-GMM] threshold (intersection) = %.4f ms\n', thr_gmm);

% Thresholding + Fisher
narrowT = ptDur < thr_gmm;
tblT = [sum(E & narrowT),  sum(E & ~narrowT);
        sum(I & narrowT),  sum(I & ~narrowT)];
R1t = sum(tblT(1,:)); C1t = sum(tblT(:,1)); Nt = sum(tblT(:));
p0  = hygepdf(tblT(1,1), Nt, C1t, R1t);
ps  = hygepdf(0:C1t, Nt, C1t, R1t);
pFishT = sum(ps(ps <= p0 + 1e-15));

% Effect size + 95% CI
nE1 = tblT(1,1); nE0 = tblT(1,2); nI1 = tblT(2,1); nI0 = tblT(2,2);
OR    = (nI1*nE0) / (nE1*nI0);
seOR  = sqrt(1/nE1 + 1/nE0 + 1/nI1 + 1/nI0);
CIOR  = exp(log(OR) + [-1 1]*1.96*seOR);

fprintf('[1D-GMM] E/I x narrow/broad:\n'); disp(tblT);
fprintf('[1D-GMM] Fisher p = %.4g; OR = %.2f [95%% CI %.2f-%.2f]\n', ...
    pFishT, OR, CIOR(1), CIOR(2));
fprintf('[1D-GMM] I narrow = %.1f%% (%d/%d); E narrow = %.1f%% (%d/%d)\n', ...
    100*nI1/sum(I), nI1, sum(I), 100*nE1/sum(E), nE1, sum(E));

%% 5. Discriminative Power of Individual Features
fprintf('\n单特征 AUC（E=0 vs I=1；AUC<0.5 时取反向并翻转方向说明）：\n');
featNames1 = {'ptDur','asym','spont','bestFMrate','bestFMdepth'};
F1 = [ptDur, asym, spont, double(B.bestFMrate), double(B.bestFMdepth)];
for j = 1:numel(featNames1)
    f = F1(E|I, j); yy = double(I(E|I));
    [~,~,~,a] = perfcurve(yy, f, 1);
    if a < 0.5, a = 1 - a; end
    fprintf('  %-12s AUC = %.3f\n', featNames1{j}, a);
end

%% 6. Classifier Comparison: 5-fold CV AUC (Evaluating whether non-linear boundaries offer superior performance)
EIidx = find(E | I);
y = double(I(EIidx));
featSets = {
    'waveform only',             [ptDur(EIidx), asym(EIidx)]
    'waveform + spont',          [ptDur(EIidx), asym(EIidx), rateFeat(EIidx,:)]
    'waveform + spont + bestFM', [ptDur(EIidx), asym(EIidx), rateFeat(EIidx,:), ...
                                   double(B.bestFMrate(EIidx)), double(B.bestFMdepth(EIidx))]
    };
k = 5;
cv = cvpartition(y, 'KFold', k, 'Stratify', true);
classNames = {'logistic','QDA','SVM-RBF'};
aucAll = zeros(size(featSets,1), numel(classNames));
for s = 1:size(featSets,1)
    Xs = featSets{s,2}; nm = featSets{s,1};
    for c = 1:numel(classNames)
        aucs = zeros(k,1);
        for fold = 1:k
            trI = training(cv, fold); teI = test(cv, fold);
            switch classNames{c}
                case 'logistic'
                    mdl = fitglm(Xs(trI,:), y(trI), 'Distribution', 'binomial');
                    phat = predict(mdl, Xs(teI,:));
                    [~,~,~,auc] = perfcurve(y(teI), phat, 1);
                case 'QDA'
                    mdl = fitcdiscr(Xs(trI,:), y(trI), 'DiscrimType', 'quadratic');
                    [~,score] = predict(mdl, Xs(teI,:));   % ClassNames 排序为 [0;1]
                    [~,~,~,auc] = perfcurve(y(teI), score(:,2), 1);
                case 'SVM-RBF'
                    mdl = fitcsvm(Xs(trI,:), y(trI), 'KernelFunction', 'rbf', ...
                        'Standardize', true, 'KernelScale', 'auto');
                    [~,score] = predict(mdl, Xs(teI,:));  % score(:,2) = I 类得分
                    [~,~,~,auc] = perfcurve(y(teI), score(:,2), 1);
            end
            aucs(fold) = auc;
        end
        aucAll(s,c) = mean(aucs);
        fprintf('%-24s %-10s CV AUC = %.3f +- %.3f\n', nm, classNames{c}, mean(aucs), std(aucs));
    end
end

%% 7. Figure 1
figure('Position', [100 100 1120 470]);

ax1 = subplot(1,2,1); hold on;
cc  = {[0.62 0.62 0.62], [0.84 0.15 0.16], [0.12 0.47 0.71]};  % no resp / Excited / Inhibited
% marker 按 E/I 区分：Excited 圆点，Inhibited 三角，no resp 小圆点
mkU  = {'o', 'o', '^'};    % 索引 u+1: u=0 no resp, u=1 E, u=2 I
mszU = [4, 5, 6];
lab  = {'Not trill-responsive', 'Excited', 'Inhibited'};
h = gobjects(3,1);
for u = [0 1 2]   % 先画 no resp（灰色垫底），再画 E/I
    idx = find(unitlist == u);
    if isempty(idx), continue; end
    h(u+1) = plot(ptDur(idx), asym(idx), 'Color', cc{u+1}, 'Marker', mkU{u+1}, ...
        'MarkerFaceColor', cc{u+1}, 'LineStyle', 'none', 'MarkerSize', mszU(u+1));
end
legend([h(2) h(3) h(1)], ...
    {sprintf('Excited (n=%d)', sum(E)), ...
     sprintf('Inhibited (n=%d)', sum(I)), ...
     sprintf('Not trill-responsive (n=%d)', sum(unitlist==0))}, ...
    'Location', 'northeast', 'FontSize', 8);
xlabel('Peak-to-trough duration (ms)'); ylabel('Asymmetry |peak/trough|');
% 一维 GMM 交点：narrow/broad 分界（虚线，灰色，不抢散点）
xline(thr_gmm, '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1.2);
text(thr_gmm + 0.008, max(ylim)*0.96, sprintf('GMM threshold = %.2f ms', thr_gmm), ...
    'FontSize', 9, 'Color', [0.25 0.25 0.25], 'VerticalAlignment', 'top');
title('Waveform features by response type');

ax2 = subplot(1,2,2); axis off;
x0 = 0.08; dx = 0.20; y0 = 0.78; dy = 0.16;
hdr = {'', 'Narrow', 'Broad', 'Total'};
dat = {'Excited', sprintf('%d', tblT(1,1)), sprintf('%d', tblT(1,2)), sprintf('%d', sum(E));
       'Inhibited', sprintf('%d', tblT(2,1)), sprintf('%d', tblT(2,2)), sprintf('%d', sum(I))};
for j = 1:4
    text(x0 + (j-1)*dx, y0, hdr{j}, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
for i = 1:2
    for j = 1:4
        text(x0 + (j-1)*dx, y0 - i*dy, dat{i,j}, 'HorizontalAlignment', 'center', ...
            'FontWeight', 'normal');
    end
end
title(sprintf('E/I x cell type (Fisher exact p = %.3g, OR = %.2f)\nI narrow %.0f%% vs E narrow %.0f%%', ...
    pFishT, OR, 100*tblT(2,1)/sum(I), 100*tblT(1,1)/sum(E)));

saveas(gcf, 'celltype_EI_analysis.png');
disp('saved: celltype_EI_analysis.png');

%% 8. Figure 2 (2D/3D comparison)
% Panels 1–3: ptDur × spont / asym × spont / ptDur × asym (using only two colors for E/I for clarity)
% Panel 4: 3D plot (ptDur, asym, spont) – rotatable for viewing
figure('Position', [80 80 1500 420]);

panels = {[ptDur, spont], 'Peak-to-trough duration (ms)', 'Spont. rate (Hz)';
          [asym,  spont], 'Asymmetry |peak/trough|',      'Spont. rate (Hz)';
          [ptDur, asym ], 'Peak-to-trough duration (ms)', 'Asymmetry |peak/trough|'};
for p = 1:3
    subplot(1,4,p); hold on;
    Xp = panels{p,1};
    idxI = find(I); idxE = find(E);
    plot(Xp(idxE,1), Xp(idxE,2), 'o', 'Color', cc{2}, 'MarkerFaceColor', cc{2}, ...
        'MarkerSize', 4, 'LineStyle', 'none', 'DisplayName', sprintf('Excited (n=%d)', numel(idxE)));
    plot(Xp(idxI,1), Xp(idxI,2), '^', 'Color', cc{3}, 'MarkerFaceColor', cc{3}, ...
        'MarkerSize', 5, 'LineStyle', 'none', 'DisplayName', sprintf('Inhibited (n=%d)', numel(idxI)));
    xlabel(panels{p,2}); ylabel(panels{p,3});
    % Use ptDur threshold line
    if p == 1 || p == 3
        xline(thr_gmm, '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1);
    end
    if p == 1, legend('Location', 'best', 'FontSize', 8); end
end

subplot(1,4,4); hold on;
idxNR = find(unitlist == 0);
plot3(ptDur(idxNR), asym(idxNR), spont(idxNR), 'o', 'Color', cc{1}, ...
    'MarkerFaceColor', cc{1}, 'MarkerSize', 3, 'LineStyle', 'none');
plot3(ptDur(E), asym(E), spont(E), 'o', 'Color', cc{2}, 'MarkerFaceColor', cc{2}, ...
    'MarkerSize', 5, 'LineStyle', 'none');
plot3(ptDur(I), asym(I), spont(I), '^', 'Color', cc{3}, 'MarkerFaceColor', cc{3}, ...
    'MarkerSize', 6, 'LineStyle', 'none');
xlabel('ptDur (ms)'); ylabel('asym'); zlabel('spont (Hz)');
title('3D distribution (rotate with rotate3d)');
view([-35 25]); grid on;

saveas(gcf, 'celltype_distribution_2d3d.png');
disp('saved: celltype_distribution_2d3d.png');
disp('在 3D 面板上执行 rotate3d on 可交互旋转查看 E/I 点云是否可分');
