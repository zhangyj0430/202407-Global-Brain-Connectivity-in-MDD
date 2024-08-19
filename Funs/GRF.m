function [Data_Corrected, ClusterSize, Header]=GRF(StatsImgFile,VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName,MaskFile,Flag,Df1,Df2,VoxelSize,Header)

if ~exist('VoxelSize','var')
    VoxelSize = ''; % The voxel size will be defined later
end

[OutPath, OutName,OutExt]=fileparts(OutputName);
if isempty(OutPath)
    OutPath='.';
end

%Read Header in.
if (~exist('Header','var')) || (exist('Header','var') && isempty(Header))
    [BrainVolume, VoxelSize, Header]=y_ReadRPI(StatsImgFile);
end

%Read Mask
[nDim1 nDim2 nDim3 nDimTimePoints]=size(BrainVolume);
if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end
nVoxels=length(find(MaskData));

% Detect the Flag and DF from the data if Flag is not defined.
if (~exist('Flag','var')) || (exist('Flag','var') && isempty(Flag))
   Header_DF = w_ReadDF(Header);
   Flag = Header_DF.TestFlag;
   Df1 = Header_DF.Df;
   Df2 = Header_DF.Df2;
end

if ~strcmpi(Flag,'Z')
    fprintf('Converting the %s maps into Z maps.\n',Flag);
    if ~exist('Df2','var')
        Df2=0;
    end
    [Z P] = y_TFRtoZ(StatsImgFile,[OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt],Flag,Df1,Df2);
end

fprintf('Estimate the smoothness from the Z statistical image.\n');
if strcmpi(Flag,'Z')
    DOF=''; %Degree of freedom for residual files
    [dLh,resels,FWHM, nVoxels]=y_Smoothest(StatsImgFile,MaskFile,DOF,VoxelSize);
else
    [dLh,resels,FWHM, nVoxels]=y_Smoothest([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt], MaskFile);
end

if IsTwoTailed
    zThrd=norminv(1 - VoxelPThreshold/2);
else
    zThrd=norminv(1 - VoxelPThreshold);
end
fprintf('The voxel Z threshold for voxel p threshold %f is: %f.\n',VoxelPThreshold,zThrd);

% Note: If two-tailed way is used, then correct positive values to Cluster P at ClusterPThreshold/2, and correct negative values to Cluster P at ClusterPThreshold/2. Together the Cluster P < ClusterPThreshold.
fprintf('The Minimum cluster size for voxel p threshold %f and cluster p threshold %f is: ',VoxelPThreshold,ClusterPThreshold);
if IsTwoTailed
    ClusterPThreshold = ClusterPThreshold/2;
end

% Calculate Expectations of m clusters Em and exponent Beta for inference.
D=3;
Em = nVoxels * (2*pi)^(-(D+1)/2) * dLh * (zThrd*zThrd-1)^((D-1)/2) * exp(-zThrd*zThrd/2);
EN = nVoxels * (1-normcdf(zThrd)); %In Friston et al., 1994, EN = S*Phi(-u). (Expectation of N voxels)  % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
Beta = ((gamma(D/2+1)*Em)/(EN)) ^ (2/D); % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.

% Get the minimum cluster size
pTemp=1;
ClusterSize=0;
while pTemp >= ClusterPThreshold
    ClusterSize=ClusterSize+1;
    pTemp = 1 - exp(-Em * exp(-Beta * ClusterSize^(2/D))); %K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
end

fprintf('%f voxels\n',ClusterSize);

ConnectivityCriterion = 26; % Corner connection is used in FSL.

if strcmpi(Flag,'Z')
    [BrainVolume, VoxelSize, Header]=y_ReadRPI(StatsImgFile);
else
    [BrainVolume, VoxelSize, Header]=y_ReadRPI([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt]);
end

%Apply the Mask to the Brain Volume
BrainVolume = BrainVolume.*MaskData;


if ClusterSize > 0
    BrainVolume(BrainVolume < zThrd & BrainVolume > -zThrd) = 0;
%     BrainVolume = BrainVolume .* (BrainVolume >= zThrd);
    [theObjMask, theObjNum]=bwlabeln(BrainVolume,ConnectivityCriterion);
    for x=1:theObjNum
        theCurrentCluster = theObjMask==x;
        if length(find(theCurrentCluster)) < ClusterSize
            BrainVolume(logical(theCurrentCluster))=0;
        end
    end
end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];
if ~isempty(OutputName)
    y_Write(BrainVolume,Header,[OutPath,filesep,OutName,OutExt]);
end

Data_Corrected=BrainVolume;

