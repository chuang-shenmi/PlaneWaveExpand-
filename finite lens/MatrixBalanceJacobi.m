function [x]=MatrixBalanceJacobi(A,b)
% Balance the matrix through Jacobi preconditioning to reduce the condition number of matrix A
% input: A is a square matrix, which can be expressed as A = L + D + L^T,
%        then the preconditioning matrix M = D in Jacobi preconditioning.
%        The equation to be solved is Ax=b.
% output: x is the solution of Ax=b.

[m,n] = size(A);
if m ~= n
    error("A is not square!")
end
m = length(b);
if m ~= n
    error("The dimensions of A and b do not match, so an equation cannot be formed.")
end

% Constructing the diagonal matrix required for the diagonal scaling method
D = zeros(n,n);
for i = 1:n
    D(i,i) = 1/sqrt(max(abs(A(i,i)),realmin)); % To prevent division by 0 due to the diagonal elements of A being too small, use machine precision and the maximum value among the diagonal elements
end

% Formulate and solve the equivalent equation A_hat*x_hat = b_hat
A_hat = D*A*D;
b_hat = D*b;
x_hat = A_hat \ b_hat;

% Express the solution in terms of x.
x = D*x_hat;
