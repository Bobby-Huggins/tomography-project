% Apply the binImage function to the given images, and save the results in
% /data/output

% Must be run with Current Folder at root of project directory.

% Images to bin:
filePrefix = '20211129_bell_pepper';
% Binning factor:
binning = 4;

% Set up the in/out paths and directories:
basePath = pwd;
images = dir(fullfile(basePath, '/data/input/**/corrected/', ...
    strcat(filePrefix, '*.tif')));
for ii = 1:length(images)
    image = im2double(imread(fullfile(images(ii).folder, images(ii).name)));
    disp(['Processing image ', num2str(ii), ' of ', num2str(length(images))]);
    binnedImage = binImage(image, binning);
    imwrite(im2uint8(binnedImage), ...
        fullfile(basePath, '/data/output/binned/', num2str(binning), ...
        '/', strcat('binned_', num2str(binning), '_', images(ii).name)));
end