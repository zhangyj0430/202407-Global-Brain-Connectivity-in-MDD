clc;clear;

%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
path=[PATH,'/SampleData/seedFC_map'];
outpath=[PATH,'/SampleData/ComBet_seedFC_data'];
mask=load_nii([PATH,'/seed_Mask/AAL90_3mm_mask.nii']);
Nvoxel=size(find(mask.img~=0),1);
mask=logical(mask.img);

%% Correct the center effect of the seedFC map by using ComBatHarmonization.
SubInfo = readtable([PATH,'/subject_info/SubInfo.xlsx']);
ROI={'ROI1_','ROI2_','ROI3_','ROI4_','ROI5_','ROI6_','ROI7_','ROI8_'};
for g=1:8
    file1=dir([path,'/z*',ROI{g},'*HC_*.nii']);
    file2=dir([path,'/z*',ROI{g},'*MDD_*.nii']);
    file=[file1;file2];
    
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
end
