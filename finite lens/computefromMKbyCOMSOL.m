function [para_list] = computefromMKbyCOMSOL(data_file, M)
% Calculate the transmittance and phase of a manufacturable structure by reading the equivalent mass and stiffness parameters computed by COMSOL using scanned geometric parameters.
% This function is currently unsafe, as many of its default parameters cannot be modified; use with caution.

% INPUT:
%        data_file: Where are COMSOL calculation results stored, including filenames
%        M：Expansion Order (default value: 5)

% OUTPUT：
%         para_list: Structure containing three geometric parameters of the scan, equivalent mass, equivalent stiffness, transmittance, and transmission phase


if nargin == 1
    M = 5;
end


comsol_result = load(data_file);
% Let's take a different approach here: substitute the calculated values of K and M into the PWE theory for the calculation to avoid the compression of similar values.
mlist = comsol_result.M;
klist = comsol_result.K;
para_list.hmass = comsol_result.hmass_list;
para_list.wmass = comsol_result.wmass_list;
para_list.wspring = comsol_result.wspring_list;

%% Plate Parameter
plate.rho = [7700 7700];  % density kg/m^3
plate.E = [200e9 200e9];  % Young's Modulus Pa
plate.niu = [0.3 0.3];  % Poission ratio
plate.h = [0.005 0.005];  % thickness m
plate.d = 0.04;  % distance between two plates m
plate.eta = 0;  % damping factor


%% Lattice parameter
lattice.a = 0.042;  % lattice constant m
lattice.a1 = [lattice.a 0];  % lattice basis vector 1
lattice.a2 = [0 lattice.a];  % lattice basis vector 2


%% Medium parameter
medium.rho = 1000;  % density kg/m^3
medium.c0 = 1500;  % sound speed m/s


%% Incident parameter
incident.theta = 0*pi/180;  % Elevation Angle rad
incident.phi = 0*pi/180;  % Azimuth rad
incident.P0 = 10;  % Amplitute  Pa

freq = 10e3;  % Frequency Hz


%% PWE core
tau = zeros(length(klist),1);
phi = zeros(length(klist),1);
tau_p = zeros(length(klist),1);
stl = zeros(length(klist),1);
W2_G = zeros(length(klist),(2*M+1)^2);
k_zG = zeros(length(klist),(2*M+1)^2);

% In the `resonator` parameter matrix, while the number of rows for the position coordinates depends only on the number of resonators in a lattice, the number of columns in the stiffness matrix and mass matrix depends on the number of resonators in a lattice, and the number of rows depends on the number of masses and springs within a single resonator.
last_percent = 0; % Records the percentage of the previous output
for i = 1:length(klist)
        %% Resonator parameter
        resonator.N = 1;
        resonator.k = [klist(i);
                       klist(i)*0.5;
                       klist(i)];
        resonator.m = [mlist(i);
                       mlist(i);];
        resonator.r = [0 0;];
        resonator.eta = [0];
        [tau_power, tau_pressure, W2_Gout, k_zGout] = PWE4PlateResonatorPlateDimlessNDOF2(plate,resonator,lattice,medium,incident,M,freq);
        stl(i) = 10*log10(1./tau_power);
        tau_p(i) = tau_power;
        tau(i) = abs(tau_pressure);
        if angle(tau_pressure) > 0
            phi(i) = angle(tau_pressure);
        else
            phi(i) = angle(tau_pressure)+2*pi;
        end
        W2_G(i,:) = W2_Gout;
        k_zG(i,:) = k_zGout;
        current_iter = i;
        percent = floor(current_iter/length(mlist)*100);
        if percent > last_percent
            fprintf('已完成：%d%%\n', percent);
            last_percent = percent;
        end
end

para_list.m = mlist;
para_list.k = klist;
para_list.tau = tau;
para_list.tau_p = tau_p;
para_list.phi = phi;
