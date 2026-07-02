% 输入数据: 
data = norm_meanrate(oklist',:);
peak = bestFMrate(oklist');

% 计算
N = size(data, 1);
sharpness = zeros(N, 1); % 存储锐度值(使用半高全宽的倒数)

for i = 1:N
    rates = data(i, :);
    p = peak(i);
    max_rate = rates(p);
    half_max = max_rate / 2;
    
    % 左侧宽度计算
    if p > 1
        left_side = rates(1:p);
        % 找到第一个低于半高值的点
        left_idx = find(left_side >= half_max, 1, 'first');
        
        if isempty(left_idx)
            left_width = p - 0.5; % 外推
        elseif left_idx == 1
            left_width = p - 1; % 边界点
        else
            % 线性插值
            x1 = left_idx - 1;
            x2 = left_idx;
            y1 = rates(x1);
            y2 = rates(x2);
            left_width = p - (x1 + (half_max - y1)/(y2 - y1));
        end
    else
        left_width = 0; % 峰值在最左侧
    end
    
    % 右侧宽度计算
    if p < 5
        right_side = rates(p:end);
        % 找到最后一个低于半高值的点
        right_idx = find(right_side >= half_max, 1, 'last') + p - 1;
        
        if isempty(right_idx)
            right_width = 5 - p + 0.5; % 外推
        elseif right_idx == 5
            right_width = 5 - p; % 边界点
        else
            % 线性插值
            x1 = right_idx;
            x2 = right_idx + 1;
            y1 = rates(x1);
            y2 = rates(x2);
            right_width = (x1 + (half_max - y1)/(y2 - y1)) - p;
        end
    else
        right_width = 0; % 峰值在最右侧
    end
    
    fwhm = left_width + right_width;
    sharpness(i) = 1 / fwhm; % 锐度与宽度成反比
end