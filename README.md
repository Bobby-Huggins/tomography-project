# Code for Inverse Problems Project Course

## Dependencies
1. [ASTRA Toolbox](https://github.com/astra-toolbox/astra-toolbox) for Filtered Backprojection and for building the forward operator.
2. [TVReg](https://github.com/jakobsj/TVReg) for Total Variation regularization.

## Basic Usage
See example\_01.m for basic usage so far. You may have to open the tomographyProject.prj folder to get MATLAB to add all the appropriate folders to the path.

Note that all of the full-size images are not tracked in this repo, to keep the size manageable. But the data we collected should go in the corresponding folders in /data/input. The binned images have been added to the repo, since they were less than a GB all together.

## Notes
See also /reconstruction/computeReconstructions.m  for a script that will compute reconstructions for both noise cases, over a range of alphas. It stores the SSIM and L-Curve statistics for each reconstruction in the results for review (but does not save the results to a file automatically). This script can take a while to run depending on the resolution of the reconstructions.
