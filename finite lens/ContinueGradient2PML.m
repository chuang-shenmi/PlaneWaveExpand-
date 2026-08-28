function [m_selected, k_selected, tau_selected, phi_selected] = ContinueGradient2PML(focus, lattice, m_selected, k_selected, tau_selected, phi_selected, k, m, tau_p, phi)

% ContinueGradient2PML pads the edges of the active metasurface by
% assigning physical unit cells to the PML region that smoothly continue 
% the theoretical phase gradient (focus.phase_func), preventing kinematic shear.
%
% Inputs:
%   focus, lattice: Structs containing geometry and phase target function.
%   m_selected, k_selected, tau_selected, phi_selected: Matrices of the ACTIVE lens parameters.
%   k, m, tau_p, phi: The complete discrete dataset from the PWE sweep.
%
% Outputs:
%   Padded parameter matrices representing the full supercell.

    N_PML_units = round(focus.l_PML / lattice.a);
    if N_PML_units == 0
        return; % No PML padding required
    end
    
    % Adjust internal PML length to perfectly match discrete units
    focus.l_PML = lattice.a * N_PML_units;

    % ---------------------------------------------------------
    % Pad X-axis (Left and Right edges)
    % ---------------------------------------------------------
    if strcmp(focus.type, '1D_X') || strcmp(focus.type, '2D')
        
        % 1. Define the coordinates of the PML units extending outward
        % The active lens boundary is at Lx_lens/2. The PML units start just outside it.
        x_right_PML = linspace(focus.Lx_lens/2 + lattice.a/2, ...
                               focus.Lx_lens/2 + lattice.a/2 + (N_PML_units-1)*lattice.a, ...
                               N_PML_units);
                           
        x_left_PML = linspace(-focus.Lx_lens/2 - lattice.a/2 - (N_PML_units-1)*lattice.a, ...
                              -focus.Lx_lens/2 - lattice.a/2, ...
                              N_PML_units);

        % 2. Preallocate the padding arrays
        % Since we are currently doing 1D line focusing along X, the Y dimension is 1.
        % If '2D', we would need to evaluate Y_active. For now, we assume Y=0.
        pad_m_left = zeros(1, N_PML_units);
        pad_k_left = zeros(1, N_PML_units);
        pad_tau_left = zeros(1, N_PML_units);
        pad_phi_left = zeros(1, N_PML_units);
        
        pad_m_right = zeros(1, N_PML_units);
        pad_k_right = zeros(1, N_PML_units);
        pad_tau_right = zeros(1, N_PML_units);
        pad_phi_right = zeros(1, N_PML_units);
        
        % 3. Inverse Design for the Left PML Padding
        for i = 1:N_PML_units
            target_phase_L = mod(focus.phase_func(x_left_PML(i), 0), 2*pi);
            
            % Circular phase wrapping logic
            diff_phase = mod(phi(:) - target_phase_L, 2*pi);
            diff_phase = min(diff_phase, 2*pi - diff_phase);
            
            % Apodization guardrail (Demand high transmission)
            transmission_penalty = zeros(size(tau_p(:)));
            transmission_penalty(tau_p(:) < 0.7) = 100;
            
            % Composite cost function
            cost = diff_phase + 2.0 * (1 - tau_p(:)) + transmission_penalty;
            
            [~, min_idx] = min(cost);
            pad_m_left(i) = m(min_idx);
            pad_k_left(i) = k(min_idx);
            pad_tau_left(i) = tau_p(min_idx);
            pad_phi_left(i) = phi(min_idx);
        end
        
        % 4. Inverse Design for the Right PML Padding
        for i = 1:N_PML_units
            target_phase_R = mod(focus.phase_func(x_right_PML(i), 0), 2*pi);
            
            diff_phase = mod(phi(:) - target_phase_R, 2*pi);
            diff_phase = min(diff_phase, 2*pi - diff_phase);
            
            transmission_penalty = zeros(size(tau_p(:)));
            transmission_penalty(tau_p(:) < 0.7) = 100;
            cost = diff_phase + 2.0 * (1 - tau_p(:)) + transmission_penalty;
            
            [~, min_idx] = min(cost);
            pad_m_right(i) = m(min_idx);
            pad_k_right(i) = k(min_idx);
            pad_tau_right(i) = tau_p(min_idx);
            pad_phi_right(i) = phi(min_idx);
        end

        % 5. Assemble the final matrices horizontally
        m_selected = [pad_m_left, m_selected, pad_m_right];
        k_selected = [pad_k_left, k_selected, pad_k_right];
        tau_selected = [pad_tau_left, tau_selected, pad_tau_right];
        phi_selected = [pad_phi_left, phi_selected, pad_phi_right];
    end

    % ---------------------------------------------------------
    % Pad Y-axis (Top and Bottom edges)
    % ---------------------------------------------------------
    if strcmp(focus.type, '1D_Y') || strcmp(focus.type, '2D')
        % To be implemented if you expand to 2D Point Focusing.
        % The logic will exactly mirror the X-axis logic, but operating
        % vertically over the columns of the matrices instead of the rows.
        disp('Warning: Y-axis phase continuation padding is not yet implemented.');
    end
end