close all
clear
clc

% Reconstructions from the low-dose and high-dose datasets do not align,
% (whether using TV of FBP), but are off by a small rotation. This script
% computes the rotation for a given resolution (binning factor) and saves
% the transformation in a file so that it may be applied repeatedly in the
% reconstruction functions. The reconstruction functions will throw a
% warning if they cannot find this file, and will return an uncorrected
% image. Otherwise they apply the transformation and return a corrected
% image in the Reconstruction.
%%
factor = 4;
fbpLowNoise = filteredBP(360, 'binning', factor, 'high dose', 'noRegistration');
fbpHighNoise = filteredBP(360, 'binning', factor, 'low dose', 'noRegistration');
%%
figure;
imshowpair(fbpLowNoise.Image, fbpHighNoise.Image);
[optimizer, metric] = imregconfig('multimodal');
optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 3000;

% movingRegistered = imregister(moving, fixed, 'affine', optimizer,
% metric);
%[fbpHighNoiseRegistered, transform] = imregister(fbpHighNoise.Image, fbpLowNoise.Image, ...
%                                        'rigid', optimizer, metric, 'DisplayOptimization', true);
transform = imregtform(fbpHighNoise.Image, fbpLowNoise.Image, 'rigid', optimizer, metric);
fbpHighNoiseRegistered = imwarp(fbpHighNoise.Image, transform, 'OutputView', imref2d(size(fbpHighNoise.Image)));

figure
imshowpair(fbpLowNoise.Image, fbpHighNoiseRegistered,'Scaling','joint')
%% Save the Transform Data for Use in Processing Reconstructions:
save(['registrationTransform_' num2str(factor)], 'transform');