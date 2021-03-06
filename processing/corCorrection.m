function [offset] = corCorrection(sinogram)
% corCorrection: Find the offset of the center of rotation from a
% (full-resolution) sinogram.
%
% INPUT:
%   sinogram :: double(n,m)
%       A sinogram with columns corresponding to evenly spaced imaging
%       angles accross a full 360 degrees.
% OUTPUT:
%   offset :: int
%       An integer representing the shift to be applied. 

    [rows, cols] = size(sinogram);
   
    % Assuming the columns span 360 degrees evenly, this will be the
    % (approximate) between one measurement and its opposite.
    opposite_offset = fix(cols/2);
    
    % For each angle from 0 to 180:
    correlations = zeros(rows*2-1, opposite_offset);
    indices = zeros(1, opposite_offset);
    for ii = 1:opposite_offset
        % Compute the cross-correlation of the data and its opposite image.
        % Flip the latter to undo the mirroring.
        correlation = xcorr(sinogram(:,ii),...
                            flip(sinogram(:,ii+opposite_offset)));
        % Record this cross-correlation, and also the offset which
        % maximizes the cross-correlation:
        correlations(:,ii) = correlation;
        [~, ind] = max(correlation(:));
        % Flipping the image will double the offset:
        indices(ii) = (rows-ind)/2;
    end
    
    % For debugging, print the offset which maximizes the mean
    % cross-correlation, as well as the mean, median, and mode for the
    % individual best offsets (these should all be close):
    [~, ind] = max(sum(correlations, 2));
    disp(["Best Offset for Averaged Correlations: ", (rows-ind)/2]);
    disp(["Mean Best Offset: ", mean(indices)]);
    disp(["Median Best Offset: ", median(indices)]);
    disp(["Mode Best Offset: ", mode(indices)]);
    offset = mode(indices);
end