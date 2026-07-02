%   Plot FRA from saved data (Data_FRA_data.mat)
%   Type is written in another .xls file, will import to Data_FRA_data.mat
%   separately
load Data_FRA_data2025.mat
load FRA_param_list.mat

chantemp=input('Enter unit number: ')
%%  Plot BPN raster
reps=5;
ind=77;

figure
hold on
for i=1:reps*ind
    sz=2;
    if ~isempty(bpn.raster{chantemp,i})==1
    scatter(bpn.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
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

%%  Plot BPN FRA heatmaps
% BPN
for f=1:13
    for l=1:6
        okind=find(sgi_freq==bpn_freq(f)&sgi_level==bpn_level(l)&sgi_type==0);
        if isempty(okind)
            fra_tot(f,l)=0;
            fra_on(f,l)=0;
            fra_sus(f,l)=0;
            fra_off(f,l)=0;
        else
            fra_tot(f,l)=(bpn.mean_tot(chantemp,okind));
            fra_on(f,l)=(bpn.mean_on(chantemp,okind));
            fra_sus(f,l)=(bpn.mean_sus(chantemp,okind));
            fra_off(f,l)=(bpn.mean_off(chantemp,okind));
        end
    end
end

fig = figure;
fig.Position=[280 0 800 600];
tiledlayout(2,2,TileSpacing="compact")
nexttile
h1 = heatmap(bpn_freq,bpn_level,fra_tot','ColorMethod','median');
colormap jet
grid off
h1.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16'};
h1.XLabel = {'Frequency (kHz)'};
h1.YLabel = {'SPL (dB)'};
h1.Title = {'BPN FRA (Total Rate)'};
nexttile
h2 = heatmap(bpn_freq,bpn_level,fra_on','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16'};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'BPN FRA (Onset Rate)'};
nexttile
h2 = heatmap(bpn_freq,bpn_level,fra_sus','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16'};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'BPN FRA (Sustained Rate)'};
nexttile
h2 = heatmap(bpn_freq,bpn_level,fra_off','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16'};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'BPN FRA (Offset Rate)'};

%% Plot Tone raster
reps=5;
ind=84;

figure
hold on
for i=1:reps*ind
    sz=2;
    if ~isempty(pt.raster{chantemp,i})==1
    scatter(pt.raster{chantemp,i},i-0.5,sz,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0],'LineWidth',1);
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

%%  Plot Tone FRA heatmaps
% Tone
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

fig = figure;
fig.Position=[280 0 800 600];
tiledlayout(2,2,TileSpacing="compact")
nexttile
h1 = heatmap(tone_freq,tone_level,fra_pt_tot','ColorMethod','median');
colormap jet
grid off
h1.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h1.XLabel = {'Frequency (kHz)'};
h1.YLabel = {'SPL (dB)'};
h1.Title = {'Tone FRA (Total Rate)'};
nexttile
h2 = heatmap(tone_freq,tone_level,fra_pt_on','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'Tone FRA (Onset Rate)'};
nexttile
h2 = heatmap(tone_freq,tone_level,fra_pt_sus','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'Tone FRA (Sustained Rate)'};
nexttile
h2 = heatmap(tone_freq,tone_level,fra_pt_off','ColorMethod','median');
colormap jet
grid off
h2.XDisplayLabels = {'0.25' '' '0.5'  '' '1' '' '2' '' '4' '' '8' '' '16' ''};
h2.XLabel = {'Frequency (kHz)'};
h2.YLabel = {'SPL (dB)'};
h2.Title = {'Tone FRA (Offset Rate)'};
