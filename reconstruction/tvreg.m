%tvreg_demo1  Demo script for a TV tomography problem
%
% This script illustrates the use of the TV algorithm
% implemented in the functions tvreg_upn and tvreg_gpbb.
% The user can easily modify the script for
% other noise levels, regularization etc..
%
% The scripts loads a a clean threedimensional version of the 
% classical Shepp-Logan phantom image, and  
% obtains the observed data by multiplication with 
% a tomography matrix A and addition of noise.
% The algorithms tvreg_upn and tvreg_gpbb are used to 
% obtain the TV reconstructions of the phantom. An reference
% solution is calculated to obtain an estimate of the optimal
% objective.

clear
close all
clc
%% Set parameters
binning = 16;
xDim = ceil(2240/binning);
yDim = ceil(2240/binning);
numProjections = 180; % Number of projections to reconstruct from

alpha  = 0.1;        % Regularization parameter
% r1_max = xDim/2;         % Halfwidth of object cube
% N      = 2*r1_max; % Full width of object cube
% N3     = N^2;        % Total number of variables
dims   = [xDim,yDim];    % Dimensions
% u_max  = r1_max;         % Halfwidth of projection planes
% U      = 2*u_max;  % Full width of projection planes

filePrefix   = '20211129_bell_pepper_low_dose_';
assert(mod(360, numProjections) == 0, 'Number of angles does not evenly divide 360 degrees.');
angleInterval       = 360/numProjections;
I0x1                = 1;
I0x2                = ceil(256/binning);
I0y1                = 1;
I0y2                = ceil(256/binning);
angles              = (angleInterval : angleInterval : 360);
sinogram            = createSinogram(filePrefix, numProjections, angleInterval, ...
                                      I0x1, I0x2, I0y1, I0y2, ...
                                      'binning', binning); 
%% Construct tomography system matrix A and make spy plot

% Define reconstruction size


% Define physical parameters of the scan
pixelSize               = 0.050*binning;
distanceSourceDetector  = 553.74;
distanceSourceOrigin    = 110.66 + 100;
distanceOriginDetector  = distanceSourceDetector - distanceSourceOrigin;
geometricMagnification  = distanceSourceDetector / distanceSourceOrigin;
effectivePixelSize      = pixelSize / geometricMagnification;

% Subsample sinogram
% angleInterval   = 5;
% anglesSparse    = 0 : angleInterval : (360 - angleInterval);
% ind             = ismembertol(angles, anglesSparse);
% sinogramSparse  = sinogram(ind, :);

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
%A = astra_mex_matrix('get', projectionMatrix);
A = opTomo('strip_fanflat', projectionGeometry, volumeGeometry);

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
opt.k_max    = 400;
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

%% Plot convergence rates in terms of objective function values of the 
%% three methods, comparing to the final reference objective function value
figure
%stairs(abs((fxkl_UPN-fs)/fs),'r')
stairs(abs(fxkl_UPN),'r')
% hold on
% stairs(abs((fxkl_UPNz-fs)/fs),'b')
% stairs(abs((fxkl_GPBB-fs)/fs),'g')
%stairs(abs(fxkl_GPBB),'g')
set(gca,'yscale','log')
% legend('UPN','UPN_0','GPBB')
xlabel('k')
ylabel('(f(x^k)-f^*)/f^*')
title('Convergence')

%% Display reconstructions
recon = Reconstruction('TV', alpha, 1000, 'UPN', reshape(xk_UPN, dims));
figure
%plotLayers(reshape(xk_GPBB,dims))
imshow(reshape(sqrt(xk_UPN), dims), []);
%recon.show
%suptitle('GPBB reconstruction')

% figure
% plotLayers(reshape(xk_UPN,dims))
% %suptitle('UPN reconstruction')
% 
% figure
% plotLayers(reshape(xk_UPNz,dims))
% %suptitle('UPN_0 reconstruction')