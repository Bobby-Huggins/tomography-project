function [sinogram] = createSinogram(filePrefix, nProj, ...
                                      I0x1, I0x2, I0y1, I0y2)
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
% OUTPUT:
%   sinogram :: double(nProj, cols)
%       Sinogram of data, where cols is X-ray image width.
%   
% Inverse Problems Project Work course 2021
% Alexander Meaney, 15.11.2021
% Adapted by:
% Keijo Korhonen, Ville Suokas, and Bobby Huggins

% Look at first projection and get dimensions
I               = double(imread([filePrefix '0001.tif']));
[rows, cols]    = size(I);

% Initialize empty sinogram
sinogram = zeros(nProj, cols);

% Loop over all projections and fill in sinogram
for iii = 1 : nProj
    disp(['Processing angle ' num2str(iii) '/' num2str(nProj) '.']);
    
    % Create full filename
    filename = [filePrefix sprintf('%.04d', iii) '.tif'];
    
    % Read in image
    I           = double(imread(filename));
    I0region    = I(I0y1:I0y2, I0x1:I0x2);
    I0          = mean(I0region(:));
    
    % Pick out center row and insert it into the sinogram
    projectionData      = I(rows/2, :);
    projectionData      = -log(projectionData/I0);
    sinogram(iii, :)    = projectionData; 
end

end

