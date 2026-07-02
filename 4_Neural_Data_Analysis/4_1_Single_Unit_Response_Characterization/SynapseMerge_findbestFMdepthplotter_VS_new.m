clear;
SynapseMerge_findbestFMdepth_VS

%% Calculate Normalized Mean Rate errorbar data
for i=1:4
    norm_mean1(:,i)=mean(meanvs((bestFMdepth_vs'==i),:),1);
    norm_err1(:,i)=std(meanvs((bestFMdepth_vs'==i),:),0,1)./sqrt(callcount(1,:));
end

%% Plot Normalized Mean Rate 
f1=figure('Position',[100 400 550 300]);
f1=tiledlayout(1,2);
nexttile
box on;
hold on;
for i=1:4
errorbar((1:4),norm_mean1(:,i),norm_err1(:,i),'LineWidth',2);
end
title('VS')
ylabel('Mean VS')
ylim([0.2 0.8])
xticks(1:4)
xticklabels([125 250 500 1000])
xlabel('FM Depth (Hz)')
xlim([0.5 4.5]);
% ylim([0 0.5]);

% nexttile
% box on;
% hold on;
% for i=1:4
% errorbar((1:4),norm_mean2(:,i),norm_err2(:,i),'LineWidth',2);
% end
% title('Negative')
% ylabel('Mean VS')
% ylim([0.2 0.8])
% xticks(1:4)
% xticklabels([125 250 500 1000])
% xlabel('FM Depth (Hz)')
% xlim([0.5 4.5]);
% % ylim([0 0.5]);

lgd = legend('bestFMdepth=125','bestFMdepth=250','bestFMdepth=500','bestFMdepth=1000');
lgd.Layout.Tile='east';
% title(f1,'Normalized Average Rate')

% %%
% f1=figure('Position',[100 400 900 300]);
% f1=tiledlayout(1,2);
% nexttile
% plot((1:5),mean(norm_mean((ind1==1&bestFMrate'==1),:)),'LineWidth',2);
% hold on;
% plot((1:5),mean(norm_mean((ind1==1&bestFMrate'==2),:)),'LineWidth',2);
% plot((1:5),mean(norm_mean((ind1==1&bestFMrate'==3),:)),'LineWidth',2);
% plot((1:5),mean(norm_mean((ind1==1&bestFMrate'==4),:)),'LineWidth',2);
% plot((1:5),mean(norm_mean((ind1==1&bestFMrate'==5),:)),'LineWidth',2);
% title('Positive')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% nexttile
% plot((1:5),1.-mean(norm_mean((ind2==1&bestFMrate'==1),:)),'LineWidth',2);
% hold on;
% plot((1:5),1.-mean(norm_mean((ind2==1&bestFMrate'==2),:)),'LineWidth',2);
% plot((1:5),1.-mean(norm_mean((ind2==1&bestFMrate'==3),:)),'LineWidth',2);
% plot((1:5),1.-mean(norm_mean((ind2==1&bestFMrate'==4),:)),'LineWidth',2);
% plot((1:5),1.-mean(norm_mean((ind2==1&bestFMrate'==5),:)),'LineWidth',2);
% title('Negative')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
% lgd.Layout.Tile='east';
% title(f1,'Normalized Rate (Average)')
% %%
% f2=figure('Position',[100 100 900 300]);
% f2=tiledlayout(1,2);
% nexttile
% errorbar((1:5),mean(norm_max((ind1==1&bestFMrate'==1),:)),std(norm_max((ind1==1&bestFMrate'==1),:))/sqrt(callcount(1,1)),'LineWidth',2);
% hold on;
% errorbar((1:5),mean(norm_max((ind1==1&bestFMrate'==2),:)),std(norm_max((ind1==1&bestFMrate'==2),:))/sqrt(callcount(1,2)),'LineWidth',2);
% errorbar((1:5),mean(norm_max((ind1==1&bestFMrate'==3),:)),std(norm_max((ind1==1&bestFMrate'==3),:))/sqrt(callcount(1,3)),'LineWidth',2);
% errorbar((1:5),mean(norm_max((ind1==1&bestFMrate'==4),:)),std(norm_max((ind1==1&bestFMrate'==4),:))/sqrt(callcount(1,4)),'LineWidth',2);
% errorbar((1:5),mean(norm_max((ind1==1&bestFMrate'==5),:)),std(norm_max((ind1==1&bestFMrate'==5),:))/sqrt(callcount(1,5)),'LineWidth',2);
% title('Positive')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% nexttile
% errorbar((1:5),1.-mean(norm_min((ind2==1&bestFMrate'==1),:)),std(norm_min((ind2==1&bestFMrate'==1),:))/sqrt(callcount(2,1)),'LineWidth',2);
% hold on;
% errorbar((1:5),1.-mean(norm_min((ind2==1&bestFMrate'==2),:)),std(norm_min((ind2==1&bestFMrate'==2),:))/sqrt(callcount(2,2)),'LineWidth',2);
% errorbar((1:5),1.-mean(norm_min((ind2==1&bestFMrate'==3),:)),std(norm_min((ind2==1&bestFMrate'==3),:))/sqrt(callcount(2,3)),'LineWidth',2);
% errorbar((1:5),1.-mean(norm_min((ind2==1&bestFMrate'==4),:)),std(norm_min((ind2==1&bestFMrate'==4),:))/sqrt(callcount(2,4)),'LineWidth',2);
% errorbar((1:5),1.-mean(norm_min((ind2==1&bestFMrate'==5),:)),std(norm_min((ind2==1&bestFMrate'==5),:))/sqrt(callcount(2,5),'LineWidth',2);
% title('Negative')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
% lgd.Layout.Tile='east';
% title(f2,'Normalized Rate (Best of Each)')

% f2=figure('Position',[100 100 900 300]);
% f2=tiledlayout(1,2);
% nexttile
% plot((1:5),mean(norm_sus((ind1==1&bestFMrate'==1),[4 8 12 16 20])),'LineWidth',2);
% hold on;
% plot((1:5),mean(norm_sus((ind1==1&bestFMrate'==2),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),mean(norm_sus((ind1==1&bestFMrate'==3),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),mean(norm_sus((ind1==1&bestFMrate'==4),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),mean(norm_sus((ind1==1&bestFMrate'==5),[4 8 12 16 20])),'LineWidth',2);
% title('Positive')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% nexttile
% plot((1:5),1.-mean(norm_sus((ind2==1&bestFMrate'==1),[4 8 12 16 20])),'LineWidth',2);
% hold on;
% plot((1:5),1.-mean(norm_sus((ind2==1&bestFMrate'==2),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),1.-mean(norm_sus((ind2==1&bestFMrate'==3),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),1.-mean(norm_sus((ind2==1&bestFMrate'==4),[4 8 12 16 20])),'LineWidth',2);
% plot((1:5),1.-mean(norm_sus((ind2==1&bestFMrate'==5),[4 8 12 16 20])),'LineWidth',2);
% title('Negative')
% ylabel('Normalized Rate')
% xticks(1:5)
% xticklabels([16 22.5 32 45 64])
% xlabel('FM Rate (Hz)')
% 
% lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
% lgd.Layout.Tile='east';
% title(f2,'Normalized Rate (Depth=1000Hz)')

