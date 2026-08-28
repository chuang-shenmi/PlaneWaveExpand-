function [m_selected, k_selected, tau_selected, phi_selected] = CopyOutermostUnit2PML(focus, lattice, m_selected, k_selected, tau_selected, phi_selected)

% The PML works best if the resonators "spill" into it smoothly. 
% We pad the edges by copying the outermost active unit cells into the PML region.
N_PML_units = round(focus.l_PML / lattice.a);
% Because rounding errors can occur here, adjust the length of the PML.
focus.l_PML = lattice.a*N_PML_units;

% Pad X-axis (Left and Right edges)
if strcmp(focus.type, '1D_X') || strcmp(focus.type, '2D')
    m_selected = [repmat(m_selected(:, 1), 1, N_PML_units), m_selected, repmat(m_selected(:, end), 1, N_PML_units)];
    k_selected = [repmat(k_selected(:, 1), 1, N_PML_units), k_selected, repmat(k_selected(:, end), 1, N_PML_units)];
    tau_selected = [repmat(tau_selected(:, 1), 1, N_PML_units), tau_selected, repmat(tau_selected(:, end), 1, N_PML_units)];
    phi_selected = [repmat(phi_selected(:, 1), 1, N_PML_units), phi_selected, repmat(phi_selected(:, end), 1, N_PML_units)];
end

% Pad Y-axis (Top and Bottom edges)
if strcmp(focus.type, '1D_Y') || strcmp(focus.type, '2D')
    m_selected = [repmat(m_selected(1, :), N_PML_units, 1); m_selected; repmat(m_selected(end, :), N_PML_units, 1)];
    k_selected = [repmat(k_selected(1, :), N_PML_units, 1); k_selected; repmat(k_selected(end, :), N_PML_units, 1)];
    tau_selected = [repmat(tau_selected(1, :), N_PML_units, 1); tau_selected; repmat(tau_selected(end, :), N_PML_units, 1)];
    phi_selected = [repmat(phi_selected(1, :), N_PML_units, 1); phi_selected; repmat(phi_selected(end, :), N_PML_units, 1)];
end
