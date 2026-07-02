function PCA_CM = fm_pca_2factor_conditionmean(spk_hist, varargin)
% PCA on condition means for non-simultaneously recorded neurons
% spk_hist: [N x Trials x T]
% Creates per-neuron condition means, stacks across neurons, runs PCA.
%
% Outputs (original + extensions):
% - coeff, explained, mu: PCA decomposition (on time-concatenated condition means)
% - scores_cond: [C x T x NumPC] PC scores of condition means over time
% - mean_traj: [R x D x T x d3] reshaped scores for first PCs (condition means only)
% - mean_traj_depthAvg: [R x T x d3] average across depths per rate (NEW)
% - mean_traj_rateAvg : [D x T x d3] average across rates per depth (NEW)
% - Dmtx_mahal: [C x C x T] Mahalanobis distances between condition means over time (NEW name)
% - Dmtx_eucl : [C x C x T] Euclidean distances between condition means over time (NEW)
% - md_all: [T x 1] average pairwise distance over conditions (selected DistType)
% - md_rate_only: [T x 1] avg distance for pairs differing only in rate (same depth) (NEW)
% - md_depth_only: [T x 1] avg distance for pairs differing only in depth (same rate) (NEW)
% - md_all_CI: [T x 3] bootstrap mean, lower, upper (NEW)
% - md_rate_only_CI: [T x 3] bootstrap CI (NEW)
% - md_depth_only_CI: [T x 3] bootstrap CI (NEW)
% - params, cond_labels
%
% New options:
%   'PlotAvgOverlays'     : true/false to overlay depth-avg and rate-avg on traj figure
%   'DistType'            : 'Mahalanobis' (default) or 'Euclidean' for md_* outputs and plots
%   'AlsoComputeEuclidean': true/false to compute/store Dmtx_eucl alongside Mahalanobis
%   'NBoot'               : bootstrap iterations for CI (default 1000)
%   'Alpha'               : CI alpha (default 0.05)
%   'KforMD'              : number of PCs to use for distance (Mahalanobis or Euclidean) (default 5)
%   'AvgLineWidth'        : line width for overlays (default 3)

p = inputParser;
p = inputParser;
addParameter(p,'NumRates',5);
addParameter(p,'NumDepths',4);
addParameter(p,'TrialsPerCond',10);
addParameter(p,'Zscore',true);
addParameter(p,'TimeMask',[]);
addParameter(p,'SmoothWin',0);
addParameter(p,'NumPC',10);
addParameter(p,'KforMD',5);
addParameter(p,'SliceTimes',[]);
addParameter(p,'Plot',true);
% New (from prior merge)
addParameter(p,'PlotAvgOverlays',true);
addParameter(p,'DistType','Mahalanobis');
addParameter(p,'AlsoComputeEuclidean',true);
addParameter(p,'NBoot',1000);
addParameter(p,'Alpha',0.05);
addParameter(p,'AvgLineWidth',3);
% New controls for separate clean plots
addParameter(p,'PlotAvgSeparateDepth',true); % shows only depth-avg per rate
addParameter(p,'PlotAvgSeparateRate',true);  % shows only rate-avg per depth
addParameter(p,'PlotAvgSliceDepth',true);    % 2D scatter at selected times for depth-avg
addParameter(p,'PlotAvgSliceRate',true);     % 2D scatter at selected times for rate-avg
parse(p,varargin{:}); S=p.Results;

[N, Trials, T] = size(spk_hist);
assert(Trials == S.NumRates*S.NumDepths*S.TrialsPerCond, 'Trial count mismatch');

% Time subset
if ~isempty(S.TimeMask)
  spk_hist = spk_hist(:,:,S.TimeMask);
  T = size(spk_hist,3);
end

% Smoothing
if S.SmoothWin > 1
  k = ones(1,S.SmoothWin)/S.SmoothWin;
  for n=1:N
    for tr=1:Trials
      spk_hist(n,tr,:) = conv(squeeze(spk_hist(n,tr,:)), k, 'same');
    end
  end
end

% Build condition trial indices
idx = cell(S.NumRates, S.NumDepths);
tid = 0;
for r=1:S.NumRates
  for d=1:S.NumDepths
    idx{r,d} = (1:S.TrialsPerCond) + tid;
    tid = tid + S.TrialsPerCond;
  end
end

% Compute condition means per neuron: [N x C x T]
C = S.NumRates * S.NumDepths;
cond_mean = nan(N, C, T);
c = 0;
for r=1:S.NumRates
  for d=1:S.NumDepths
    c = c + 1;
    tr = idx{r,d};
    cond_mean(:,c,:) = mean(spk_hist(:,tr,:), 2, 'omitnan');
  end
end

% Optional z-score per neuron across conditions and time
if S.Zscore
  mu_n = squeeze(mean(cond_mean, [2 3], 'omitnan'));            % [N]
  sd_n = squeeze(std(cond_mean, 0, [2 3], 'omitnan')) + eps;    % [N]
  for n=1:N
    cond_mean(n,:,:) = (cond_mean(n,:,:) - mu_n(n)) / sd_n(n);
  end
end

% PCA on pooled time (stable axes)
Xall = [];
for t=1:T
  Xt = squeeze(cond_mean(:,:,t))'; % [C x N]
  Xall = [Xall; Xt];
end
[coeff, ~, ~, ~, explained, mu] = pca(Xall, 'Centered', true);
NumPC = min(S.NumPC, size(coeff,2));

% Project per time
scores_cond = nan(C, T, NumPC);
for t=1:T
  Xt = squeeze(cond_mean(:,:,t))'; % [C x N]
  scores_cond(:,t,:) = (Xt - mu) * coeff(:,1:NumPC);
end

% Reshape mean trajectories per (rate, depth) for first up to 3 PCs
d3 = min(3, NumPC);
mean_traj = nan(S.NumRates, S.NumDepths, T, d3);
c = 0;
for r=1:S.NumRates
  for d=1:S.NumDepths
    c = c + 1;
    mean_traj(r,d,:,:) = squeeze(scores_cond(c,:,1:d3));
  end
end

% NEW: averages over factors
mean_traj_depthAvg = nan(S.NumRates, T, d3); % avg across depths
for r=1:S.NumRates
  mean_traj_depthAvg(r,:,:) = squeeze(mean(mean_traj(r,:,:,:), 2, 'omitnan'));
end
mean_traj_rateAvg = nan(S.NumDepths, T, d3); % avg across rates
for d=1:S.NumDepths
  mean_traj_rateAvg(d,:,:) = squeeze(mean(mean_traj(:,d,:,:), 1, 'omitnan'));
end

% Labels
cond_labels = strings(C,1);
c=0;
for r=1:S.NumRates
  for d=1:S.NumDepths
    c=c+1; cond_labels(c) = sprintf('R%d-D%d', r, d);
  end
end

% Distance computations (Mahalanobis and/or Euclidean) using K PCs
K = min(S.KforMD, NumPC);
Dmtx_mahal = nan(C, C, T);
Dmtx_eucl  = nan(C, C, T);

for t=1:T
  Sk = squeeze(scores_cond(:, t, 1:K)); % [C x K]
  % Mahalanobis
  Sigma = cov(Sk);                       % covariance across conditions
  if rcond(Sigma) < 1e-6
    % Regularize
    Sigma = Sigma + 1e-3*eye(size(Sigma));
  end
  invSig = pinv(Sigma);
  for i=1:C
    for j=1:C
      v = Sk(i,:) - Sk(j,:);
      Dmtx_mahal(i,j,t) = sqrt(max(0, v * invSig * v'));
      Dmtx_eucl(i,j,t)  = norm(v);
    end
  end
end

% Choose primary distance type for md_* outputs
useMah = strcmpi(S.DistType,'Mahalanobis');
if useMah
  Dmtx_primary = Dmtx_mahal;
else
  Dmtx_primary = Dmtx_eucl;
end

% Pair masks
% - all unordered pairs
mask_all = triu(true(C),1);
% - pairs differing only in rate (same depth): for each depth d, all pairs of rates
mask_rate_only = false(C,C);
for d=1:S.NumDepths
  conds_d = ((1:S.NumRates)-1)*S.NumDepths + d; % indices at depth d
  for i=1:numel(conds_d)
    for j=i+1:numel(conds_d)
      mask_rate_only(conds_d(i), conds_d(j)) = true;
    end
  end
end
% - pairs differing only in depth (same rate): for each rate r, all pairs of depths
mask_depth_only = false(C,C);
for r=1:S.NumRates
  conds_r = (r-1)*S.NumDepths + (1:S.NumDepths); % indices at rate r
  for i=1:numel(conds_r)
    for j=i+1:numel(conds_r)
      mask_depth_only(conds_r(i), conds_r(j)) = true;
    end
  end
end

% Average distances over time
md_all        = nan(T,1);
md_rate_only  = nan(T,1);
md_depth_only = nan(T,1);
for t=1:T
  M = Dmtx_primary(:,:,t);
  md_all(t)        = mean(M(mask_all), 'omitnan');
  md_rate_only(t)  = mean(M(mask_rate_only), 'omitnan');
  md_depth_only(t) = mean(M(mask_depth_only), 'omitnan');
end

% Bootstrap confidence intervals over pairs
NBoot = S.NBoot; alpha = S.Alpha;
md_all_CI        = nan(T,3);
md_rate_only_CI  = nan(T,3);
md_depth_only_CI = nan(T,3);

% Precompute pair index lists
[i_all,  j_all ] = find(mask_all);
[i_rate, j_rate] = find(mask_rate_only);
[i_depth,j_depth]= find(mask_depth_only);

for t=1:T
  M = Dmtx_primary(:,:,t);
  % all pairs
  vals_all = M(sub2ind([C C], i_all, j_all));
  boot_all = boot_mean(vals_all, NBoot);
  md_all_CI(t,:) = [mean(vals_all,'omitnan'), prctile(boot_all, 100*alpha/2), prctile(boot_all, 100*(1-alpha/2))];
  % rate-only
  vals_rate = M(sub2ind([C C], i_rate, j_rate));
  boot_rate = boot_mean(vals_rate, NBoot);
  md_rate_only_CI(t,:) = [mean(vals_rate,'omitnan'), prctile(boot_rate, 100*alpha/2), prctile(boot_rate, 100*(1-alpha/2))];
  % depth-only
  vals_depth = M(sub2ind([C C], i_depth, j_depth));
  boot_depth = boot_mean(vals_depth, NBoot);
  md_depth_only_CI(t,:) = [mean(vals_depth,'omitnan'), prctile(boot_depth, 100*alpha/2), prctile(boot_depth, 100*(1-alpha/2))];
end

% Plotting
if S.Plot
  rate_colors  = lines(S.NumRates);
  depth_styles = {'-','--',':','-.','-'};
  depth_markers= {'o','s','d','^','*'};

  % Explained variance
  figure('Name','Explained variance (condition-mean PCA)');
  MaxPC = min(10, NumPC);
  subplot(2,1,1);
  bar(1:MaxPC, explained(1:MaxPC), 0.7); grid on;
  xlabel('PC'); ylabel('Explained variance (%)');
  title(sprintf('Per-PC explained variance (PC1..PC%d)', MaxPC));
  subplot(2,1,2);
  plot(1:MaxPC, cumsum(explained(1:MaxPC)),'-o','LineWidth',1.6); grid on;
  xlabel('PC'); ylabel('Cumulative variance (%)');

  % Trajectories of condition means (PC1–PC3) with optional overlays
  figure('Name','Condition-mean trajectories (PC1–PC3)');
  hold on; grid on;
  mk_t = round(linspace(1,T,6));
  for r=1:S.NumRates
    for d=1:S.NumDepths
      Y = squeeze(mean_traj(r,d,:,:)); % [T x d3]
      col = rate_colors(r,:);
      if d3 >= 3
        plot3(Y(:,1), Y(:,2), Y(:,3), 'LineStyle', depth_styles{d}, 'Color', col, 'LineWidth', 1.8);
        plot3(Y(mk_t,1), Y(mk_t,2), Y(mk_t,3), depth_markers{d}, 'Color', col, 'MarkerFaceColor', col, 'MarkerSize',5, 'LineStyle','none');
        xlabel('PC1'); ylabel('PC2'); zlabel('PC3'); view(3);
      elseif d3 >= 2
        plot(Y(:,1), Y(:,2), 'LineStyle', depth_styles{d}, 'Color', col, 'LineWidth', 1.8);
        plot(mk_t, Y(mk_t,1), depth_markers{d}, 'Color', col, 'MarkerFaceColor', col, 'MarkerSize',5, 'LineStyle','none');
        xlabel('PC1'); ylabel('PC2');
      else
        plot(1:T, Y(:,1), 'LineStyle', depth_styles{d}, 'Color', col, 'LineWidth', 1.8);
        plot(mk_t, Y(mk_t,1), depth_markers{d}, 'Color', col, 'MarkerFaceColor', col, 'MarkerSize',5, 'LineStyle','none');
        xlabel('Time'); ylabel('PC1');
      end
    end
  end
  title('Condition-mean trajectories: Color=Rate, Style/Marker=Depth');

  if S.PlotAvgOverlays
    % Overlay: average across depths for each rate (thick solid, rate colors)
    for r = 1:S.NumRates
      col = rate_colors(r,:);
      YavgD = squeeze(mean_traj_depthAvg(r,:,:)); % [T x d3]
      if d3 >= 3
        plot3(YavgD(:,1), YavgD(:,2), YavgD(:,3), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
      elseif d3 == 2
        plot(YavgD(:,1), YavgD(:,2), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
      else
        plot(1:T, YavgD(:,1), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
      end
    end
    % Overlay: average across rates for each depth (thick dashed, depth colors)
    depth_colors = hsv(S.NumDepths);
    for d = 1:S.NumDepths
      colD = depth_colors(d,:);
      YavgR = squeeze(mean_traj_rateAvg(d,:,:)); % [T x d3]
      if d3 >= 3
        plot3(YavgR(:,1), YavgR(:,2), YavgR(:,3), '--', 'Color', colD, 'LineWidth', S.AvgLineWidth);
      elseif d3 == 2
        plot(YavgR(:,1), YavgR(:,2), '--', 'Color', colD, 'LineWidth', S.AvgLineWidth);
      else
        plot(1:T, YavgR(:,1), '--', 'Color', colD, 'LineWidth', S.AvgLineWidth);
      end
    end
    legend({'per-depth trajectories','depth-avg per rate (solid)','rate-avg per depth (dashed)'}, 'Location','bestoutside');
  end

  % Distance plots
  figure('Name',sprintf('Pairwise distances (%s) over time', S.DistType));
  subplot(3,1,1); plot(md_all,'k','LineWidth',1.5); hold on;
  plot_ci(md_all_CI); grid on; xlabel('Time'); ylabel('Avg pairwise');
  title(sprintf('All pairs (%s)', S.DistType));
  subplot(3,1,2); plot(md_rate_only,'b','LineWidth',1.5); hold on;
  plot_ci(md_rate_only_CI, [0 0 1]); grid on; xlabel('Time'); ylabel('Rate-only pairs');
  title('Pairs differing only in Rate (same Depth)');
  subplot(3,1,3); plot(md_depth_only,'r','LineWidth',1.5); hold on;
  plot_ci(md_depth_only_CI, [1 0 0]); grid on; xlabel('Time'); ylabel('Depth-only pairs');
  title('Pairs differing only in Depth (same Rate)');

  % Optional: show a few distance matrices
  selT = S.SliceTimes; if isempty(selT), selT = round(linspace(1,T,4)); end
  figure('Name',sprintf('Distance matrices (%s) at selected times', S.DistType));
  for i=1:numel(selT)
    t = selT(i);
    subplot(2, ceil(numel(selT)/2), i);
    imagesc(Dmtx_primary(:,:,t)); axis image; colorbar;
    title(sprintf('t=%d', t)); xlabel('Cond'); ylabel('Cond');
    set(gca,'XTick',1:C,'YTick',1:C,'XTickLabel',cond_labels,'YTickLabel',cond_labels,'TickLabelInterpreter','none'); xtickangle(90);
  end
end

% === Clean figure: Depth-averaged per rate (no background) ===
if S.Plot && S.PlotAvgSeparateDepth
  rate_colors = lines(S.NumRates);
  figure('Name','Depth-averaged trajectories per rate (clean)'); hold on; grid on;
  if d3>=3, view(3); xlabel('PC1'); ylabel('PC2'); zlabel('PC3'); else, xlabel('PC1'); ylabel('PC2'); end
  title('Depth-averaged per rate (thick lines, no background)');
  for r=1:S.NumRates
    col = rate_colors(r,:);
    YavgD = squeeze(mean_traj_depthAvg(r,:,:)); % [T x d3]
    if d3>=3
      plot3(YavgD(:,1), YavgD(:,2), YavgD(:,3), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
    elseif d3==2
      plot(YavgD(:,1), YavgD(:,2), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
    else
      plot(1:T, YavgD(:,1), '-', 'Color', col, 'LineWidth', S.AvgLineWidth);
    end
  end
  legend(arrayfun(@(r) sprintf('Rate %d', r), 1:S.NumRates, 'UniformOutput', false), 'Location','bestoutside');
end

% Optional compact slice scatter for depth-avg
if S.Plot && S.PlotAvgSliceDepth && d3>=2
  rate_colors = lines(S.NumRates);
  selT = S.SliceTimes; if isempty(selT), selT = round(linspace(1,T,4)); end
  figure('Name','Depth-avg per rate: PC1–PC2 slices'); 
  for i=1:numel(selT)
    t = selT(i);
    subplot(2, ceil(numel(selT)/2), i); hold on; grid on;
    XY = zeros(S.NumRates,2);
    for r=1:S.NumRates
      YavgD = squeeze(mean_traj_depthAvg(r,:,:)); % [T x d3]
      XY(r,:) = YavgD(t,1:2);
    end
    scatter(XY(:,1), XY(:,2), 60, rate_colors, 'filled');
    text(XY(:,1), XY(:,2), arrayfun(@(r) sprintf('R%d',r), 1:S.NumRates,'UniformOutput',false), ...
         'FontSize',8, 'VerticalAlignment','bottom');
    xlabel('PC1'); ylabel('PC2'); title(sprintf('t=%d', t));
  end
end

% === Clean figure: Rate-averaged per depth (no background) ===
if S.Plot && S.PlotAvgSeparateRate
  depth_colors = hsv(S.NumDepths);
  figure('Name','Rate-averaged trajectories per depth (clean)'); hold on; grid on;
  if d3>=3, view(3); xlabel('PC1'); ylabel('PC2'); zlabel('PC3'); else, xlabel('PC1'); ylabel('PC2'); end
  title('Rate-averaged per depth (thick lines, no background)');
  for d=1:S.NumDepths
    colD = depth_colors(d,:);
    YavgR = squeeze(mean_traj_rateAvg(d,:,:)); % [T x d3]
    if d3>=3
      plot3(YavgR(:,1), YavgR(:,2), YavgR(:,3), '-', 'Color', colD, 'LineWidth', S.AvgLineWidth);
    elseif d3==2
      plot(YavgR(:,1), YavgR(:,2), '-', 'Color', colD, 'LineWidth', S.AvgLineWidth);
    else
      plot(1:T, YavgR(:,1), '-', 'Color', colD, 'LineWidth', S.AvgLineWidth);
    end
  end
  legend(arrayfun(@(d) sprintf('Depth %d', d), 1:S.NumDepths, 'UniformOutput', false), 'Location','bestoutside');
end

% Optional compact slice scatter for rate-avg
if S.Plot && S.PlotAvgSliceRate && d3>=2
  depth_colors = hsv(S.NumDepths);
  selT = S.SliceTimes; if isempty(selT), selT = round(linspace(1,T,4)); end
  figure('Name','Rate-avg per depth: PC1–PC2 slices'); 
  for i=1:numel(selT)
    t = selT(i);
    subplot(2, ceil(numel(selT)/2), i); hold on; grid on;
    XY = zeros(S.NumDepths,2);
    for d=1:S.NumDepths
      YavgR = squeeze(mean_traj_rateAvg(d,:,:)); % [T x d3]
      XY(d,:) = YavgR(t,1:2);
    end
    scatter(XY(:,1), XY(:,2), 60, depth_colors, 'filled');
    text(XY(:,1), XY(:,2), arrayfun(@(d) sprintf('D%d',d), 1:S.NumDepths,'UniformOutput',false), ...
         'FontSize',8, 'VerticalAlignment','bottom');
    xlabel('PC1'); ylabel('PC2'); title(sprintf('t=%d', t));
  end
end

% Assemble output
PCA_CM = struct();
PCA_CM.coeff = coeff;
PCA_CM.explained = explained;
PCA_CM.mu = mu;
PCA_CM.scores_cond = scores_cond;
PCA_CM.mean_traj = mean_traj;
PCA_CM.mean_traj_depthAvg = mean_traj_depthAvg;
PCA_CM.mean_traj_rateAvg  = mean_traj_rateAvg;
PCA_CM.Dmtx_mahal = Dmtx_mahal;
PCA_CM.Dmtx_eucl  = Dmtx_eucl;
PCA_CM.md_all        = md_all;
PCA_CM.md_rate_only  = md_rate_only;
PCA_CM.md_depth_only = md_depth_only;
PCA_CM.md_all_CI        = md_all_CI;
PCA_CM.md_rate_only_CI  = md_rate_only_CI;
PCA_CM.md_depth_only_CI = md_depth_only_CI;
PCA_CM.params = S;
PCA_CM.cond_labels = cond_labels;
end

% ---------- helpers ----------
function bootvals = boot_mean(vals, NBoot)
% Bootstrap mean from a vector vals (ignores NaNs)
vals = vals(~isnan(vals));
if isempty(vals)
  bootvals = nan(NBoot,1);
  return;
end
n = numel(vals);
bootvals = nan(NBoot,1);
for b=1:NBoot
  idx = randi(n, n, 1);
  bootvals(b) = mean(vals(idx));
end
end

function plot_ci(CI, col)
% CI: [T x 3] [mean, lower, upper]
if nargin<2, col = [0 0 0]; end
t = (1:size(CI,1))';
m = CI(:,1); lo = CI(:,2); hi = CI(:,3);
fill([t; flipud(t)], [lo; flipud(hi)], col, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot(t, m, '-', 'Color', col, 'LineWidth', 1.2);
end
