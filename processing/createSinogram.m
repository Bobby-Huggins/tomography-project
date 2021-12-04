function [sinogram] = createSinogram(filePrefix, nProj, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      binning, corCorrection)
% createSinogram - Create sinogram from cone beam measurements.
%
% INPUT:
%   filePrefix :: string
%       Path and prefix of X-ray images.
%   nProj :: int
%       Number of projection angles.
%   I0x1,...,I0y2 :: int(s)
%       X and Y coordinates defining the calibration
%       window.
%   binning :: int
%       A scaling factor such that #ofBins = #ofPixels/binning.
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


% Look at first projection and get dimensions
I               = double(imread([filePrefix '001.tif']));
[rows, cols]    = size(I);
rows            = rows / binning;
cols            = cols / binning;

% Initialize empty sinogram
sinogram = zeros(nProj, cols);

% Loop over all projections and fill in sinogram
for iii = 1 : nProj
    disp(['Processing angle ' num2str(iii) '/' num2str(nProj) '.']);
    
    % Create full filename
    filename = [filePrefix sprintf('%.03d', iii) '.tif'];
    
    % Read in image
    I           = double(imread(filename));
    I           = circshift(I, corCorrection, 2);
    I           = binImage(I, binning);
    I0region    = I(I0y1:(I0y2/binning), I0x1:(I0x2/binning));
    I0          = mean(I0region(:));
    %Ilog        = -log(I/I0);
    
    % Pick out center row and insert it into the sinogram
    projectionData      = I(rows/2, :);
    projectionData      = -log(projectionData/I0);
    sinogram(iii, :)    = projectionData; 
end

end
