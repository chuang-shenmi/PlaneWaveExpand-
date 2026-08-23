function G = ReciprocalVectors(R, M)
% 根据正格矢R和截断阶数M生成倒格矢G
[num,dim] = size(R);
if num ~= dim
    error("正格子基矢量个数与维度不一致！")
end

G = zeros((2*M+1)^dim,dim);
cnt = 1;
if dim == 1
    a = R;
    b = 2*pi/a;
    for m = -M:M
        G(cnt) = m*b;
        cnt = cnt + 1;
    end
end
if dim == 2
    a1 = R(1,:);
    a2 = R(2,:);
    if det(R) == 0
        b1 = [2*pi/a1(1) 0];
        b2 = [0 2*pi/a2(2)];
    else
        b1 = [2*pi*a2(2)/(-a2(1)*a1(2)+a1(1)*a2(2)) 2*pi*a2(1)/(a2(1)*a1(2)-a1(1)*a2(2))];
        b2 = [2*pi*a1(2)/(a2(1)*a1(2)-a1(1)*a2(2)) 2*pi*a1(1)/(-a2(1)*a1(2)+a1(1)*a2(2))];
    end
    for m = -M:M
        for n = -M:M
            G(cnt,:) = m*b1+n*b2;
            cnt = cnt + 1;
        end
    end
end
if dim == 3  % 三维暂未开发
    error("三维暂未开发")
    %             a1 = R(1,:);
    %             a2 = R(2,:);
    %             a3 = R(3,:);
    %             for p = -M:M
    %
    %             end
end
