clc;clear;
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/1_ComBet_GBCmap/ComBet_data_D2_GSR';
Center={'HC_Med','HC_noMed','HC_FE','HC_recurrent','HC_onsetB21','HC_onsetS21'};
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');

%% subgroup index
ind_FE=find(~isnan(SubInfo.FE));
ind_recurrent=find(~isnan(SubInfo.No_FE));
ind_Med=find(~isnan(SubInfo.Med));
ind_No_Med=find(~isnan(SubInfo.No_Med));
ind_onsetB21=find(~isnan(SubInfo.onsetB21));
ind_onsetS21=find(~isnan(SubInfo.onsetS21));
ind={ind_Med,ind_No_Med,ind_FE,ind_recurrent,ind_onsetB21,ind_onsetS21}; 
%% testt restricted in the mask
MaskFile='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/3_GoupLevel_analysis/wGBCr_mww_withCov_mdd_hc_GRF_Vp0001_twotail_mask.nii';
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

for c=1:6
    cov=Cov(ind{c},:);
    Covariates={cov(num_hc+1:end,:);cov(1:num_hc,:)};   
    Data=data(ind{1,c});
    DependentDirs={Data(num_hc+1:end,:);Data(1:num_hc,:)};
    mwU_withCov(DependentDirs,['wGBCr_mww_',Center{c}],MaskFile,Covariates);  
    [Data_Corrected, Header]=y_FDR_Image(['wGBCr_mww_',Center{c}],0.05,['wGBCr_mww_',Center{c},'_FDR'],MaskFile);
end








