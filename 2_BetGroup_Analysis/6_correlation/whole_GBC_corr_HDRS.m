clc;clear;
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/1_GBC_calculate/ComBet_data_D2_GSR';
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask';
Mask=[mask_dir,'/AAL90_3mm_mask.nii'];
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

