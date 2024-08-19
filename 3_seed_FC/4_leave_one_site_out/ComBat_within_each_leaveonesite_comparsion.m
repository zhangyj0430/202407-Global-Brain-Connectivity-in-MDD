clc;clear;

%% define work dir
PATH='/home1/zhangyj/Desktop/MDD/MDD_GBC';
addpath(genpath([PATH,'/Funs']));

% mask
mask=load_nii([PATH,'/seed_Mask/AAL90_3mm_mask.nii']);
Mask_dir=[PATH,'/seed_Mask/AAL90_3mm_mask.nii'];
Nvoxel=size(find(mask.img~=0),1);
mask=logical(mask.img);

% data path
data_dir=[PATH,'/SampleData/seedFC_map'];
outpath=[PATH,'/3_seed_FC/4_leave_one_site_out'];
ROI={'ROI1_','ROI2_','ROI3_','ROI4_','ROI5_','ROI6_','ROI7_','ROI8_'};
Center={'CMU','CSU','GCMU1','GCMU2','KMU','PKU','SCU','SWU','YMU','ZZU'};
voxel_p =0.001;
cluster_p=0.05;

% confound regression 
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');
Cov=[SubInfo.age,SubInfo.sex,SubInfo.FD];
group=SubInfo.ID;
disease=SubInfo.group+1;
disease = dummyvar(disease);
mod = disease(:,2);

%% leval one out: regional between-group analysis
for k=1:8
    file1=dir([data_dir,'/z*',ROI{k},'*HC_*.nii']);
    file2=dir([data_dir,'/z*',ROI{k},'*MDD_*.nii']);
    all_file=[file1;file2];
    
    AllVolume=zeros(Nvoxel,length(all_file));
    for numsub=1:length(all_file)
        tem=load_nii([all_file(numsub).folder,'/',all_file(numsub).name]);
        temp=reshape(tem.img,[],1);
        AllVolume(:,numsub)=temp(mask,:);
    end
    ind=sum(AllVolume,2)~=0;
    data=AllVolume(ind,:);
     
    for c=1:10
        site_ind=find(SubInfo.ID~=c);
        g=group(site_ind,:);
        m=mod(site_ind,:);
        D=data(:,site_ind);
        DD= combat(D,g',m,1);
        data_new=zeros(Nvoxel,length(site_ind));
        data_new(ind,:)=DD;
        
        file=all_file(site_ind);
        mkdir([outpath,'/without_',Center{c}]);
        
        for sub=1:size(data_new,2)
            temp=zeros(size(mask));
            temp(mask) = data_new(:,sub);
            file(sub).name
            subject=load_nii([file(sub).folder,'/',file(sub).name]);
            subject.img=temp;
            save_nii(subject,[outpath,'/without_',Center{c},'/',file(sub).name(1:end-4),'_ComBet.nii']);
        end
        
        hc_dirs=dir([outpath,'/without_',Center{c},'/z*',ROI{k},'*HC_*.nii']);
        hc=[];
        for i=1:length(hc_dirs)
            hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
        end
        mdd_dirs=dir([outpath,'/without_',Center{c},'/z*',ROI{k},'*MDD_*.nii']);
        mdd=[];
        for i=1:length(mdd_dirs)
            mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name] ;
        end      
        mm=SubInfo.group(site_ind);
        num_hc=size(find(mm==0),1);
        cov=Cov(site_ind,:);
        Covariates={cov(num_hc+1:end,:);cov(1:num_hc,:)};
        Data=[hc;mdd];
        DepDirs={Data(num_hc+1:end,:);Data(1:num_hc,:)};
        mwU_withCov(DepDirs,[outpath,'/Result_LeaveOS/wGBCr_mww_hc_mdd_',ROI{k},Center{c}],Mask_dir,Covariates);
        [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([outpath,'/Result_LeaveOS/wGBCr_mww_hc_mdd_',ROI{k},Center{c}],voxel_p,1,cluster_p,[outpath,'/Result_LeaveOS/wGBCr_mww_hc_mdd_GRF_',ROI{k},Center{c},'_Vp0001_twotail'],Mask_dir);
    end
end
