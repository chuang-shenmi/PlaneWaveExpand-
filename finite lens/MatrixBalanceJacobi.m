function [x]=MatrixBalanceJacobi(A,b)
% Balance the matrix through Jacobi preconditioning to reduce the condition number of matrix A
% input: A is a square matrix, which can be expressed as A = L + D + L^T,
%        then the preconditioning matrix M = D in Jacobi preconditioning.
%        The equation to be solved is Ax=b.
% output: x is the solution of Ax=b.

[m,n] = size(A);
if m ~= n
    error("A不是一个方阵!")
end
m = length(b);
if m ~= n
    error("A和b的维度不一致，无法形成方程")
end

% 构建对角缩放（Diagonal Scaling）法所需对角矩阵
D = zeros(n,n);
for i = 1:n
    D(i,i) = 1/sqrt(max(abs(A(i,i)),realmin));  % 为防止A对角线元素过小出现除以0的情况，取机器精度和对角元中最大值
end

% 建立并求解等价方程 A_hat*x_hat=b_hat
A_hat = D*A*D;
b_hat = D*b;
x_hat = A_hat \ b_hat;

% 将解还原回x
x = D*x_hat;