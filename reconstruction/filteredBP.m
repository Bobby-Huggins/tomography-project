function recon = filteredBP(...
    numProjections, binning, dataset)
% FBP Reconstruction
%
% Inverse Problems Project Work course 2021
% Alexander Meaney, 15.11.2021
% Adapted by:
% Keijo Korhonen, Ville Suokas, and Bobby Huggins

%% Create sinogram
xDim = ceil(2240/binning);
yDim = ceil(2240/binning);
assert(mod(360, numProjections) == 0, 'Number of angles does not evenly divide 360 degrees.');
angleInterval       = 360/numProjections;
I0x1                = 1;
I0x2                = ceil(256/binning);
I0y1                = 1;
I0y2                = ceil(256/binning);
angles              = (angleInterval : angleInterval : 360);
switch dataset
    case 'low dose'
        filePrefix = '20211129_bell_pepper_low_dose_';
    case 'high dose'
        filePrefix = '20211129_bell_pepper_';
    otherwise
        error("Supported datasets are 'low dose' or 'high dose'.");
end
    
sinogram           = createSinogram(filePrefix, numProjections, angleInterval, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      binning);                              

% Define physical parameters of the scan
pixelSize               = 0.050*binning;
distanceSourceDetector  = 553.74;
distanceSourceOrigin    = 110.66 + 100;
distanceOriginDetector  = distanceSourceDetector - distanceSourceOrigin;
geometricMagnification  = distanceSourceDetector / distanceSourceOrigin;
effectivePixelSize      = pixelSize / geometricMagnification;
angles                  = (angleInterval : angleInterval : 360);

% Create shorthands for needed variables
DSO                 = distanceSourceOrigin;
DOD                 = distanceOriginDetector;
M                   = geometricMagnification;
[~, numDetectors]   = size(sinogram);
effPixel            = effectivePixelSize;


% Rather technical ASTRA Tomography Toolbox code to compute FBP fan beam
% reconstruction

% Distance from source to origin specified in terms of effective pixel size
DSO             = DSO / effPixel;

% Distance from origin to detector specified in terms of effective pixel size
DOD             = DOD /effPixel;

% ASTRA uses angles in radians
anglesRad       = deg2rad(angles);

% ASTRA code begins here
fprintf('Creating geometries and data objects in ASTRA... ');

% Create volume geometry, i.e. reconstruction geometry
volumeGeometry = astra_create_vol_geom(yDim, xDim);

% Create projection geometry
projectionGeometry = astra_create_proj_geom('fanflat', M, numDetectors, ...
                                            anglesRad, DSO, DOD);
                                        
% Create projector
projectorObject = astra_create_projector('strip_fanflat', ...
                                         projectionGeometry, ...
                                         volumeGeometry);

% Create 2D data object for reconstruction
reconstructionObject = astra_mex_data2d('create', '-vol', ...
                                        volumeGeometry, 0);

% Create 2D data object for sinogram
projectionsObject = astra_mex_data2d('create', '-sino', ...
                                     projectionGeometry, sinogram);

fprintf('done.\n');

% Create and initialize reconstruction algorithm
fprintf('Creating reconstruction algorithm in ASTRA... ');
cfg                         = astra_struct('FBP');
cfg.ProjectorId             = projectorObject;
cfg.ReconstructionDataId    = reconstructionObject;
cfg.ProjectionDataId        = projectionsObject;
reconstructionAlgorithm     = astra_mex_algorithm('create', cfg);
fprintf('done.\n');

% Run reconstruction algorithm
fprintf('Running reconstruction algorithm in ASTRA... ');
astra_mex_algorithm('run', reconstructionAlgorithm);
fprintf('done.\n');

% Get reconstruction as a matrix
fbp = astra_mex_data2d('get', reconstructionObject);

% Memory cleanup
astra_mex_data2d('delete', volumeGeometry);
astra_mex_data2d('delete', projectionGeometry);
astra_mex_data2d('delete', reconstructionObject);
astra_mex_data2d('delete', projectionsObject);
astra_mex_algorithm('delete', reconstructionAlgorithm);
astra_clear;
%clearvars -except recon

%% Return a Reconstruction object:
recon = Reconstruction('FBP', 0.0, 0, fbp);
