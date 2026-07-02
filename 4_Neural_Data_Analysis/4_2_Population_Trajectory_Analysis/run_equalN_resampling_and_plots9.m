function RS = run_equalN_resampling_and_plots5(spk_hist, PCA_CM, idx_groups, varargin)
% Equal-N resampling analysis and plotting with overlay and summary figures.
% Includes:
% - trajectory plots
% - distance time-courses
% - summary violin plots
% - confusion-style summary matrices with significance asterisks
% - rate-pair violin plots collapsed across depth
% - rate-pair summary matrix per group with significance stars
% - depth-pair violin plots collapsed across rate
% - depth-pair summary matrix per group with significance stars

% ---------------- Parse inputs ----------------
p = inputParser;
addParameter(p,'TargetN', []);
addParameter(p,'NResamples', 200);
addParameter(p,'NumPC', min(5, size(PCA_CM.scores_cond,3)));
addParameter(p,'KforMD', []);
addParameter(p,'PCDims', []);
addParameter(p,'AlphaCI', 0.05);
addParameter(p,'RateColors', []);
addParameter(p,'DepthStyles', {'-','--',':','-.','-'});
addParameter(p,'DepthMarkers', {'o','s','d','^','*'});
addParameter(p,'MarkerSlices', 6);
addParameter(p,'GroupOrder', []);
addParameter(p,'DistType', 'Mahalanobis');
addParameter(p,'PlotAvgOverlays', false);
addParameter(p,'PlotAvgSeparateDepth', true);
addParameter(p,'PlotAvgSeparateRate', true);
addParameter(p,'PlotAvgSliceDepth', true);
addParameter(p,'PlotAvgSliceRate', true);
addParameter(p,'AvgLineWidth', 3);
addParameter(p,'PlotRateOnlyByDepth', true);
addParameter(p,'PlotDepthOnlyByRate', true);
addParameter(p,'OverlayGroupColors', []);
addParameter(p,'PlotOverlayRateOnly', true);
addParameter(p,'PlotOverlayDepthOnly', true);

% Summary options
addParameter(p,'SummaryTimeWindow', []);
addParameter(p,'PlotSummaryByRateDepth', true);
addParameter(p,'SummaryShowViolin', true);
addParameter(p,'SummaryShowCI', true);
addParameter(p,'SummaryGroupColors', []);
addParameter(p,'SummaryDoStats', true);
addParameter(p,'SummaryStatMethod', 'auto'); % 'auto'|'anova'|'kruskal'
addParameter(p,'SummaryPairwise', true);
addParameter(p,'SummaryIntervalType', 'ci_mean'); % 'ci_mean'|'iqr'|'percentile'|'sd'
addParameter(p,'SummaryPercentile', [2.5 97.5]);

% Confusion summary
addParameter(p,'PlotSummaryConfusion', true);
addParameter(p,'SummaryConfusionMetric', 'auc'); % 'auc'|'meandiff'
addParameter(p,'SummaryConfusionAbsolute', true);
addParameter(p,'SummaryConfusionShowSig', true);
addParameter(p,'SummaryConfusionAlpha', 0.05);
addParameter(p,'SummaryConfusionSigMethod', 'ranksum'); % 'ranksum'|'ttest'
addParameter(p,'SummaryConfusionFDR', true);

% Rate-pair analysis
addParameter(p,'PlotRatePairViolins', true);
addParameter(p,'RatePairViolinUseSummaryWindow', true);
addParameter(p,'PlotRatePairMatrix', true);
addParameter(p,'PlotRatePairMatrixSig', true);
addParameter(p,'RatePairMatrixSigMethod', 'ranksum'); % 'ranksum'|'ttest'
addParameter(p,'RatePairMatrixSigAlpha', 0.05);
addParameter(p,'RatePairMatrixSigFDR', true);

% Depth-pair analysis
addParameter(p,'PlotDepthPairViolins', true);
addParameter(p,'DepthPairViolinUseSummaryWindow', true);
addParameter(p,'PlotDepthPairMatrix', true);
addParameter(p,'PlotDepthPairMatrixSig', true);
addParameter(p,'DepthPairMatrixSigMethod', 'ranksum'); % 'ranksum'|'ttest'
addParameter(p,'DepthPairMatrixSigAlpha', 0.05);
addParameter(p,'DepthPairMatrixSigFDR', true);

parse(p, varargin{:});
S = p.Results;

% Harden fields
if ~isfield(S,'MarkerSlices') || isempty(S.MarkerSlices)
  S.MarkerSlices = 6;
end
S.MarkerSlices = max(1, round(S.MarkerSlices));

if isempty(S.KforMD), S.KforMD = min(5, S.NumPC); end
if isempty(S.PCDims), S.PCDims = min(3, size(PCA_CM.mean_traj,4)); end

R = PCA_CM.params.NumRates;
D = PCA_CM.params.NumDepths;
T = size(PCA_CM.mean_traj, 3);

if isempty(S.RateColors), S.RateColors = lines(R); end

if numel(S.DepthMarkers) < D
  S.DepthMarkers = repmat(S.DepthMarkers, 1, ceil(D/numel(S.DepthMarkers)));
end
if numel(S.DepthStyles) < D
  S.DepthStyles = repmat(S.DepthStyles, 1, ceil(D/numel(S.DepthStyles)));
end
S.DepthMarkers = S.DepthMarkers(1:D);
S.DepthStyles  = S.DepthStyles(1:D);

% Order groups
gNames_all = fieldnames(idx_groups);
if ~isempty(S.GroupOrder)
  gNames = S.GroupOrder(ismember(S.GroupOrder, gNames_all));
else
  gNames = gNames_all;
end
numGroups = numel(gNames);

if isempty(S.OverlayGroupColors), S.OverlayGroupColors = lines(numGroups); end
if isempty(S.SummaryGroupColors), S.SummaryGroupColors = lines(numGroups); end

% Summary window setup
tStart = [];
tEnd   = [];
if ~isempty(S.SummaryTimeWindow) && numel(S.SummaryTimeWindow) >= 2
  tStart = max(1, S.SummaryTimeWindow(1));
  tEnd   = min(T, S.SummaryTimeWindow(2));
end

% ---------------- Resampling ----------------
if ~isempty(tStart) && ~isempty(tEnd)
  summaryWin_for_resample = [tStart tEnd];
else
  summaryWin_for_resample = [];
end

RS = resampled_group_spread(spk_hist, PCA_CM, idx_groups, ...
      'TargetN', S.TargetN, 'NResamples', S.NResamples, ...
      'NumRates', R, 'NumDepths', D, ...
      'TrialsPerCond', PCA_CM.params.TrialsPerCond, ...
      'TimeMask', PCA_CM.params.TimeMask, ...
      'SmoothWin', PCA_CM.params.SmoothWin, ...
      'Zscore', PCA_CM.params.Zscore, ...
      'NumPC', S.NumPC, 'KforMD', S.KforMD, ...
      'LambdaReg', 0.1, 'ReturnTraj', true, ...
      'DistType', S.DistType, ...
      'SummaryTimeWindow', summaryWin_for_resample, ...
      'RatePairMatrixSigMethod', S.RatePairMatrixSigMethod, ...
      'RatePairMatrixSigAlpha', S.RatePairMatrixSigAlpha, ...
      'RatePairMatrixSigFDR', S.RatePairMatrixSigFDR, ...
      'DepthPairMatrixSigMethod', S.DepthPairMatrixSigMethod, ...
      'DepthPairMatrixSigAlpha', S.DepthPairMatrixSigAlpha, ...
      'DepthPairMatrixSigFDR', S.DepthPairMatrixSigFDR);

% ---------------- Trajectory plots ----------------
mk_t = unique(round(linspace(1, T, S.MarkerSlices)));
C = R*D;

for gi = 1:numel(gNames)
  gname = gNames{gi};
  G = RS.(gname);
  if ~isfield(G, 'traj_median') || isempty(G.traj_median), continue; end

  figName = sprintf('Equal-N median trajectories: %s (TargetN=%d, NResamples=%d, Dist=%s)', ...
                    gname, RS.params.TargetN, RS.params.NResamples, S.DistType);
  figure('Color','w','Name', figName); hold on; grid on;
  if S.PCDims >= 3, view(3); end
  xlabel('PC1'); ylabel('PC2'); if S.PCDims >= 3, zlabel('PC3'); end
  title(figName);

  traj4 = reshape(G.traj_median(:,:,1:S.PCDims), [C, T, S.PCDims]);
  legend_elems = gobjects(C,1);
  legend_txt = strings(C,1);
  cidx = 0;

  for r = 1:R
    col = S.RateColors(r,:);
    for d = 1:D
      cidx = cidx + 1;
      Y = squeeze(traj4((r-1)*D+d,:,:));
      if S.PCDims >= 3
        h = plot3(Y(:,1), Y(:,2), Y(:,3), S.DepthStyles{d}, 'Color', col, 'LineWidth', 1.8);
        plot3(Y(mk_t,1), Y(mk_t,2), Y(mk_t,3), S.DepthMarkers{d}, ...
          'Color', col, 'MarkerFaceColor', col, 'LineStyle','none', 'MarkerSize', 5);
      else
        h = plot(Y(:,1), Y(:,2), S.DepthStyles{d}, 'Color', col, 'LineWidth', 1.8);
        plot(Y(mk_t,1), Y(mk_t,2), S.DepthMarkers{d}, ...
          'Color', col, 'MarkerFaceColor', col, 'LineStyle','none', 'MarkerSize', 5);
      end
      legend_elems(cidx) = h;
      legend_txt(cidx) = sprintf('R%d-D%d', r, d);
    end
  end
  legend(legend_elems, legend_txt, 'Location','bestoutside');
end

group_linw = linspace(1.2, 2.4, max(1, numel(gNames)));
figNameAll = sprintf('Equal-N median trajectories: ALL GROUPS (TargetN=%d, NResamples=%d, Dist=%s)', ...
                     RS.params.TargetN, RS.params.NResamples, S.DistType);
figure('Color','w','Name', figNameAll); hold on; grid on;
if S.PCDims >= 3, view(3); end
xlabel('PC1'); ylabel('PC2'); if S.PCDims >= 3, zlabel('PC3'); end
title(figNameAll);

legend_entries = {};
legend_handles = gobjects(0);

for gi = 1:numel(gNames)
  gname = gNames{gi};
  G = RS.(gname);
  if ~isfield(G,'traj_median') || isempty(G.traj_median), continue; end
  lw = group_linw(gi);

  for r = 1:R
    col = S.RateColors(r,:);
    for d = 1:D
      Y = squeeze(G.traj_median((r-1)*D+d,:,1:S.PCDims));
      if S.PCDims >= 3
        h = plot3(Y(:,1),Y(:,2),Y(:,3), S.DepthStyles{d}, 'Color', col, 'LineWidth', lw);
      else
        h = plot(Y(:,1),Y(:,2), S.DepthStyles{d}, 'Color', col, 'LineWidth', lw);
      end
      legend_handles(end+1) = h; %#ok<AGROW>
      legend_entries{end+1} = sprintf('%s R%d-D%d', gname, r, d); %#ok<AGROW>
    end
  end
end
legend(legend_handles, legend_entries, 'Location','bestoutside');

% ---------------- Distance time-course panels ----------------
for gi = 1:numel(gNames)
  gname = gNames{gi};
  G = RS.(gname);
  if ~isfield(G,'md_all') || isempty(G.md_all), continue; end

  plot_md_ci_series(G.md_all,        S.AlphaCI, sprintf('Equal-N %s-distance(t): %s (ALL pairs)',  S.DistType, gname), 'Mean pairwise (all pairs)');
  plot_md_ci_series(G.md_rate_only,  S.AlphaCI, sprintf('Equal-N %s-distance(t): %s (Rate-only)',  S.DistType, gname), 'Mean pairwise (rate-only, same depth)');
  plot_md_ci_series(G.md_depth_only, S.AlphaCI, sprintf('Equal-N %s-distance(t): %s (Depth-only)', S.DistType, gname), 'Mean pairwise (depth-only, same rate)');
end

% ---------------- Optional facets ----------------
for gi = 1:numel(gNames)
  gname = gNames{gi};
  G = RS.(gname);

  if S.PlotRateOnlyByDepth && isfield(G,'md_rate_only_byDepth') && ~isempty(G.md_rate_only_byDepth)
    figNameDepthFacets = sprintf('Equal-N %s-distance(t): %s (Rate-only by Depth)', S.DistType, gname);
    figure('Color','w','Name', figNameDepthFacets);
    Dloc = size(G.md_rate_only_byDepth,1);
    nrows = ceil(Dloc/2); ncols = 2;

    for d = 1:Dloc
      subplot(nrows,ncols,d); hold on; grid on;
      md = squeeze(G.md_rate_only_byDepth(d,:,:));
      [tvec, mu, lo, hi] = ci_from_resamples(md, S.AlphaCI);
      fill_ci(tvec, lo, hi, [0.9 0.7 0.7], 0.35);
      plot(tvec, mu, 'r-', 'LineWidth', 1.6);
      xlabel('Time'); ylabel('Rate-only'); title(sprintf('Depth %d', d));
    end
    sgtitle(figNameDepthFacets);
  end

  if S.PlotDepthOnlyByRate && isfield(G,'md_depth_only_byRate') && ~isempty(G.md_depth_only_byRate)
    figNameRateFacets = sprintf('Equal-N %s-distance(t): %s (Depth-only by Rate)', S.DistType, gname);
    figure('Color','w','Name', figNameRateFacets);
    Rloc = size(G.md_depth_only_byRate,1);
    nrows = ceil(Rloc/2); ncols = 2;

    for r = 1:Rloc
      subplot(nrows,ncols,r); hold on; grid on;
      md = squeeze(G.md_depth_only_byRate(r,:,:));
      [tvec, mu, lo, hi] = ci_from_resamples(md, S.AlphaCI);
      fill_ci(tvec, lo, hi, [0.7 0.9 0.7], 0.35);
      plot(tvec, mu, 'g-', 'LineWidth', 1.6);
      xlabel('Time'); ylabel('Depth-only'); title(sprintf('Rate %d', r));
    end
    sgtitle(figNameRateFacets);
  end
end

% ---------------- Overlays across groups ----------------
if S.PlotOverlayRateOnly
  figOverlayRate = sprintf('Overlay across groups: %s-distance (Rate-only, same depth)', S.DistType);
  figure('Color','w','Name', figOverlayRate); hold on; grid on;
  xlabel('Time (index)');
  ylabel('Mean pairwise (rate-only, same depth)');
  title(figOverlayRate);

  legend_entries = cell(1, numGroups);
  for gi = 1:numGroups
    gname = gNames{gi};
    if ~isfield(RS.(gname),'md_rate_only') || isempty(RS.(gname).md_rate_only), continue; end
    md = RS.(gname).md_rate_only;
    [tvec, mu, lo, hi] = ci_from_resamples(md, S.AlphaCI);
    col = S.OverlayGroupColors(gi,:);
    fill_ci(tvec, lo, hi, col, 0.15);
    plot(tvec, mu, '-', 'Color', col, 'LineWidth', 2.0);
    legend_entries{gi} = gname;
  end
  legend(legend_entries, 'Location','best');
end

if S.PlotOverlayDepthOnly
  figOverlayDepth = sprintf('Overlay across groups: %s-distance (Depth-only, same rate)', S.DistType);
  figure('Color','w','Name', figOverlayDepth); hold on; grid on;
  xlabel('Time (index)');
  ylabel('Mean pairwise (depth-only, same rate)');
  title(figOverlayDepth);

  legend_entries = cell(1, numGroups);
  for gi = 1:numGroups
    gname = gNames{gi};
    if ~isfield(RS.(gname),'md_depth_only') || isempty(RS.(gname).md_depth_only), continue; end
    md = RS.(gname).md_depth_only;
    [tvec, mu, lo, hi] = ci_from_resamples(md, S.AlphaCI);
    col = S.OverlayGroupColors(gi,:);
    fill_ci(tvec, lo, hi, col, 0.15);
    plot(tvec, mu, '-', 'Color', col, 'LineWidth', 2.0);
    legend_entries{gi} = gname;
  end
  legend(legend_entries, 'Location','best');
end

% ---------------- Summary across groups ----------------
RS.summary = struct();

if S.PlotSummaryByRateDepth && ~isempty(tStart) && ~isempty(tEnd) && tStart <= tEnd
  [validG_rate, rate_vals_cell]   = extract_window_means_for_groups(RS, gNames, 'md_rate_only',  tStart, tEnd);
  [validG_depth, depth_vals_cell] = extract_window_means_for_groups(RS, gNames, 'md_depth_only', tStart, tEnd);

  [rate_mean, rate_lo, rate_hi]     = mean_ci95_cell(rate_vals_cell);
  [depth_mean, depth_lo, depth_hi]  = mean_ci95_cell(depth_vals_cell);

  RS.summary.rate_only.validGroups = validG_rate;
  RS.summary.rate_only.window_vals = rate_vals_cell;
  RS.summary.rate_only.mean = rate_mean;
  RS.summary.rate_only.ci_lo = rate_lo;
  RS.summary.rate_only.ci_hi = rate_hi;

  RS.summary.depth_only.validGroups = validG_depth;
  RS.summary.depth_only.window_vals = depth_vals_cell;
  RS.summary.depth_only.mean = depth_mean;
  RS.summary.depth_only.ci_lo = depth_lo;
  RS.summary.depth_only.ci_hi = depth_hi;

  figSumRate = sprintf('Summary (Rate-only) %s-distance, [%d %d]: violin + interval (%s)', ...
    S.DistType, tStart, tEnd, S.SummaryIntervalType);
  figure('Color','w','Name', figSumRate);
  plot_group_summary_violin_meanBootstrap(rate_vals_cell, validG_rate, S.SummaryGroupColors, ...
    'Window-mean per bootstrap (rate-only)', ...
    S.SummaryIntervalType, S.SummaryPercentile);
  title(figSumRate);

  rate_stats = [];
  if S.SummaryDoStats && numel(validG_rate) >= 2
    rate_stats = do_group_stats(rate_vals_cell, validG_rate, S.SummaryStatMethod, S.SummaryPairwise);
    subtitle_from_stats(rate_stats);
  end
  RS.summary.rate_only.stats = rate_stats;

  figSumDepth = sprintf('Summary (Depth-only) %s-distance, [%d %d]: violin + interval (%s)', ...
    S.DistType, tStart, tEnd, S.SummaryIntervalType);
  figure('Color','w','Name', figSumDepth);
  plot_group_summary_violin_meanBootstrap(depth_vals_cell, validG_depth, S.SummaryGroupColors, ...
    'Window-mean per bootstrap (depth-only)', ...
    S.SummaryIntervalType, S.SummaryPercentile);
  title(figSumDepth);

  depth_stats = [];
  if S.SummaryDoStats && numel(validG_depth) >= 2
    depth_stats = do_group_stats(depth_vals_cell, validG_depth, S.SummaryStatMethod, S.SummaryPairwise);
    subtitle_from_stats(depth_stats);
  end
  RS.summary.depth_only.stats = depth_stats;
elseif S.PlotSummaryByRateDepth && ~isempty(S.SummaryTimeWindow)
  warning('SummaryTimeWindow invalid (start > end). Skipping summary plots.');
end

% ---------------- Confusion-matrix summary ----------------
if S.PlotSummaryConfusion && ~isempty(tStart) && ~isempty(tEnd) && tStart <= tEnd
  sigOpts = struct( ...
    'doShow', S.SummaryConfusionShowSig, ...
    'alpha',  S.SummaryConfusionAlpha, ...
    'method', S.SummaryConfusionSigMethod, ...
    'doFDR',  S.SummaryConfusionFDR);

  if exist('validG_rate','var') && numel(validG_rate) >= 2
    [M_rate, fig_rate, P_rate, Q_rate] = plot_group_confusion_matrix_from_bootstrap( ...
      rate_vals_cell, validG_rate, ...
      sprintf('Confusion (Rate-only) %s-distance [%d %d]', S.DistType, tStart, tEnd), ...
      S.SummaryConfusionMetric, S.SummaryConfusionAbsolute, sigOpts);

    RS.summary.rate_only.confusion = struct( ...
      'M', M_rate, 'P', P_rate, 'Q', Q_rate, 'fig', fig_rate, ...
      'metric', S.SummaryConfusionMetric, ...
      'absolute', S.SummaryConfusionAbsolute, ...
      'sigOpts', sigOpts);
  end

  if exist('validG_depth','var') && numel(validG_depth) >= 2
    [M_depth, fig_depth, P_depth, Q_depth] = plot_group_confusion_matrix_from_bootstrap( ...
      depth_vals_cell, validG_depth, ...
      sprintf('Confusion (Depth-only) %s-distance [%d %d]', S.DistType, tStart, tEnd), ...
      S.SummaryConfusionMetric, S.SummaryConfusionAbsolute, sigOpts);

    RS.summary.depth_only.confusion = struct( ...
      'M', M_depth, 'P', P_depth, 'Q', Q_depth, 'fig', fig_depth, ...
      'metric', S.SummaryConfusionMetric, ...
      'absolute', S.SummaryConfusionAbsolute, ...
      'sigOpts', sigOpts);
  end
end

% ---------------- Rate-pair violin plots ----------------
if S.PlotRatePairViolins
  for gi = 1:numel(gNames)
    gname = gNames{gi};
    G = RS.(gname);

    if ~isfield(G,'rate_pair_dist') || isempty(G.rate_pair_dist)
      continue;
    end

    if S.RatePairViolinUseSummaryWindow && ~isempty(tStart) && ~isempty(tEnd)
      ttl = sprintf('Rate-pair distances collapsed across depth: %s [%d %d]', gname, tStart, tEnd);
    else
      ttl = sprintf('Rate-pair distances collapsed across depth: %s [full window]', gname);
    end

    figure('Color','w','Name',ttl); hold on; grid on;
    plot_violin_matrix_columns(G.rate_pair_dist', G.rate_pair_labels, []);
    ylabel(sprintf('%s distance', S.DistType));
    title(ttl, 'Interpreter','none');
    xtickangle(45);
  end
end

% ---------------- Rate-pair matrix ----------------
if S.PlotRatePairMatrix
  for gi = 1:numel(gNames)
    gname = gNames{gi};
    G = RS.(gname);

    if ~isfield(G,'rate_pair_matrix_mean') || isempty(G.rate_pair_matrix_mean)
      continue;
    end

    if ~isempty(tStart) && ~isempty(tEnd)
      figName = sprintf('Rate-pair summary matrix: %s [%d %d]', gname, tStart, tEnd);
    else
      figName = sprintf('Rate-pair summary matrix: %s [full window]', gname);
    end

    figure('Color','w','Name', figName);
    imagesc(G.rate_pair_matrix_mean);
    axis image;
    colorbar;
    title(figName, 'Interpreter','none');
    xlabel('FM rate');
    ylabel('FM rate');
    set(gca, 'XTick', 1:R, 'YTick', 1:R);

    hold on;
    for r = 1:R
      plot(r, r, 'kx', 'MarkerSize', 10, 'LineWidth', 1.2);
    end

    clim = caxis;
    for r1 = 1:R
      for r2 = 1:R
        if r1 == r2 || isnan(G.rate_pair_matrix_mean(r1,r2))
          continue;
        end

        val = G.rate_pair_matrix_mean(r1,r2);
        if val > mean(clim)
          txtColor = 'w';
        else
          txtColor = 'k';
        end

        text(r2, r1, sprintf('%.2f', val), ...
          'HorizontalAlignment', 'center', ...
          'VerticalAlignment', 'middle', ...
          'FontSize', 8, ...
          'Color', txtColor);

        if S.PlotRatePairMatrixSig && isfield(G,'rate_pair_matrix_q') && ~isempty(G.rate_pair_matrix_q)
          qv = G.rate_pair_matrix_q(r1,r2);
          stars = p_to_stars(qv, S.RatePairMatrixSigAlpha);
          if ~isempty(stars)
            text(r2, r1-0.28, stars, ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Color', txtColor);
          end
        end
      end
    end
  end
end

% ---------------- Depth-pair violin plots ----------------
if S.PlotDepthPairViolins
  for gi = 1:numel(gNames)
    gname = gNames{gi};
    G = RS.(gname);

    if ~isfield(G,'depth_pair_dist') || isempty(G.depth_pair_dist)
      continue;
    end

    if S.DepthPairViolinUseSummaryWindow && ~isempty(tStart) && ~isempty(tEnd)
      ttl = sprintf('Depth-pair distances collapsed across rate: %s [%d %d]', gname, tStart, tEnd);
    else
      ttl = sprintf('Depth-pair distances collapsed across rate: %s [full window]', gname);
    end

    figure('Color','w','Name',ttl); hold on; grid on;
    plot_violin_matrix_columns(G.depth_pair_dist', G.depth_pair_labels, []);
    ylabel(sprintf('%s distance', S.DistType));
    title(ttl, 'Interpreter','none');
    xtickangle(45);
  end
end

% ---------------- Depth-pair matrix ----------------
if S.PlotDepthPairMatrix
  for gi = 1:numel(gNames)
    gname = gNames{gi};
    G = RS.(gname);

    if ~isfield(G,'depth_pair_matrix_mean') || isempty(G.depth_pair_matrix_mean)
      continue;
    end

    if ~isempty(tStart) && ~isempty(tEnd)
      figName = sprintf('Depth-pair summary matrix: %s [%d %d]', gname, tStart, tEnd);
    else
      figName = sprintf('Depth-pair summary matrix: %s [full window]', gname);
    end

    figure('Color','w','Name', figName);
    imagesc(G.depth_pair_matrix_mean);
    axis image;
    colorbar;
    title(figName, 'Interpreter','none');
    xlabel('FM depth');
    ylabel('FM depth');
    set(gca, 'XTick', 1:D, 'YTick', 1:D);

    hold on;
    for d0 = 1:D
      plot(d0, d0, 'kx', 'MarkerSize', 10, 'LineWidth', 1.2);
    end

    clim = caxis;
    for d1 = 1:D
      for d2 = 1:D
        if d1 == d2 || isnan(G.depth_pair_matrix_mean(d1,d2))
          continue;
        end

        val = G.depth_pair_matrix_mean(d1,d2);
        if val > mean(clim)
          txtColor = 'w';
        else
          txtColor = 'k';
        end

        text(d2, d1, sprintf('%.2f', val), ...
          'HorizontalAlignment', 'center', ...
          'VerticalAlignment', 'middle', ...
          'FontSize', 8, ...
          'Color', txtColor);

        if S.PlotDepthPairMatrixSig && isfield(G,'depth_pair_matrix_q') && ~isempty(G.depth_pair_matrix_q)
          qv = G.depth_pair_matrix_q(d1,d2);
          stars = p_to_stars(qv, S.DepthPairMatrixSigAlpha);
          if ~isempty(stars)
            text(d2, d1-0.28, stars, ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Color', txtColor);
          end
        end
      end
    end
  end
end

end


% ---------- Dependencies ----------

function RS = resampled_group_spread(spk_hist, PCA_CM, idx_groups, varargin)
p = inputParser;
addParameter(p,'NumRates', PCA_CM.params.NumRates);
addParameter(p,'NumDepths', PCA_CM.params.NumDepths);
addParameter(p,'TrialsPerCond', PCA_CM.params.TrialsPerCond);
addParameter(p,'TimeMask', PCA_CM.params.TimeMask);
addParameter(p,'SmoothWin', PCA_CM.params.SmoothWin);
addParameter(p,'Zscore', PCA_CM.params.Zscore);
addParameter(p,'NumPC', min(5, size(PCA_CM.scores_cond,3)));
addParameter(p,'KforMD', []);
addParameter(p,'TargetN', []);
addParameter(p,'NResamples', 200);
addParameter(p,'ReturnTraj', true);
addParameter(p,'LambdaReg', 0.1);
addParameter(p,'DistType', 'Mahalanobis');
addParameter(p,'SummaryTimeWindow', []);

addParameter(p,'RatePairMatrixSigMethod', 'ranksum');
addParameter(p,'RatePairMatrixSigAlpha', 0.05);
addParameter(p,'RatePairMatrixSigFDR', true);

addParameter(p,'DepthPairMatrixSigMethod', 'ranksum');
addParameter(p,'DepthPairMatrixSigAlpha', 0.05);
addParameter(p,'DepthPairMatrixSigFDR', true);

parse(p, varargin{:});
S = p.Results;

if isempty(S.KforMD), S.KforMD = min(5, S.NumPC); end

R = S.NumRates;
D = S.NumDepths;
C = R*D;

coeff_full = PCA_CM.coeff;
mu_ref = PCA_CM.mu(:)';

spk = spk_hist;
[~, Trials, T] = size(spk);

if ~isempty(S.TimeMask)
  spk = spk(:,:,S.TimeMask);
  T = size(spk,3);
end

if S.SmoothWin > 1
  k = ones(1,S.SmoothWin)/S.SmoothWin;
  Nall = size(spk,1);
  for n = 1:Nall
    for tr = 1:Trials
      spk(n,tr,:) = conv(squeeze(spk(n,tr,:)), k, 'same');
    end
  end
end

cond_trials = cell(R, D);
tid = 0;
for r = 1:R
  for d = 1:D
    cond_trials{r,d} = (1:PCA_CM.params.TrialsPerCond) + tid;
    tid = tid + PCA_CM.params.TrialsPerCond;
  end
end

gNames = fieldnames(idx_groups);
sizes = zeros(numel(gNames),1);
for i = 1:numel(gNames)
  sizes(i) = numel(idx_groups.(gNames{i}));
end
if isempty(S.TargetN), S.TargetN = min(sizes); end
TargetN = S.TargetN;

RS = struct();
RS.params = S;

for i = 1:numel(gNames)
  RS.(gNames{i}) = struct( ...
    'md_all', nan(T,S.NResamples), ...
    'md_rate_only', nan(T,S.NResamples), ...
    'md_depth_only', nan(T,S.NResamples), ...
    'md_rate_only_byDepth', nan(D,T,S.NResamples), ...
    'md_depth_only_byRate', nan(R,T,S.NResamples), ...
    'traj_median', [], ...
    'traj_all', [], ...
    'rate_pair_labels', [], ...
    'rate_pair_dist', [], ...
    'rate_pair_matrix_mean', [], ...
    'rate_pair_matrix_lo', [], ...
    'rate_pair_matrix_hi', [], ...
    'rate_pair_matrix_p', [], ...
    'rate_pair_matrix_q', [], ...
    'depth_pair_labels', [], ...
    'depth_pair_dist', [], ...
    'depth_pair_matrix_mean', [], ...
    'depth_pair_matrix_lo', [], ...
    'depth_pair_matrix_hi', [], ...
    'depth_pair_matrix_p', [], ...
    'depth_pair_matrix_q', []);
end

compute_cond_mean_z = @(idx_sel) compute_cond_mean_for_group(spk, idx_sel, cond_trials, S.Zscore);

mask_all = triu(true(C),1);

mask_rate_only = false(C,C);
for d = 1:D
  conds_d = ((1:R)-1)*D + d;
  for i = 1:numel(conds_d)
    for j = i+1:numel(conds_d)
      mask_rate_only(conds_d(i),conds_d(j)) = true;
    end
  end
end

mask_depth_only = false(C,C);
for r = 1:R
  conds_r = (r-1)*D + (1:D);
  for i = 1:numel(conds_r)
    for j = i+1:numel(conds_r)
      mask_depth_only(conds_r(i),conds_r(j)) = true;
    end
  end
end

[i_rate,j_rate]   = find(mask_rate_only);
[i_depth,j_depth] = find(mask_depth_only);

pairs_rate_byDepth = cell(D,1);
for d = 1:D
  conds_d = ((1:R)-1)*D + d;
  P = [];
  for i = 1:numel(conds_d)
    for j = i+1:numel(conds_d)
      P = [P; conds_d(i), conds_d(j)]; %#ok<AGROW>
    end
  end
  pairs_rate_byDepth{d} = P;
end

pairs_depth_byRate = cell(R,1);
for r = 1:R
  conds_r = (r-1)*D + (1:D);
  P = [];
  for i = 1:numel(conds_r)
    for j = i+1:numel(conds_r)
      P = [P; conds_r(i), conds_r(j)]; %#ok<AGROW>
    end
  end
  pairs_depth_byRate{r} = P;
end

% Rate-pair definitions
rate_pair_idx = nchoosek(1:R, 2);
numRatePairs = size(rate_pair_idx, 1);
rate_pair_labels = cell(numRatePairs,1);
for k = 1:numRatePairs
  rate_pair_labels{k} = sprintf('R%d-R%d', rate_pair_idx(k,1), rate_pair_idx(k,2));
end

% Depth-pair definitions
depth_pair_idx = nchoosek(1:D, 2);
numDepthPairs = size(depth_pair_idx, 1);
depth_pair_labels = cell(numDepthPairs,1);
for k = 1:numDepthPairs
  depth_pair_labels{k} = sprintf('D%d-D%d', depth_pair_idx(k,1), depth_pair_idx(k,2));
end

for gi = 1:numel(gNames)
  gname = gNames{gi};
  base_idx = idx_groups.(gname)(:);

  if numel(base_idx) < TargetN
    warning('%s has only %d neurons; skipping.', gname, numel(base_idx));
    continue;
  end

  if S.ReturnTraj
    scores_store = nan(C,T,S.NumPC,S.NResamples);
  else
    scores_store = [];
  end

  if ~isempty(S.SummaryTimeWindow) && numel(S.SummaryTimeWindow) >= 2
    tw1 = max(1, S.SummaryTimeWindow(1));
    tw2 = min(T, S.SummaryTimeWindow(2));
  else
    tw1 = 1;
    tw2 = T;
  end

  rate_pair_store  = nan(numRatePairs,  S.NResamples);
  depth_pair_store = nan(numDepthPairs, S.NResamples);

  for rs = 1:S.NResamples
    idx = randsample(base_idx, TargetN, false);
    cond_mean_sub = compute_cond_mean_z(idx);

    coeff_sub = coeff_full(idx, 1:S.NumPC);
    mu_sub    = mu_ref(idx);

    scores_sub = nan(C, T, S.NumPC);
    for t = 1:T
      Xt = squeeze(cond_mean_sub(:,:,t))';
      Xt_centered = Xt - mu_sub;
      scores_sub(:, t, :) = Xt_centered * coeff_sub;
    end

    K = min(S.KforMD, S.NumPC);
    md_all_t = nan(T,1);
    md_rate_only_t = nan(T,1);
    md_depth_only_t = nan(T,1);
    md_rate_byDepth_t = nan(D,T);
    md_depth_byRate_t = nan(R,T);

    for t = 1:T
      Skt = squeeze(scores_sub(:,t,1:K));

      if strcmpi(S.DistType,'Euclidean')
        M = squareform(pdist(Skt, 'euclidean'));
      else
        Sig = cov(Skt);
        if ~isempty(S.LambdaReg) && S.LambdaReg > 0
          Sig = (1-S.LambdaReg)*Sig + S.LambdaReg*eye(size(Sig));
        end
        if rcond(Sig) < 1e-6
          Sig = Sig + 1e-3*eye(size(Sig));
        end
        invSig = pinv(Sig);
        M = nan(C,C);
        for a = 1:C
          for b = a+1:C
            v = Skt(a,:) - Skt(b,:);
            d = sqrt(max(0, v*invSig*v'));
            M(a,b) = d;
            M(b,a) = d;
          end
        end
      end

      md_all_t(t)        = mean(M(mask_all), 'omitnan');
      md_rate_only_t(t)  = mean(M(sub2ind([C C], i_rate, j_rate)), 'omitnan');
      md_depth_only_t(t) = mean(M(sub2ind([C C], i_depth, j_depth)), 'omitnan');

      for d0 = 1:D
        P = pairs_rate_byDepth{d0};
        if ~isempty(P)
          md_rate_byDepth_t(d0,t) = mean(arrayfun(@(k) M(P(k,1),P(k,2)), 1:size(P,1)), 'omitnan');
        end
      end

      for r0 = 1:R
        P = pairs_depth_byRate{r0};
        if ~isempty(P)
          md_depth_byRate_t(r0,t) = mean(arrayfun(@(k) M(P(k,1),P(k,2)), 1:size(P,1)), 'omitnan');
        end
      end
    end

    RS.(gname).md_all(:,rs)        = md_all_t;
    RS.(gname).md_rate_only(:,rs)  = md_rate_only_t;
    RS.(gname).md_depth_only(:,rs) = md_depth_only_t;
    RS.(gname).md_rate_only_byDepth(:,:,rs) = md_rate_byDepth_t;
    RS.(gname).md_depth_only_byRate(:,:,rs) = md_depth_byRate_t;

    % Window-averaged condition distance matrix
    Mwin = nan(C,C,tw2-tw1+1);
    ttc = 0;
    for t2 = tw1:tw2
      ttc = ttc + 1;
      Skt = squeeze(scores_sub(:,t2,1:K));

      if strcmpi(S.DistType,'Euclidean')
        Mt = squareform(pdist(Skt, 'euclidean'));
      else
        Sig = cov(Skt);
        if ~isempty(S.LambdaReg) && S.LambdaReg > 0
          Sig = (1-S.LambdaReg)*Sig + S.LambdaReg*eye(size(Sig));
        end
        if rcond(Sig) < 1e-6
          Sig = Sig + 1e-3*eye(size(Sig));
        end
        invSig = pinv(Sig);
        Mt = nan(C,C);
        for a = 1:C
          for b = a+1:C
            v = Skt(a,:) - Skt(b,:);
            dtmp = sqrt(max(0, v*invSig*v'));
            Mt(a,b) = dtmp;
            Mt(b,a) = dtmp;
          end
        end
      end
      Mwin(:,:,ttc) = Mt;
    end

    Mbar = mean(Mwin, 3, 'omitnan');

    % Rate-pair distances collapsed across depth
    for kp = 1:numRatePairs
      r1 = rate_pair_idx(kp,1);
      r2 = rate_pair_idx(kp,2);

      vals = nan(D,1);
      for d0 = 1:D
        c1 = (r1-1)*D + d0;
        c2 = (r2-1)*D + d0;
        vals(d0) = Mbar(c1,c2);
      end
      rate_pair_store(kp, rs) = mean(vals, 'omitnan');
    end

    % Depth-pair distances collapsed across rate
    for kp = 1:numDepthPairs
      d1 = depth_pair_idx(kp,1);
      d2 = depth_pair_idx(kp,2);

      vals = nan(R,1);
      for r0 = 1:R
        c1 = (r0-1)*D + d1;
        c2 = (r0-1)*D + d2;
        vals(r0) = Mbar(c1,c2);
      end
      depth_pair_store(kp, rs) = mean(vals, 'omitnan');
    end

    if S.ReturnTraj
      scores_store(:,:,:,rs) = scores_sub;
    end
  end

  if S.ReturnTraj
    RS.(gname).traj_median = median(scores_store, 4, 'omitnan');
  end

  % ---------- Rate-pair summaries ----------
  RS.(gname).rate_pair_labels = rate_pair_labels;
  RS.(gname).rate_pair_dist   = rate_pair_store;

  M_mean = nan(R,R);
  M_lo   = nan(R,R);
  M_hi   = nan(R,R);

  for kp = 1:numRatePairs
    r1 = rate_pair_idx(kp,1);
    r2 = rate_pair_idx(kp,2);

    v = rate_pair_store(kp,:);
    v = v(~isnan(v));
    if isempty(v), continue; end

    m  = mean(v, 'omitnan');
    pr = prctile(v, [2.5 97.5]);

    M_mean(r1,r2) = m; M_mean(r2,r1) = m;
    M_lo(r1,r2)   = pr(1); M_lo(r2,r1) = pr(1);
    M_hi(r1,r2)   = pr(2); M_hi(r2,r1) = pr(2);
  end

  for r0 = 1:R
    M_mean(r0,r0) = NaN;
    M_lo(r0,r0)   = NaN;
    M_hi(r0,r0)   = NaN;
  end

  M_p = nan(R,R);
  M_q = nan(R,R);
  pvec_pairs = nan(numRatePairs,1);

  for kp = 1:numRatePairs
    this_v = rate_pair_store(kp,:);
    this_v = this_v(~isnan(this_v));

    other_idx = setdiff(1:numRatePairs, kp);
    other_v = rate_pair_store(other_idx,:);
    other_v = other_v(:);
    other_v = other_v(~isnan(other_v));

    if isempty(this_v) || isempty(other_v)
      pvec_pairs(kp) = NaN;
      continue;
    end

    switch lower(S.RatePairMatrixSigMethod)
      case 'ranksum'
        try
          p_here = ranksum(this_v, other_v, 'tail', 'right');
        catch
          p_here = NaN;
        end
      case 'ttest'
        try
          [~, p_here] = ttest2(this_v, other_v, 'Vartype', 'unequal', 'Tail', 'right');
        catch
          p_here = NaN;
        end
      otherwise
        error('Unknown RatePairMatrixSigMethod: %s', S.RatePairMatrixSigMethod);
    end

    pvec_pairs(kp) = p_here;
  end

  if S.RatePairMatrixSigFDR
    [qvec_pairs, ~] = fdr_bh(pvec_pairs, S.RatePairMatrixSigAlpha);
  else
    qvec_pairs = pvec_pairs;
  end

  for kp = 1:numRatePairs
    r1 = rate_pair_idx(kp,1);
    r2 = rate_pair_idx(kp,2);

    M_p(r1,r2) = pvec_pairs(kp); M_p(r2,r1) = pvec_pairs(kp);
    M_q(r1,r2) = qvec_pairs(kp); M_q(r2,r1) = qvec_pairs(kp);
  end

  for r0 = 1:R
    M_p(r0,r0) = NaN;
    M_q(r0,r0) = NaN;
  end

  RS.(gname).rate_pair_matrix_mean = M_mean;
  RS.(gname).rate_pair_matrix_lo   = M_lo;
  RS.(gname).rate_pair_matrix_hi   = M_hi;
  RS.(gname).rate_pair_matrix_p    = M_p;
  RS.(gname).rate_pair_matrix_q    = M_q;

  % ---------- Depth-pair summaries ----------
  RS.(gname).depth_pair_labels = depth_pair_labels;
  RS.(gname).depth_pair_dist   = depth_pair_store;

  M_mean_d = nan(D,D);
  M_lo_d   = nan(D,D);
  M_hi_d   = nan(D,D);

  for kp = 1:numDepthPairs
    d1 = depth_pair_idx(kp,1);
    d2 = depth_pair_idx(kp,2);

    v = depth_pair_store(kp,:);
    v = v(~isnan(v));
    if isempty(v), continue; end

    m  = mean(v, 'omitnan');
    pr = prctile(v, [2.5 97.5]);

    M_mean_d(d1,d2) = m; M_mean_d(d2,d1) = m;
    M_lo_d(d1,d2)   = pr(1); M_lo_d(d2,d1) = pr(1);
    M_hi_d(d1,d2)   = pr(2); M_hi_d(d2,d1) = pr(2);
  end

  for d0 = 1:D
    M_mean_d(d0,d0) = NaN;
    M_lo_d(d0,d0)   = NaN;
    M_hi_d(d0,d0)   = NaN;
  end

  M_p_d = nan(D,D);
  M_q_d = nan(D,D);
  pvec_depth = nan(numDepthPairs,1);

  for kp = 1:numDepthPairs
    this_v = depth_pair_store(kp,:);
    this_v = this_v(~isnan(this_v));

    other_idx = setdiff(1:numDepthPairs, kp);
    other_v = depth_pair_store(other_idx,:);
    other_v = other_v(:);
    other_v = other_v(~isnan(other_v));

    if isempty(this_v) || isempty(other_v)
      pvec_depth(kp) = NaN;
      continue;
    end

    switch lower(S.DepthPairMatrixSigMethod)
      case 'ranksum'
        try
          p_here = ranksum(this_v, other_v, 'tail', 'right');
        catch
          p_here = NaN;
        end
      case 'ttest'
        try
          [~, p_here] = ttest2(this_v, other_v, 'Vartype', 'unequal', 'Tail', 'right');
        catch
          p_here = NaN;
        end
      otherwise
        error('Unknown DepthPairMatrixSigMethod: %s', S.DepthPairMatrixSigMethod);
    end

    pvec_depth(kp) = p_here;
  end

  if S.DepthPairMatrixSigFDR
    [qvec_depth, ~] = fdr_bh(pvec_depth, S.DepthPairMatrixSigAlpha);
  else
    qvec_depth = pvec_depth;
  end

  for kp = 1:numDepthPairs
    d1 = depth_pair_idx(kp,1);
    d2 = depth_pair_idx(kp,2);

    M_p_d(d1,d2) = pvec_depth(kp); M_p_d(d2,d1) = pvec_depth(kp);
    M_q_d(d1,d2) = qvec_depth(kp); M_q_d(d2,d1) = qvec_depth(kp);
  end

  for d0 = 1:D
    M_p_d(d0,d0) = NaN;
    M_q_d(d0,d0) = NaN;
  end

  RS.(gname).depth_pair_matrix_mean = M_mean_d;
  RS.(gname).depth_pair_matrix_lo   = M_lo_d;
  RS.(gname).depth_pair_matrix_hi   = M_hi_d;
  RS.(gname).depth_pair_matrix_p    = M_p_d;
  RS.(gname).depth_pair_matrix_q    = M_q_d;
end
end

function cond_mean = compute_cond_mean_for_group(spk, idx_sel, cond_trials, doZ)
Ng = numel(idx_sel);
R  = size(cond_trials,1);
D  = size(cond_trials,2);
C  = R*D;

cond_mean = nan(Ng, C, size(spk,3));
c = 0;
for r = 1:R
  for d = 1:D
    c = c + 1;
    tr = cond_trials{r,d};
    cond_mean(:, c, :) = mean(spk(idx_sel, tr, :), 2, 'omitnan');
  end
end

if doZ
  mu_n = squeeze(mean(cond_mean, [2 3], 'omitnan'));
  sd_n = squeeze(std(cond_mean, 0, [2 3], 'omitnan')) + eps;
  for n = 1:Ng
    cond_mean(n,:,:) = (cond_mean(n,:,:) - mu_n(n)) / sd_n(n);
  end
end
end

function fill_ci(x, lo, hi, colorRGB, alphaVal)
x = x(:);
lo = lo(:);
hi = hi(:);
X = [x; flipud(x)];
Y = [lo; flipud(hi)];
h = fill(X, Y, colorRGB, 'LineStyle','none');
set(h, 'FaceAlpha', alphaVal);
end

function [tvec, mu, lo, hi] = ci_from_resamples(md_series, alpha)
tvec = (1:size(md_series,1))';
mu = mean(md_series, 2, 'omitnan');
sd = std(md_series, 0, 2, 'omitnan');
n  = sum(~isnan(md_series), 2);
z  = -erfcinv(alpha)*sqrt(2);
sem = sd ./ max(1, sqrt(n));
lo = mu - z*sem;
hi = mu + z*sem;
end

function [validG, vals_cell] = extract_window_means_for_groups(RS, gNames, fieldName, tStart, tEnd)
validG = {};
vals_cell = {};
for gi = 1:numel(gNames)
  gname = gNames{gi};
  if ~isfield(RS, gname) || ~isfield(RS.(gname), fieldName), continue; end
  M = RS.(gname).(fieldName);
  if isempty(M), continue; end
  wv = mean(M(tStart:tEnd, :), 1, 'omitnan');
  if all(isnan(wv)), continue; end
  validG{end+1} = gname; %#ok<AGROW>
  vals_cell{end+1} = wv(:); %#ok<AGROW>
end
end

function [m, lo, hi] = mean_ci95_cell(vals_cell)
G = numel(vals_cell);
m = nan(G,1);
lo = nan(G,1);
hi = nan(G,1);
z = 1.95996398454005;
for i = 1:G
  v = vals_cell{i};
  v = v(~isnan(v));
  if isempty(v), continue; end
  m(i) = mean(v);
  se = std(v) / sqrt(numel(v));
  lo(i) = m(i) - z*se;
  hi(i) = m(i) + z*se;
end
end

function stats = do_group_stats(vals_cell, gNames, method, doPairwise)
stats = struct('method', [], 'p', NaN, 'tbl', [], 'posthoc', [], 'pairwise', []);

y = [];
grp = {};
for i = 1:numel(vals_cell)
  v = vals_cell{i};
  if ~isnumeric(v), continue; end
  v = v(:);
  v = v(~isnan(v));
  if isempty(v), continue; end
  y = [y; v]; %#ok<AGROW>
  grp = [grp; repmat(gNames(i), numel(v), 1)]; %#ok<AGROW>
end

if numel(unique(grp)) < 2 || isempty(y)
  warning('do_group_stats: not enough valid groups/data for stats.');
  return;
end

if strcmpi(method, 'auto')
  normal_ok = true;
  for i = 1:numel(vals_cell)
    v = vals_cell{i};
    if ~isnumeric(v), normal_ok = false; break; end
    v = v(~isnan(v));
    if numel(v) < 8
      normal_ok = false; break;
    end
    warnState = warning('off', 'stats:lillietest:OutOfRangeP');
    try
      [h,~] = lillietest(v);
    catch
      h = 1;
    end
    warning(warnState);
    if h == 1
      normal_ok = false; break;
    end
  end
  method_use = tern(normal_ok, 'anova', 'kruskal');
else
  method_use = lower(method);
end
stats.method = method_use;

switch method_use
  case 'anova'
    [p, tbl, st] = anova1(y, grp, 'off');
    stats.p = p;
    stats.tbl = tbl;
    try
      c = multcompare(st, 'Display', 'off');
      stats.posthoc = array2table(c, 'VariableNames', {'Group1','Group2','CI_lo','CI_hi','Diff','p'});
    catch
      stats.posthoc = [];
    end

  case 'kruskal'
    [p, tbl, st] = kruskalwallis(y, grp, 'off');
    stats.p = p;
    stats.tbl = tbl;
    try
      c = multcompare(st, 'Display', 'off');
      stats.posthoc = array2table(c, 'VariableNames', {'Group1','Group2','CI_lo','CI_hi','Diff','p'});
    catch
      stats.posthoc = [];
    end

  otherwise
    warning('Unknown SummaryStatMethod: %s. Skipping stats.', method_use);
end

if doPairwise
  ng = numel(vals_cell);
  pairs = nchoosek(1:ng, 2);
  pU = nan(size(pairs,1),1);
  pT = nan(size(pairs,1),1);

  for k = 1:size(pairs,1)
    a = pairs(k,1);
    b = pairs(k,2);
    va = vals_cell{a};
    vb = vals_cell{b};
    if ~isnumeric(va) || ~isnumeric(vb), continue; end
    va = va(~isnan(va));
    vb = vb(~isnan(vb));
    if isempty(va) || isempty(vb), continue; end

    pU(k) = ranksum(va, vb);
    try
      [~, pT(k)] = ttest2(va, vb, 'Vartype', 'unequal');
    catch
      pT(k) = NaN;
    end
  end

  [qU, ~] = fdr_bh(pU);
  [qT, ~] = fdr_bh(pT);

  pairTbl = table(pairs(:,1), pairs(:,2), pU, qU, pT, qT, ...
    'VariableNames', {'i','j','p_ranksum','q_ranksum','p_ttest','q_ttest'});

  ii = pairTbl.i;
  jj = pairTbl.j;
  pairTbl.Group1 = arrayfun(@(k) gNames{k}, ii, 'UniformOutput', false);
  pairTbl.Group2 = arrayfun(@(k) gNames{k}, jj, 'UniformOutput', false);

  pairTbl = pairTbl(:, {'Group1','Group2','p_ranksum','q_ranksum','p_ttest','q_ttest'});
  stats.pairwise = pairTbl;
end
end

function out = tern(cond, a, b)
if cond
  out = a;
else
  out = b;
end
end

function subtitle_from_stats(stats)
if isempty(stats) || ~isfield(stats,'method') || isnan(stats.p), return; end
t = sprintf('%s across groups: p = %.3g', upper(stats.method), stats.p);
sgtitle(t);
fprintf('%s\n', t);
if istable(stats.posthoc)
  disp('Post-hoc (multcompare):');
  disp(stats.posthoc);
end
if istable(stats.pairwise)
  disp('Pairwise tests with FDR:');
  disp(stats.pairwise);
end
end

function [q, crit_p] = fdr_bh(pvals, qlevel)
if nargin < 2 || isempty(qlevel)
  qlevel = 0.05;
end

p = pvals(:);
q = nan(size(p));

valid = ~isnan(p);
pv = p(valid);

if isempty(pv)
  crit_p = NaN;
  q = reshape(q, size(pvals));
  return;
end

[ps, sortIdx] = sort(pv);
m = numel(ps);

thresh = (1:m)'/m * qlevel;
rej = ps <= thresh;

if any(rej)
  kmax = find(rej, 1, 'last');
  crit_p = ps(kmax);
else
  crit_p = NaN;
end

q_sorted = ps .* m ./ (1:m)';
q_sorted = min(1, q_sorted);

for k = m-1:-1:1
  q_sorted(k) = min(q_sorted(k), q_sorted(k+1));
end

qv = nan(size(pv));
qv(sortIdx) = q_sorted;

q(valid) = qv;
q = reshape(q, size(pvals));
end

function out = plot_md_ci_series(md_series, alpha, figName, ylab)
out = [];
if nargin < 2 || isempty(alpha) || ~isscalar(alpha)
  alpha = 0.05;
end
if isempty(md_series) || ~isnumeric(md_series)
  warning('plot_md_ci_series: empty or non-numeric md_series for "%s". Skipping.', figName);
  return;
end
if isvector(md_series)
  md_series = md_series(:);
end
[T, N] = size(md_series);
if T < 1 || N < 1 || all(isnan(md_series), 'all')
  warning('plot_md_ci_series: no valid data for "%s". Skipping.', figName);
  return;
end

[tvec, mu, lo, hi] = ci_from_resamples(md_series, alpha);
figure('Color','w','Name', figName); hold on; grid on;
xlabel('Time (index)'); ylabel(ylab); title(figName);
fill_ci(tvec, lo, hi, [0.6 0.8 1.0], 0.4);
plot(tvec, mu, 'b-', 'LineWidth', 1.8);
plot(tvec, median(md_series, 2, 'omitnan'), 'k--', 'LineWidth', 1.0);
legend({'95% CI','Mean','Median'}, 'Location','best');
end

function plot_group_summary_violin_meanBootstrap(vals_cell, gNames, colors, ylab, intervalType, percentileRange)
if nargin < 6 || isempty(percentileRange), percentileRange = [2.5 97.5]; end
if isempty(colors) || size(colors,1) < numel(vals_cell)
  colors = lines(numel(vals_cell));
end

numGroups = numel(vals_cell);
hold on; grid on;
xticks(1:numGroups);
xticklabels(gNames);
xlim([0.5, numGroups+0.5]);
ylabel(ylab);

for gi = 1:numGroups
  v = vals_cell{gi};
  if ~isnumeric(v) || isempty(v), continue; end
  v = v(:);
  v = v(~isnan(v));
  if isempty(v), continue; end

  try
    [f, y] = ksdensity(v);
    f = f / max(f);
    xCenter = gi;
    w = 0.35 * f;
    patch([xCenter - w, fliplr(xCenter + w)], [y, fliplr(y)], colors(gi,:), ...
      'FaceAlpha', 0.25, 'EdgeColor', 'none');
    plot(xCenter + w, y, '-', 'Color', colors(gi,:), 'LineWidth', 0.8);
    plot(xCenter - w, y, '-', 'Color', colors(gi,:), 'LineWidth', 0.8);
  catch
    jitter = 0.15 * (rand(numel(v),1) - 0.5);
    scatter(gi + jitter, v, 10, colors(gi,:), 'filled', 'MarkerFaceAlpha', 0.35);
  end
end

for gi = 1:numGroups
  v = vals_cell{gi};
  if ~isnumeric(v) || isempty(v), continue; end
  v = v(:);
  v = v(~isnan(v));
  if isempty(v), continue; end

  m = mean(v, 'omitnan');
  col = colors(gi,:);

  switch lower(intervalType)
    case 'ci_mean'
      n = numel(v);
      sd = std(v, 'omitnan');
      sem = sd / max(1, sqrt(n));
      z = 1.95996398454005;
      lo = m - z*sem;
      hi = m + z*sem;

    case 'sd'
      sd = std(v, 'omitnan');
      lo = m - sd;
      hi = m + sd;

    case 'iqr'
      pr = prctile(v, [25 75]);
      lo = pr(1);
      hi = pr(2);

    case 'percentile'
      pr = prctile(v, percentileRange);
      lo = pr(1);
      hi = pr(end);

    otherwise
      n = numel(v);
      sd = std(v, 'omitnan');
      sem = sd / max(1, sqrt(n));
      z = 1.95996398454005;
      lo = m - z*sem;
      hi = m + z*sem;
  end

  plot(gi, m, 'o', 'Color', col, 'MarkerFaceColor', col, 'MarkerSize', 6);
  line([gi gi], [lo, hi], 'Color', col, 'LineWidth', 1.8);
end
end

function [M, figH, P, Q] = plot_group_confusion_matrix_from_bootstrap(vals_cell, gNames, figTitle, metric, doAbsolute, sigOpts)
if nargin < 6 || isempty(sigOpts)
  sigOpts = struct('doShow',true,'alpha',0.05,'method','ranksum','doFDR',true);
end
if ~isfield(sigOpts,'doShow'), sigOpts.doShow = true; end
if ~isfield(sigOpts,'alpha'),  sigOpts.alpha  = 0.05; end
if ~isfield(sigOpts,'method'), sigOpts.method = 'ranksum'; end
if ~isfield(sigOpts,'doFDR'),  sigOpts.doFDR  = true; end

G = numel(vals_cell);
M = nan(G,G);
P = nan(G,G);
Q = nan(G,G);

V = cell(G,1);
for i = 1:G
  v = vals_cell{i};
  if ~isnumeric(v), v = []; end
  v = v(:);
  v = v(~isnan(v));
  V{i} = v;
end

for i = 1:G
  for j = i+1:G
    xi = V{i};
    xj = V{j};

    if isempty(xi) || isempty(xj)
      continue;
    end

    switch lower(metric)
      case 'auc'
        n1 = numel(xi);
        n2 = numel(xj);
        try
          allx = [xi; xj];
          r = tiedrank(allx);
          R1 = sum(r(1:n1));
          U1 = R1 - n1*(n1+1)/2;
          auc = U1 / (n1*n2);
        catch
          auc = mean(bsxfun(@gt, xi(:), xj(:)), 'all') + ...
                0.5 * mean(bsxfun(@eq, xi(:), xj(:)), 'all');
        end

        if doAbsolute
          val = abs(auc - 0.5) * 2;
          M(i,j) = val;
          M(j,i) = val;
        else
          M(i,j) = auc;
          M(j,i) = 1 - auc;
        end

      case 'meandiff'
        d = mean(xi, 'omitnan') - mean(xj, 'omitnan');
        if doAbsolute
          d = abs(d);
          M(i,j) = d;
          M(j,i) = d;
        else
          M(i,j) = d;
          M(j,i) = -d;
        end

      otherwise
        error('Unknown SummaryConfusionMetric: %s', metric);
    end

    switch lower(sigOpts.method)
      case 'ranksum'
        try
          p = ranksum(xi, xj);
        catch
          p = NaN;
        end

      case 'ttest'
        try
          [~, p] = ttest2(xi, xj, 'Vartype', 'unequal');
        catch
          p = NaN;
        end

      otherwise
        error('Unknown SummaryConfusionSigMethod: %s', sigOpts.method);
    end

    P(i,j) = p;
    P(j,i) = p;
  end
end

upMask = triu(true(G,G), 1);
pvec = P(upMask);

if sigOpts.doFDR
  [qvec, ~] = fdr_bh(pvec, sigOpts.alpha);
else
  qvec = pvec;
end

Q(upMask) = qvec;
Q = mirror_upper_to_lower(Q);

figH = figure('Color','w','Name', figTitle);
imagesc(M);
axis image;
colorbar;
title(figTitle, 'Interpreter','none');
set(gca, ...
  'XTick', 1:G, 'YTick', 1:G, ...
  'XTickLabel', gNames, 'YTickLabel', gNames, ...
  'TickLabelInterpreter', 'none');
xtickangle(45);

if strcmpi(metric,'auc')
  caxis([0 1]);
end

hold on;
for k = 1:G
  plot(k, k, 'kx', 'MarkerSize', 10, 'LineWidth', 1.2);
end

if sigOpts.doShow
  for i = 1:G
    for j = i+1:G
      q = Q(i,j);
      if isnan(q) || q >= sigOpts.alpha
        continue;
      end
      stars = p_to_stars(q, sigOpts.alpha);
      if isempty(stars)
        continue;
      end

      cellVal = M(i,j);
      if ~isnan(cellVal) && strcmpi(metric,'auc') && cellVal > 0.6
        txtColor = 'w';
      else
        txtColor = 'k';
      end

      text(j, i, stars, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Color', txtColor, ...
        'FontWeight', 'bold', ...
        'FontSize', 12);
    end
  end
end

disp('Confusion matrix raw P-values:');
disp(P);
disp('Confusion matrix corrected Q-values:');
disp(Q);
end

function A = mirror_upper_to_lower(A)
n = size(A,1);
for i = 1:n
  for j = i+1:n
    A(j,i) = A(i,j);
  end
end
end

function stars = p_to_stars(p, alpha)
if isnan(p) || p >= alpha
  stars = '';
elseif p < 1e-3
  stars = '***';
elseif p < 1e-2
  stars = '**';
else
  stars = '*';
end
end

function plot_violin_matrix_columns(X, xlabels, colors)
% X = [Nresamples x Npairs]
[~, nCols] = size(X);

if nargin < 3 || isempty(colors)
  colors = lines(nCols);
end
if size(colors,1) < nCols
  colors = lines(nCols);
end

hold on; grid on;
xlim([0.5 nCols+0.5]);
xticks(1:nCols);
xticklabels(xlabels);

for j = 1:nCols
  v = X(:,j);
  v = v(~isnan(v));
  if isempty(v), continue; end

  try
    [f, y] = ksdensity(v);
    f = f / max(f);
    w = 0.35 * f;
    patch([j-w, fliplr(j+w)], [y', fliplr(y')], colors(j,:), ...
      'FaceAlpha', 0.25, 'EdgeColor', 'none');
    plot(j+w, y, '-', 'Color', colors(j,:), 'LineWidth', 0.8);
    plot(j-w, y, '-', 'Color', colors(j,:), 'LineWidth', 0.8);
  catch
    jitter = 0.12 * (rand(numel(v),1)-0.5);
    scatter(j + jitter, v, 10, colors(j,:), 'filled', 'MarkerFaceAlpha', 0.3);
  end

  m = mean(v, 'omitnan');
  pr = prctile(v, [2.5 97.5]);
  plot(j, m, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 5);
  line([j j], [pr(1) pr(2)], 'Color', 'k', 'LineWidth', 1.2);
end
end
