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
lattice.a2 = [0 4*lattice.a];  % 晶格基矢量2


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


%% Grating parameter
k0 = omega/medium.c0;  % wave number
grating.type = '1D_X';  % Since refraction doesn't provide a focal point, manually set the PML working mode.
grating.zeta_max = 10;  % PML damping strength max
grating.mlist = [0.049 0.017 0.073 0.049];
grating.klist = [4.3768e8 3.3455e7 1.6469e8 1.9081e8];
N_period = 5;  % Repeat the supercell to create a finite metasurface
grating.mlist = repmat(grating.mlist, 1, N_period);
grating.klist = repmat(grating.klist, 1, N_period);
grating.l_PML = lambda;  % set the length of PML as long as wavelength
grating.l_PML = lattice.a * round(grating.l_PML / lattice.a);  % Since the length of the PML must be an integer multiple of the lattice length, adjust its length.
N_PML_units = round(grating.l_PML/lattice.a);
m_selected = [repmat(grating.mlist(1), 1, N_PML_units), grating.mlist, repmat(grating.mlist(end), 1, N_PML_units)];
k_selected = [repmat(grating.klist(1), 1, N_PML_units), grating.klist, repmat(grating.klist(end), 1, N_PML_units)];
grating.Lx_lens = lattice.a*length(grating.mlist);
grating.Ly_lens = lattice.a;
grating.Lx_total = lattice.a * length(m_selected);
grating.Ly_total = lattice.a;

% Update lattice vectors for the total, massive computational domain
lattice.a1 = [grating.Lx_total, 0];
lattice.a2 = [0, grating.Ly_total];

% Generate coordinates for all resonators (centered around x = 0)
N_total = length(m_selected);
x_pos = (-(N_total-1)/2 : 1 : (N_total-1)/2) * lattice.a;
r_selected = [x_pos', zeros(N_total, 1)];

%% 平面波展开法计算透射系数
M = 50;  % 平面波截断阶数


% resonator中的参数矩阵，除位置坐标行数仅与一个晶格内谐振器的数量有关外，弹性系数矩阵和质量矩阵的列数与一个晶格内谐振器数量有关，而行数与一个谐振器内有几个质量和弹簧有关。
%% 谐振器参数
resonator.N = length(k_selected);  % 一个晶格内谐振器的数量
%        % 优化前，仅挑选单胞相位梯度
resonator.k = [k_selected;
               k_selected*0.5;
               k_selected];  % 弹簧的弹性系数矩阵
resonator.m = [m_selected;
               m_selected];  % 振子的质量矩阵
resonator.r = r_selected;  % 振子在晶格内的位置
resonator.eta = [0];  % 谐振器的损耗因子

[tau_power, tau_pressure, W2_Gout, k_zGout, G, feature] = PWE4PlateResonatorPlateDimless2DOF_Matrix(plate,resonator,lattice,medium,incident,M,freq,grating);
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
x = -grating.Lx_total/2:0.005:grating.Lx_total/2;
y = -grating.Ly_total/2:0.005:grating.Ly_total/2;
z = plate.d:0.005:grating.Lx_total;  % 从下板以下开始计算
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
    % P_tr = GenTransmissionField(W2_G, G, k_zG, k, field, P_trG_numerator, plate.d, 0);
    % P_tr = GenTransmissionField_Matrix(W2_G, G, k_zG, k, field, P_trG_numerator, plate.d);
    P_tr = GenTransmissionField_PML(W2_G, G, k_zG, k, field, P_trG_numerator, 0);
    figure("Name",sprintf("Transmission Field (freq = %d Hz, M = %d, zeta = %d)",f0,M,grating.zeta_max))
    surf(xx,zzx,real(P_tr))
    view([-180 90])
    shading interp
    colormap jet
    xlabel('x/m')
    ylabel('z/m')
end

toc
% Note: passing 'resonator.k' instead of 'k1'
% [m_opt, k_opt, cost_opt] = AnomalousRefractionOptimization2DOF(plate, medium, incident, freq, M, lattice, resonator.m, resonator.k, resonator.r);