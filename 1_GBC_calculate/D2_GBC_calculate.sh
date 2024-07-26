cd /home1/zhangyj/Desktop/MDD/Data
filename=$(ls D2_GSR_S)
outpath=/home1/zhangyj/Desktop/MDD/MDD_GBC/1_GBC_calculate/D2_GBCMap
input=/home1/zhangyj/Desktop/MDD/MDD_GBC/SampleData/D2_GSR_S
maskpath=/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask

for name in $filename
do 
 
3dTcorrMap -input ${input}/${name}/*.nii -mask ${maskpath}/AAL90_3mm_mask.nii -Zmean ${outpath}/${name}_Zmean.nii -Thresh 0.3 ${outpath}/${name}_uGBC_r03.nii

done


