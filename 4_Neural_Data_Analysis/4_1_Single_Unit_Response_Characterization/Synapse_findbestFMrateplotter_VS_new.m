clear;
Synapse_findbestFMrate_VS

%% Plot Distribution of bestFMrates (Line Plot)
for i=1:5
    for j=1:2
    bestFMratecount(i,j)=length(find(bestFMrate_vs==i&unitlist==j));
    end
end

figure('position',[100 100 400 300])
plot((1:5),bestFMratecount(:,1),'r-+',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerFaceColor','r')
hold on
plot((1:5),bestFMratecount(:,2),'b--x',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerFaceColor','b')
xlim([0.5 5.5]);
xticks([1 2 3 4 5]);
xticklabels([16 22.5 32 45 64]);
xlabel("Best FM Depth (Hz)");
ylabel("Number of Units");
legend('Positive units','Negative units');

%% Calculate Normalized Mean Rate errorbar data
for i=1:5
    norm_mean1(:,i)=mean(meanvs((ind1==1&bestFMrate_vs'==i),:));
    norm_mean2(:,i)=mean(meanvs((ind2==1&bestFMrate_vs'==i),:));
    norm_err1(:,i)=std(meanvs((ind1==1&bestFMrate_vs'==i),:))./sqrt(callcount(1,:));
    norm_err2(:,i)=std(meanvs((ind2==1&bestFMrate_vs'==i),:))./sqrt(callcount(2,:));
end

%% Plot Normalized Mean Rate 
f1=figure('Position',[100 400 550 300]);
f1=tiledlayout(1,2);
nexttile
box on;
hold on;
for i=1:5
errorbar((1:5),norm_mean1(:,i),norm_err1(:,i),'LineWidth',2);
end
title('Positive')
ylabel('Mean VS')
% ylim([0.2 0.9])
xticks(1:5)
xticklabels([16 22.5 32 45 64])
xlabel('FM Rate (Hz)')
xlim([0.5 5.5])
ylim([0 0.6]);

nexttile
box on;
hold on;
for i=1:5
errorbar((1:5),norm_mean2(:,i),norm_err2(:,i),'LineWidth',2);
end
title('Negative')
ylabel('Mean VS')
% ylim([0.2 0.9])
xticks(1:5)
xticklabels([16 22.5 32 45 64])
xlabel('FM Rate (Hz)')
xlim([0.5 5.5])
ylim([0 0.6]);

lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
lgd.Layout.Tile='east';

