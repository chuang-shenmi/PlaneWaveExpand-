function F = SincWaveExcitation(meta, N_PW, kx, G, ky, incident)
% Limits incident force to the active lens area, preventing PML "hotspots".
% Determine active lengths based on lens type
if strcmp(meta.type, '1D_X') || strcmp(meta.type, '2D')
    Lx_act = meta.Lx_lens;
else
    Lx_act = meta.Lx_total; % Infinite in X
end

if strcmp(meta.type, '1D_Y') || strcmp(meta.type, '2D')
    Ly_act = meta.Ly_lens;
else
    Ly_act = meta.Ly_total; % Infinite in Y
end

F = zeros(N_PW,1);

for n = 1:N_PW
    gx = kx + G(n,1);
    gy = ky + G(n,2);

    % Evaluate Sinc function for X-axis
    if abs(gx) < 1e-10
        Sx = Lx_act / meta.Lx_total;
    else
        Sx = (2 * sin(gx * Lx_act / 2)) / (gx * meta.Lx_total);
    end

    % Evaluate Sinc function for Y-axis
    if abs(gy) < 1e-10
        Sy = Ly_act / meta.Ly_total;
    else
        Sy = (2 * sin(gy * Ly_act / 2)) / (gy * meta.Ly_total);
    end

    % The 2D Fourier coefficient is the product of the 1D coefficients
    F(n) = incident.P0 * Sx * Sy;
end

F = 2 * F; % Hard boundary reflection multiplier
end