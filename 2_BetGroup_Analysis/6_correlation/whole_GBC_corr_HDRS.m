clc;clear;

%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
data_dir=[PATH,'/SampleData/ComBet_GBC_map'];
SubInfo = readtable([PATH,'/subject_info/SubInfo.xlsx']);
Mask=[PATH,'/seed_Mask/AAL90_3mm_mask.nii'];

%% load files
mdd_dirs=dir([data_dir,'/*MDD*.nii']);
mdd=[];
for i=1:length(mdd_dirs)
    mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name] ;
end

%% whole brain GBC cor. HDRS
ind=find(SubInfo.hdrs_type==17);
Ind=ind-1079;
data=mdd(Ind);
DependentDirs={data};
SeedSeries=SubInfo.hdrs(ind);
cov={[SubInfo.age(ind),SubInfo.sex(ind),SubInfo.FD(ind)]};
[rCorr,Header]=y_Correlation_Image(DependentDirs,SeedSeries,'Whole_GBC_HDRS',Mask,[],cov);

