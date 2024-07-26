clc;clear;
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask';
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/3_seed_FC/2_ComBet_FCmap/Combet_seedFC_map';
Mask=[mask_dir,'/AAL90_3mm_mask.nii'];
ROI={'ROI1','ROI2','ROI3','ROI4','ROI5','ROI6','ROI7','ROI8'};
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');

%% regional between-group analysis_negative
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
Covariates={[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)]};
voxel_p =0.001;
cluster_p=0.05;
str='Vp0001';
for g=1:8
    hc_dirs=dir([data_dir,'/z*',ROI{g},'*HC_*.nii']);
    hc=[];
    for i=1:length(hc_dirs)
        hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
    end
    mdd_dirs=dir([data_dir,'/z*',ROI{g},'*MDD_*.nii']);
    mdd=[];
    for i=1:length(mdd_dirs)
        mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name] ;
    end
    DependentDirs={mdd;hc};
    mwU_withCov(DependentDirs,['Sphere_wGBCr_mww_mdd_hc_',ROI{g}],Mask,Covariates);    
    [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF(['Sphere_wGBCr_mww_mdd_hc_',ROI{g}],voxel_p,1,cluster_p,['Sphere_wGBCr_mww_mdd_hc_GRF_',ROI{g},'_',str],Mask);
end

%% adult:regional between-group analysis
ind_hc=find(SubInfo.group==0&SubInfo.age>=18);
ind_mdd=find(SubInfo.group==1&SubInfo.age>=18);
Covariates={[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)]};

for g=1:8
    hc_dirs=dir([data_dir,'/z*',ROI{g},'*HC_*.nii']);
    hc_dirs=hc_dirs(ind_hc,:);
    hc=[];
    for i=1:length(hc_dirs)
        hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
    end
    mdd_dirs=dir([data_dir,'/z*',ROI{g},'*MDD_*.nii']);
    mdd_dirs=mdd_dirs(ind_mdd-1079,:);
    mdd=[];
    for i=1:length(mdd_dirs)
        mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name];
    end
    DependentDirs={mdd;hc};
    mwU_withCov(DependentDirs,['Sphere_adult_wGBCr_mww_mdd_hc_',ROI{g}],Mask,Covariates);   
    [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF(['Sphere_adult_wGBCr_mww_mdd_hc_',ROI{g}],voxel_p,1,cluster_p,['Sphere_adult_wGBCr_mww_mdd_hc_GRF_',ROI{g},'_',str],Mask);
end