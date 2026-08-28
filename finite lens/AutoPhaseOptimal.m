function [target_phase_wrapped, phase_offset] = AutoPhaseOptimal(target_phase_continuous, phi, tau_p, min_transmission_threshold)
% AutoPhaseOptimal searches the phase origin which gives the best compromise
% between phase matching and high transmission for the manufacturable data.

if nargin < 4
    min_transmission_threshold = 0.7;
end

phi = phi(:);
tau_p = tau_p(:);
valid_idx = isfinite(phi) & isfinite(tau_p);
if ~any(valid_idx)
    error('AutoPhaseOptimal: no valid COMSOL transmission data.');
end
phi = mod(phi(valid_idx), 2*pi);
tau_p = tau_p(valid_idx);
high_tau_idx = tau_p >= min_transmission_threshold;
if ~any(high_tau_idx)
    high_tau_idx = true(size(tau_p));
end

% The phase origin is a constant phase and therefore does not change focusing.
phase_offset_list = linspace(0, 2*pi, 721);
phase_offset_list(end) = [];
cost_list = zeros(size(phase_offset_list));
for i = 1:length(phase_offset_list)
    target_phase = mod(target_phase_continuous(:) + phase_offset_list(i), 2*pi);
    phase_error = zeros(size(target_phase));
    tau_selected = zeros(size(target_phase));
    for j = 1:length(target_phase)
        phase_difference = abs(angle(exp(1i*(phi-target_phase(j)))));
        phase_difference(~high_tau_idx) = inf;
        [phase_error(j), min_idx] = min(phase_difference);
        tau_selected(j) = tau_p(min_idx);
    end
    cost_list(i) = mean(phase_error.^2) + 0.2*mean((1-tau_selected).^2);
end

[~, min_idx] = min(cost_list);
phase_offset = phase_offset_list(min_idx);
target_phase_wrapped = mod(target_phase_continuous + phase_offset, 2*pi);
end
