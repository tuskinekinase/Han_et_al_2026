% Run after Synapse_vocTrill_calcRate.m
% Presumed to already have chantemp ready
%If not, uncomment the following code:

% chantemp=[];
% chantemp=input('Enter list of ok channels (1-64) as a vector: ')

%% Set modulation parameters
amlist=[repmat(16,1,4) repmat(22.5,1,4) repmat(32,1,4) repmat(45,1,4) ...
    repmat(64,1,4) repmat(22.5,1,7) repmat(16,1,4) repmat(22.5,1,4) ...
    repmat(32,1,4) repmat(45,1,4) repmat(64,1,4)];     %List of FMs
amlist=1000./amlist;
depthlist=[repmat([125 250 500 1000],1,5) repmat(250,1,7) repmat([125 250 500 1000],1,5)];
stimstart(1:47,1)=1000; %change to ms
stimend(1:47,1)=1450;

for i=1:length(chantemp)
%% collect absolute spike times
j=chantemp(i);
z=1;
for s=1:47 %number of SGI
    tspikes=[];
    for tt=1:10 %number of trials
        tempspikes=[];
        tempspikes=raster_sort{j,(s-1)*10+tt}';tempspikes=tempspikes.*1000;
        tspikes=[tspikes tempspikes];
    end

    spike_times=tspikes;
    stim_dur=stimend(s,1)-stimstart(s,1);
 % stimtype=FM
        T=amlist(s);
    num_T = ceil(stim_dur/T);
    stimstart(s,1);
    stimend(s,1);

    num_spikes = length(find(spike_times >=(stimstart(s,1)+50)  & spike_times < stimend(s,1)+25));      %find the number of spikes
    spike_times=spike_times-stimstart(s,1);  %real spike times

    p = 1;
%     unit_spikes(i,s)=num_spikes;
    unit_spikes(s)=num_spikes;
    stt=[]; stt=spike_times(spike_times>=50 & spike_times < stim_dur+25);


    spike_abs(1:length(stt),z)=mod(stt,T);

    %
    r=0;
    q=0;

    if(num_spikes ~= 0) 
        k = 1;
        e = length(stt);
        for counter1=1:e(1,1)
            if(spike_abs(counter1,z) > 0)
                spike_abs2(k,1) = spike_abs(counter1,z);
                 r = r + cos((2*pi*(spike_abs2(k,1)))/T);          %variable for calculating vector strength
                q = q + sin((2*pi*(spike_abs2(k,1)))/T);          %variable for calculating vector strength
%                 r = r + (cos((2*pi*(spike_abs2(k,1)))/T))^2;          %variable for calculating vector strength
%                 q = q + (sin((2*pi*(spike_abs2(k,1)))/T))^2;
                if z==3
                    ck(k)=(cos((2*pi*(spike_abs2(k,1)))/T))^2;
                    sk(k)=(sin((2*pi*(spike_abs2(k,1)))/T))^2;
                    ck2(k)=cos((2*pi*(spike_abs2(k,1)))/T);
                    sk2(k)=sin((2*pi*(spike_abs2(k,1)))/T);
                    totr(k)=r;
                    totq(k)=q;
                    ns3=num_spikes;
                end
                k=k+1;
            end
        end
        vs(i,z)=(r^2+q^2)^.5/num_spikes;
%         vs(z)=(r+q)^.5/num_spikes;
        ray(i,z)=2*num_spikes*vs(z)^2;
        z = z+1;
    elseif num_spikes<=0
        vs(i,z)=0;
        ray(i,z)=0;
        z = z+1;

    end %end num_spikes~=0 loop
    %     t = t+1;
end %end loop for each stimulus

% %% Make figure
% figure('Position',[300 0 900 750]);
% tiledlayout(3,2,TileSpacing="compact")
% nexttile %plot trill FM
%     depthlist_plot=[125 250 500 1000];
%     hold on;
%     semilogy(log2(depthlist_plot./1000),ray(i,1:4),'bo-');
%     semilogy(log2(depthlist_plot./1000),ray(i,5:8),'rv-');
%     semilogy(log2(depthlist_plot./1000),ray(i,9:12),'gs-');
%     semilogy(log2(depthlist_plot./1000),ray(i,13:16),'cd-');
%     semilogy(log2(depthlist_plot./1000),ray(i,17:20),'mx-');
%     line([log2(depthlist_plot(1)/1000) log2(depthlist_plot(4)./1000)],[13.8 13.8],'color',[0.5 0.5 0.5]);
%     xlim([-3 0]);
%     clear xticks;
%     xticks(-3:1:0);
%     xticklabels({'125','250','500','1000'});
%     xlabel('FM Modulation Depth (Hz)');
%     ylabel('Rayleigh');
%     title('FM Depth Frequency (trill)');
% 
% nexttile %plot trill FM vector strength
%     depthlist_plot=[125 250 500 1000];
%     hold on;
%     semilogy(log2(depthlist_plot./1000),vs(i,1:4),'bo-');
%     semilogy(log2(depthlist_plot./1000),vs(i,5:8),'rv-');
%     semilogy(log2(depthlist_plot./1000),vs(i,9:12),'gs-');
%     semilogy(log2(depthlist_plot./1000),vs(i,13:16),'cd-');
%     semilogy(log2(depthlist_plot./1000),vs(i,17:20),'mx-');
%     xlim([-3 0]);
%     clear xticks;
%     xticks(-3:1:0);
%     xticklabels({'125','250','500','1000'});
%     xlabel('FM Modulation Depth (Hz)');
%     ylabel('Vector Strength');
%     title('FM Depth Frequency (trill)');
%     legend('16Hz','22.5Hz','32Hz','45Hz','64Hz')
% 
% nexttile %plot flat FM
%     depthlist_plot=[125 250 500 1000];
%     hold on;
%     semilogy(log2(depthlist_plot./1000),ray(i,28:31),'bo-');
%     semilogy(log2(depthlist_plot./1000),ray(i,32:35),'rv-');
%     semilogy(log2(depthlist_plot./1000),ray(i,36:39),'gs-');
%     semilogy(log2(depthlist_plot./1000),ray(i,40:43),'cd-');
%     semilogy(log2(depthlist_plot./1000),ray(i,44:47),'mx-');
%     line([log2(depthlist_plot(1)/1000) log2(depthlist_plot(4)./1000)],[13.8 13.8],'color',[0.5 0.5 0.5]);
%     xlim([-3 0]);
%     clear xticks;
%     xticks(-3:1:0);
%     xticklabels({'125','250','500','1000'});
%     xlabel('FM Modulation Depth (Hz)');
%     ylabel('Rayleigh');
%     title('FM Depth Frequency (flat)');
% 
% nexttile %plot flat FM vector strength
%     depthlist_plot=[125 250 500 1000];
%     hold on;
%     semilogy(log2(depthlist_plot./1000),vs(i,28:31),'bo-');
%     semilogy(log2(depthlist_plot./1000),vs(i,32:35),'rv-');
%     semilogy(log2(depthlist_plot./1000),vs(i,36:39),'gs-');
%     semilogy(log2(depthlist_plot./1000),vs(i,40:43),'cd-');
%     semilogy(log2(depthlist_plot./1000),vs(i,44:47),'mx-');
%     xlim([-3 0]);
%     clear xticks;
%     xticks(-3:1:0);
%     xticklabels({'125','250','500','1000'});
%     xlabel('FM Modulation Depth (Hz)');
%     ylabel('Vector Strength');
%     title('FM Depth Frequency (flat)');
% 
% nexttile %plot carrier frequency
%     freqlist_plot=flip([7083*2 7083*sqrt(2) 7083 7083/sqrt(2) 7083/2 7083/4 7038/16]);
%     hold on;
%     semilogy(log2(freqlist_plot),flip(ray(i,21:27)),'bo-')
%     line(log2([7083*2 7038/16]),[13.8 13.8],'color',[0.5 0.5 0.5]);
%     xlim([log2(7038/16) log2(7083*2)])
%     clear xticks;
%     xticks(log2(freqlist_plot));
%     xticklabels(freqlist_plot);
%     xlabel('Carrier Frequency (Hz)');
%     ylabel('Rayleigh');
%     title('Carrier Frequency');
% 
% nexttile %plot carrier frequency vector strength
%     freqlist_plot=flip([7083*2 7083*sqrt(2) 7083 7083/sqrt(2) 7083/2 7083/4 7038/16]);
%     hold on;
%     semilogy(log2(freqlist_plot),flip(vs(i,21:27)),'bo-')
%     xlim([log2(7038/16) log2(7083*2)])
%     clear xticks;
%     xticks(log2(freqlist_plot));
%     xticklabels(freqlist_plot);
%     xlabel('Carrier Frequency (Hz)');
%     ylabel('Vector Strength');
%     title('Carrier Frequency');
end