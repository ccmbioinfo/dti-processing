#!/bin/bash

atlas=/hpf/projects/brudno/data/language/atlas-aal/ROI_MNI_V5.nii
atlas_text=/hpf/projects/brudno/data/language/atlas-aal/ROI_MNI_V5.txt
mni=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz

mkdir dti
dtifit -k corr.nii.gz -o dti/dti -m corr_brain_mask.nii.gz -r *.bvec -b *.bval
fslmaths dti/dti_L2.nii.gz -add dti/dti_L3.nii.gz -div 2 dti/dti_RD.nii.gz
fslmaths dti/dti_L1.nii.gz dti/dti_AD.nii.gz
flirt -interp nearestneighbour -in dti/dti_FA.nii.gz -ref $mni -applyxfm -out dti/dti_FA_mni -init corr_mni.mat -noresample -noresampblur
flirt -interp nearestneighbour -in dti/dti_MD.nii.gz -ref $mni -applyxfm -out dti/dti_MD_mni -init corr_mni.mat -noresample -noresampblur
flirt -interp nearestneighbour -in dti/dti_RD.nii.gz -ref $mni -applyxfm -out dti/dti_RD_mni -init corr_mni.mat -noresample -noresampblur
flirt -interp nearestneighbour -in dti/dti_AD.nii.gz -ref $mni -applyxfm -out dti/dti_AD_mni -init corr_mni.mat -noresample -noresampblur
mkdir -p roi/{fa,rd,ad,md}
parallel "fslmaths $atlas -thr {} -uthr {} roi/md/{}.mas; fslstats dti/dti_MD_mni.nii.gz -k roi/md/{}.mas -M >> roi/md/md-aal.{}.txt" ::: $(awk '{print $3}' $atlas_text);
parallel "fslmaths $atlas -thr {} -uthr {} roi/ad/{}.mas; fslstats dti/dti_AD_mni.nii.gz -k roi/ad/{}.mas -M >> roi/ad/ad-aal.{}.txt" ::: $(awk '{print $3}' $atlas_text);
parallel "fslmaths $atlas -thr {} -uthr {} roi/fa/{}.mas; fslstats dti/dti_FA_mni.nii.gz -k roi/fa/{}.mas -M >> roi/fa/fa-aal.{}.txt" ::: $(awk '{print $3}' $atlas_text);
parallel "fslmaths $atlas -thr {} -uthr {} roi/rd/{}.mas; fslstats dti/dti_RD_mni.nii.gz -k roi/rd/{}.mas -M >> roi/rd/rd-aal.{}.txt" ::: $(awk '{print $3}' $atlas_text);
for D in roi/*; do cd $D; grep "" *txt | ruby -lane 'a=$_.split("."); print [a[0].split("/")[0],a[1],$_.split(":")[-1]].join("\t")' | tee extract.txt; cd ../..; done;
paste <(awk '{print $1}' $atlas_text) <(awk '{print $2}' roi/md/extract.txt ) <(awk '{print $3="MD: "$3}' roi/md/extract.txt ) <(awk '{print $3="RD: "$3}' roi/rd/extract.txt ) <(awk '{print $3="AD: "$3}' roi/ad/extract.txt) <(awk '{print $3="FA: "$3}' roi/fa/extract.txt) > roi/roi.txt

