function binImages(binning)

% Apply the binImage function to the given images, and save the results in
% /data/output/binned/$binningFactor/

% Must be run with Current Folder at root of project directory. New folders
% may need to be created manually for different binning factors.

% Images to bin:
filePrefix = '20211129_bell_pepper';
% Center of rotation correction:
corCorrection = -4;

% Set up the in/out paths and directories:
basePath = pwd;
images = dir(fullfile(basePath, '/data/input/**/corrected/', ...
    strcat(filePrefix, '*.tif')));

for ii = 1:length(images)
    image = im2double(imread(fullfile(images(ii).folder, images(ii).name)));
    image = circshift(image, corCorrection, 2);
    disp(['Processing image ', num2str(ii), ' of ', num2str(length(images))]);
    if binning ~= 1
        binnedImage = binImage(image, binning);
    else
        binnedImage = image;
    end
    imwrite(im2uint16(binnedImage), ...
        fullfile(basePath, '/data/output/binned/', num2str(binning), ...
        '/', strcat('binned_', num2str(binning), '_', images(ii).name)));
end