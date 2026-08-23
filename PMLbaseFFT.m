function [Kz, Kirchoff] = PMLbaseFFT(omega, G, medium, meta, incident, Kirchoff)


N_PW = size(G,1);
k0 = omega/medium.c0;
kx = k0 * sin(incident.theta) * cos(incident.phi);
ky = k0 * sin(incident.theta) * sin(incident.phi);
% Dynamic Nyquist grid sizing
max_nx = max(abs(round(G(:,1) / (2*pi/meta.Lx_total))));
max_ny = max(abs(round(G(:,2) / (2*pi/meta.Ly_total))));

Nx_grid = max(2^nextpow2(4 * max_nx + 1), 1024);
Ny_grid = max(2^nextpow2(4 * max_ny + 1), 1024);

% Dimensionless normalized coordinates (xi, eta)
xi_vec = (-Nx_grid/2 : Nx_grid/2 - 1) * (meta.Lx_total / Nx_grid);
eta_vec = (-Ny_grid/2 : Ny_grid/2 - 1) * (meta.Ly_total / Ny_grid);
[XI, ETA] = meshgrid(xi_vec, eta_vec);

% Selective Damping Based on lens type (1D_X, 1D_Y, or 2D)
zeta_x = zeros(size(XI));
zeta_y = zeros(size(ETA));

switch meta.type
    case '1D_X'
        mask_x = abs(XI) > (meta.Lx_lens / 2);
        zeta_x(mask_x) = meta.zeta_max * ((abs(XI(mask_x)) - meta.Lx_lens/2) / meta.l_PML).^3;
    case '1D_Y'
        mask_y = abs(ETA) > (meta.Ly_lens / 2);
        zeta_y(mask_y) = meta.zeta_max * ((abs(ETA(mask_y)) - meta.Ly_lens/2) / meta.l_PML).^3;
    case '2D'
        mask_x = abs(XI) > (meta.Lx_lens / 2);
        zeta_x(mask_x) = meta.zeta_max * ((abs(XI(mask_x)) - meta.Lx_lens/2) / meta.l_PML).^3;
        mask_y = abs(ETA) > (meta.Ly_lens / 2);
        zeta_y(mask_y) = meta.zeta_max * ((abs(ETA(mask_y)) - meta.Ly_lens/2) / meta.l_PML).^3;
end

% Calculate dimensionless stretching functions
s_matrix = 1 + 1i * (zeta_x + zeta_y);
S_D = s_matrix.^(-3);  % Dimensionless Stiffness stretching
S_rho = s_matrix;      % Dimensionless Density stretching

% Fluid inverse stretch functions
S_inv_x_fluid = 1 ./ (1 + 1i * zeta_x);
S_inv_y_fluid = 1 ./ (1 + 1i * zeta_y);

% 2D-FFT to extract expansion coefficients
D_factor_fft = fftshift(fft2(S_D)) / (Nx_grid * Ny_grid);
rho_factor_fft = fftshift(fft2(S_rho)) / (Nx_grid * Ny_grid);
S_inv_x_fft = fftshift(fft2(S_inv_x_fluid)) / (Nx_grid * Ny_grid); % Fluid X
S_inv_y_fft = fftshift(fft2(S_inv_y_fluid)) / (Nx_grid * Ny_grid); % Fluid Y

% Build Toeplitz matrices using purely integer dimensionless indices
D_toeplitz = zeros(N_PW, N_PW);
rho_toeplitz = zeros(N_PW, N_PW);
S_inv_x_toeplitz = zeros(N_PW, N_PW);
S_inv_y_toeplitz = zeros(N_PW, N_PW);

cx = floor(Nx_grid/2) + 1;
cy = floor(Ny_grid/2) + 1;

for m_idx = 1:N_PW
    for n_idx = 1:N_PW
        % Map specific G vector difference to FFT grid
        idx_x = round((G(m_idx,1) - G(n_idx,1)) / (2*pi/meta.Lx_total)) + cx;
        idx_y = round((G(m_idx,2) - G(n_idx,2)) / (2*pi/meta.Ly_total)) + cy;

        if idx_x > 0 && idx_x <= Nx_grid && idx_y > 0 && idx_y <= Ny_grid
            D_toeplitz(m_idx, n_idx) = D_factor_fft(idx_y, idx_x);
            rho_toeplitz(m_idx, n_idx) = rho_factor_fft(idx_y, idx_x);
            % Assign fluid Toeplitz elements
            S_inv_x_toeplitz(m_idx, n_idx) = S_inv_x_fft(idx_y, idx_x);
            S_inv_y_toeplitz(m_idx, n_idx) = S_inv_y_fft(idx_y, idx_x);
        end
    end
end

% Convolve the Toeplitz matrices with your original diagonal operators
Kirchoff.K_1p = D_toeplitz * Kirchoff.K_1p;
Kirchoff.K_2p = D_toeplitz * Kirchoff.K_2p;
Kirchoff.M_1p = rho_toeplitz * Kirchoff.M_1p;
Kirchoff.M_2p = rho_toeplitz * Kirchoff.M_2p;

% Kirchoff.F1 = SincWaveExcitation(meta, N_PW, kx, G, ky, incident);
Kirchoff.F1 = GaussianBeamExcitation(meta, N_PW, kx, G, ky, incident);

% Couple fluid PML matrix (K_zG)
Kx = diag(kx+G(:,1));
Ky = diag(ky+G(:,2));
Dx = S_inv_x_toeplitz * (-1i * Kx);
Dy = S_inv_y_toeplitz * (-1i * Ky);
Kz_squared = (k0^2 * eye(N_PW)) + (Dx * Dx) + (Dy * Dy);
% Use stable eigenvalue decomposition instead of unstable sqrtm()
[V_sq, D_sq] = eig(Kz_squared);
lambda_kz = sqrt(diag(D_sq)); % Element-wise scalar square root is perfectly stable
% Enforce rigorous branch cuts for forward propagation and decay
for j = 1:length(lambda_kz)
    kz = lambda_kz(j);
    
    % Rule A: Enforce decay (Imaginary part must be <= 0)
    if imag(kz) > 1e-8
        kz = -kz;
    end
    
    % Rule B: Enforce forward propagation for purely real modes
    if abs(imag(kz)) <= 1e-8 && real(kz) < 0
        kz = -kz;
    end
    
    lambda_kz(j) = kz;
end

% Kz = sqrtm(Kz_squared);
% 
% % Enforce radiation condition (Negative imaginary part with zero real part)
% [V_eig, D_eig] = eig(Kz);
% diag_Kz = diag(D_eig);
% wrong_sign_mask = (abs(real(diag_Kz)) < 1e-10) & (imag(diag_Kz) > 1e-10);
% diag_Kz(wrong_sign_mask) = conj(diag_Kz(wrong_sign_mask));

% Reconstruct the corrected Kz matrix
Kz = V_sq * diag(lambda_kz) / V_sq;
Kz_inv = V_sq * diag(1./lambda_kz) / V_sq;

Kirchoff.C_1f = medium.rho*omega*Kz_inv;
Kirchoff.C_2f = medium.rho*omega*Kz_inv;