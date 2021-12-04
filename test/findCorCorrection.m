close all
clear all
clc

filePrefix   = '20211129_bell_pepper_low_dose_';
nProj               = 360;
I0x1                = 1;
I0x2                = 200;
I0y1                = 1;
I0y2                = 200;
binning             = 1;
sinogram            = createSinogram(filePrefix, nProj, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      binning);
corCorrection(sinogram);