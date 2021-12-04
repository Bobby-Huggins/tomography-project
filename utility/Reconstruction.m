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
        function show(recon, options)
            arguments
                recon (1,1) Reconstruction
                options.Contrast (1,1) {mustBeNumeric} = 1
            end
            imshow((recon.Image).^(1/options.Contrast), []);
        end
    end
end

