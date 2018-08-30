#!/bin/sh
for D in */
do
  cd $D
  eddy_correct *.nii.gz corr 0
  bet corr.nii.gz corr_brain -m
  fsl2scheme -bvalfile *.bval -bvecfile *.bvec > A.scheme
  image2voxel -4dimage corr.nii.gz -outputfile dwi.Bfloat
  dtfit dwi.Bfloat A.scheme -bgmask corr_brain_mask.nii.gz -outputfile dt.Bdouble
  for PROG in fa md; do
    cat dt.Bdouble | ${PROG} | voxel2image -outputroot ${PROG} -header corr.nii.gz
  done
  cd ..
done
