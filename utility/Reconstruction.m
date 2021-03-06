classdef Reconstruction
    %RECONSTRUCTION Class for containing reconstructed images.
    
    properties
        RegMethod
        Alpha
        MaxK
        Image
        DataFidelity
        GradLxNorm
    end
    properties(Dependent)
        Size
    end
    
    methods
        function recon = Reconstruction(regMethod, alpha, maxK, image, dataFidelity, gradLxNorm)
            %RECONSTRUCTION Construct an instance of this class
            %   Size will be derived from the image
            recon.RegMethod = regMethod;
            recon.Alpha = alpha;
            recon.MaxK = maxK;
            recon.Image = image;
            recon.DataFidelity = dataFidelity;
            % Grad norm is already multiplied by alpha in the code.
            % We should undo this for L-Curve method:
            recon.GradLxNorm = gradLxNorm/alpha;
        end
        function disp(recon)
            fprintf(1,...
                ['Reconstruction Details:\n', ...
                    '    Method: %s\n', '    Size: %dx%d\n', ...
                    '    Alpha: %6.4f\n', '    MaxK: %d\n', ...
                    'Data Fidelity: %e\n', 'Norm of Gradient of Lx: %e\n'], ...
                    recon.RegMethod, recon.Size(1), recon.Size(2), ...
                    recon.Alpha, recon.MaxK, recon.DataFidelity, recon.GradLxNorm);
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

