% This script corrects the projection images. The HiRemoteEx-program has 
% to be started.

% Topias Rusanen, 2015
% topias.rusanen@helsinki.fi
close all;
clear;
clc;

%% Variables

% numAngles = 60;
% angle = 180/numAngles;

hipic = startHipic();
%% In order to apply the correction properly, we need to remove the camera information from Background and Shading image

% filepath = 'C:\Users\Samuli\Documents\CT Data\Samu\20161229_emoji\test_fold';
% filename = 'emoji_frame01';
% darkcurrent_file = 'C:\Users\Samuli\Documents\CT Data\Samu\20161229_emoji\Background_20161229.tif';
% flatfield_file = 'C:\Users\Samuli\Documents\CT Data\Samu\20161229_emoji\Shading_20161229_v2.tif';
% 
% darkcurrent_empty = 'C:\Users\Samuli\Documents\CT Data\Samu\20161229_emoji\Background_20161229_empty.tif';

filepath            = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_bell_pepper_low_dose';
filename            = '20211129_bell_pepper_low_dose_';
darkcurrent_file    = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_correction_images\20211129_background_1500ms_2.tif';
flatfield_file      = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_correction_images\20211129_shading_1500ms_40kV_01mA_2.tif';

darkcurrent_empty   = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_correction_images\20211129_background_1500ms_empty_2.tif';

background=imread(darkcurrent_file);
imwrite(background, darkcurrent_empty)





%% Connect to RemoteEx and initialize HiPic

%hipic = startHipic();
setCorrectionSettings(hipic, darkcurrent_empty, flatfield_file);

%% Open the data connection

% dataconn = openDataConnection();





%% Do postprocessing
%This is the background subtraction and shading applied....
doPostProcessing(hipic, filepath);


%% Close the data connection

% closeDataConnection(dataconn);

%% Shut down HiPic

stopHipic(hipic);


%% Disable control over rotator
%%
%stopAPT(apt);



