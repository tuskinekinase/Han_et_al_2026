% Run after Synapse_vocTrill_calcRate.m and Synapse_vocTrill_calcRayVS.m
% Save rates, Rayleight and VS into Data_vocTrill_data

if exist('Data_vocTrill_data.mat','file') ~= 0
load Data_vocTrill_data.mat;
else
    save_ind=0;
end

% % This code is for empty
% if exist('save_ind','var') == 0
%     save_ind=0;
% end

leng=length(chantemp);

an_name(save_ind+1:(save_ind+leng),1)=input('Enter animal name (Example: "Thomas"): ');
date(save_ind+1:(save_ind+leng),1)=input('Enter recording date (Example: 20240117): ');
spl(save_ind+1:(save_ind+leng),1)=input('Enter sound pressure level (dB): ');
chan(save_ind+1:(save_ind+leng),1)=sortchan(chantemp);
unit(save_ind+1:(save_ind+leng),1)=sortunit(chantemp);
group(save_ind+1:(save_ind+leng),1)=input('Enter group code (normal hearing = 0, hearing impaired = 1): ');

% Save block 1 (vocFM FM depth freq combi)
trilldepth.mean_off(save_ind+1:(save_ind+leng),:)=mean_off1(:,:);
trilldepth.std_off(save_ind+1:(save_ind+leng),:)=std_off1(:,:);
trilldepth.mean_on(save_ind+1:(save_ind+leng),:)=mean_on1(:,:);
trilldepth.std_on(save_ind+1:(save_ind+leng),:)=std_on1(:,:);
trilldepth.mean_spont(save_ind+1:(save_ind+leng),:)=mean_spont1(:,:);
trilldepth.std_spont(save_ind+1:(save_ind+leng),:)=std_spont1(:,:);
trilldepth.mean_sus(save_ind+1:(save_ind+leng),:)=mean_sus1(:,:);
trilldepth.std_sus(save_ind+1:(save_ind+leng),:)=std_sus1(:,:);
trilldepth.mean_tot(save_ind+1:(save_ind+leng),:)=mean_tot1(:,:);
trilldepth.std_tot(save_ind+1:(save_ind+leng),:)=std_tot1(:,:);
trilldepth.ray(save_ind+1:(save_ind+leng),:)=ray(:,1:20);
trilldepth.vs(save_ind+1:(save_ind+leng),:)=vs(:,1:20);

for i=1:leng
    for j=1:200
        trilldepth.raster{save_ind+i,j}=raster_sort{chantemp(i),j};
    end
end

% Save block 2 (vocFM flat carrier frequency)
flatcarrier.mean_off(save_ind+1:(save_ind+leng),:)=mean_off2(:,:);
flatcarrier.std_off(save_ind+1:(save_ind+leng),:)=std_off2(:,:);
flatcarrier.mean_on(save_ind+1:(save_ind+leng),:)=mean_on2(:,:);
flatcarrier.std_on(save_ind+1:(save_ind+leng),:)=std_on2(:,:);
flatcarrier.mean_spont(save_ind+1:(save_ind+leng),:)=mean_spont2(:,:);
flatcarrier.std_spont(save_ind+1:(save_ind+leng),:)=std_spont2(:,:);
flatcarrier.mean_sus(save_ind+1:(save_ind+leng),:)=mean_sus2(:,:);
flatcarrier.std_sus(save_ind+1:(save_ind+leng),:)=std_sus2(:,:);
flatcarrier.mean_tot(save_ind+1:(save_ind+leng),:)=mean_tot2(:,:);
flatcarrier.std_tot(save_ind+1:(save_ind+leng),:)=std_tot2(:,:);
flatcarrier.ray(save_ind+1:(save_ind+leng),:)=ray(:,21:27);
flatcarrier.vs(save_ind+1:(save_ind+leng),:)=vs(:,21:27);

for i=1:leng
    for j=201:270
        flatcarrier.raster{save_ind+i,j-200}=raster_sort{chantemp(i),j};
    end
end

% Save block 3 (vocFM flat FM depth freq combi)
flatdepth.mean_off(save_ind+1:(save_ind+leng),:)=mean_off3(:,:);
flatdepth.std_off(save_ind+1:(save_ind+leng),:)=std_off3(:,:);
flatdepth.mean_on(save_ind+1:(save_ind+leng),:)=mean_on3(:,:);
flatdepth.std_on(save_ind+1:(save_ind+leng),:)=std_on3(:,:);
flatdepth.mean_spont(save_ind+1:(save_ind+leng),:)=mean_spont3(:,:);
flatdepth.std_spont(save_ind+1:(save_ind+leng),:)=std_spont3(:,:);
flatdepth.mean_sus(save_ind+1:(save_ind+leng),:)=mean_sus3(:,:);
flatdepth.std_sus(save_ind+1:(save_ind+leng),:)=std_sus3(:,:);
flatdepth.mean_tot(save_ind+1:(save_ind+leng),:)=mean_tot3(:,:);
flatdepth.std_tot(save_ind+1:(save_ind+leng),:)=std_tot3(:,:);
flatdepth.ray(save_ind+1:(save_ind+leng),:)=ray(:,28:47);
flatdepth.vs(save_ind+1:(save_ind+leng),:)=vs(:,28:47);

for i=1:leng
    for j=271:470
        flatdepth.raster{save_ind+i,j-270}=raster_sort{chantemp(i),j};
    end
end

save_ind=save_ind+leng;

% save Data_vocTrill_data an_name date spl chan unit group... 
%     trilldepth flatcarrier flatdepth save_ind
