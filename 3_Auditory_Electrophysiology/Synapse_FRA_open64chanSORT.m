close all;
clear;
addpath(genpath('C:\Users\emily\Documents\MATLAB\TDTMatlabSDK'));
BLOCKPATH='C:\TDT\OpenEx\Tanks\64ch_FRA_calibrate-240117-141027\Hunter-250610-150440';
data = TDTbin2mat(BLOCKPATH);

File=fullfile(BLOCKPATH, 'eNe1_TestSort.txt');
temp_allsorts=load(File);    % Use OpenExplorer to export OpenSorter result (Sort Code only!) to Tank folder as eNe1_TestSort.txt

%%  Extract Time Code
reps=5;    %Repetition. Change according to setup
tc=1;       %Duty cycle. Change according to setup
delay=0;  %Delay. Change according to setup

fs=data.streams.Time.fs;
ti=1/fs;
ind=max(data.epocs.WVd_.data);
sgi_leng=ind*reps;

onset=data.scalars.fS1p.ts(1:sgi_leng)-0.1;
offset=data.scalars.fS1p.ts(1:sgi_leng)+0.4;

tleng=offset(1)-onset(1);
tlist=(ti:ti:(offset-onset));

%%  Extract SGI
sgi_list=data.epocs.WVd_.data(1:sgi_leng);

% The current experiments does not have an ending condition. We only
% extract the relevant ones.

%%  Sort spikes into channels
temp_allspikes=data.snips.eNe1.ts;  %This is all timestamps for all spike events.
temp_allchans=data.snips.eNe1.chan; %This is all corresponding channels for each spike events in "snips.eNe1.ts"

%These codes yield allspikes{:,1} as raster data (timestamps) for all
%recorded spikes, sorted into 64 individual channels.
for i=1:64
    allspikes{i,1}=temp_allspikes(temp_allchans==i);
    allsorts{i,1}=temp_allsorts(temp_allchans==i);  % Use this for sort code
end

%By the way, data.snips.eNe1.data (an Nx30 single) records the waveforms
%surrounding each spikes. The window is 30 data points long.

%%  Sort spikes into blocks

%These codes sort all spikes in allspikes{:,1} into individual blocks
%according to time code.
for i=1:64
    allspikes_temp=allspikes{i};
    allsorts_temp=allsorts{i};  % Use this for sort code
    for j=1:length(onset)
        raster{i,j}=allspikes_temp(find(allspikes{i,1}>onset(j)&allspikes{i,1}<=offset(j)))-onset(j);
        sortnum{i,j}=allsorts_temp(find(allspikes{i,1}>onset(j)&allspikes{i,1}<=offset(j)));
    end
end

%%  List valid streamed data
t_total=tc*sgi_leng;
ti_total=int64(t_total*fs);

data_true=data.streams.LFP1.data(:,1:ti_total);
ts_true=data.streams.Time.data(:,1:ti_total);
%This yields streamed data within valide recording periods.

%%  Chunk valid streamed data
for i=1:64
    for j=1:length(onset)
        data_block{i,j}=data_true(i,((j-1)*length(tlist)+1):j*length(tlist));
    end
end

%%  reorder raster and stream block index
[sgi,allindex]=sort(sgi_list);

data_block_order={};
raster_order={};
for i=1:64
    for j=1:length(sgi_list)
        data_block_order{i,j}=data_block{i,allindex(j)};
        raster_order{i,j}=raster{i,allindex(j)};
        sortnum_order{i,j}=sortnum{i,allindex(j)};
    end
end

%% Separate multiunits
for i=1:64
    for j=1:length(allindex)
        for s=1:5
            if any(sortnum_order{i,j}==s)==1
            sortnum_temp{i+(s-1)*100, j}=sortnum_order{i,j}(sortnum_order{i,j}==s); %shift each new unit by 100
            raster_temp{i+(s-1)*100, j}=raster_order{i,j}(sortnum_order{i,j}==s);
            sortchan_temp(i+(s-1)*100, j)=i; %yields channel info for each unit
            sortunit_temp(i+(s-1)*100, j)=s; %yields unit num for each unit (including zero)
            else
                sortnum_temp{i+(s-1)*100, j}=[];
                raster_temp{i+(s-1)*100, j}=[];
                sortchan_temp(i+(s-1)*100, j)=i;
                sortunit_temp(i+(s-1)*100, j)=0;
            end
        end
    end
end

for i=1:length(sortchan_temp(:,1))
    sortchan(i,1)=sortchan_temp(i,1);
    sortunit(i,1)=max(sortunit_temp(i,:));  %find all units with at least one sorted instance. This will serve as the source of real channels.
end    

raster_sort=raster_temp;
sortnum_sort=sortnum_temp;