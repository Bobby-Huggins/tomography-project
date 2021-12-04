function binnedImage = binImage(image, binning)
% binImage: Bin the neighboring pixels of the X-ray image, according to a
% binning factor.
%
% INPUT:
%   image :: double(rows, cols)
%   binning :: int
%       A scaling factor such that #ofBins = #ofPixels/binning.
%
% OUTPUT:
%   binnedImage :: double(rows/binning, cols/binning);

[rows, cols] = size(image);
% Initialize a new image with proportionally fewer rows and columns.
% Warn if the bins will not evenly divide the image.
if mod(rows, binning) ~= 0
    warning(['Number of rows (', num2str(rows), ...
        ') is not divisible by binning factor (', num2str(binning), ...
        '). Edge bins will be undersized.']);
end
if mod(cols, binning) ~= 0
    warning(['Number of columns (', num2str(cols), ...
        ') is not divisible by binning factor (', num2str(binning), ...
        '). Edge bins will be undersized.']);
end
newRows = ceil(rows/binning);
newCols = ceil(cols/binning);
binnedImage = zeros(newRows, newCols);

for r = 1:newRows
    % Handle the edges as special cases, in case the bins do not evenly
    % divide the image:
    binTop = (r-1)*binning + 1;
    if r == newRows
        binBottom = rows;
    else
        binBottom = r*binning;
    end
    
    for c = 1:newCols
        binLeft = (c-1)*binning + 1;
        if c == newCols
            binRight = cols;
        else
            binRight = c*binning;
        end
        % Average the image over the specified bin:
        value = sum(image(binTop:binBottom, binLeft:binRight), 'all');
        binnedImage(r, c) = value;
    end
end
end

