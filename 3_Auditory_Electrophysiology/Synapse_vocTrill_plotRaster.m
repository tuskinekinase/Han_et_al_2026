%   Run after Synapse_vocFM_open64chanMUA.m
%   Plot raster of 4 vocFM recordings.
%%  Select channel
chantemp=input('Enter channel (1-64): ')

%%  Plot 
f = figure;
f.Position=[280 300 1200 400];
tiledlayout(1,3,TileSpacing="compact")

%%  Plot Flat FM Depth
nexttile
hold on
for i=271:470
    sz=2;
    scatter(raster_order{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
end
x = [onset(1) offset(1)];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0.5 2]);
ylim([270 470]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

% Draw stimuli border
x2 = [t_pre t_pre];
y2 = [270 470];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [t_pre+0.45 t_pre+0.45];
y3 = [270 470];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

% % Draw box
% rectangle('Position',[1.25,0,0.001,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)
% rectangle('Position',[1.2,10,0.1,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)
% rectangle('Position',[1.15,20,0.2,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)
% rectangle('Position',[1.1,30,0.3,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)
% rectangle('Position',[1.05,40,0.4,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)
% rectangle('Position',[1,50,0.5,10],'FaceColor','none','EdgeColor',[1 0.6 0.6], ...
%     'LineWidth',1)

title('Flat FM Depth');
xlabel('Time (s)');
ylabel('FM Frequency');
yticks(290:40:450)
yticklabels({'16','22.5','32','45','64'})

%%  Plot Trill FM Depth
nexttile
hold on
for i=1:200
    sz=2;
    scatter(raster_order{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
end
x = [onset(1) offset(1)];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0.5 2]);
ylim([0 200]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

% Draw stimuli border
x2 = [t_pre t_pre];
y2 = [0 200];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [t_pre+0.45 t_pre+0.45];
y3 = [0 200];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

title('Trill FM Depth');
xlabel('Time (s)');
ylabel('FM Frequency (Hz)');
yticks(20:40:180)
yticklabels({'16','22.5','32','45','64'})

%%  Plot Carrier Frequency
nexttile
hold on
for i=201:270
    sz=2;
    scatter(raster_order{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
end
x = [onset(1) offset(1)];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.6 0.6 0.6],'LineStyle','-')
xlim([0.5 2]);
ylim([200 270]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

% Draw stimuli border
x2 = [t_pre t_pre];
y2 = [200 270];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [t_pre+0.45 t_pre+0.45];
y3 = [200 270];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

title('FM Carrier Frequency');
xlabel('Time (s)');
ylabel('Carrier Frequency (kHz)');
yticks(205:10:265)
yticklabels({'14.2','10','7.1','5','3.54','1.77','0.44'})
