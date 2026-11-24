%% cell type x BMF/BMD distribution test
D = load('bestFMratedepth_listnew.mat');
narrow   = double(D.narrow(:));      % 1 = narrow, 0 = wide
unitlist = double(D.unitlist(:));    % 1 = E, 2 = I, 0 = no response

resp = unitlist > 0;                 % 只用有响应的单元
n    = narrow(resp);
rbmf = double(D.bestFMrate(resp));      % 1..5
tbmf = double(D.bestFMrate_VS(resp));   % 1..5
rbmd = double(D.bestFMdepth(resp));     % 1..4
tbmd = double(D.bestFMdepth_VS(resp));  % 1..4

vars   = {rbmf, tbmf, rbmd, tbmd};
names  = {'rBMF','tBMF','rBMD','tBMD'};
B = 20000;
rng(42);

p_all = zeros(1, numel(vars));

fprintf('%-6s %8s %8s %10s %10s %10s\n','var','chi2','df','p_chi2','p_MC','minE');
for k = 1:numel(vars)
    v = vars{k};

    % 2 x nCat 列联表（行 = wide/narrow）
    nCat = max(v);
    T = zeros(2, nCat);
    for i = 1:numel(n)
        T(n(i)+1, v(i)) = T(n(i)+1, v(i)) + 1;
    end

    % 卡方
    [~, chi2, p_chi2] = crosstab(n, v);
    df = (size(T,1)-1) * (size(T,2)-1);

    % 期望频数
    E = sum(T,2) * sum(T,1) / sum(T(:));
    minE = min(E(:));

    % Monte Carlo 重排
    obs = chi2stat(T);
    cnt = 0;
    for b = 1:B
        pv = n(randperm(numel(n)));
        Tb = zeros(2, nCat);
        for i = 1:numel(pv)
            Tb(pv(i)+1, v(i)) = Tb(pv(i)+1, v(i)) + 1;
        end
        if chi2stat(Tb) >= obs - 1e-12
            cnt = cnt + 1;
        end
    end
    p_mc = (cnt + 1) / (B + 1);

    p_all(k) = p_mc;

    fprintf('%-6s %8.3f %8d %10.4f %10.4f %10.2f\n', names{k}, chi2, df, p_chi2, p_mc, minE);

    if k == 1, disp('  rBMF table (rows: wide, narrow):'); disp(T); end
    if k == 3, disp('  rBMD table (rows: wide, narrow):'); disp(T); end
end

q_bh   = bh_fdr(p_all);
q_bonf = min(p_all * numel(p_all), 1);

fprintf('\n%-6s %10s %10s %10s\n', 'var', 'p_raw', 'q_BH', 'q_Bonf');
for k = 1:numel(vars)
    fprintf('%-6s %10.4f %10.4f %10.4f\n', names{k}, p_all(k), q_bh(k), q_bonf(k));
end

function s = chi2stat(T)
    rs = sum(T,2); cs = sum(T,1); N = sum(T(:));
    E = rs * cs / N;
    s = sum(sum((T - E).^2 ./ E));
end

function q = bh_fdr(p)
% Benjamini-Hochberg FDR
    p = p(:);
    n = numel(p);
    [ps, idx] = sort(p);
    q = ps .* n ./ (1:n)';
    for i = n-1:-1:1
        q(i) = min(q(i), q(i+1));
    end
    q = min(q, 1);
    qq = zeros(n, 1);
    qq(idx) = q;
    q = qq;
end