function ParameterCheck(resonator, lattice, plate)

if size(resonator.k,2) ~= resonator.N
    % 弹性系数矩阵的元素个数不能和谐振器数量匹配
    if size(resonator.k,2) == 1  % 所有弹簧弹性系数相同
        resonator.k = resonator.k*ones(1,resonator.N);
    else
        error("谐振器数量或弹簧刚度矩阵有误！")
    end
end
if size(resonator.k,1) ~= size(resonator.m,1) + 1
    error("物理模型要求弹簧数量始终比质量数量多一，请检查！")
end
if size(resonator.m,2) ~= resonator.N
    % 质量矩阵的元素个数不能和谐振器数量匹配
    if size(resonator.m,2) == 1  % 所有振子质量相同
        resonator.m = resonator.m*ones(1,resonator.N);
    else
        error("谐振器数量或振子质量矩阵有误！")
    end
end
if size(resonator.r,2) ~= length(lattice.a1)
    % 谐振器附着点坐标有误
    error("谐振器附着点位置坐标矩阵有误！")
end
if size(resonator.r,1) ~= resonator.N
    % 谐振器坐标组数量与谐振器数量不匹配
    error("谐振器坐标组数量不足！")
end
if plate.d <= (plate.h(1)+plate.h(2))/2
    error("两板间隔过小，几何存在干涉！")
end