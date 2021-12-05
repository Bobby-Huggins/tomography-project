function [recon] = totalVariation(...
                        numProjections, subsampling, factor, dataset, ...
                        alpha, maxK)
%% totalVariation - Compute an approximation of the minimum total variation solution.
%
% INPUTS:
% numProjections :: int
%   The number of evenly spaced projections in the measurement data. Must
%   divide 360.
%   subsampling :: string
%       Either 'subsampling' or 'binning'.
%   factor :: int
%       A scaling factor for the subsampling/binning.
% dataset :: string
%   The comparison dataset: either 'low dose' or 'high dose'.
% alpha :: double
%   The regularization parameter.
% maxK :: int
%   The maximum number of iterations in the optimization procedure.
%
% OUTPUTS:
% recon :: Reconstruction (see class file in /utility).
%   A class containing the reconstructed image and associated data.

xDim = ceil(2240/factor);
yDim = ceil(2240/factor);
dims   = [xDim,yDim];
assert(mod(360, numProjections) == 0, 'Number of angles does not evenly divide 360 degrees.');
angleInterval       = 360/numProjections;
I0x1                = 1;
I0x2                = ceil(256/factor);
I0y1                = 1;
I0y2                = ceil(256/factor);
angles              = (angleInterval : angleInterval : 360);
switch dataset
    case 'low dose'
        filePrefix = '20211129_bell_pepper_low_dose_';
    case 'high dose'
        filePrefix = '20211129_bell_pepper_';
    otherwise
        error("Supported datasets are 'low dose' or 'high dose'.");
end
    
sinogram            = createSinogram(filePrefix, numProjections, angleInterval, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      subsampling, factor);
%% Construct tomography system matrix A

% Define physical parameters of the scan
pixelSize               = 0.050*factor;
distanceSourceDetector  = 553.74;
distanceSourceOrigin    = 110.66 + 100;
distanceOriginDetector  = distanceSourceDetector - distanceSourceOrigin;
geometricMagnification  = distanceSourceDetector / distanceSourceOrigin;
effectivePixelSize      = pixelSize / geometricMagnification;

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
% anglesRad       = deg2rad(anglesSparse);
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

% Create projection matrix
projectionMatrix = astra_mex_projector('matrix', projectorObject);

% Obtain projection matrix as a MATLAB sparse matrix
A = astra_mex_matrix('get', projectionMatrix);
%A = opTomo('strip_fanflat', projectionGeometry, volumeGeometry);

fprintf('done.\n');

% Memory cleanup
astra_mex_data2d('delete', volumeGeometry);
astra_mex_data2d('delete', projectionGeometry);
astra_mex_projector('delete', projectorObject);
astra_mex_matrix('delete', projectionMatrix);

% The TV Toolbox Expects the Transpose (may lead to a rotation compared to
% other reconstructions):
sinogram = sinogram';

%% Parameters for the reconstruction algorithms
tau         = 1e-4*norm(sinogram(:),'inf');       % Huber smoothing parameter

% Specify nonnegativity constraints
constraint.type = 2;
constraint.c    = 0*ones(prod(dims),1);
constraint.d    = 1*ones(prod(dims),1);

% Options
opt.epsb_rel = 1e-6;
opt.k_max    = maxK;
opt.qs       = 1;
opt.K        = 2;
opt.verbose  = 1;
opt.beta     = 0.95;

b = sinogram(:);

% % Options for reference solution
% opt_ref.epsb_rel = 1e-8;
% opt_ref.k_max    = 2000;
% opt_ref.verbose  = 1;

%% Solve: Compute TV minimizer
disp(['Starting Iterative TV reconstruction with max iterations ',...
    num2str(maxK), '...']);
% % Reference solution
% [x_ref fxk_ref hxk_ref gxk_ref fxkl_ref info_ref] = ...
%     tvreg_upn(A,b,alpha,tau,dims,constraint,opt_ref);
% fs = fxkl_ref(end);     % Final reference objective function value

% Solve using GPBB
% tic
% [xk_GPBB fxk_GPBB hxk_GPBB gx_kGPBB fxkl_GPBB info_GPBB] = ...
%     tvreg_gpbb(A,b,alpha,tau,dims,constraint,opt);
% tGPBB = toc

% % Solve using UPN
tic
[xk_UPN fxk_UPN hxk_UPN gxk_UPN fxkl_UPN info_UPN] = ...
    tvreg_upn(A,b,alpha,tau,dims,constraint,opt);
tupn = toc
% 
% % Solve using UPN0
% tic
% opt.qs = 0;
% [xk_UPNz fxk_UPNz hxk_UPNz gxk_UPNz fxkl_UPNz info_UPNz] = ...
%     tvreg_upn(A,b,alpha,tau,dims,constraint,opt);
% tupnz = toc

% %% Plot convergence rates in terms of objective function values of the 
% %% three methods, comparing to the final reference objective function value
% figure
% %stairs(abs((fxkl_UPN-fs)/fs),'r')
% stairs(abs(fxkl_UPN),'r')
% % hold on
% % stairs(abs((fxkl_UPNz-fs)/fs),'b')
% % stairs(abs((fxkl_GPBB-fs)/fs),'g')
% %stairs(abs(fxkl_GPBB),'g')
% set(gca,'yscale','log')
% % legend('UPN','UPN_0','GPBB')
% xlabel('k')
% ylabel('(f(x^k)-f^*)/f^*')
% title('Convergence')

%% Return reconstruction
% Transpose the image to align orientation with FBP:
recon = Reconstruction('TV', alpha, maxK, reshape(xk_UPN, dims)');