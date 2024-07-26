clc;clear;
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask';
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/1_ComBet_GBCmap/ComBet_data_D2_GSR';
Mask=[mask_dir,'/AAL90_3mm_mask.nii'];
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

SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
cov_hc=[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)];
cov_mdd=[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];
signrank_withCov({hc},'signrankT_HC',Mask,{cov_hc});    
[GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF('signrankT_HC.nii',0.001,1,0.05,'signrankT_HC_GRF',Mask);

signrank_withCov({mdd},'signrankT_MDD',Mask,{cov_mdd});  
[GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF('signrankT_MDD.nii',0.001,1,0.05,'signrankT_MDD_GRF',Mask);
