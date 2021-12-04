function binImages(filePrefix, binning)
% Apply the binImage function to the given images, and save the results in
% /data/output

% Set up the in/out paths and directories:
basePath = pwd;
images = dir(fullfile(basePath, '/data/input/**/corrected/', ...
    strcat(filePrefix, '*.tif')));
for ii = 1:length(images)
    image = imread(fullfile(images(ii).folder, images(ii).name));
    disp(['Processing image ', num2str(ii), ' of ', num2str(length(images))]);
    binnedImage = binImage(image, binning);
    imwrite(binnedImage, ...
        fullfile(basePath, '/data/output/binned/', num2str(binning), ...
        '/', strcat('binned_', num2str(binning), '_' images(ii).name)), ...
        'TIFF');
end
