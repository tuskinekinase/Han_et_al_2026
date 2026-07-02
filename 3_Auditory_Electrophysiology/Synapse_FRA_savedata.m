% Run after Synapse_FRA_calcRate.m
% Save rates into Data_FRA_data

if exist('Data_FRA_data2025.mat','file') ~= 0
load Data_FRA_data2025.mat;
else
    save_ind=0;
    list_inhib=[]; list_on=[]; list_sus=[]; list_off=[]; 
    best_bpn=[]; best_tone=[];
end

% % This code is for empty
% if exist('save_ind','var') == 0
%     save_ind=0;
% end

leng=length(chantemp);

an_name(save_ind+1:(save_ind+leng),1)=input('Enter animal name (Example: "Thomas"): ');
date(save_ind+1:(save_ind+leng),1)=input('Enter recording date (Example: 20240117): ');
spl(save_ind+1:(save_ind+leng),1)=input('Enter max sound pressure level (dB): ');
chan(save_ind+1:(save_ind+leng),1)=sortchan(chantemp);
unit(save_ind+1:(save_ind+leng),1)=sortunit(chantemp);
group(save_ind+1:(save_ind+leng),1)=input('Enter group code (normal hearing = 0, hearing impaired = 1): ');

% Save block 1 (Bandpass noise)
bpn.mean_off(save_ind+1:(save_ind+leng),:)=mean_off_temp(:,1:77);
bpn.std_off(save_ind+1:(save_ind+leng),:)=std_off_temp(:,1:77);
bpn.mean_on(save_ind+1:(save_ind+leng),:)=mean_on_temp(:,1:77);
bpn.std_on(save_ind+1:(save_ind+leng),:)=std_on_temp(:,1:77);
bpn.mean_spont(save_ind+1:(save_ind+leng),:)=mean_spont_temp(:,1:77);
bpn.std_spont(save_ind+1:(save_ind+leng),:)=std_spont_temp(:,1:77);
bpn.mean_sus(save_ind+1:(save_ind+leng),:)=mean_sus_temp(:,1:77);
bpn.std_sus(save_ind+1:(save_ind+leng),:)=std_sus_temp(:,1:77);
bpn.mean_tot(save_ind+1:(save_ind+leng),:)=mean_tot_temp(:,1:77);
bpn.std_tot(save_ind+1:(save_ind+leng),:)=std_tot_temp(:,1:77);

for i=1:leng
    for j=1:385
        bpn.raster{save_ind+i,j}=raster_sort{chantemp(i),j};
    end
end

% Save block 2 (Pure tone)
pt.mean_off(save_ind+1:(save_ind+leng),:)=mean_off_temp(:,78:161);
pt.std_off(save_ind+1:(save_ind+leng),:)=std_off_temp(:,78:161);
pt.mean_on(save_ind+1:(save_ind+leng),:)=mean_on_temp(:,78:161);
pt.std_on(save_ind+1:(save_ind+leng),:)=std_on_temp(:,78:161);
pt.mean_spont(save_ind+1:(save_ind+leng),:)=mean_spont_temp(:,78:161);
pt.std_spont(save_ind+1:(save_ind+leng),:)=std_spont_temp(:,78:161);
pt.mean_sus(save_ind+1:(save_ind+leng),:)=mean_sus_temp(:,78:161);
pt.std_sus(save_ind+1:(save_ind+leng),:)=std_sus_temp(:,78:161);
pt.mean_tot(save_ind+1:(save_ind+leng),:)=mean_tot_temp(:,78:161);
pt.std_tot(save_ind+1:(save_ind+leng),:)=std_tot_temp(:,78:161);

for i=1:leng
    for j=386:805
        pt.raster{save_ind+i,j-385}=raster_sort{chantemp(i),j};
    end
end

save_ind=save_ind+leng;

save Data_FRA_data2025 an_name date spl chan unit group... 
    bpn pt list_inhib list_on list_sus list_off...
    best_bpn best_tone save_ind
