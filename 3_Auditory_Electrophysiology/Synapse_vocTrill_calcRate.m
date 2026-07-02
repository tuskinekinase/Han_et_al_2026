%   Run after Synapse_vocTrill_open64chanSORT is run.
%   Calculate rates for each block of FRA.
chantemp=[];
% chantemp=input('Enter list of ok channels (1-64) as a vector: ')
% chantemp=[1 5 6 10 14 23 24 27 28 29 30 31 32 49 50 55 60 62 130 155]'
chantemp=find((sortunit~=0)==1);

% Control onset and offset time
t_on=0.1;
t_off=0.1;

for i=1:length(chantemp)
j=chantemp(i);

%% vocFM FM depth freq combi
%Calculate spont mean and std
spike_spont=[]; spike_tot=[]; spike_on=[]; spike_sus=[]; spike_off=[];
rate_spont=[]; rate_tot=[]; rate_on=[]; rate_sus=[]; rate_off=[];

for sgi=1:20
    for trial=1:10
            ind_temp=(sgi-1)*10+trial;
        %spont: 1-0.2s pre stim
            spike_spont(sgi,trial)=length(find(raster_sort{j,ind_temp}>0&raster_sort{j,ind_temp}<=0.8));
            rate_spont(sgi,trial)=spike_spont(sgi,trial)/0.8;
        %total: entire 0.5 sec of stim
            spike_tot(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=1.45));
            rate_tot(sgi,trial)=spike_tot(sgi,trial)/0.45;
        %onset: 0-0.1 sec of stim
            spike_on(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=(1+t_on)));
            rate_on(sgi,trial)=spike_on(sgi,trial)/t_on;
        %sustained: 0.1-0.5 sec of stim
            spike_sus(sgi,trial)=length(find(raster_sort{j,ind_temp}>(1+t_on)&raster_sort{j,ind_temp}<=1.45));
            rate_sus(sgi,trial)=spike_sus(sgi,trial)/(0.45-t_on);
        %offset: 0-0.1 post stim
            spike_off(sgi,trial)=length(find(raster_sort{j,ind_temp}>1.5&raster_sort{j,ind_temp}<=(1.45+t_off)));
            rate_off(sgi,trial)=spike_off(sgi,trial)/t_off;
    end
    mean_spont1(i,sgi)=mean(rate_spont(sgi,:));
    std_spont1(i,sgi)=std(rate_spont(sgi,:));
    mean_tot1(i,sgi)=mean(rate_tot(sgi,:));
    std_tot1(i,sgi)=std(rate_tot(sgi,:));
    mean_on1(i,sgi)=mean(rate_on(sgi,:));
    std_on1(i,sgi)=std(rate_on(sgi,:));
    mean_sus1(i,sgi)=mean(rate_sus(sgi,:));
    std_sus1(i,sgi)=std(rate_sus(sgi,:));
    mean_off1(i,sgi)=mean(rate_off(sgi,:));
    std_off1(i,sgi)=std(rate_off(sgi,:));
end

chanlist(i,1)=j;

%% vocFM FM carrier frequency
%Calculate spont mean and std
spike_spont=[]; spike_tot=[]; spike_on=[]; spike_sus=[]; spike_off=[];
rate_spont=[]; rate_tot=[]; rate_on=[]; rate_sus=[]; rate_off=[];

for sgi=21:27
    for trial=1:10
            ind_temp=(sgi-1)*10+trial;
        %spont: 1-0.2s pre stim
            spike_spont(sgi,trial)=length(find(raster_sort{j,ind_temp}>0&raster_sort{j,ind_temp}<=0.8));
            rate_spont(sgi,trial)=spike_spont(sgi,trial)/0.8;
        %total: entire 0.5 sec of stim
            spike_tot(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=1.45));
            rate_tot(sgi,trial)=spike_tot(sgi,trial)/0.45;
        %onset: 0-0.1 sec of stim
            spike_on(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=(1+t_on)));
            rate_on(sgi,trial)=spike_on(sgi,trial)/t_on;
        %sustained: 0.1-0.5 sec of stim
            spike_sus(sgi,trial)=length(find(raster_sort{j,ind_temp}>(1+t_on)&raster_sort{j,ind_temp}<=1.45));
            rate_sus(sgi,trial)=spike_sus(sgi,trial)/(0.45-t_on);
        %offset: 0-0.1 post stim
            spike_off(sgi,trial)=length(find(raster_sort{j,ind_temp}>1.5&raster_sort{j,ind_temp}<=(1.45+t_off)));
            rate_off(sgi,trial)=spike_off(sgi,trial)/t_on;
    end
    mean_spont2(i,sgi-20)=mean(rate_spont(sgi,:));
    std_spont2(i,sgi-20)=std(rate_spont(sgi,:));
    mean_tot2(i,sgi-20)=mean(rate_tot(sgi,:));
    std_tot2(i,sgi-20)=std(rate_tot(sgi,:));
    mean_on2(i,sgi-20)=mean(rate_on(sgi,:));
    std_on2(i,sgi-20)=std(rate_on(sgi,:));
    mean_sus2(i,sgi-20)=mean(rate_sus(sgi,:));
    std_sus2(i,sgi-20)=std(rate_sus(sgi,:));
    mean_off2(i,sgi-20)=mean(rate_off(sgi,:));
    std_off2(i,sgi-20)=std(rate_off(sgi,:));
end

chanlist(i,1)=j;

%% vocFM FM flat depth freq combi
%Calculate spont mean and std
spike_spont=[]; spike_tot=[]; spike_on=[]; spike_sus=[]; spike_off=[];
rate_spont=[]; rate_tot=[]; rate_on=[]; rate_sus=[]; rate_off=[];

for sgi=28:47
    for trial=1:10
            ind_temp=(sgi-1)*10+trial;
        %spont: 1-0.2s pre stim
            spike_spont(sgi,trial)=length(find(raster_sort{j,ind_temp}>0&raster_sort{j,ind_temp}<=0.8));
            rate_spont(sgi,trial)=spike_spont(sgi,trial)/0.8;
        %total: entire 0.5 sec of stim
            spike_tot(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=1.45));
            rate_tot(sgi,trial)=spike_tot(sgi,trial)/0.45;
        %onset: 0-0.1 sec of stim
            spike_on(sgi,trial)=length(find(raster_sort{j,ind_temp}>1&raster_sort{j,ind_temp}<=(1+t_on)));
            rate_on(sgi,trial)=spike_on(sgi,trial)/t_on;
        %sustained: 0.1-0.5 sec of stim
            spike_sus(sgi,trial)=length(find(raster_sort{j,ind_temp}>(1+t_on)&raster_sort{j,ind_temp}<=1.45));
            rate_sus(sgi,trial)=spike_sus(sgi,trial)/(0.45-t_on);
        %offset: 0-0.1 post stim
            spike_off(sgi,trial)=length(find(raster_sort{j,ind_temp}>1.5&raster_sort{j,ind_temp}<=(1.45+t_off)));
            rate_off(sgi,trial)=spike_off(sgi,trial)/t_on;
    end
    mean_spont3(i,sgi-27)=mean(rate_spont(sgi,:));
    std_spont3(i,sgi-27)=std(rate_spont(sgi,:));
    mean_tot3(i,sgi-27)=mean(rate_tot(sgi,:));
    std_tot3(i,sgi-27)=std(rate_tot(sgi,:));
    mean_on3(i,sgi-27)=mean(rate_on(sgi,:));
    std_on3(i,sgi-27)=std(rate_on(sgi,:));
    mean_sus3(i,sgi-27)=mean(rate_sus(sgi,:));
    std_sus3(i,sgi-27)=std(rate_sus(sgi,:));
    mean_off3(i,sgi-27)=mean(rate_off(sgi,:));
    std_off3(i,sgi-27)=std(rate_off(sgi,:));
end

chanlist(i,1)=j;

end
    

