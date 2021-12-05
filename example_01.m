close all
clear all
clc

%% Basic Example Usage of Functionality So Far

% Create binned images with a given binning factor:
factor = 8;
%%
% (Subdirectories for each binning factor may need to be created manually.)
% binImages(binning);
%% Create a TV reconstruction from the binned images, for the sparse case:
% Create sparse reconstruction with 18 angles and a binning factor of 8.
% Regularization paramater alpha=0.05, and max iterations=400.
tvSparse = totalVariation(18, 'subsampling', factor, 'high dose', 0.1, 1000);
tvSparse
% The return type of totalVariation is a  Reconstruction class which
% contains the image and associated data. See /utility/Reconstruction.m for
% more details.
%% And for the dense case:
% Create sparse reconstruction with 180 angles and a binning factor of 8.
% Regularization paramater alpha=0.05, and max iterations=400.
tvNoisy = totalVariation(180, 'subsampling', factor, 'low dose', 5.0, 1000);
tvNoisy
%% Results
fig = figure();
tlo = tiledlayout(fig, 'flow');

nexttile
tvSparse.show('Contrast', 1);
title('Sparse Angles, Low Noise');

nexttile
tvNoisy.show();
title('Dense Angles, High Noise');

%% And Compute the Full-Dataset FBPs for Comparison:
fbpLowNoise = filteredBP(360, 'binning', factor, 'high dose');
%%
fbpHighNoise = filteredBP(360, 'binning', factor, 'low dose');
%%
nexttile
fbpLowNoise.show();
title('Maximum Angles, Low Noise');

nexttile
fbpHighNoise.show();
title('Maximum Angles, High Noise');

%% Save Images
imwrite(im2uint16(tvNoisy.Image), 'tvNoisy.tif');
imwrite(im2uint16(fbpLowNoise.Image), 'fbpLowNoise.tif');
imwrite(im2uint16(tvSparse.Image), 'tvSparse.tif');