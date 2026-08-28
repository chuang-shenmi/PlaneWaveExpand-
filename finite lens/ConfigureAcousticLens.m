function [focus] = ConfigureAcousticLens(focus, k0)
    % ConfigureAcousticLens automatically determines the lens type and 
    % generates the phase targets and PML configurations based on the focal target.
    %
    % Inputs:
    % focal_target: [x, y, z] target coordinate. (Use NaN for infinite/uniform axes).
    % Lx_lens, Ly_lens: Active dimensions of the metasurface.
    % l_PML, zeta_max: PML parameters.
    % k0: Background wavenumber.
  
    
    xf = focus.target(1);
    yf = focus.target(2);
    zf = focus.target(3);
    
    % --- 1. AUTOMATIC LENS TYPE DETERMINATION ---
    if isnan(xf) && ~isnan(yf)
        focus.type = '1D_Y'; % Focuses to a line along the X-axis
    elseif ~isnan(xf) && isnan(yf)
        focus.type = '1D_X'; % Focuses to a line along the Y-axis
    elseif ~isnan(xf) && ~isnan(yf)
        focus.type = '2D';   % Focuses to a point
    else
        error('Invalid focal target. At least one transverse axis (x or y) must be specified.');
    end
    
    % --- 2. AUTOMATIC LATTICE SIZING ---
    % Only add PML width to the axes where the phase actually varies
    if strcmp(focus.type, '1D_X') || strcmp(focus.type, '2D')
        focus.Lx_total = focus.Lx_lens + 2 * focus.l_PML;
    else
        focus.Lx_total = focus.Lx_lens; % No PML in X
    end
    
    if strcmp(focus.type, '1D_Y') || strcmp(focus.type, '2D')
        focus.Ly_total = focus.Ly_lens + 2 * focus.l_PML;
    else
        focus.Ly_total = focus.Ly_lens; % No PML in Y
    end
    
    % --- 3. PHASE DISTRIBUTION GENERATOR (Optional but highly recommended) ---
    % It is mathematically cleaner to let this function generate an anonymous 
    % function for the required phase profile, which you can evaluate anywhere.
    switch focus.type
        case '1D_X'
            focus.phase_func = @(x,y) k0 * (sqrt((x-xf).^2 + zf^2) - zf);
        case '1D_Y'
            focus.phase_func = @(x,y) k0 * (sqrt((y-yf).^2 + zf^2) - zf);
        case '2D'
            focus.phase_func = @(x,y) k0 * (sqrt((x-xf).^2 + (y-yf).^2 + zf^2) - zf);
    end
end