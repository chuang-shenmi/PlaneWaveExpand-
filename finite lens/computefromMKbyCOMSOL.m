function [para_list] = computefromMKbyCOMSOL(data_file, M)
% 通过读取comsol扫描几何参数计算出来的等效质量和刚度参数，计算可制造的结构的透射率和相位
% 该函数目前不安全，存在大量默认参数不可修改，调用需谨慎

% INPUT:
%        data_file: comsol计算结果的存储位置，带文件名
%        M：平面波展开阶数（默认值为5）

% OUTPUT：
%         para_list: 结构体，包含扫描的三个几何参数，等效质量，等效刚度，透射率，透射相位


if nargin == 1
    M = 5;
end


comsol_result = load(data_file);
% 这里换一个思路，用计算出来的K和M带入到PWE理论中去计算，以免相近值被压缩。
mlist = comsol_result.M;
klist = comsol_result.K;
para_list.hmass = comsol_result.hmass_list;
para_list.wmass = comsol_result.wmass_list;
para_list.wspring = comsol_result.wspring_list;

%% 板参数
plate.rho = [7700 7700];  % 板的密度 kg/m^3
plate.E = [200e9 200e9];  % 板的杨氏模量 Pa
plate.niu = [0.3 0.3];  % 板的泊松比
plate.h = [0.005 0.005];  % 板的厚度 m
plate.d = 0.04;  % 上下两板间的距离 m
plate.eta = 0;  % 板的损耗因子


%% 晶格参数
lattice.a = 0.042;  % 晶格常数 m
lattice.a1 = [lattice.a 0];  % 晶格基矢量1
lattice.a2 = [0 lattice.a];  % 晶格基矢量2


%% 传播介质参数
medium.rho = 1000;  % 水的密度 kg/m^3
medium.c0 = 1500;  % 水中声速 m/s


%% 入射波参数
incident.theta = 0*pi/180;  % 仰角 rad
incident.phi = 0*pi/180;  % 方位角 rad
incident.P0 = 10;  % 幅值  Pa

freq = 10e3;  % 入射波频率 Hz


%% 平面波展开法计算透射系数
tau = zeros(length(klist),1);
phi = zeros(length(klist),1);
tau_p = zeros(length(klist),1);
stl = zeros(length(klist),1);
W2_G = zeros(length(klist),(2*M+1)^2);
k_zG = zeros(length(klist),(2*M+1)^2);

% resonator中的参数矩阵，除位置坐标行数仅与一个晶格内谐振器的数量有关外，弹性系数矩阵和质量矩阵的列数与一个晶格内谐振器数量有关，而行数与一个谐振器内有几个质量和弹簧有关。
last_percent = 0; % 记录上一次输出的百分比
for i = 1:length(klist)
        %% 谐振器参数
        resonator.N = 1;  % 一个晶格内谐振器的数量
        resonator.k = [klist(i);
                       klist(i)*0.5;
                       klist(i)];  % 弹簧的弹性系数矩阵
        resonator.m = [mlist(i);
                       mlist(i);];  % 振子的质量矩阵
        resonator.r = [0 0;];  % 振子在晶格内的位置
        resonator.eta = [0];  % 谐振器的损耗因子

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
        percent = floor(current_iter/length(mlist)*100);  % 当前百分比（整数）
        % 当百分比变化时输出一次
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


% % 绘制透射率和透射相位与弹性系数和质量的关系图
% [m,k] = meshgrid(mlist,klist);
% figure()
% surf(m,k,tau)
% ax1 = gca;
% view([0 90])
% shading interp
% colorbar
% xlabel('mass/kg')
% ylabel('stiffness/Nm^{-1}')
% figure()
% surf(m,k,phi)
% ax2 = gca;
% view([0 90])
% shading interp
% colorbar
% xlabel('mass/kg')
% ylabel('stiffness/Nm^{-1}')
