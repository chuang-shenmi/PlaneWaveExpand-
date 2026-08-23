function P_tr = GenTransmissionField(W2_G, G, k_zG, k, field, P_trG_numerator, ispoint)
% GenTransmissionField calculates the pressure transmission field according to equation 12.
%
% This function is completely vectorized and orientation-agnostic. It works for 
% single points, 1D lines, 2D planes (X-Z, Y-Z, X-Y), or full 3D volumes. This 
% unified function automatically detects whether the z-wavenumber input 
% (k_zG) is a simple vector (No PML) or a fully coupled dense matrix (PML active).

% Input:
%   W2_G: PWE coefficient of the displacement of the lower plate (N_G x 1)
%   G: Reciprocal lattice vector matrix (N_G x 2) [Gx, Gy]
%   k_zG: Wave number vector (N_G x 1) OR Wave number matrix (N_G x N_G)
%   k: Wave number vector of the incident wave [kx, ky, kz]
%   field: Struct containing .x, .y, and .z coordinate matrices. 
%          Must be provided for all 3 axes (use scalars for constant planes).
%          If ispoint==1, field is directly an M x 3 matrix of coordinates.
%   P_trG_numerator: Constant numerator (1i * rho0 * omega^2)
%   ispoint: Boolean flag (1 for M x 3 coordinate list, 0 for meshgrid struct)

% Output:
%   P_tr: Complex transmitted pressure field (same dimensions as input field coords)

N_G = size(G,1);
kx = k(1);
ky = k(2);

%% Format spatial coordinates
if ispoint
    % Format: M x 3 coordinate list [x1, y1, z1; x2, y2, z2; ...]
    R_coords = field; 
    output_size = [size(field, 1), 1];
else
    % Format: Struct with meshgrid fields
    % Ensure x, y, and z exist (default to 0 if user forgot one)
    if ~isfield(field, 'x')
        field.x = zeros(size(field.z));
    end
    if ~isfield(field, 'y')
        field.y = zeros(size(field.z));
    end
    if ~isfield(field, 'z')
        field.z = zeros(size(field.x));
    end
    
    % Flatten the meshgrids into a 1D list of 3D points
    R_coords = [field.x(:), field.y(:), field.z(:)];
    output_size = size(field.x);
end

% Preallocate the flattened output field
P_tr_flat = zeros(size(R_coords, 1), 1);


%% 2. Evaluate Field Based on Wavenumber Type
if isvector(k_zG)
    % =========================================================
    % BRANCH A: UNCOUPLED VECTOR (NO PML)
    % =========================================================
    K_vecs = zeros(N_G,3);
    K_vecs(:,1) = kx + G(:,1);
    K_vecs(:,2) = ky + G(:,2);
    K_vecs(:,3) = k_zG;

    for n = 1:N_G
        phase_term = exp(-1i * (R_coords * K_vecs(n,:).'));
        P_tr_flat = P_tr_flat + (P_trG_numerator * W2_G(n) / k_zG(n)) * phase_term;
    end

else
    % =========================================================
    % BRANCH B: COUPLED DENSE MATRIX (PML ACTIVE)
    % =========================================================
    P_trG_surf = P_trG_numerator * (k_zG \ W2_G);

    [V_kz, D_kz] = eig(k_zG);
    lambda_kz = diag(D_kz);

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

    C0 = V_kz \ P_trG_surf;

    unique_Z = unique(R_coords(:, 3));
    [~, Z_idx] = ismember(R_coords(:, 3), unique_Z);

    exp_term = exp(-1i * lambda_kz * unique_Z.');
    P_trG_z_map = V_kz * (C0 .* exp_term);

    for m = 1:N_G
        P_trG_m_Z = P_trG_z_map(m, Z_idx).';

        kx_m = kx + G(m,1);
        ky_m = ky + G(m,2);

        phase_term_xy = exp(-1i * (R_coords(:,1) * kx_m + R_coords(:,2) * ky_m));

        P_tr_flat = P_tr_flat + P_trG_m_Z .* phase_term_xy;
    end
end


% Reshape back to the original meshgrid dimensions (or leave as M x 1 for points)
P_tr = reshape(P_tr_flat, output_size);
