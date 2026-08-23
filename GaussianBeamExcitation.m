function F = GaussianBeamExcitation(meta, N_PW, kx, G, ky, incident)
% --- NEW GAUSSIAN BEAM EXCITATION ---

% 1. Define the Gaussian beam waist (standard deviation)
% We set sigma to 1/6th of the lens size. This ensures the wave smoothly 
% decays to near-zero (~0.1% amplitude) exactly at the edges of the lens,
% meaning no harsh wave energy crashes into the PML boundary.
sigma_x = meta.Lx_lens / 6;
sigma_y = meta.Ly_lens / 6;

F = zeros(N_PW,1);

for n = 1:N_PW
    gx = kx + G(n,1);
    gy = ky + G(n,2);

    % --- X-axis Profile ---
    if strcmp(meta.type, '1D_X') || strcmp(meta.type, '2D')
        % Finite Lens: Fourier Transform of a Gaussian
        Sx = (sqrt(2*pi) * sigma_x / meta.Lx_total) * exp(-0.5 * (gx * sigma_x)^2);
    else
        % Infinite Plate: Perfect uniform plane wave (Kronecker Delta)
        if abs(gx) < 1e-10
            Sx = 1;
        else
            Sx = 0;
        end
    end

    % --- Y-axis Profile ---
    if strcmp(meta.type, '1D_Y') || strcmp(meta.type, '2D')
        % Finite Lens: Fourier Transform of a Gaussian
        Sy = (sqrt(2*pi) * sigma_y / meta.Ly_total) * exp(-0.5 * (gy * sigma_y)^2);
    else
        % Infinite Plate: Perfect uniform plane wave (Kronecker Delta)
        if abs(gy) < 1e-10
            Sy = 1;
        else
            Sy = 0;
        end
    end

    % The 2D Fourier coefficient is the product of the 1D profiles
    F(n) = incident.P0 * Sx * Sy;
end

% Hard boundary reflection multiplier (Keep this exactly as it was)
F = 2 * F;
end