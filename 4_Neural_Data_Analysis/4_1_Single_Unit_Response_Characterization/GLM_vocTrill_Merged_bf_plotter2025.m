%   Plot violin for both unit type and BF
%   Normally this would be run from GLM_vocTrill_plottermain.m, 
%   but just in case, perform an extra check

if exist('coef_vs')==0
    warning('GLM fit not performed. Performing GLM fit with GLM_vocTrill_glmfit2025.m now...')
    GLM_vocTrill_glmfit2025
end

if exist('coef_vs')==1
    disp('Performing plot data type check...')
    coeftemp=[];
    coeftype=[];
    plotdatatemp=input('Input 1 to plot Rate coefficients, input 2 to plot VS coefficients: ');
    if plotdatatemp==1
        coeftemp=coef_rate;
        coeftype={"Norm FR"};
    elseif plotdatatemp==2
        coeftemp=coef_vs;
        coeftype={"VS"};
    else
        error('Invalid input')
    end
end

%%  Merge bflist
load bestFMratedepth_listnew.mat

bflist_merge=bflist;

bflist_merge(unitlist==2)=bflist_merge(unitlist==2)-3;


%%  Make violin plot

%   Contour
figure('position',[100 200 400 350]);
tiledlayout(1,3);

nexttile
violinplot(coeftemp(okind,2),okind(okind),'ViolinColor',[0.3 0.3 0.3]);
xticklabels({'All'});
xlabel({'Unit Type'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (Carrier Type)'];
title(txt);
xlim([0.5 1.5]);
ylim([-0.3 0.5]);
plot([0.5 1.5],[0 0],'Color',[0.5 0.5 0.5]);

nexttile([1 2]);
violinplot(coeftemp(okind,2),bflist_merge(okind));
xlim([0 4]);
ylim([-0.3 0.5]);
% ylim([-0.3 0.5]);
xticklabels({'Low BF','Mid BF','Hi BF'});
xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (Carrier Type)'];
title(txt);
plot([0 4],[0 0],'Color',[0.5 0.5 0.5]);

%   FMrate
figure('position',[500 200 400 350]);
tiledlayout(1,3);

nexttile
violinplot(coeftemp(okind,3),okind(okind),'ViolinColor',[0.3 0.3 0.3]);
xticklabels({'All'});
xlabel({'Unit Type'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Rate)'];
title(txt);
ylim([-1 1.1]);
% ylim([-0.4 0.8]);
plot([0.5 1.5],[0 0],'Color',[0.5 0.5 0.5]);

nexttile([1 2]);
violinplot(coeftemp(okind,3),bflist_merge(okind));
xlim([0 4]);
ylim([-0.7 0.8]);
% ylim([-0.7 0.5]);
xticklabels({'Low BF','Mid BF','Hi BF'});
xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Rate)'];
title(txt);
plot([0 4],[0 0],'Color',[0.5 0.5 0.5]);

%   FMdepth
figure('position',[900 200 400 350]);
tiledlayout(1,3);

nexttile
violinplot(coeftemp(okind,4),okind(okind),'ViolinColor',[0.3 0.3 0.3]);
xticklabels({'All'});
xlabel({'Unit Type'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Depth)'];
title(txt);
ylim([-1 1.1]);
% ylim([-0.4 0.8]);
plot([0.5 1.5],[0 0],'Color',[0.5 0.5 0.5]);

nexttile([1 2]);
violinplot(coeftemp(okind,4),bflist_merge(okind));
xlim([0 4]);
ylim([-1 1.1]);
% ylim([-0.4 0.8]);
xticklabels({'Low BF','Mid BF','Hi BF'});
xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Depth)'];
title(txt);
plot([0 4],[0 0],'Color',[0.5 0.5 0.5]);

%% make scatter plot
figure('position',[500 200 500 350]);
hold on;
scatter(best_tone(bflist==1|bflist==4), coeftemp(bflist==1|bflist==4,2),...
    'Marker','+','MarkerEdgeColor',[0 0.4470 0.7410])

scatter(best_tone(bflist==2|bflist==5), coeftemp(bflist==2|bflist==5,2),...
    'Marker','+','MarkerEdgeColor',[0.8500 0.3250 0.0980])

scatter(best_tone(bflist==3|bflist==6), coeftemp(bflist==3|bflist==6,2),...
    'Marker','+','MarkerEdgeColor',[0.9290 0.6940 0.1250])

% set(gca, 'XScale', 'log')
xlim([0 20000])
ylim([-0.3 0.5])

% plot([5000 5000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])
% plot([10000 10000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])

xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (Carrier Type)'];
title(txt);
plot([0 20000],[0 0],'Color',[0.5 0.5 0.5]);

legend('Low','Mid','High','Location','NorthEastOutside')

%FM rate
figure('position',[600 200 500 350]);
hold on;
scatter(best_tone(bflist==1|bflist==4), coeftemp(bflist==1|bflist==4,3),...
    'Marker','+','MarkerEdgeColor',[0 0.4470 0.7410])

scatter(best_tone(bflist==2|bflist==5), coeftemp(bflist==2|bflist==5,3),...
    'Marker','+','MarkerEdgeColor',[0.8500 0.3250 0.0980])

scatter(best_tone(bflist==3|bflist==6), coeftemp(bflist==3|bflist==6,3),...
    'Marker','+','MarkerEdgeColor',[0.9290 0.6940 0.1250])

% set(gca, 'XScale', 'log')
xlim([0 20000])
ylim([-0.7 0.8])

% plot([5000 5000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])
% plot([10000 10000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])

xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM rate)'];
title(txt);
plot([0 20000],[0 0],'Color',[0.5 0.5 0.5]);

legend('Low','Mid','High','Location','NorthEastOutside')

%FM dpeth
figure('position',[700 200 500 350]);
hold on;
scatter(best_tone(bflist==1|bflist==4), coeftemp(bflist==1|bflist==4,4),...
    'Marker','+','MarkerEdgeColor',[0 0.4470 0.7410])

scatter(best_tone(bflist==2|bflist==5), coeftemp(bflist==2|bflist==5,4),...
    'Marker','+','MarkerEdgeColor',[0.8500 0.3250 0.0980])

scatter(best_tone(bflist==3|bflist==6), coeftemp(bflist==3|bflist==6,4),...
    'Marker','+','MarkerEdgeColor',[0.9290 0.6940 0.1250])

% set(gca, 'XScale', 'log')
xlim([0 20000])
ylim([-1 1.1])

% plot([5000 5000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])
% plot([10000 10000],[-0.3 0.5],'LineStyle','--','Color',[0.5 0.5 0.5])

xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM depth)'];
title(txt);
plot([0 20000],[0 0],'Color',[0.5 0.5 0.5]);

legend('Low','Mid','High','Location','NorthEastOutside')