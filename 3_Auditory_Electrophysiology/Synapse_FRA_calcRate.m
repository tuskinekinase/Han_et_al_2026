%   Run after Synapse_FRA_open64chanSORT is run.
%   Calculate rates for each block of FRA.
chantemp=[];
% chantemp=input('Enter list of ok channels (1-64) as a vector: ')
% chantemp=[1 5 6 10 14 23 24 27 28 29 30 31 32 49 50 55 60 62 130 155]'
chantemp=find((sortunit~=0)==1);

% Control onset and offset time
t_on=0.1;
t_off=0.1;

load FRA_param_list.mat

for i=1:length(chantemp)
j=chantemp(i);

%% Calc Rates
spike_spont=[]; spike_tot=[]; spike_on=[]; spike_sus=[]; spike_off=[];
rate_spont=[]; rate_tot=[]; rate_on=[]; rate_sus=[]; rate_off=[];

for sgi=1:161
    for trial=1:5
            ind_temp=(sgi-1)*5+trial;
        %spont: 1-0.2s pre stim
            spike_spont(sgi,trial)=length(find(raster_sort{j,ind_temp}>0&raster_sort{j,ind_temp}<=0.1));
            rate_spont(sgi,trial)=spike_spont(sgi,trial)/0.1;
        %total: entire 0.5 sec of stim
            spike_tot(sgi,trial)=length(find(raster_sort{j,ind_temp}>0.1&raster_sort{j,ind_temp}<=0.3));
            rate_tot(sgi,trial)=spike_tot(sgi,trial)/0.2;
        %onset: 0-0.1 sec of stim
            spike_on(sgi,trial)=length(find(raster_sort{j,ind_temp}>0.1&raster_sort{j,ind_temp}<=(0.1+t_on)));
            rate_on(sgi,trial)=spike_on(sgi,trial)/t_on;
        %sustained: 0.1 sec-end of stim
            spike_sus(sgi,trial)=length(find(raster_sort{j,ind_temp}>(0.1+t_on)&raster_sort{j,ind_temp}<=0.3));
            rate_sus(sgi,trial)=spike_sus(sgi,trial)/(0.2-t_on);
        %offset: 0-0.1 post stim
            spike_off(sgi,trial)=length(find(raster_sort{j,ind_temp}>0.3&raster_sort{j,ind_temp}<=(0.3+t_off)));
            rate_off(sgi,trial)=spike_off(sgi,trial)/t_off;
    end
    mean_spont_temp(i,sgi)=mean(rate_spont(sgi,:));
    std_spont_temp(i,sgi)=std(rate_spont(sgi,:));
    mean_tot_temp(i,sgi)=mean(rate_tot(sgi,:));
    std_tot_temp(i,sgi)=std(rate_tot(sgi,:));
    mean_on_temp(i,sgi)=mean(rate_on(sgi,:));
    std_on_temp(i,sgi)=std(rate_on(sgi,:));
    mean_sus_temp(i,sgi)=mean(rate_sus(sgi,:));
    std_sus_temp(i,sgi)=std(rate_sus(sgi,:));
    mean_off_temp(i,sgi)=mean(rate_off(sgi,:));
    std_off_temp(i,sgi)=std(rate_off(sgi,:));
end


unitnum=sortunit(i);
channum=sortchan(i);

end
