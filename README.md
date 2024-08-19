# MDD_GlobalBarainConnectivity
This repository provides core code and relevant toolboxes for data analysis in the article entitled "Dysfunction in Sensorimotor and Default Mode Networks in Major Depressive Disorder with Insights from Global Brain Connectivity " Zhang et al. Nature Mental Heanth 2024.

## Overview
Content includes standalone software and source code. Due to the large size of the analyzed data, we have provided the code and the significant GBC measurement in a public data repository. The project is structured into four parts corresponding to the major analyses in the article, including GBC analysis, Association analysis, Seed-based analysis and Validation.


## Toolboxes
The code and toolboxes were included below. 

SPM12, https://www.fil.ion.ucl.ac.uk/spm/software/spm12/

SeeCAT, www.nitrc.org/projects/seecat/

AFNI, https://afni.nimh.nih.gov/

ComBatHarmonization, ver. 20180620, https://github.com/Jfortin1/ComBatHarmonization

DPABI_V4.2, http://rfmri.org/DPABI

IBM SPSS Statistics 26, commercial software, https://www.ibm.com/products/spss-statistics

NeuroSynth, web-based decoding functions were used, https://neurosynth.org/

Brainnet Viewer, http://www.nitrc.org/projects/bnv/

We thank the authors and developers for providing these wonderful tools for data analysis. 

## Installation guide
Please use the “add path” method in MATLAB to add toolboxes and scripts. 

## GBC analysis
1. Generate voxel-wise GBC maps for each participant by AFNI’s 3dTcorrMap program. The input for this step is the preprocessed fMRI data.
2. Correct the center effect of the GBC map by using ComBatHarmonization.
3. Calculate the global mean GBC values, and using Kolmogorov-Smirnov test and quantile-quantile plot to examine the data normality distribution. Accordingly, compare the global mean GBC between groups using the appropriate statistical tests. 
4. Calculate the significant spatial GBC patterns in MDD and HV
5. Calculate the alterations in the GBC in MDD. 

## Association Analysis
1. We used voxel-wise correlation analysis to examine the relationship between the GBC maps and the HDRS-17 scores.
2. We used Neurosynth (https://neurosynth.org/) to assess the topic terms associated with the alterations in the GBC in MDD. 
	(i) The thresholded Z-maps derived from the between-group comparisons were first divided into MDD-positive and MDD-negative maps 
	(ii) The Z-maps were then analyzed using the “decoder” function of the Neurosynth python code. 
	(iii) For each of the maps, the noncognitive terms (e.g., anatomical and demographic terms) were removed and the top 30 cognitive terms were selected. 
	(iv) The cognitive terms were visualized on a word-cloud plot with the font size scaled according to their correlation with corresponding meta-analytic maps generated by Neurosynth.

## Seed-based analysis
1. Seed regions were defined using a 5-mm sphere around peak voxel coordinates of the significant clusters from the GBC analysis
2. Calculate the seed-basd FC map for each participant.
3. Correct the center effect of the gradient score by using ComBatHarmonization.
4. Calculate the alterations in the seed FC in MDD.

## Validation
Validation analysis were conducted by accounting for potential influencing factors. 
1. The inclusion of participants younger than 18 years could account for differences in brain development between groups. To address this, we repeated the statistical analysis, focusing solely on adult participants (MDD=1,000, HV=1,029). 
2. We employed a leave-single-site-out validation strategy to assess whether the main findings were influenced by specific sites. This involved repeating the between-group comparisons, each time excluding data from one site. Within each validation, we utilized the ComBat harmonization model to correct for site effects in the remaining nine sites after excluding one site. The Dice coefficient (DSC) index was used to examine the similarity between each validation result and the main finding
