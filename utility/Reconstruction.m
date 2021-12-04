classdef Reconstruction
    %RECONSTRUCTION Class for containing reconstructed images.
    
    properties
        RegMethod
        Alpha
        MaxK
        Image
    end
    properties(Dependent)
        Size
    end
    
    methods
        function recon = Reconstruction(regMethod, alpha, maxK, image)
            %RECONSTRUCTION Construct an instance of this class
            %   Size will be derived from the image
            recon.RegMethod = regMethod;
            recon.Alpha = alpha;
            recon.MaxK = maxK;
            recon.Image = image;
        end
        function disp(recon)
            fprintf(1,...
                ['Reconstruction Details:\n', ...
                    '    Method: %s\n', '    Size: %dx%d\n', ...
                    '    Alpha: %6.4f\n', '    MaxK: %d\n'], ...
                    recon.RegMethod, recon.Size(1), recon.Size(2), ...
                    recon.Alpha, recon.MaxK);
        end
        function s = get.Size(recon)
            s = size(recon.Image);
        end
        function show(recon, contrast)
            if nargin == 1
                figure();
                imshow(recon.Image, []);
            else
                switch contrast
                    case 'default'
                        figure();
                        imshow(recon.Image, []);
                    case 'high contrast'
                        figure();
                        imshow(sqrt(recon.Image), []);
                    otherwise
                        warning('Using default.contrast');
                        figure();
                        imshow(recon.Image, []);
                end
            end
        end
    end
end

