clear;
Synapse_findbestFMrate_new

%% Plot Scatterhist
figure(1)
scatterhist(best_tone(oklist),bestFMrate(oklist),...
    'Group',unitlist(oklist), ...
    'Kernel','on',...
    'Location','SouthWest','LineWidth',2,...
    'Direction','in','Marker','+x','MarkerSize',5,'Color','rb',...
    'LineStyle',{'-',':'});
hold on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis tight
title('Tone Best Frequency/Best FM Rate');
xlabel("Tone Best Frequency (Hz)");
ylabel("Best FM Rate (Hz)");
ylim([0.5 5.5]);
yticks([1 2 3 4 5]);
yticklabels([16 22.5 32 45 64]);
legend('Positive units','Negative units');

% figure(2)
% scatterhist(best_tone(oklist),bestdepth(oklist),...
%     'Group',unitlist(oklist), ...
%     'Kernel','on',...
%     'Location','SouthWest','LineWidth',2,...
%     'Direction','in','Marker','+x','MarkerSize',5,'Color','rb',...
%     'LineStyle',{'-',':'});
% hold on
% ax = gca;
% ax.XAxisLocation = 'origin';
% ax.YAxisLocation = 'origin';
% axis tight
% title('Tone Best Frequency/Best FM Depth');
% xlabel("Tone Best Frequency (Hz)");
% ylabel("Best FM Depth (Hz)");
% ylim([0.5 4.5]);
% yticks([1 2 3 4]);
% yticklabels([125 250 500 1000]);
% legend('Positive units','Negative units');

%% Plot Distribution of bestFMrates (Line Plot)
for i=1:5
    for j=1:2
    bestFMratecount(i,j)=length(find(bestFMrate==i&unitlist==j));
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
    norm_mean1(:,i)=mean(norm_meanrate((ind1==1&bestFMrate'==i),:));
    norm_mean2(:,i)=mean(norm_meanrate((ind2==1&bestFMrate'==i),:));
    norm_err1(:,i)=std(norm_meanrate((ind1==1&bestFMrate'==i),:))./sqrt(callcount(1,:));
    norm_err2(:,i)=std(norm_meanrate((ind2==1&bestFMrate'==i),:))./sqrt(callcount(2,:));
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
ylabel('Normalized susFR')
ylim([0.2 0.9])
xticks(1:5)
xticklabels([16 22.5 32 45 64])
xlabel('FM Rate (Hz)')
xlim([0.5 5.5])

nexttile
box on;
hold on;
for i=1:5
    % errorbar((1:5),1.-norm_mean2(:,i),norm_err2(:,i),'LineWidth',2);
    errorbar((1:5),norm_mean2(:,i),norm_err2(:,i),'LineWidth',2);
end
title('Negative')
% ylabel('1-Normalized susFR')
ylabel('Normalized susFR')
ylim([0.1 0.8])
xticks(1:5)
xticklabels([16 22.5 32 45 64])
xlabel('FM Rate (Hz)')
xlim([0.5 5.5])

lgd = legend('bestFMrate=16','bestFMrate=22.5','bestFMrate=32','bestFMrate=45','bestFMrate=64');
lgd.Layout.Tile='east';
% title(f1,'Normalized Firing Rate')

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


%% Sort data into distance to best
dist_neg4_1=[norm_meanrate((ind1==1&bestFMrate'==5),1)];
dist_neg3_1=[norm_meanrate((ind1==1&bestFMrate'==4),1);norm_meanrate((ind1==1&bestFMrate'==5),2)];
dist_neg2_1=[norm_meanrate((ind1==1&bestFMrate'==3),1);norm_meanrate((ind1==1&bestFMrate'==4),2);norm_meanrate((ind1==1&bestFMrate'==5),3)];
dist_neg1_1=[norm_meanrate((ind1==1&bestFMrate'==2),1);norm_meanrate((ind1==1&bestFMrate'==3),2);norm_meanrate((ind1==1&bestFMrate'==4),3);norm_meanrate((ind1==1&bestFMrate'==5),4)];
dist_0_1=(max(norm_meanrate(ind1==1,:),[],2));
dist_pos1_1=[norm_meanrate((ind1==1&bestFMrate'==1),2);norm_meanrate((ind1==1&bestFMrate'==2),3);norm_meanrate((ind1==1&bestFMrate'==3),4);norm_meanrate((ind1==1&bestFMrate'==4),5)];
dist_pos2_1=[norm_meanrate((ind1==1&bestFMrate'==1),3);norm_meanrate((ind1==1&bestFMrate'==2),4);norm_meanrate((ind1==1&bestFMrate'==3),5)];
dist_pos3_1=[norm_meanrate((ind1==1&bestFMrate'==1),4);norm_meanrate((ind1==1&bestFMrate'==2),5)];
dist_pos4_1=[norm_meanrate((ind1==1&bestFMrate'==1),5)];

dist_neg4_2=[norm_meanrate((ind2==1&bestFMrate'==5),1)];
dist_neg3_2=[norm_meanrate((ind2==1&bestFMrate'==4),1);norm_meanrate((ind2==1&bestFMrate'==5),2)];
dist_neg2_2=[norm_meanrate((ind2==1&bestFMrate'==3),1);norm_meanrate((ind2==1&bestFMrate'==4),2);norm_meanrate((ind2==1&bestFMrate'==5),3)];
dist_neg1_2=[norm_meanrate((ind2==1&bestFMrate'==2),1);norm_meanrate((ind2==1&bestFMrate'==3),2);norm_meanrate((ind2==1&bestFMrate'==4),3);norm_meanrate((ind2==1&bestFMrate'==5),4)];
dist_0_2=(max(norm_meanrate(ind2==1,:),[],2));
dist_pos1_2=[norm_meanrate((ind2==1&bestFMrate'==1),2);norm_meanrate((ind2==1&bestFMrate'==2),3);norm_meanrate((ind2==1&bestFMrate'==3),4);norm_meanrate((ind2==1&bestFMrate'==4),5)];
dist_pos2_2=[norm_meanrate((ind2==1&bestFMrate'==1),3);norm_meanrate((ind2==1&bestFMrate'==2),4);norm_meanrate((ind2==1&bestFMrate'==3),5)];
dist_pos3_2=[norm_meanrate((ind2==1&bestFMrate'==1),4);norm_meanrate((ind2==1&bestFMrate'==2),5)];
dist_pos4_2=[norm_meanrate((ind2==1&bestFMrate'==1),5)];

line1=[mean(dist_neg4_1) mean(dist_neg3_1) mean(dist_neg2_1) mean(dist_neg1_1) mean(dist_0_1) mean(dist_pos1_1) mean(dist_pos2_1) mean(dist_pos3_1) mean(dist_pos4_1)];
line2=[mean(dist_neg4_2) mean(dist_neg3_2) mean(dist_neg2_2) mean(dist_neg1_2) mean(dist_0_2) mean(dist_pos1_2) mean(dist_pos2_2) mean(dist_pos3_2) mean(dist_pos4_2)];

error1=[std(dist_neg4_1)/sqrt(length(dist_neg4_1)) ...
    std(dist_neg3_1)/sqrt(length(dist_neg3_1)) ...
    std(dist_neg2_1)/sqrt(length(dist_neg2_1)) ...
    std(dist_neg1_1)/sqrt(length(dist_neg1_1)) ...
    std(dist_0_1)/sqrt(length(dist_0_1)) ...
    std(dist_pos1_1)/sqrt(length(dist_pos1_1)) ...
    std(dist_pos2_1)/sqrt(length(dist_pos2_1)) ...
    std(dist_pos3_1)/sqrt(length(dist_pos3_1)) ...
    std(dist_pos4_1)/sqrt(length(dist_pos4_1))];

error2=[std(dist_neg4_2)/sqrt(length(dist_neg4_2)) ...
    std(dist_neg3_2)/sqrt(length(dist_neg3_2)) ...
    std(dist_neg2_2)/sqrt(length(dist_neg2_2)) ...
    std(dist_neg1_2)/sqrt(length(dist_neg1_2)) ...
    std(dist_0_2)/sqrt(length(dist_0_2)) ...
    std(dist_pos1_2)/sqrt(length(dist_pos1_2)) ...
    std(dist_pos2_2)/sqrt(length(dist_pos2_2)) ...
    std(dist_pos3_2)/sqrt(length(dist_pos3_2)) ...
    std(dist_pos4_2)/sqrt(length(dist_pos4_2))];

f1=figure('Position',[100 400 400 300]);
errorbar(-4:4,line1,error1,'r-','LineWidth',2);
hold on;
errorbar(-4:4,line2,error2,'b--','LineWidth',2);
title('Rate Selectivity Peak')
ylabel('Normalized Rate')
ylim([0 1])
xticks(-4:4)
xticklabels(-2:0.5:2)
xlabel('Distance to Best Frequency (Octave)')
legend('Positive','Negative')