%   Goal: To make a profile plotter that shows Tone FRA, Flat Raster,
%   Contour raster, and lind plot showing mean susrate and VS on each 
%   data point

addpath('C:\Users\emily\Documents\MATLAB\synapse');
load Data_FRA_data.mat
load Data_vocTrill_data.mat
load Data_vocCall_data.mat

load Audio_vocCallData.mat;

chantemp=input('Enter unit ID: ')

%%  Preprocess VS which are too low
for i=1:385
    for j=1:20
        % if trilldepth.ray(i,j)<=13.6&trilldepth.mean_sus(i,j)<=2
        if trilldepth.ray(i,j)<=3&&trilldepth.mean_sus(i,j)<=2
            % trilldepth.vs(i,j)=NaN;
            trilldepth.vs(i,j)=0;
        end
    end
end

%%  Plot Tone FRA heatmaps
% Tone
load FRA_param_list.mat

for f=1:14
    for l=1:6
        okind=find(sgi_freq==tone_freq(f)&sgi_level==tone_level(l)&sgi_type==1)-77;
        if isempty(okind)
            fra_pt_tot(f,l)=0;
            fra_pt_on(f,l)=0;
            fra_pt_sus(f,l)=0;
            fra_pt_off(f,l)=0;
        else
            fra_pt_tot(f,l)=(pt.mean_tot(chantemp,okind));
            fra_pt_on(f,l)=(pt.mean_on(chantemp,okind));
            fra_pt_sus(f,l)=(pt.mean_sus(chantemp,okind));
            fra_pt_off(f,l)=(pt.mean_off(chantemp,okind));
        end
    end
end

f1=figure('Position',[100 400 220 200]);
h2 = heatmap(tone_freq,tone_level,fra_pt_sus','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'Tone FRA (Sustained Rate)'};

figname=sprintf('Tone FRA %d', chantemp);
print(f1, '-dsvg', figname, '-vector')

%%  Prepare Trill Data
reps=10;    %Repetition. Change according to setup
tc=2.5;       %Duty cycle. Change according to setup
delay=1;  %Delay. Change according to setup

% fs=data.streams.Time.fs;
% ti=1/fs;
ind=20;
% sgi_leng=ind*reps;

onset=0;
offset=2.5;

%%  Plot Flat FM Depth
f2=figure('Position',[200 400 250 300]);
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
xlim([0.8 1.65]);
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
ylabel('FM Frequency (Hz)');
yticks(20:40:220)
yticklabels({'16','22.5','32','45','64'})

figname=sprintf('Flat Raster %d', chantemp);
print(f2, '-dsvg', figname, '-vector')

%%  Plot Trill FM Depth
f3=figure('Position',[300 400 250 300]);
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
xlim([0.8 1.65]);
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
ylabel('FM Frequency (Hz)');
yticks(20:40:220);
yticklabels({'16','22.5','32','45','64'})

figname=sprintf('Trill Raster %d', chantemp);
print(f3, '-dsvg', figname, '-vector')

%%  Plot Rate figure
ratedata_temp=trilldepth.mean_sus(chantemp,:);
rateerr_temp=trilldepth.std_sus(chantemp,:)/sqrt(10);

% figure('Position',[500 400 200 160]);
f4=figure('Position',[500 400 200 320]);
tiledlayout(2,1);

nexttile
hold on;
errorbar(1:5,ratedata_temp([1 5 9 13 17]),rateerr_temp([1 5 9 13 17]),'Color',[0.8 0.8 1],'LineWidth',2);
errorbar(1:5,ratedata_temp([2 6 10 14 18]),rateerr_temp([2 6 10 14 18]),'Color',[0.6 0.6 1],'LineWidth',2);
errorbar(1:5,ratedata_temp([3 7 11 15 19]),rateerr_temp([3 7 11 15 19]),'Color',[0.4 0.4 1],'LineWidth',2);
errorbar(1:5,ratedata_temp([4 8 12 16 20]),rateerr_temp([4 8 12 16 20]),'Color',[0 0 1],'LineWidth',2);
title('Rate');
xticks(1:5);
xticklabels([16 22.5 32 45 64]);
xlabel('FM Rate (Hz)')
ylabel('susFR')

%%  Plot VS figure
vsdata_temp=trilldepth.vs(chantemp,:);

% figure('Position',[700 400 200 160]);
nexttile
hold on;
plot(1:5,vsdata_temp([1 5 9 13 17]),'Color',[0.8 0.8 1],'LineWidth',2);
plot(1:5,vsdata_temp([2 6 10 14 18]),'Color',[0.6 0.6 1],'LineWidth',2);
plot(1:5,vsdata_temp([3 7 11 15 19]),'Color',[0.4 0.4 1],'LineWidth',2);
plot(1:5,vsdata_temp([4 8 12 16 20]),'Color',[0 0 1],'LineWidth',2);
title('VS');
xticks(1:5);
xticklabels([16 22.5 32 45 64]);
xlabel('FM Rate (Hz)')
ylabel('VS')

figname=sprintf('Rate VS %d', chantemp);
print(f4, '-dsvg', figname, '-vector')

%%  Plot Calls
%Plot waveforms behind first
f5=figure('Position',[700 400 250 300]);
hold on
plot(audio_ts_pad,5*audio_pad(9,:)+5,"Color",[0.7 0.7 0.7])

plot(audio_ts_pad,5*audio_pad(10,:)+15,"Color",[0.7 0.7 0.7])

plot(audio_ts_pad,5*audio_pad(11,:)+25,"Color",[0.7 0.7 0.7])

plot(audio_ts_pad,5*audio_pad(12,:)+35,"Color",[0.7 0.7 0.7])

%Plot Trills and draw borders
reps=10;    %Repetition. Change according to setup
tc=4;       %Duty cycle. Change according to setup
delay=1;  %Delay. Change according to setup

ind=4;
sgi_leng=ind*reps;

onset=0;
offset=2.5;


hold on
for i=1:40
    sz=2;
    if ~isempty(calltrill.raster{chantemp,i})
    scatter(calltrill.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
    end
end
x = [onset tc];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0.75 tc-2.15]);
ylim([0 40]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= delay;

%Draw stimuli border

x2 = [t_pre t_pre];
y2 = [0 reps*ind];
line(x2,y2,'Color',[0.8 0.8 0.8],'LineStyle','-')

x3 = [1+t_audio(9:12) 1+t_audio(9:12)]';
y3 = [linspace(0,30,4)' linspace(10,40,4)']';
line(x3,y3,'Color',[0.8 0.8 0.8],'LineStyle','-')

title('Call Responses');
xlabel('Time (s)');
ylabel('Calls');
yticks(5:10:35);
yticklabels({'1','2','3','4'})

figname=sprintf('Real Trills %d', chantemp);
print(f5, '-dsvg', figname, '-vector')
