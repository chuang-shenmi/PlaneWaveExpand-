function [tau_power, tau_pressure, W2_G, Kz, G, feature] = PWE4PlateResonatorPlateDimless2DOF_PML(plate,resonator,lattice,medium,incident,M,freq,meta)
% Calculation of Transmission Coefficients and Other Parameters Using the Plane Wave Expansion Method for the Dimensionless Equations of a Resonator Composed of Two Thin Plates with an Interlayer (N=2)


%%  Check whether the number of parameters are matched.
ParameterCheck(resonator, lattice, plate);


%% Initialize and generate reciprocal vectors
omega = 2*pi*freq;
k0 = omega/medium.c0;
% Orthogonal arrow R(m_=1,n_=1)
lattice.R = [lattice.a1;lattice.a2];
% Generate Reciprocal Vectors
G = ReciprocalVectors(lattice.R, M);
N_PW = size(G,1);
% the area of the unit cell associated with the periodic lattice
S = norm(lattice.a1)*norm(lattice.a2)*sin(acos(dot(lattice.a1,lattice.a2)/(norm(lattice.a1)*norm(lattice.a2))));
% Bending stiffness of the plate
plate.D = plate.E.*plate.h.^3./(12.*(1-plate.niu.^2));
if plate.eta
    plate.D = plate.D.*(1+1i*plate.eta);
end



%% Non-dimensionalization
% Step 1: Select feature physical quantity
% The featured length is chosen as the geometric mean of the lattice constants
L0 = sqrt(S);
% The featured mass is chosen as the mass of the upper plate within a single lattice
M0 = plate.rho(1)*plate.h(1)*S;
% The featured wavenumber is chosen as the reciprocal of the featured length
k0_feature = 1/L0;
% According to the dispersion relation of bending waves on the plate, the featured frequency is defined as
omega0 = 1/L0^2*sqrt(plate.D(1)/(plate.rho(1)*plate.h(1)));
% featured time is the reciprocal of the featured frequency
T0 = 1/omega0;
% Based on the above basic quantities, define featured force and featured pressure
F0 = M0*L0*omega0^2;
p0 = M0*omega0^2/L0;

feature.L0 = L0;  % feature length
feature.M0 = M0;  % feature mass
feature.k0 = k0_feature;  % feature wave number
feature.omega0 = omega0;  % feature frequency
feature.T0 = T0;  % feature time
feature.F0 = F0;  % feature force
feature.p0 = p0;  % feature pressure
feature.rho0 = M0/L0^3;  % feature mass density
feature.k_spring = plate.D(1)/L0^2;  % feature stiffness of spring

% Step 2: Non-dimensionalize
omega = omega/feature.omega0;
k0 = k0/feature.k0;
incident.P0 = incident.P0/feature.p0;
G = G*feature.L0;
resonator.k = resonator.k/feature.k_spring;
resonator.m = resonator.m/feature.M0;
medium.rho = medium.rho/feature.rho0;
medium.c0 = medium.c0/(feature.L0/feature.T0);
plate.d = plate.d/feature.L0;
resonator.r = resonator.r/feature.L0;


%% PWE core
nfreq = length(freq);
alpha_power = zeros(1,nfreq);
tau_power = zeros(1,nfreq);
tau_pressure = zeros(1,nfreq);
P_refG = zeros(N_PW,nfreq);
P_trG = zeros(N_PW,nfreq); 
k_zG = zeros(N_PW,nfreq);
Kz = zeros(N_PW, N_PW, nfreq);

for i = 1:nfreq
    % incident wave vectors
    kx = k0(i) * sin(incident.theta) * cos(incident.phi);
    ky = k0(i) * sin(incident.theta) * sin(incident.phi);
    kz = k0(i) * cos(incident.theta);

    Kirchoff.K_1p = zeros(N_PW,N_PW);
    Kirchoff.K_2p = zeros(N_PW,N_PW);
    Kirchoff.C_1f = zeros(N_PW,N_PW);
    Kirchoff.C_2f = zeros(N_PW,N_PW);
    Kirchoff.M_1p = zeros(N_PW,N_PW);
    Kirchoff.M_2p = zeros(N_PW,N_PW);
    Kirchoff.D_r11 = zeros(N_PW,N_PW);
    Kirchoff.D_r12 = zeros(N_PW,N_PW);
    Kirchoff.D_r21 = zeros(N_PW,N_PW);
    Kirchoff.D_r22 = zeros(N_PW,N_PW);
    Kirchoff.F1 = zeros(N_PW,1);
    Kirchoff.F2 = zeros(N_PW,1);
    
    % Whether PML is on or off
    for m = 1:N_PW
        kplusG_square = (kx+G(m,1))^2+(ky+G(m,2))^2;
        Kirchoff.K_1p(m,m) = (kplusG_square)^2;
        Kirchoff.K_2p(m,m) = plate.D(2)/plate.D(1)*(kplusG_square)^2;
        Kirchoff.M_1p(m,m) = 1;
        Kirchoff.M_2p(m,m) = (plate.rho(2)*plate.h(2))/(plate.rho(1)*plate.h(1));
    end
    
    % If PML is off
    if nargin == 7
        for m = 1:N_PM
            kplusG_square = (kx+G(m,1))^2+(ky+G(m,2))^2;
            k0square = k0(i)^2;
            if k0square >= kplusG_square
                k_zG(m,i) = sqrt(k0square-kplusG_square);
            else
                k_zG(m,i) = -1i*sqrt(kplusG_square-k0square);
            end
            Kirchoff.C_1f(m,m) = medium.rho*omega(i)/k_zG(m,i);
            Kirchoff.C_2f(m,m) = medium.rho*omega(i)/k_zG(m,i);
            if G(m,1) == 0 && G(m,2) == 0
                Kirchoff.F1(m) = 2*incident.P0;  % No PML
            end
        end
    end

    % If PML is on
    if nargin >= 8 && isstruct(meta) && isfield(meta,'l_PML') && meta.l_PML > 0
        % Convert physical lengths into dimensionless fractions
        meta.l_PML  = meta.l_PML / feature.L0;
        meta.Lx_lens = meta.Lx_lens / feature.L0;
        meta.Ly_lens = meta.Ly_lens / feature.L0; 
        meta.Lx_total = meta.Lx_total / feature.L0;
        meta.Ly_total = meta.Ly_total / feature.L0;
        % PML core
        [Kz(:,:,i), Kirchoff] = PMLbaseFFT(omega(i), G, medium, plate, meta, incident, Kirchoff);
    end


    % resonator
    Dr11 = zeros(resonator.N,1);
    Dr12 = zeros(resonator.N,1);
    Dr21 = zeros(resonator.N,1);
    Dr22 = zeros(resonator.N,1); 
    if resonator.eta ~= 0
        if isvector(resonator.eta)
            damping = 1 + 1i * resonator.eta;
        else
            damping = (1 + 1i * resonator.eta)*ones(resonator.N,1);
        end
    else  % there is no damping, make the variable be 1.
        damping = ones(resonator.N,1);
    end
    for j = 1:resonator.N
        % resonator.m: N column * 2 row
        m1 = resonator.m(1,j);
        m2 = resonator.m(2,j);
        % resonator.k: N column * 3 row
        k1 = resonator.k(1,j)*damping(j);
        k2 = resonator.k(2,j)*damping(j);
        k3 = resonator.k(3,j)*damping(j);

        % cal local dynamic stiffness
        DSA = k1 + k2 - m1*omega(i)^2;
        DSB = k2 + k3 - m2*omega(i)^2;
        % cal dynamic stiffness matrix element
        Dr11(j) = -k1+(k1^2*DSB)/(DSA*DSB-k2^2);
        Dr12(j) = (k1*k2*k3)/(DSA*DSB-k2^2);
        Dr21(j) = Dr12(j);
        Dr22(j) = -k3+(k3^2*DSA)/(DSA*DSB-k2^2);

        Pj = zeros(N_PW,1);
        Pj_prime = zeros(1,N_PW);
        for n = 1:N_PW
            Pj(n,1) = exp(1i*dot(G(n,:),resonator.r(j,:)));
            Pj_prime(1,n) = exp(-1i*dot(G(n,:),resonator.r(j,:)));
        end
        Kirchoff.D_r11 = Kirchoff.D_r11 + Dr11(j)*Pj*Pj_prime;
        Kirchoff.D_r12 = Kirchoff.D_r12 + Dr12(j)*Pj*Pj_prime;
        Kirchoff.D_r21 = Kirchoff.D_r12;
        Kirchoff.D_r22 = Kirchoff.D_r22 + Dr22(j)*Pj*Pj_prime;
    end

    % Solve the Kirchoff equations (Matrix form: A*W=F)
    A11 = Kirchoff.K_1p + 1i*omega(i)*Kirchoff.C_1f - omega(i)^2*Kirchoff.M_1p - Kirchoff.D_r11;
    A12 = -Kirchoff.D_r12;
    A21 = -Kirchoff.D_r21;
    A22 = Kirchoff.K_2p + 1i*omega(i)*Kirchoff.C_2f - omega(i)^2*Kirchoff.M_2p - Kirchoff.D_r22;
    A = [A11 A12; A21 A22];
    F = [Kirchoff.F1; Kirchoff.F2];
    
    if cond(A) < 1e6
        W_G = A \ F;  % cal displacement coefficient
    else
        W_G = MatrixBalanceJacobi(A,F);
    end
    W1_G = W_G(1:N_PW);
    W2_G = W_G(N_PW+1:end);
    
    % If PML is off
    if nargin == 7
        for m = 1:N_PW
            if G(m,1) == 0 && G(m,2) == 0
                P_refG(m,i) = incident.P0 - 1i*medium.rho*omega(i)^2*W1_G(m)/k_zG(m,i);
            else
                P_refG(m,i) = -1i*medium.rho*omega(i)^2*W1_G(m)/k_zG(m,i);
            end
            P_trG(m,i) = 1i*medium.rho*omega(i)^2*W2_G(m)*exp(-1i*k_zG(m,i)*plate.d)/k_zG(m,i);
            alpha_power(i) = alpha_power(i) + abs(P_refG(m))^2*k_zG(m,i);
            tau_pressure(i) = tau_pressure(i) + P_trG(m,i)*real(k_zG(m,i));
            tau_power(i) = tau_power(i) + abs(P_trG(m,i))^2*real(k_zG(m,i));
        end
        tau_pressure = tau_pressure / (incident.P0 * kz);
        tau_power = tau_power / (abs(incident.P0)^2 * kz);
    end

    % If PML is on
    if nargin >= 8 && isstruct(meta) && isfield(meta,'l_PML') && meta.l_PML > 0
        % 1. Incident Wave Vector (From Sinc aperture distribution)
        % Kirchoff.F1 is 2 * P_inc, so we divide by 2 to isolate the incident field
        P_inc_vec = Kirchoff.F1 / 2;

        % 2. Reflection Coefficient (Matches Formula 35)
        % P_ref = P_inc - (i * rho * omega^2 / Kz) * W1
        P_refG_vec = P_inc_vec - 1i * medium.rho * omega(i)^2 * (Kz \ W1_G);
        
        % 3. Transmission Coefficient (Matches Formula 36)
        % P_tr = (i * rho * omega^2 / Kz) * W2 * exp(-i * Kz * d)
        % First, compute the pressure exactly at the bottom plate:
        P_trG_vec = 1i * medium.rho * omega(i)^2 * (Kz \ W2_G);
        
%         % Second, apply the formal matrix exponential phase projection (exp(-i*Kz*d)):
%         [V_kz, D_kz] = eig(Kz);
%         lambda_kz_prop = diag(D_kz);
%         P_trG_vec = V_kz * (exp(1i * lambda_kz_prop * plate.d) .* (V_kz \ P_surf2));

        % Store the exact theoretical vectors
        P_refG(:, i) = P_refG_vec;
        P_trG(:, i)  = P_trG_vec;

        % 4. Power Metrics using the Hermitian Inner Product (P' * Kz * P)
        kz_inc = k0(i) * cos(incident.theta);
        
        alpha_power(i) = real(P_refG_vec' * Kz * P_refG_vec) / (abs(incident.P0)^2 * kz_inc);
        tau_power(i)   = real(P_trG_vec' * Kz * P_trG_vec)   / (abs(incident.P0)^2 * kz_inc);
    end
end




% Restore the dimensions of the output physical quantities (ensuring that the main program uses dimensional quantities, while the calculations within this function use dimensionless quantities)
W2_G = W2_G*feature.L0;
Kz = Kz.*feature.k0;
G = G/feature.L0;




