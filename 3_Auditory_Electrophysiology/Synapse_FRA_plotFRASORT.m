%   Run after Synapse_FRA_open64chanMUA is run.
%   Plot BPN and tone FRA in heatmaps.
%%  Plot raster and FRA heatmap
chantemp=input('Enter channel (1-64): ')
figure
hold on
for i=1:reps*ind
    sz=2;
    if isempty(raster_sort{chantemp,i})~=1
    scatter(raster_sort{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',1);
    end
end
x = [0 1];
y = [linspace(reps,reps*(ind-1),ind-1)' linspace(reps,reps*(ind-1),ind-1)'];
line(x,y,'Color',[0.8 0.8 0.8],'LineStyle','-')
xlim([0 0.5]);
ylim([0 reps*ind]);

% t_pre = input ('Enter pre-stimulus delay (s): ');
% t_pre = 0.2;
t_pre= 0.1;

% Draw stimuli border
x2 = [t_pre t_pre];
y2 = [0 reps*ind];
line(x2,y2,'Color',[0.6 0.6 0.6],'LineStyle','-')
x3 = [t_pre+0.2 t_pre+0.2];
y3 = [0 reps*ind];
line(x3,y3,'Color',[0.6 0.6 0.6],'LineStyle','-')

%% Plot FRA heatmap
for i=1:length(sortchan)
    for j=1:805
        spike_temp(i,j)=length(find(raster_sort{i,j}>=0.1&raster_sort{i,j}<=0.4));
        rate_temp(i,j)=spike_temp(i,j)/0.3;
    end
end

for i=1:length(sortchan)
    for j=1:161
        jlist=((j-1)*5+1):((j-1)*5+5);
        rate_mean(i,j)=mean(rate_temp(i,jlist));
    end
end

load FRA_param_list.mat

% BPN
for f=1:13
    for l=1:6
        okind=find(sgi_freq==bpn_freq(f)&sgi_level==bpn_level(l)&sgi_type==0);
        if isempty(okind)
            fra(f,l)=0;
        else
            fra(f,l)=(rate_mean(chantemp,okind));
        end
    end
end

% Tone
for f=1:14
    for l=1:6
        okind=find(sgi_freq==tone_freq(f)&sgi_level==tone_level(l)&sgi_type==1);
        if isempty(okind)
            fra_pt(f,l)=0;
        else
            fra_pt(f,l)=(rate_mean(chantemp,okind));
        end
    end
end

fig = figure;
fig.Position=[280 0 400 600];
tiledlayout(2,1,TileSpacing="compact")
nexttile
h1 = heatmap(bpn_freq,bpn_level,fra','ColorMethod','median');
colormap jet
grid off
h1.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16'};
h1.XLabel = {'Frequency (kHz)'};
h1.YLabel = {'SPL (dB)'};
h1.Title = {'BPN'};
nexttile
h2 = heatmap(tone_freq,tone_level,fra_pt','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'Tone'};
