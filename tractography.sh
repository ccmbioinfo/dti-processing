#/bin/bash

track -inputmodel dt -seedfile fa_mask.nii.gz -anisthresh .2 -curvethresh 60 -inputfile dt.Bdouble > allTracts.Bfloat
vtkstreamlines -colourorient < allTracts.Bfloat > allTracts.vtk
camino_to_trackvis -i allTracts.Bfloat -o allTracts.trk --nifti corr.nii.gz
