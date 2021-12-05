close all
clear
clc
%% Compute TV Reconstructions for both cases, accross a range of alphas.

% Set all parameters, and record them for reference:

alphas = 2.^linspace(-14, 9, 24);
factor = 8;
maxK = 1000;
numProjectionsSparse = 18;
numProjectionsDense = 180;
subsamplingMethod = 'subsampling';

results.sparse.ssim = zeros(length(alphas), 1);
results.sparse.lCurve = zeros(length(alphas), 2);
results.sparse.numProjections = numProjectionsSparse;

results.dense.ssim = zeros(length(alphas), 1);
results.dense.lCurve = zeros(length(alphas), 2);
results.dense.numProjections = numProjectionsDense;

results.alphas = alphas;
results.factor = factor;
results.maxK = maxK;
results.subsampling = subsamplingMethod;

% Build a reference reconstruction, to compute SSIM against. We use binning
% for this to reduce the noise as much as possible:
reference = filteredBP(360, 'binning', factor, 'high dose');

for aa = 1:length(alphas)
    alpha = alphas(aa);
    tvSparse = totalVariation(numProjectionsSparse, 'subsampling', factor, ...
                                'high dose', alpha, maxK);
    tvDense = totalVariation(numProjectionsDense, 'subsampling', factor, ...
                                'low dose', alpha, maxK);
    
    results.sparse.ssim(aa) = ssim(tvSparse.Image, reference.Image);
    results.sparse.lCurve(aa, 1) = tvSparse.DataFidelity;
    results.sparse.lCurve(aa, 2) = tvSparse.GradLxNorm;
    
    results.dense.ssim(aa) = ssim(tvDense.Image, reference.Image);
    results.dense.lCurve(aa, 1) = tvDense.DataFidelity;
    results.dense.lCurve(aa, 2) = tvDense.GradLxNorm;
end
%% Plot the L-Curve of the Results:
fig = figure;
tlo = tiledlayout(1,2);

nexttile
loglog(results.dense.lCurve(:, 1), results.dense.lCurve(:, 2));
axis equal
axis square
title('L-Curve for Dense Case');

nexttile
loglog(results.sparse.lCurve(:, 1), results.sparse.lCurve(:, 2));
axis equal
axis square
title('L-Curve for Sparse Case');