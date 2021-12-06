function [sinogram] = createSinogram(filePrefix, nProj, angleInterval, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      subsampling, factor)
% createSinogram - Create sinogram from cone beam measurements.
%
% INPUT:
%   filePrefix :: string
%       Path and prefix of X-ray images.
%   nProj :: int
%       Number of projection angles.
%   angleInterval :: int
%       Separation (in degrees) between each projection.
%   I0x1,...,I0y2 :: int(s)
%       X and Y coordinates defining the calibration
%       window.
%   subsampling :: string
%       Either 'subsampling' or 'binning'.
%   factor :: int
%       A scaling factor for the subsampling/binning.
%   corCorrection :: int
%       The number of pixels to shift each original image to correct for
%       the offset center of rotation.
%
% OUTPUT:
%   sinogram :: double(nProj, cols)
%       Sinogram of data, where cols is X-ray image width.
%   
% Inverse Problems Project Work course 2021
% Alexander Meaney, 15.11.2021
% Adapted by:
% Keijo Korhonen, Ville Suokas, and Bobby Huggins

switch subsampling
    case 'subsampling'
        fullPrefix = strcat('subsampled_', num2str(factor), '_', filePrefix);
    case 'binning'
        fullPrefix = strcat('binned_', num2str(factor), '_', filePrefix);
    otherwise
        error("Subsampling argument must take value 'subsampling' or 'binning'.");
end

% Look at first projection and get dimensions
I               = im2double(imread([fullPrefix, '001.tif']));
[rows, cols]    = size(I);

% Initialize empty sinogram
sinogram = zeros(nProj, cols);
disp(['Creating sinogram of size ', num2str(nProj), ' by ', num2str(cols)]);

% Loop over all projections and fill in sinogram
for iii = 1 : nProj
    aaa = round(iii*angleInterval);
    %disp(['Processing angle ' num2str(iii) '/' num2str(nProj) '.']);
    
    % Create full filename
    filename = [fullPrefix sprintf('%.03d', aaa) '.tif'];
    
    % Read in image
    I           = im2double(imread(filename));
    I0region    = I(I0y1:(I0y2/factor), I0x1:(I0x2/factor));
    I0          = mean(I0region(:));
    
    % Pick out center row and insert it into the sinogram
    projectionData      = I(rows/2, :);
    projectionData      = -log(projectionData/I0);
    sinogram(iii, :)    = projectionData; 
end

end
