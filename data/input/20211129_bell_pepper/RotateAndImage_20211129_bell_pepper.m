% This script takes projection images of the sample. The HiRemoteEx-program has 
% to be started.

% Topias Rusanen, 2015
% topias.rusanen@helsinki.fi

% Alexander Meaney, 2020
% alexander.meaney@helsinki.fi

clear;
close all;
clc;

%% Variables

angle = 1;
exposure_time = 1500;
x = 0;
filepath            = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_bell_pepper';
filename            = '20211129_bell_pepper_';
darkcurrent_file    = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_correction_images\20211129_background_1500ms.tif';
flatfield_file      = 'C:\Users\Samuli\Documents\X-ray Data\ville-robert-keijo\20211129_correction_images\20211129_shading_1500ms_40kV_1mA';


%% Connect to RemoteEx and initialize HiPic

hipic = startHipic();
setCorrectionSettings(hipic, darkcurrent_file, flatfield_file);

%% Open the data connection

dataconn = openDataConnection();


%% Initialize the ActiveX-component in order to control the rotator

apt = startAPT();


%% Wait a while for the GUI to load.
pause(10);


%% Set exposure time in milliseconds

setExposureTime(hipic, exposure_time);


%% Do the imaging

data = zeros([2368 2240]);

for iii=1:361
    if iii ~= 1
        disp('Moving the sample rotator...')
        moveRotator(apt, angle);
        disp('Movement done.')
    end
    disp(['Acquiring image number ' num2str(iii) '...'])
    data = acquireImage(hipic, dataconn);
    imwrite(data, [filepath '\' parseFilename(filename, iii)])
    disp('Image acquired and saved to disk.')
end

disp('Done.')


%% Do postprocessing

% doPostProcessing(hipic, filepath);


%% Close the data connection

closeDataConnection(dataconn);


%% Shut down HiPic

stopHipic(hipic);


%% Disable control over rotator

stopAPT(apt);


