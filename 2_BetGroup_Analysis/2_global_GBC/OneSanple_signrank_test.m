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

%% Calculate the significant spatial GBC patterns in MDD and HV
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
cov_hc=[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)];
cov_mdd=[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];
signrank_withCov({hc},'signrankT_HC',Mask,{cov_hc});    
[GRF_Data_Corrected_hc,ClusterSize_hc,GRF_Header_hc]=GRF('signrankT_HC.nii',0.001,1,0.05,'signrankT_HC_GRF',Mask);
signrank_withCov({mdd},'signrankT_MDD',Mask,{cov_mdd});  
[GRF_Data_Corrected_mdd,ClusterSize_mdd,GRF_Header_mdd]=GRF('signrankT_MDD.nii',0.001,1,0.05,'signrankT_MDD_GRF',Mask);
