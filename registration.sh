#!/bin/sh

atlas=/hpf/projects/brudno/data/language/atlas-aal/ROI_MNI_V5.nii
mni=$FSLDIR/data/standard/MNI152_T1_2mm_brain

for D in */
do
  cd $D
    flirt -in corr_brain.nii.gz -ref $mni -out corr_mni -omat corr_mni.mat
    convert_xfm -omat mni_to_corr.mat -inverse corr_mni.mat
    flirt -in $atlas -applyxfm -init mni_to_corr.mat -ref corr_brain.nii.gz -out aal_to_corr.nii.gz -interp nearestneighbour
  cd ..
done
