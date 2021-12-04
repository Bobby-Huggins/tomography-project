classdef Reconstruction
    %RECONSTRUCTION Class for containing reconstructed images.
    
    properties
        RegMethod
        Alpha
        Algorithm
        MaxK
        Image
    end
    properties(Dependent)
        Resolution
    end
    
    methods
        function recon = Reconstruction(regMethod, alpha, maxK, ...
                                        algorithm, image)
            %RECONSTRUCTION Construct an instance of this class
            %   Size will be derived from the image
            recon.RegMethod = regMethod;
            recon.Alpha = alpha;
            recon.Algorithm = algorithm;
            recon.MaxK = maxK;
            recon.Image = image;
        end
        function disp(recon)
            fprintf(1,...
                ['Reconstruction Details:\n', ...
                    'Method: %s\n', 'Size: %dx%d', ...
                    'Alpha: %6.4f', 'Algorithm: %s', ...
                    'MaxK: %d'], ...
                    recon.RegMethod, recon.Resolution(1), recon.Resolution(2), ...
                    recon.Alpha, recon.Algorithm, ...
                    recon.MaxK);
        end
        function res = get.Resolution(recon)
            res = size(recon.Image);
        end
        function show(recon)
            figure();
            imshow(recon.Image, []);
        end
    end
end

