%   Plotting 3 scatterhist for coefficients.
%   Normally this would be run from GLM_vocTrill_plottermain.m, 
%   but just in case, perform an extra check
if exist('coef_vs')==0
    warning('GLM fit not performed, please load the correct dataset and perform GLM fit with GLM_vocTrill_glmfit.m')
end
if exist('coeftemp')==0
    warning('Script not run from GLM_vocTrill_plottermain.m. Performing plot data type check...')
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
        warning('Invalid input')
    end
end

%% Plot scatterhist of coefficients by Tone Best Frequency
fig_a=figure('Position',[100 100 450 400]);
fig_a=scatterhist(coeftemp(okind,2),coeftemp(okind,3),...
    'Group',bflist(okind), ...
    'Kernel','on',...
    'Location','SouthWest','LineWidth',2,...
    'Direction','in','Marker','+ox+ox','MarkerSize',5,'Color','rrrbbb',...
    'LineStyle',{'-','-.',':','-','-.',':'});
hold on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis tight
% plot([-1 1],[-1 1],'Color',[0.5 0.5 0.5])
[P1_1,S1_1] = polyfit(coeftemp(bflist>0&bflist<=3,2),coeftemp(bflist>0&bflist<=3,3),1);
[P1_2,S1_2] = polyfit(coeftemp(bflist>3,2),coeftemp(bflist>3,3),1);
f1_1 = polyval(P1_1,[-1 1]);
f1_2 = polyval(P1_2,[-1 1]);
plot([-1 1],f1_1,'Color',[1 0.3 0.3])
plot([-1 1],f1_2,'Color',[0.3 0.3 1])
if plotdatatemp==1
    xlim([-0.3 0.3])
    ylim([-0.7 0.55])
end
if plotdatatemp==2
    xlim([-0.3 0.4])
    ylim([-0.7 0.25])
end
title(['Coefficients of Contour/FM Rate on ', coeftype]);
xlabel("Contour");
ylabel("FM Rate");
legend('BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -');

fig_b=figure('Position',[500 100 450 400]);
fig_b=scatterhist(coeftemp(okind,3),coeftemp(okind,4),...
    'Group',bflist(okind), ...
    'Kernel','on',...
    'Location','SouthWest','LineWidth',2,...
    'Direction','in','Marker','+ox+ox','MarkerSize',5,'Color','rrrbbb',...
    'LineStyle',{'-','-.',':','-','-.',':'});
hold on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis tight
[P2_1,S2_1] = polyfit(coeftemp(bflist>0&bflist<=3,3),coeftemp(bflist>0&bflist<=3,4),1);
[P2_2,S2_2] = polyfit(coeftemp(bflist>3,3),coeftemp(bflist>3,4),1);
f1_1 = polyval(P2_1,[-1 1]);
f1_2 = polyval(P2_2,[-1 1]);
plot([-1 1],f1_1,'Color',[1 0.3 0.3])
plot([-1 1],f1_2,'Color',[0.3 0.3 1])
if plotdatatemp==1
    xlim([-0.6 0.5])
    ylim([-0.8 0.65])
end
if plotdatatemp==2
    xlim([-0.7 0.25])
    ylim([-0.4 0.6])
end
title(['Coefficients of FM Rate/FM Depth on ', coeftype]);
xlabel("FM Rate");
ylabel("FM Depth");
legend('BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -');

fig_c=figure('Position',[900 100 450 400]);
fig_c=scatterhist(coeftemp(okind,2),coeftemp(okind,4),...
    'Group',bflist(okind), ...
    'Kernel','on',...
    'Location','SouthWest','LineWidth',2,...
    'Direction','in','Marker','+ox+ox','MarkerSize',5,'Color','rrrbbb',...
    'LineStyle',{'-','-.',':','-','-.',':'});
hold on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis tight
[P3_1,S3_1] = polyfit(coeftemp(bflist>0&bflist<=3,2),coeftemp(bflist>0&bflist<=3,4),1);
[P3_2,S3_2] = polyfit(coeftemp(bflist>3,2),coeftemp(bflist>3,4),1);
f1_1 = polyval(P3_1,[-1 1]);
f1_2 = polyval(P3_2,[-1 1]);
plot([-1 1],f1_1,'Color',[1 0.3 0.3])
plot([-1 1],f1_2,'Color',[0.3 0.3 1])
if plotdatatemp==1
    xlim([-0.3 0.35])
    ylim([-0.85 0.65])
end
if plotdatatemp==2
    xlim([-0.3 0.4])
    ylim([-0.4 0.6])
end
title(['Coefficients of Contour/FM Depth on ', coeftype]);
xlabel("Contour");
ylabel("FM Depth");
legend('BF<=5kHz +','5kHz<BF<=10kHz +','BF>10kHz +','BF<=5kHz -','5kHz<BF<=10kHz -','BF>10kHz -');

%% Plot boxplot of all 3 coefficients
figure('position',[0 0 350 300]);
violinplot(coeftemp(okind,2),bflist(okind),'ViolinColor',[1 0 0;1 0 0;1 0 0;0 0 1;0 0 1;0 0 1]);
xlim([0 7]);
ylim([-0.3 0.5]);
% ylim([-0.3 0.5]);
xticklabels({'Low +','Mid +','Hi +','Low -','Mid -','Hi -'});
xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (Carrier Type)'];
title(txt);
plot([0 7],[0 0],'Color',[0.5 0.5 0.5]);

figure('position',[300 0 350 300]);
violinplot(coeftemp(okind,3),bflist(okind),'ViolinColor',[1 0 0;1 0 0;1 0 0;0 0 1;0 0 1;0 0 1]);
xlim([0 7]);
ylim([-0.7 0.8]);
% ylim([-0.7 0.5]);
xticklabels({'Low +','Mid +','Hi +','Low -','Mid -','Hi -'});
xlabel({'Unit Type'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Rate)'];
title(txt);
plot([0 7],[0 0],'Color',[0.5 0.5 0.5]);

figure('position',[600 0 350 300]);
violinplot(coeftemp(okind,4),bflist(okind),'ViolinColor',[1 0 0;1 0 0;1 0 0;0 0 1;0 0 1;0 0 1]);
xlim([0 7]);
ylim([-1 1.1]);
% ylim([-0.4 0.8]);
xticklabels({'Low +','Mid +','Hi +','Low -','Mid -','Hi -'});
xlabel({'Unit BF'});
ylabel({'GLM Coefficient'});
txt=[coeftype,' Coefficient (FM Depth)'];
title(txt);
plot([0 7],[0 0],'Color',[0.5 0.5 0.5]);
