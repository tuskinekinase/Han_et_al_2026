%   Plot Raster and Ray VS (I guess) from saved data (Data_FRA_data.mat)
clear all;
load Data_vocTrill_data.mat

reps=10;    %Repetition. Change according to setup
tc=2.5;       %Duty cycle. Change according to setup
delay=1;  %Delay. Change according to setup

% fs=data.streams.Time.fs;
% ti=1/fs;
ind=20;
% sgi_leng=ind*reps;

onset=0;
offset=2.5;

% tleng=offset(1)-onset(1);
% tlist=(ti:ti:(offset-onset));

%%  Input unit number

chantemp=input('Enter unit number: ')

% %%  Plot 
% f = figure;
% f.Position=[280 300 1200 400];
% tiledlayout(1,3,TileSpacing="compact")

%%  Plot Flat FM Depth
figure('Position',[100 100 400 300])
% nexttile
hold on
for i=1:200
    sz=2;
    if isempty(flatdepth.raster{chantemp,i})~=1
    scatter(flatdepth.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
    end
end
x = [0 2.5];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0.5 2]);
ylim([0 200]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

% Draw stimuli border
x2 = [1 1];
y2 = [0 200];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [1.45 1.45];
y3 = [0 200];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

title('Flat FM Depth');
xlabel('Time (s)');
ylabel('FM Frequency');
yticks(20:40:220)
yticklabels({'16','22.5','32','45','64'})

%%  Plot Trill FM Depth
figure('Position',[100 100 400 300])
% nexttile
hold on
for i=1:200
    sz=2;
    if isempty(trilldepth.raster{chantemp,i})~=1
    scatter(trilldepth.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
    end
end
x = [0 2.5];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0.5 2]);
ylim([0 200]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

% Draw stimuli border
x2 = [1 1];
y2 = [0 200];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [1.45 1.45];
y3 = [0 200];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

title('Trill FM Depth');
xlabel('Time (s)');
ylabel('FM Frequency');
yticks(20:40:220)
yticklabels({'16','22.5','32','45','64'})

% %%  Plot Carrier Frequency
% nexttile
% hold on
% for i=1:70
%     sz=2;
%     if isempty(flatcarrier.raster{chantemp,i})~=1
%     scatter(flatcarrier.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
%               'MarkerFaceColor',[0 0 0],'LineWidth',1);
%     end
% end
% x = [0 2.5];
% y = [linspace(reps,reps*6,6)' linspace(reps,reps*6,6)'];
% line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
% xlim([0.5 2]);
% ylim([0 70]);
% 
% % t_pre = input ('Enter pre-stimulus delay (s): ');
% % t_pre = 0.2;
% t_pre= delay;
% 
% % Draw stimuli border
% x2 = [t_pre t_pre];
% y2 = [0 70];
% line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
% x3 = [t_pre+0.45 t_pre+0.45];
% y3 = [0 70];
% line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')
% 
% title('FM Carrier Frequency');
% xlabel('Time (s)');
% ylabel('Carrier Frequency (kHz)');
% yticks(5:10:65)
% yticklabels({'14.2','10','7.1','5','3.54','1.77','0.44'})