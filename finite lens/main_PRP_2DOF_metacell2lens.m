%% plate parameter
tic
plate.rho = [7700 7700];  % mass density of plate  kg/m^3
plate.E = [200e9 200e9];  % Young's Modulus of plate Pa
plate.niu = [0.3 0.3];  % Possion ratio of plate
plate.h = [0.005 0.005];  % Thickness of plate m
plate.d = 0.04;  % Distance between two plates m
plate.eta = 0;  % 板的损耗因子


%% lattice parameter
lattice.a = 0.042;  % 晶格常数 m
lattice.a1 = [lattice.a 0];  % 晶格基矢量1
lattice.a2 = [0 lattice.a];  % 晶格基矢量2


%% propagation medium parameter
medium.rho = 1000;  % 水的密度 kg/m^3
medium.c0 = 1500;  % 水中声速 m/s


%% Incident wave parameter
incident.theta = 0*pi/180;  % 仰角 rad
incident.phi = 0*pi/180;  % 方位角 rad
incident.P0 = 10;  % Amplitute  Pa

freq = 10e3;  % frequeny Hz
lambda = medium.c0/freq;  % wavelength m
omega = 2*pi*freq;


%% Focus parameter
k0 = omega/medium.c0;  % wave number
focus.target = [0, NaN, 0.15];  % 设定聚焦目标，NaN in Y means "Line Focus along Y-axis" ('1D_X')
focus.l_PML = lambda;  % set the length of PML as long as wavelength
focus.l_PML = lattice.a * round(focus.l_PML / lattice.a);  % Since the length of the PML must be an integer multiple of the lattice length, adjust its length.
focus.Lx_lens = lattice.a*17;
focus.Ly_lens = lattice.a;
focus.zeta_max = 8;

focus = ConfigureAcousticLens(focus, k0);
lattice.a1 = [focus.Lx_total, 0];
lattice.a2 = [0, focus.Ly_total];
% 直接扫描m和k的计算结果
% parasweep_result = load('Fe_2DOF_10kHz_a0.042h0.005d0.04.mat','k','m','tau_p','phi');
% [k_selected,m_selected,tau_selected,phi_selected,r_selected] = SelectOptimalResonators(focus, lattice, parasweep_result.k, parasweep_result.m, parasweep_result.tau_p, parasweep_result.phi);
% 读取comsol通过有限元计算的m和k列表并计算得到结果
data_file = 'E:\01 study\Plane Wave Expand Method\effective mass and stiffness\Rayleigh10kHz.mat';
para_list = computefromMKbyCOMSOL(data_file);
[para_selected] = SelectOptimalResonatorsCOMSOL(focus, lattice, para_list);


%% 平面波展开法计算透射系数
M = 35;  % 平面波截断阶数


% resonator中的参数矩阵，除位置坐标行数仅与一个晶格内谐振器的数量有关外，弹性系数矩阵和质量矩阵的列数与一个晶格内谐振器数量有关，而行数与一个谐振器内有几个质量和弹簧有关。
%% 谐振器参数
resonator.N = length(para_selected.k);  % 一个晶格内谐振器的数量
%        % 优化前，仅挑选单胞相位梯度
resonator.k = [para_selected.k;
               para_selected.k*0.5;
               para_selected.k];  % 弹簧的弹性系数矩阵
resonator.m = [para_selected.m;
               para_selected.m];  % 振子的质量矩阵
resonator.r = para_selected.r;  % 振子在晶格内的位置
resonator.eta = [0];  % 谐振器的损耗因子

[tau_power, tau_pressure, W2_Gout, k_zGout, G, feature] = PWE4PlateResonatorPlateDimless2DOF_PML(plate,resonator,lattice,medium,incident,M,freq,focus);
stl = 10*log10(1./tau_power);
tau_p = tau_power;
tau = abs(tau_pressure);
if angle(tau_pressure) > 0
    phi = angle(tau_pressure);
else
    phi = angle(tau_pressure)+2*pi;
end
W2_G = W2_Gout;
k_zG = k_zGout;


% % 绘制透射声场区域
x = -focus.Lx_total/2:0.005:focus.Lx_total/2;
y = -0.6:0.015:0.6;
z = 0:0.005:9*lambda;  % 从下板以下开始计算
[xx,zzx] = meshgrid(x,z);
[yy,zzy] = meshgrid(y,z);
field.x = xx;
% field.y = yy;
field.z = zzx;
for f = 1:length(freq)
    f0 = freq(f);
    omega = 2*pi*f0;
    k0 = omega/medium.c0;
    % 入射波矢量
    kx = k0 * sin(incident.theta) * cos(incident.phi);
    ky = k0 * sin(incident.theta) * sin(incident.phi);
    kz = k0 * cos(incident.theta);
    k = [kx ky kz];
    P_trG_numerator = 1i*medium.rho*omega^2;  % 这部分与倒易空间G无关，直接计算
%     field.y = zeros(size(field.y));
    % 使用前请注意修改内部的x或y为常数，看计算的平面
    P_tr = GenTransmissionField(W2_G, G, k_zG, k, field, P_trG_numerator, 0);
    figure("Name",sprintf("Transmission Field (freq = %d Hz, M = %d)",f0,M))
    surf(xx,zzx,abs(P_tr))
    view([-180 90])
    shading interp
    colormap jet
    xlabel('x/m')
    ylabel('z/m')
end


% 绘制焦点截线声压分布
linez_point = length(z);
linez = [zeros(linez_point,1) zeros(linez_point,1) z'];
linex_point = length(x);
linex = [x' zeros(linex_point,1) ones(linex_point,1)*focus.target(3)];
Ptr_line.z = GenTransmissionField(W2_G, G, k_zG, k, linez, P_trG_numerator, 1);
Ptr_line.x = GenTransmissionField(W2_G, G, k_zG, k, linex, P_trG_numerator, 1);
figure("Name",sprintf("Pressure on focal point line z (freq = %d Hz, M = %d)",f0,M))
plot(z,abs(Ptr_line.z))
figure("Name",sprintf("Pressure on focal point line x (freq = %d Hz, M = %d)",f0,M))
plot(x,abs(Ptr_line.x))


toc
% Note: passing 'resonator.k' instead of 'k1'
% [m_opt, k_opt, cost_opt] = AnomalousRefractionOptimization2DOF(plate, medium, incident, freq, M, lattice, resonator.m, resonator.k, resonator.r);