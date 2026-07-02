clear;
load FWHMstruct.mat;

%%  Create data struct
data = cell(4, 6);
for j = 1:5
    % 为每个组别创建不同长度和分布的数据
    data{1, j} = FMrate.Rate(FMrate.rBMF==j&unit_type==1);
    data{2, j} = FMrate.Rate(FMrate.rBMF==j&unit_type==-1);
    data{3, j} = FMrate.VS(FMrate.tBMF==j&unit_type==1);
    data{4, j} = FMrate.VS(FMrate.tBMF==j&unit_type==-1);
end

for i=1:4
    data{i,6}=0;
end

%%  Sort data format
% 定义组名
main_groups = {'Group 1', 'Group 2', 'Group 3', 'Group 4'};
sub_categories = {'Type 1', 'Type 2', 'Type 3', 'Type 4', 'Type 5','placeholder'};

% 创建所有数据的向量和对应的标签向量
all_data = [];
all_labels = {};

% 计算每个大组的起始位置和间隔
group_spacing = 1.0; % 大组之间的间距
subgroup_spacing = 0.15; % 子类别之间的间距

% 计算每个小提琴图的实际位置
positions = [];
current_pos = 1;

for i = 1:4 % 遍历大组
    % 为大组之间添加额外间距（占位符）
    if i > 1
        current_pos = current_pos + group_spacing;
    end
    
    for j = 1:6 % 遍历子类别
        % 计算当前位置
        pos = current_pos + (j-1) * subgroup_spacing;
        positions = [positions, pos];
        
        % 添加数据
        all_data = [all_data; data{i, j}];
        
        % 创建标签（格式：大组-子类别）
        labels = repmat({sprintf('%s-%s', main_groups{i}, sub_categories{j})}, size(data{i, j}));
        all_labels = [all_labels; labels];
    end

    % 更新当前位置到下一个大组的起始位置
    current_pos = current_pos + 6 * subgroup_spacing;
end

%%  Plot
colors = ([0.000 0.447 0.741;
0.850 0.325 0.098;
0.929 0.694 0.125;
0.494 0.184 0.556;
0.466 0.674 0.188;
0.301 0.745 0.933]);

colors_all=repmat(colors,4,1);

% 创建小提琴图
figure('position',[100 100 800 200]);
violins = violinplot(all_data, all_labels, 'ViolinColor',colors_all);

labels=repmat({'16Hz','22.5Hz','32Hz','45Hz','64Hz',''},1,4);
xticklabels(labels);
ylim([0 3]);
ylabel('Sharpness (1/FWHM)');

%%  Create second data struct
data2 = cell(4, 5);
for j = 1:4
    % 为每个组别创建不同长度和分布的数据
    data2{1, j} = FMdepth.Rate(FMdepth.rBMD==j&unit_type==1);
    data2{2, j} = FMdepth.Rate(FMdepth.rBMD==j&unit_type==-1);
    data2{3, j} = FMdepth.VS(FMdepth.tBMD==j&unit_type==1);
    data2{4, j} = FMdepth.VS(FMdepth.tBMD==j&unit_type==-1);
end

for i=1:4
    data2{i,5}=0;
end

%%  Sort data format
% 定义组名
main_groups = {'Group 1', 'Group 2', 'Group 3', 'Group 4'};
sub_categories = {'Type 1', 'Type 2', 'Type 3', 'Type 4', 'placeholder'};

% 创建所有数据的向量和对应的标签向量
all_data = [];
all_labels = {};

% 计算每个大组的起始位置和间隔
group_spacing = 1.0; % 大组之间的间距
subgroup_spacing = 0.15; % 子类别之间的间距

% 计算每个小提琴图的实际位置
positions = [];
current_pos = 1;

for i = 1:4 % 遍历大组
    % 为大组之间添加额外间距（占位符）
    if i > 1
        current_pos = current_pos + group_spacing;
    end
    
    for j = 1:5 % 遍历子类别
        % 计算当前位置
        pos = current_pos + (j-1) * subgroup_spacing;
        positions = [positions, pos];
        
        % 添加数据
        all_data = [all_data; data2{i, j}];
        
        % 创建标签（格式：大组-子类别）
        labels = repmat({sprintf('%s-%s', main_groups{i}, sub_categories{j})}, size(data2{i, j}));
        all_labels = [all_labels; labels];
    end

    % 更新当前位置到下一个大组的起始位置
    current_pos = current_pos + 6 * subgroup_spacing;
end

%%  Plot
colors = ([0.000 0.447 0.741;
0.850 0.325 0.098;
0.929 0.694 0.125;
0.494 0.184 0.556;
0.466 0.674 0.188]);

colors_all=repmat(colors,4,1);

% 创建小提琴图
figure('position',[500 100 800 200]);
violins = violinplot(all_data, all_labels, 'ViolinColor',colors_all);

labels=repmat({'125Hz','250Hz','500Hz','1000Hz',''},1,4);
xticklabels(labels);
ylim([0 3]);
ylabel('Sharpness (1/FWHM)');
