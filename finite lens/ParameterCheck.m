function ParameterCheck(resonator, lattice, plate)

if size(resonator.k,2) ~= resonator.N
    % The number of elements in the stiffness matrix does not match the number of oscillators.
    if size(resonator.k,2) == 1  % All springs have the same spring constant.
        resonator.k = resonator.k*ones(1,resonator.N);
    else
        error("There is an error in the number of resonators or the spring stiffness matrix!")
    end
end
if size(resonator.k,1) ~= size(resonator.m,1) + 1
    error("The physical model requires that the number of springs always be one more than the number of masses. Please check!")
end
if size(resonator.m,2) ~= resonator.N
    % The number of elements in the mass matrix does not match the number of resonators.
    if size(resonator.m,2) == 1  % All oscillators have the same mass
        resonator.m = resonator.m*ones(1,resonator.N);
    else
        error("There is an error in the number of resonators or the mass matrix of the oscillators!")
    end
end
if size(resonator.r,2) ~= length(lattice.a1)
    % The coordinates of the resonator attachment points are incorrect.
    error("The coordinate matrix for the resonator attachment points is incorrect!")
end
if size(resonator.r,1) ~= resonator.N
    % The number of resonator coordinate sets does not match the number of resonators.
    error("Insufficient number of resonator coordinate sets!")
end
if plate.d <= (plate.h(1)+plate.h(2))/2
    error("The spacing between the two plates is too small, resulting in geometric interference!")
end
