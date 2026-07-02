clear;
SynapseMerge_findbestFMrate_new

%% Calculate Normalized Mean Rate errorbar data
for i=1:5
    norm_mean1(:,i)=mean(norm_meanrate((bestFMrate'==i),:));
    norm_err1(:,i)=std(norm_meanrate((bestFMrate'==i),:))./sqrt(callcount(1,:));
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
title('FM Rate')
ylabel('Normalized susFR')
ylim([0.2 0.8])
xticks(1:5)
xticklabels([16 22.5 32 45 64])
xlabel('FM Rate (Hz)')
xlim([0.5 5.5])

lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
lgd.Layout.Tile='east';
% title(f1,'Normalized Firing Rate')
