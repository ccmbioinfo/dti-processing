# DTI Processing

Topics covered in DTI processing:
1. Preparation for DTI processing, including
  1. Eddy current correction
  2. Brain extraction
2. Connectivity matrices

## Getting Started

### Prerequisites

For ease of use (to not have to load required modules on every login), I would recommend adding the following to your ~/.bashrc file:

```
module load fsl
module load ruby
module load dcmtk
module load mricron
module load camino/2014.02.06
module load java/1.8.0_91
module load camino-trackvis/0.2.8.1
export CAMINO_HEAP_SIZE=15000
export FSLDIR=/hpf/tools/centos6/fsl/5.0.6/
. ${FSLDIR}/etc/fslconf/fsl.sh
```

When logging into the server, specify the following tags to be able to use FSLView

```
ssh <user>@<server> -taY -X
```

For a lot of the steps, you need an atlas for the brain, with identified regions of interests (ROIs). For example, I used the [AAL atlas](http://www.gin.cnrs.fr/en/tools/aal-aal2/).

### Organizing the Data

Usually, folders of patient DICOM images will be made available to you. To be able to analyze the data, these files need to be converted into NIfTI format. 

To convert a folder of DICOM images, run the following command (note that no slash can be at the end of the input folder, or the program will complain):

```
dcm2nii -i N -d N -f N -o <output> <input>
```

This should return a NIfTI file, .bvec, and .bval file.

Now, this can be run on the entire folder for the patient and then later organized, or organized first and then separated out. Essentially, only the images in folders tagged with "DTI" need to be used. They'll usually be separated by b-values of the associated images (the common b-values I've dealt with include b1000, b1600, and b2600) and I like putting these into separate folders.

You can either run dcm2nii on the entire Patient1 folder, and then separate the files associated to each of the b-values. Alternatively, you can pin-point what subfolders are required specifically, and then run dcm2nii on each of them. Whatever you'd like. The end result for any given patient (let's call this specifc one Patient1), the folder structure will be as such:

* Patient1
  * 1000
    * 1000.nii.gz
    * 1000.bvec
    * 1000.bval
  * 1600
    * 1600.nii.gz
    * 1600.bvec
    * 1600.bval
  * 2600
    * 2600.nii.gz
    * 2600.bvec
    * 2600.bval
    

## Using the Scripts

And what they do - very important, you know.

### Preprocessing

Navigate to the uppermost level of your patient (AKA in our example, the Patient1 folder), and simply run the script:

```
sh preprocessing.sh
```

This will, for each b-value folder, correct the DTI image for eddy current distortion, flaws in the image due to the varying magnetic field inducing an electric current. It will also isolate the brain from the rest of the skull. Furthermore, this will fit the diffusion tensor to the image. FA images and MD images will also be generated.

### Registration

Similar to the preprocessing step, run the script in the uppermost level of your patient (the Patient1 folder):

```
sh registration.sh
```

For each b-value folder, this will use FLIRT to map the DTI image into a standardized space (called MNI space), and a transformation matrix will be created for this mapping. This matrix will be inversed, so that we can map the atlas (that has all of the ROIs labelled, and is in MNI space) into the space of the DTI images.

### Tractography

For the tractography portion, I did the work within the b-value folder (for example, in the Patient1/1000 folder)

Before performing tractography, a FA mask should be generated. There might be a better way to do it, but I viewed the FA image using FSLView:

```
fslview fa.nii.gz
```

Then, at the top, there's a Min/Max section. I noted of the value in the Max field, taking just under that value (for example, if my Max value was 0.4985, I might have used the value 0.4984 for the next step). To double-check this, if you enter that new value into the Min field, then only the most intense areas should appear on the screen.

```
fslmaths fa.nii.gz -thr <newValue> -bin fa_mask
```

The script can then be run within a specific b-value folder:

```
sh tractography.sh
```

Then Camino is utilized to create tractography files that can be viewed using Paraview (allTracts.vtk). TrackVis is another tool that can be used to visualize the tractography files, but I had less luck with the files actually appearing (maybe it was being overloaded with data, not sure) - the track of interest for this program would be allTracts.trk:

### ROI

DTI images are created (using FSL's dtifit tool) and calculated (RD, AD images). A helpful site that explained the difference between FA, RD, MD, and AD was [Diffusion Imaging](http://www.diffusion-imaging.com/2013/01/relation-between-neural-microstructure.html). 

Intensity values are calculated for each of the ROIs in the atlas, and the concatenated into a single file. The last line involves process substitution, so use bash instead of sh to run the script:

```
bash roi.sh
```

## Resources

* [Connectivity Matrices Tutorial](http://camino.cs.ucl.ac.uk/index.php?n=Tutorials.ConnectivityMatrices) - The basis for the connectivity matrices part of this project
* [Tractography Tutorial](http://camino.cs.ucl.ac.uk/index.php?n=Tutorials.BasicStreamlineTracking) 
* [DTI Processing Tutorial](http://www.cabiatl.com/Resources/Course/tutorial/html/dti.html) 

## Acknowledgments

* Thanks to Justin Foong for all of his help! Also, to Steven Ufkes for helping to transfer the data to somewhere I could actually access.
* Also thank you to those in the Stroke Lab for having the patience to allow me to work on this project!