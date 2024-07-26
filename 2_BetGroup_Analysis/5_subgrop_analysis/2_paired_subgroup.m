clc;clear;
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/1_ComBet_GBCmap/ComBet_data_D2_GSR';
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');

%% subgroup index
ind_Med=find(SubInfo.Med==1);
ind_No_Med=find(SubInfo.No_Med==1);
ind_FE=find(SubInfo.FE==1);
ind_RE=find(SubInfo.No_FE==1);
ind_onsetB21=find(SubInfo.onsetB21==1);
ind_onsetS21=find(SubInfo.onsetS21==1);
ind={ind_Med,ind_No_Med,ind_FE,ind_RE,ind_onsetB21,ind_onsetS21}; 
%% testt restricted in the mask
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask/seed_Mask';
MaskFile=[mask_dir,'/AAL90_3mm_mask.nii'];
Cov=[SubInfo.age,SubInfo.sex,SubInfo.FD];
num_hc=size(find(SubInfo.group==0),1);
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
data=[hc;mdd];
%% Med vs. No_Med
Covariates={Cov(ind_Med,:);Cov(ind_No_Med,:)};   
DependentDirs={data(ind_Med,:);data(ind_No_Med,:)};
mwU_withCov(DependentDirs,'wGBCr_mww_Med_NoMed',MaskFile,Covariates); 
[Data_Corrected, Header]=GRF('wGBCr_mww_Med_NoMed',0.001,1,0.05,'wGBCr_mww_Med_NoMed_GRF',MaskFile);

%% FE vs. RE
Covariates={Cov(ind_FE,:);Cov(ind_RE,:)};   
DependentDirs={data(ind_FE,:);data(ind_RE,:)};
mwU_withCov(DependentDirs,'wGBCr_mww_FE_RE',MaskFile,Covariates); 
[Data_Corrected, Header]=GRF('wGBCr_mww_FE_RE',0.001,1,0.05,'wGBCr_mww_FE_RE_GRF',MaskFile);

%% Onset>21 vs. Onset<21
Covariates={Cov(ind_onsetS21,:);Cov(ind_onsetB21,:)};   
DependentDirs={data(ind_onsetS21,:);data(ind_onsetB21,:)};
mwU_withCov(DependentDirs,'wGBCr_mww_OA',MaskFile,Covariates); 
[Data_Corrected, Header]=GRF('wGBCr_mww_OA',0.001,1,0.05,'wGBCr_mww_OA_GRF',MaskFile);





