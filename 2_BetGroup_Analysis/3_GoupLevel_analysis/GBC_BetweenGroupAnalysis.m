clc;clear;
%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
data_dir=[PATH,'/SampleData/ComBet_GBC_map'];
Mask=[PATH,'/seed_Mask/AAL90_3mm_mask.nii'];

%% load files and subject information
SubInfo = readtable([PATH,'/subject_info/SubInfo.xlsx']);
hc_dirs=dir([data_dir,'/*HC*.nii']);
hc=[];
for i=1:length(hc_dirs)
    hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name];
end
mdd_dirs=dir([data_dir,'/*MDD*.nii']);
mdd=[];
for i=1:length(mdd_dirs)
    mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name] ;
end

%% regional between-group analysis
voxel_p =0.001;
cluster_p=0.05;
str={'Vp0001_twotail'};
tail=1;
DependentDirs={mdd;hc};
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
Covariates={[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)]};
mwU_withCov(DependentDirs,'wGBCr_mww_withCov_mdd_hc',Mask,Covariates);    
[GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF('wGBCr_mww_withCov_mdd_hc.nii',voxel_p,1,cluster_p,'wGBCr_mww_withCov_mdd_hc_GRF_Vp0001_twotail',Mask,'Z');    

%% only adult: regional between-group analysis
hc_adult=find(SubInfo.group==0&SubInfo.age>=18);
mdd_adult=find(SubInfo.group==1&SubInfo.age>=18);
DependentDirs_adult={mdd(mdd_adult-1079,:);hc(hc_adult,:)};
Covariates_adult={[SubInfo.age(mdd_adult),SubInfo.sex(mdd_adult),SubInfo.FD(mdd_adult)];[SubInfo.age(hc_adult),SubInfo.sex(hc_adult),SubInfo.FD(hc_adult)]};
mwU_withCov(DependentDirs_adult,'adult_wGBCr_mww_withCov_mdd_hc',Mask,Covariates_adult);  
[GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF('adult_wGBCr_mww_withCov_mdd_hc.nii',voxel_p,1,cluster_p,'adult_wGBCr_mww_withCov_mdd_hc_GRF_Vp0001_twotail',Mask,'Z');    
