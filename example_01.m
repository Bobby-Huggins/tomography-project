close all
clear all
clc

%% Basic Example Usage of Functionality So Far

% Create binned images with a given binning factor:
% (Subdirectories for each binning factor may need to be created manually.)
binImages(8);
%% Create a TV reconstruction from the binned images, for the sparse case:
% Create sparse reconstruction with 18 angles and a binning factor of 8.
% Regularization paramater alpha=0.05, and max iterations=400.
tvSparse = totalVariation(18, 8, 'high dose', 0.05, 400);
% The return type of totalVariation is a  Reconstruction class which
% contains the image and associated data. See /utility/Reconstruction.m for
% more details.
%% And for the dense case:
% Create sparse reconstruction with 180 angles and a binning factor of 8.
% Regularization paramater alpha=0.05, and max iterations=400.
tvNoisy = totalVariation(180, 8, 'low dose', 0.1, 400);
%% Results
fig = figure();
tlo = tiledlayout(fig, 'flow');

nexttile
tvSparse.show('Contrast', 1.2);
title('Sparse Angles, Low Noise');

nexttile
tvNoisy.show();
title('Dense Angles, High Noise');