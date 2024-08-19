clc;clear;
%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));
data_dir=[PATH,'/SampleData/ComBet_GBC_map'];
Mask=[PATH,'/seed_Mask/AAL90_3mm_mask.nii'];
mask=logical(y_ReadAll(Mask));
str={'HC','MDD'};
DD=[];
hc_dirs=dir([data_dir,'/*HC*.nii']);
mdd_dirs=dir([data_dir,'/*MDD*.nii']);
file={hc_dirs,mdd_dirs};
group_D=[];

%% load files and subject information, and calculate the global mean GBC values
SubInfo = readtable([PATH,'/subject_info/SubInfo.xlsx']);
for i=1:length(file{1,1})
    D1{i,1}=[file{1,1}(i).folder,'/',file{1,1}(i).name] ;
end
[ A1,~,~,header]=y_ReadAll(D1);
for i=1:length(file{1,2})
    D2{i,1}=[file{1,2}(i).folder,'/',file{1,2}(i).name] ;
end
[ A2,~,~,header]=y_ReadAll(D2);
A={A1,A2};
for m=1:2
    data=reshape(A{1,m},[],size(A{1,m},4));
    data=data(mask,:);
    group_D{1,m}=mean(data,1);
    group_D{2,m}=str{1,m};
end
save('meanGBC.mat','group_D');

%% Compare the global mean GBC between groups using the appropriate statistical tests
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
cov_hc=[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)];
cov_mdd=[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];
DependentVariable=[group_D{1,1},group_D{1,2}]';
OtherCovariatesMatrix=[cov_hc;cov_mdd];
 [r, b, ~] = regress_out(DependentVariable, OtherCovariatesMatrix);
 x1=r(1:size(ind_hc,1))+b(1);
 x2=r(size(ind_hc,1)+1:end)+b(1);
[p,~,stats] = ranksum(x1,x2);


