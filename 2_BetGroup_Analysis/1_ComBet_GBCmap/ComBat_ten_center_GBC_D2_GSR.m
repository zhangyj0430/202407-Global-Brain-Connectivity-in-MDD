clc;
clear;
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
mask=load_nii([PATH,'/seed_Mask/AAL90_3mm_mask.nii']);
Nvoxel=size(find(mask.img~=0),1);
mask=logical(mask.img);
path='/home1/zhangyj/Desktop/MDD/MDD_GBC/1_GBC_calculate/D2_GBCMap';
outpath='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/1_ComBet_GBCmap/ComBet_data_D2_GSR';
file1=dir([path,'/*HC_*Zmean.nii']);
file2=dir([path,'/*MDD_*Zmean.nii']);
file=[file1;file2];
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');

AllVolume=zeros(Nvoxel,length(file));
for numsub=1:length(file)
    tem=load_nii([file(numsub).folder,'/',file(numsub).name]); 
    temp=reshape(tem.img,[],1);  
    AllVolume(:,numsub)=temp(mask,:);
end
ind=sum(AllVolume,2)~=0;
data=AllVolume(ind,:);

group=SubInfo.ID;
disease=SubInfo.group+1;
disease = dummyvar(disease);
mod = disease(:,2);
data= combat(data,group,mod,1);
data_new=zeros(Nvoxel,length(file));
data_new(ind,:)=data;

for sub=1:size(data_new,2)
    temp=zeros(size(mask));  
    temp(mask) = data_new(:,sub);
    file(sub).name
    subject=load_nii([file(sub).folder,'/',file(sub).name]); 
    subject.img=temp;
    save_nii(subject,[outpath,'/',file(sub).name(1:end-4),'_ComBet.nii']);
end
