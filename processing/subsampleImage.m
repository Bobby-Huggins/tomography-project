function img = subsampleImage(image, factor)
% subsampleImage - Subsample every factor-th pixel, starting from (1,1),
%   and return the subsampled image. This will decrease the size of the
%   image without changing the signal-to-noise ratio.
%
% INPUT:
%   image :: double(rows, cols)
%   factor :: int
%       A scaling factor such that #ofNewPixels = #ofOldPixels/factor.
%
% OUTPUT:
%   binnedImage :: double(rows/binning, cols/binning);

[rows, cols] = size(image);
% Initialize a new image with proportionally fewer rows and columns.

newRows = floor(rows/factor);
newCols = floor(cols/factor);
img = zeros(newRows, newCols);

for r = 1:newRows
    for c = 1:newCols
        value = image((r-1)*factor+1, (c-1)*factor+1);
        img(r, c) = value;
    end
end
end