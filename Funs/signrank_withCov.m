function signrank_withCov(DependentDirs,OutputName,MaskFile,OtherCovariates)
% [TTest2_T,Header] = y_TTest2_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates,PALMSettings)
% Perform two sample t test with or without covariates.
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. The T is corresponding to the first group minus the second group. 2 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. 2 by 1 cell
%   OtherCovariates - The other covariates. 2 by 1 cell 
%   PALMSettings - Settings for permutation test with PALM. 161116.
% Output:
%   TTest2_T - the T value (corresponding to the first group minus the second group), also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% Core function re-written by YAN Chao-Gan 140225.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


if nargin<=3
    OtherCovariates=[];
    if nargin<=2
        MaskFile=[];
    end
end

GroupNumber=length(DependentDirs);

DependentVolume=[];
GroupLabel=[];
OtherCovariatesMatrix=[];
for i=1:GroupNumber
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    fprintf('\n\tImage Files in Group %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(4,DependentVolume,AllVolume);
      
    if ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    GroupLabel=[GroupLabel;ones(size(AllVolume,4),1)*i];
    clear AllVolume
end

GroupLabel(GroupLabel==2)=-1;

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

%Regressors = [GroupLabel,ones(nDim4,1),OtherCovariatesMatrix];

if ~exist('MaskFile','var')
    MaskFile = '';
end


if ~isnumeric(DependentVolume)
    [DependentVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentVolume);
    fprintf('\n\tImage Files in the Group:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
else
    VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));
end

% [nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

MaskData = any(DependentVolume,4) .* MaskData; % skip the voxels with all zeros

p_OLS_brain=zeros(nDim1,nDim2,nDim3);
z_OLS_brain=zeros(nDim1,nDim2,nDim3);


fprintf('\n\tRegression Calculating...\n');
for i=1:nDim1
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if MaskData(i,j,k)
                DependentVariable=squeeze(DependentVolume(i,j,k,:));                            
                [r, b, ~] = regress_out(DependentVariable, OtherCovariatesMatrix);
                x1=r(1:size(find(GroupLabel==1),1))+b(1);
                x2=r(size(find(GroupLabel==1),1)+1:end)+b(1);
%                 x1=DependentVariable(1:size(find(GroupLabel==1),1));
%                 x2=DependentVariable(size(find(GroupLabel==1),1)+1:end);
%                 STATS = mwwtest(x1',x2');
%                 p_OLS_brain(i,j,k,:)=STATS.p(1,2);
%                 z_OLS_brain(i,j,k,:)=STATS.Z;
                [p,~,stats] = signrank(x1,x2);
                 p_OLS_brain(i,j,k,:)=p;
                z_OLS_brain(i,j,k,:)=stats.zval;
            end
        end
    end
end

%b_OLS_brain(isnan(b_OLS_brain))=0;
z_OLS_brain(isnan(z_OLS_brain))=0;
Header.pinfo = [1;0;0];
Header.dt    = [16,0];

DOF = nDim4 - size(OtherCovariatesMatrix,2);

[dLh,resels,FWHM, nVoxels] = y_Smoothest(z_OLS_brain, MaskFile, DOF, VoxelSize);

HeaderTWithDOF=Header;
HeaderTWithDOF.descrip=sprintf('DPABI{T_[%.1f]}{dLh_%f}{FWHMx_%fFWHMy_%fFWHMz_%fmm}',DOF,dLh,FWHM(1),FWHM(2),FWHM(3));    
y_Write(z_OLS_brain,HeaderTWithDOF,OutputName);  %y_Write(TF_ForContrast_brain,HeaderTWithDOF,[OutputName,'_',TF_Flag,'_ForContrast','.nii']);
y_Write(p_OLS_brain,HeaderTWithDOF,[OutputName,'_p','.nii']); %YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size)



fprintf('\n\tMWU Test Calculation finished.\n');
