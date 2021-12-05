function subssampleImages(factor)
% Apply the subsampleImage function to the given images, and save the
%   results in /data/output/subsampled/$factor/

% Must be run with Current Folder at root of project directory. New folders
% may need to be created manually for different subsampling factors.

% Images to bin:
filePrefix = '20211129_bell_pepper';
% Center of rotation correction, to be applied as a circshift to original:
corCorrection = -4;

% Set up the in/out paths and directories:
basePath = pwd;
images = dir(fullfile(basePath, '/data/input/**/corrected/', ...
    strcat(filePrefix, '*.tif')));

for ii = 1:length(images)
    image = im2double(imread(fullfile(images(ii).folder, images(ii).name)));
    image = circshift(image, corCorrection, 2);
    disp(['Processing image ', num2str(ii), ' of ', num2str(length(images))]);
    if factor ~= 1
        image = subsampleImage(image, factor);
    end
    imwrite(im2uint16(image), ...
        fullfile(basePath, '/data/output/subsampled/', num2str(factor), ...
        '/', strcat('subsampled_', num2str(factor), '_', images(ii).name)));
end