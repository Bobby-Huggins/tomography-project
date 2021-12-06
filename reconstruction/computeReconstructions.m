close all
clear
clc
%% Compute TV Reconstructions for both cases, accross a range of alphas.

% Set all parameters, and record them for reference:

alphas = 2.^linspace(-14, 9, 24);
factor = 4;
maxK = 1000;
numProjectionsSparse = 18;
numProjectionsDense = 180;
subsamplingMethod = 'subsampling';

results.sparse.mse = zeros(length(alphas), 1);
results.sparse.ssim = zeros(length(alphas), 1);
results.sparse.lCurve = zeros(length(alphas), 2);
results.sparse.numProjections = numProjectionsSparse;

results.dense.mse = zeros(length(alphas), 1);
results.dense.ssim = zeros(length(alphas), 1);
results.dense.lCurve = zeros(length(alphas), 2);
results.dense.numProjections = numProjectionsDense;

results.alphas = alphas;
results.factor = factor;
results.maxK = maxK;
results.subsampling = subsamplingMethod;

% Set up file IO:

% Set up the in/out paths and directories:
basePath = pwd;
saveReconstructions = 1;

% Build a reference reconstruction, to compute SSIM against. We use binning
% for this to reduce the noise as much as possible:
reference = filteredBP(360, 'binning', factor, 'high dose');

for aa = 1:length(alphas)
    disp(['Computing reconstruction set ', num2str(aa), ...
            ' of ', num2str(length(alphas))]);
    alpha = alphas(aa);
    tvSparse = totalVariation(numProjectionsSparse, 'subsampling', factor, ...
                                'high dose', alpha, maxK);
    tvDense = totalVariation(numProjectionsDense, 'subsampling', factor, ...
                                'low dose', alpha, maxK);
    
    results.sparse.mse(aa) = immse(tvSparse.Image, reference.Image);
    results.sparse.ssim(aa) = ssim(tvSparse.Image, reference.Image);
    results.sparse.lCurve(aa, 1) = tvSparse.DataFidelity;
    results.sparse.lCurve(aa, 2) = tvSparse.GradLxNorm;
    
    results.dense.mse(aa) = immse(tvDense.Image, reference.Image);
    results.dense.ssim(aa) = ssim(tvDense.Image, reference.Image);
    results.dense.lCurve(aa, 1) = tvDense.DataFidelity;
    results.dense.lCurve(aa, 2) = tvDense.GradLxNorm;
    
    if saveReconstructions
        imwrite(im2uint16(tvSparse.Image), ...
            fullfile(basePath, '/data/output/reconstructions/', num2str(factor), '/', ...
            strcat('tv_sparse_', num2str(factor), sprintf('_alpha_%09.5f', alpha), '.tif')));
        img = Tiff(fullfile(basePath, '/data/output/reconstructions/', num2str(factor), '/', ...
            strcat('tv_sparse_', num2str(factor), sprintf('_alpha_%09.5f', alpha), '.tif')), ...
            'r+');
        imageDescription = sprintf('Dataset=%s, Method=%s, Size=%dx%d, Alpha=%e, maxK=%d, Data Fidelity=%e, Norm of Gradient=%e',...
            'sparse', tvSparse.RegMethod, tvSparse.Size(1), tvSparse.Size(2), tvSparse.Alpha, ...
            tvSparse.MaxK, tvSparse.DataFidelity, tvSparse.GradLxNorm);
        setTag(img, 'ImageDescription', imageDescription);
        rewriteDirectory(img);
        close(img);
        
        imwrite(im2uint16(tvDense.Image), ...
            fullfile(basePath, '/data/output/reconstructions/', num2str(factor), '/', ...
            strcat('tv_dense_', num2str(factor), sprintf('_alpha_%09.5f', alpha), '.tif')));
        img = Tiff(fullfile(basePath, '/data/output/reconstructions/', num2str(factor), '/', ...
            strcat('tv_dense_', num2str(factor), sprintf('_alpha_%09.5f', alpha), '.tif')), ...
            'r+');
        imageDescription = sprintf('Dataset=%s, Method=%s, Size=%dx%d, Alpha=%e, maxK=%d, Data Fidelity=%e, Norm of Gradient=%e',...
            'dense', tvDense.RegMethod, tvDense.Size(1), tvDense.Size(2), tvDense.Alpha, ...
            tvDense.MaxK, tvDense.DataFidelity, tvDense.GradLxNorm);
        setTag(img, 'ImageDescription', imageDescription);
        rewriteDirectory(img);
        close(img);
    end
end

% Save the resulting L-Curve and SSIM statistics:
save(fullfile(basePath, '/data/output/reconstructions/', num2str(factor), '/', ...
    strcat('tv_', num2str(factor), '_alphas_', num2str(alphas(1)), ...
    '_to_', num2str(alphas(length(alphas))), '.mat')),...
    'results');
%% Plot the Results:
fig = figure;
tlo = tiledlayout(1,2);

nexttile
loglog(results.dense.lCurve(:, 1), results.dense.lCurve(:, 2));
axis equal
axis square
title('L-Curve for Dense Case');
xlabel('Data Fidelity');
ylabel('Sum of Norms of Gradient');

nexttile
loglog(results.sparse.lCurve(:, 1), results.sparse.lCurve(:, 2));
axis equal
axis square
title('L-Curve for Sparse Case');
xlabel('Data Fidelity');
ylabel('Sum of Norms of Gradient');

figure;

semilogx(results.alphas, results.dense.ssim);
title('SSIM for Dense Case');
xlabel('Alpha');
ylabel('SSIM');

hold on;
semilogx(results.alphas, results.sparse.ssim);
legend('Dense Case', 'Sparse Case');

figure;

semilogx(results.alphas, results.dense.mse);
title('MSE');
xlabel('Alpha');
ylabel('MSE');

hold on;
semilogx(results.alphas, results.sparse.mse);
legend('Dense Case', 'Sparse Case');