clc;clear;
%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
outpath=[PATH,'/ComBet_GBC_map'];
mask=load_nii([PATH,'/seed_Mask/AAL90_3mm_mask.nii']);
Nvoxel=size(find(mask.img~=0),1);
mask=logical(mask.img);

%% load files and subject information
file1=dir([PATH,'/SampleData/GBC_map/*HC_*Zmean.nii']);
file2=dir([PATH,'/SampleData/GBC_map/*MDD_*Zmean.nii']);
file=[file1;file2];
SubInfo = readtable([PATH,'/subject_info/SubInfo.xlsx']);
AllVolume=zeros(Nvoxel,length(file));
for numsub=1:length(file)
    tem=load_nii([file(numsub).folder,'/',file(numsub).name]); 
    temp=reshape(tem.img,[],1);  
    AllVolume(:,numsub)=temp(mask,:);
end
ind=sum(AllVolume,2)~=0;
data=AllVolume(ind,:);

%% Correct the center effect of the GBC map by using ComBatHarmonization.
group=SubInfo.ID;
disease=SubInfo.group+1;
disease = dummyvar(disease);
mod = disease(:,2);
data= combat(data,group,mod,1);
data_new=zeros(Nvoxel,length(file));
data_new(ind,:)=data;

%% Save the corrected GBC map
for sub=1:size(data_new,2)
    temp=zeros(size(mask));  
    temp(mask) = data_new(:,sub);
    file(sub).name
    subject=load_nii([file(sub).folder,'/',file(sub).name]); 
    subject.img=temp;
    save_nii(subject,[outpath,'/',file(sub).name(1:end-4),'_ComBet.nii']);
end
