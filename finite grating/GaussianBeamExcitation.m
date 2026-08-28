function F = GaussianBeamExcitation(meta, N_PW, G, incident)
% --- NEW GAUSSIAN BEAM EXCITATION ---

% 1. Define the Gaussian beam waist (standard deviation)
% We set sigma to 1/6th of the lens size. This ensures the wave smoothly 
% decays to near-zero (~0.1% amplitude) exactly at the edges of the lens,
% meaning no harsh wave energy crashes into the PML boundary.
sigma_x = meta.Lx_lens / 6;
sigma_y = meta.Ly_lens / 6;
tol_G = 1e-10;  % tolerance

Gx = G(:,1);
Gy = G(:,2);

A_G = zeros(N_PW, 1);

switch meta.type
    case '1D_X'
        mask = abs(Gy) < tol_G;
        A_G(mask) = (sqrt(2*pi) * sigma_x / meta.Lx_total) * exp(-0.5 * (Gx(mask) * sigma_x).^2);

    case '1D_Y'
        mask = abs(Gx) < tol_G;
        A_G(mask) = (sqrt(2*pi) * sigma_y / meta.Ly_total) * exp(-0.5 * (Gy(mask) * sigma_y).^2);

    case '2D'
        A_G = (2*pi * sigma_x * sigma_y) / (meta.Lx_total * meta.Ly_total) ...
            * exp(-0.5 * (Gx * sigma_x).^2) ...
            * exp(-0.5 * (Gy * sigma_y).^2);

    otherwise
        error('Unknown meta.type: %s', meta.type);
end


% Hard boundary reflection multiplier (Keep this exactly as it was)
F = 2 *incident.P0 * A_G;
end