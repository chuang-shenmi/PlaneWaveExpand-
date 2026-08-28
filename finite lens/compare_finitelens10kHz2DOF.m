function out = compare_finitelens10kHz2DOF(para_list)
%
% compare_finitelens10kHz2DOF.m
%
% Model exported on Aug 27 2026, 21:45 by COMSOL 6.2.0.290.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('E:\01 study\Plane Wave Expand Method\finite lens\scangeom');

model.label('compare_finitelens10kHz2DOF.mph');

% 将存储在para_list里的数据转换到参数列表里
N_cell = length(para_list.r);
model.param.group.create('par2');
model.param.label('mass parameter');
model.param('par2').label('spring parameter');
for i = 1:N_cell
    wmass_label = ['wmass', num2str(i)];
    dmass_label = ['dmass', num2str(i)];
    hmass_label = ['hmass', num2str(i)];
    model.param.set(wmass_label, [num2str(para_list.wmass(i)), ' [m]']);
    model.param.set(dmass_label, ['wmass', num2str(i)]);
    model.param.set(hmass_label, [num2str(para_list.hmass(i)), ' [m]']);
    model.param.set(['mmass', num2str(i)], ['rho_Fe*',wmass_label,'*',dmass_label,'*',hmass_label]);
    wspring_label = ['wspring', num2str(i)];
    hspring_label = ['hspring', num2str(i)];
    model.param('par2').set(wspring_label, [num2str(para_list.wspring(i)), ' [m]']);
    model.param('par2').set(hspring_label, ['(d/2-',hmass_label,')/2']);
    model.param('par2').set(['kspring', num2str(i)], ['E_Fe*',wspring_label,'*',wspring_label,'/',hspring_label]);
end
model.param.group.create('par3');
model.param('par3').label('plate medium and incident parameter');
model.param('par3').set('f0', '10e3 [Hz]');
model.param('par3').set('omega', '2*pi[rad]*f0');
model.param('par3').set('rho_Fe', '7700 [kg/m^3]');
model.param('par3').set('nu_Fe', '0.3');
model.param('par3').set('E_Fe', '200 [GPa]');
model.param('par3').set('rho0', '1000 [kg/m^3]');
model.param('par3').set('c0', '1500 [m/s]', 'sound speed in water');
model.param('par3').set('lambda', 'c0/f0');
model.param('par3').set('Z0', 'rho0*c0', 'characteristic impedance of water');
model.param('par3').set('theta', '0 [deg]');
model.param('par3').set('phi', '0 [deg]');
model.param('par3').set('p0', '10 [Pa]');
model.param('par3').set('w_beam', '12*a');
model.param('par3').set('B0', '(E_Fe*t0^3)/(12*(1-nu_Fe^2))', 'Bending stiffness of aluminum plate');
model.param('par3').set('lambdaL', '2*pi*((B0/(rho_Fe*t0*omega^2))^(1/4))', 'bending wave length');
model.param.group.create('par4');
model.param('par4').label('metacell parameter');
model.param('par4').set('N_cell', '25');
model.param('par4').set('d', '0.04 [m]');
model.param('par4').set('a', '0.042 [m]');
model.param('par4').set('t0', '0.005 [m]');


model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.result.table.create('tbl1', 'Table');

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').create('blk1', 'Block');
model.component('comp1').geom('geom1').feature('blk1').label('plate up');
model.component('comp1').geom('geom1').feature('blk1').set('pos', {'-N_cell/2*a' '-a/2' '0'});
model.component('comp1').geom('geom1').feature('blk1').set('size', {'a' 'a' 't0'});
model.component('comp1').geom('geom1').create('blk2', 'Block');
model.component('comp1').geom('geom1').feature('blk2').label('plate bottom');
model.component('comp1').geom('geom1').feature('blk2').set('pos', {'-N_cell/2*a' '-a/2' '-(d+t0)'});
model.component('comp1').geom('geom1').feature('blk2').set('size', {'a' 'a' 't0'});
model.component('comp1').geom('geom1').create('blk3', 'Block');
model.component('comp1').geom('geom1').feature('blk3').label('tranmit domain');
model.component('comp1').geom('geom1').feature('blk3').set('pos', {'-N_cell/2*a' '-a/2' 't0'});
model.component('comp1').geom('geom1').feature('blk3').set('size', {'a' 'a' '10*lambda'});
model.component('comp1').geom('geom1').feature('blk3').set('layername', {[native2unicode(hex2dec({'5c' '42'}), 'unicode') ' 1']});
model.component('comp1').geom('geom1').feature('blk3').setIndex('layer', 'lambda', 0);
model.component('comp1').geom('geom1').feature('blk3').set('layerbottom', false);
model.component('comp1').geom('geom1').feature('blk3').set('layertop', true);
model.component('comp1').geom('geom1').create('blk4', 'Block');
model.component('comp1').geom('geom1').feature('blk4').label('incident domain');
model.component('comp1').geom('geom1').feature('blk4').set('pos', {'-N_cell/2*a' '-a/2' '-(d+t0+3*lambda)'});
model.component('comp1').geom('geom1').feature('blk4').set('size', {'a' 'a' '3*lambda'});
model.component('comp1').geom('geom1').feature('blk4').set('layername', {[native2unicode(hex2dec({'5c' '42'}), 'unicode') ' 1']});
model.component('comp1').geom('geom1').feature('blk4').setIndex('layer', 'lambda', 0);
model.component('comp1').geom('geom1').create('arr1', 'Array');
model.component('comp1').geom('geom1').feature('arr1').set('type', 'linear');
model.component('comp1').geom('geom1').feature('arr1').set('linearsize', N_cell);
model.component('comp1').geom('geom1').feature('arr1').set('displ', {'a' '0' '0'});
model.component('comp1').geom('geom1').feature('arr1').selection('input').set({'blk1' 'blk2' 'blk3' 'blk4'});
for i = 1:N_cell
    spring1_label = ['blk',num2str(5*i)];
    mass1_label = ['blk',num2str(5*i+1)];
    spring2_label = ['blk',num2str(5*i+2)];
    mass2_label = ['blk',num2str(5*i+3)];
    spring3_label = ['blk',num2str(5*i+4)];
    wmass_label = ['wmass', num2str(i)];
    dmass_label = ['dmass', num2str(i)];
    hmass_label = ['hmass', num2str(i)];
    wspring_label = ['wspring', num2str(i)];
    hspring_label = ['hspring', num2str(i)];
    pos_x_off = ((N_cell-1)/2-(i-1));
    spring_pos_x = ['-',wspring_label,'/2-',num2str(pos_x_off),'*a'];
    spring_pos_y = ['-',wspring_label,'/2'];
    spring1_pos_z = ['-',hspring_label];
    spring2_pos_z = ['-(',hspring_label,'+',hmass_label,'+',hspring_label,'*2)'];
    spring3_pos_z = ['-(',hspring_label,'+',hmass_label,'+',hspring_label,'*2+',hmass_label,'+',hspring_label,')'];
    mass_pos_x = ['-',wmass_label,'/2-',num2str(pos_x_off),'*a'];
    mass_pos_y = ['-',wmass_label,'/2'];
    mass1_pos_z = ['-(',hspring_label,'+',hmass_label,')'];
    mass2_pos_z = ['-(',hspring_label,'+',hmass_label,'+',hspring_label,'*2+',hmass_label,')'];
    % spring 1
    model.component('comp1').geom('geom1').create(spring1_label, 'Block');
    model.component('comp1').geom('geom1').feature(spring1_label).label(['spring ',num2str(i),'.1']);
    model.component('comp1').geom('geom1').feature(spring1_label).set('pos', {spring_pos_x spring_pos_y spring1_pos_z});
    model.component('comp1').geom('geom1').feature(spring1_label).set('size', {wspring_label wspring_label hspring_label});
    model.component('comp1').geom('geom1').feature(spring1_label).set('layerbottom', false);
    % mass 1
    model.component('comp1').geom('geom1').create(mass1_label, 'Block');
    model.component('comp1').geom('geom1').feature(mass1_label).label(['mass ',num2str(i),'.1']);
    model.component('comp1').geom('geom1').feature(mass1_label).set('pos', {mass_pos_x mass_pos_y mass1_pos_z});
    model.component('comp1').geom('geom1').feature(mass1_label).set('size', {wmass_label dmass_label hmass_label});
    model.component('comp1').geom('geom1').feature(mass1_label).set('layerbottom', false);
    % spring 2
    model.component('comp1').geom('geom1').create(spring2_label, 'Block');
    model.component('comp1').geom('geom1').feature(spring2_label).label(['spring ',num2str(i),'.2']);
    model.component('comp1').geom('geom1').feature(spring2_label).set('pos', {spring_pos_x spring_pos_y spring2_pos_z});
    model.component('comp1').geom('geom1').feature(spring2_label).set('size', {wspring_label wspring_label [hspring_label,'*2']});
    model.component('comp1').geom('geom1').feature(spring2_label).set('layerbottom', false);
    % mass 2
    model.component('comp1').geom('geom1').create(mass2_label, 'Block');
    model.component('comp1').geom('geom1').feature(mass2_label).label(['mass ',num2str(i),'.2']);
    model.component('comp1').geom('geom1').feature(mass2_label).set('pos', {mass_pos_x mass_pos_y mass2_pos_z});
    model.component('comp1').geom('geom1').feature(mass2_label).set('size', {wmass_label dmass_label hmass_label});
    model.component('comp1').geom('geom1').feature(mass2_label).set('layerbottom', false);
    % spring 3
    model.component('comp1').geom('geom1').create(spring3_label, 'Block');
    model.component('comp1').geom('geom1').feature(spring3_label).label(['spring ',num2str(i),'.3']);
    model.component('comp1').geom('geom1').feature(spring3_label).set('pos', {spring_pos_x spring_pos_y spring3_pos_z});
    model.component('comp1').geom('geom1').feature(spring3_label).set('size', {wspring_label wspring_label hspring_label});
    model.component('comp1').geom('geom1').feature(spring3_label).set('layerbottom', false);
    % 在过去对节点组的使用中，发现该指令会严重拖慢运行速度，因此这里不进行分组
%     % group the components in a resonator
%     grp_label = ['grp',num2str(i)];
%     model.component('comp1').geom('geom1').nodeGroup.create(grp_label);
%     model.component('comp1').geom('geom1').nodeGroup(grp_label).label(['resonator ',num2str(i)]);
%     model.component('comp1').geom('geom1').nodeGroup(grp_label).placeAfter('arr1');
%     model.component('comp1').geom('geom1').nodeGroup('grp1').add(spring1_label);
%     model.component('comp1').geom('geom1').nodeGroup('grp1').add(mass1_label);
%     model.component('comp1').geom('geom1').nodeGroup('grp1').add(spring2_label);
%     model.component('comp1').geom('geom1').nodeGroup('grp1').add(mass2_label);
%     model.component('comp1').geom('geom1').nodeGroup('grp1').add(spring3_label);
end
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');

model.component('comp1').variable.create('var2');
model.component('comp1').variable('var2').set('k0', 'intop1(acpr.k)');
model.component('comp1').variable('var2').set('k0x', 'k0*sin(theta)*cos(phi)');
model.component('comp1').variable('var2').set('k0y', 'k0*sin(theta)*sin(phi)');
model.component('comp1').variable('var2').set('k0z', 'k0*cos(theta)');
model.component('comp1').variable('var2').set('p_inc', 'p0*exp(-i*(k0x*x+k0y*y+k0z*z))');
model.component('comp1').variable('var2').set('p_beam', 'p_inc*exp(-((x-x0)-k0x/k0z*z)^2/(w_beam/2)^2)');
model.component('comp1').variable('var2').set('x0', '0[m]');

model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material.create('mat2', 'Common');
model.component('comp1').material.create('mat3', 'Common');
model.component('comp1').material('mat1').selection.set([3 4 8 9 10 11 14 15 19 20 21 22 25 26 30 31 32 33 36 37 41 42 43 44 47 48 52 53 54 55 58 59 63 64 65 66 69 70 74 75 76 77 80 81 85 86 87 88 91 92 96 97 98 99 102 103 107 108 109 110 113 114 118 119 120 121 124 125 129 130 131 132 135 136 140 141 142 143 146 147 151 152 153 154 157 158 162 163 164 165 168 169 173 174 175 176 179 180 184 185 186 187 190 191 195 196 197 198 201 202 206 207 208 209 212 213 217 218 219 220 223 224 228 229 230 231 234 235 239 240 241 242 245 246 250 251 252 253 256 257 261 262 263 264 267 268 272 273 274 275]);
model.component('comp1').material('mat1').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.component('comp1').material('mat1').propertyGroup.create('Murnaghan', 'Murnaghan');
model.component('comp1').material('mat2').selection.set([1 2 5 6 12 13 16 17 23 24 27 28 34 35 38 39 45 46 49 50 56 57 60 61 67 68 71 72 78 79 82 83 89 90 93 94 100 101 104 105 111 112 115 116 122 123 126 127 133 134 137 138 144 145 148 149 155 156 159 160 166 167 170 171 177 178 181 182 188 189 192 193 199 200 203 204 210 211 214 215 221 222 225 226 232 233 236 237 243 244 247 248 254 255 258 259 265 266 269 270]);
model.component('comp1').material('mat2').propertyGroup('def').func.create('eta', 'Piecewise');
model.component('comp1').material('mat2').propertyGroup('def').func.create('Cp', 'Piecewise');
model.component('comp1').material('mat2').propertyGroup('def').func.create('rho', 'Piecewise');
model.component('comp1').material('mat2').propertyGroup('def').func.create('k', 'Piecewise');
model.component('comp1').material('mat2').propertyGroup('def').func.create('cs', 'Interpolation');
model.component('comp1').material('mat2').propertyGroup('def').func.create('an1', 'Analytic');
model.component('comp1').material('mat2').propertyGroup('def').func.create('an2', 'Analytic');
model.component('comp1').material('mat2').propertyGroup('def').func.create('an3', 'Analytic');
model.component('comp1').material('mat3').selection.set([3 4 7 8 9 10 11 14 15 18 19 20 21 22 25 26 29 30 31 32 33 36 37 40 41 42 43 44 47 48 51 52 53 54 55 58 59 62 63 64 65 66 69 70 73 74 75 76 77 80 81 84 85 86 87 88 91 92 95 96 97 98 99 102 103 106 107 108 109 110 113 114 117 118 119 120 121 124 125 128 129 130 131 132 135 136 139 140 141 142 143 146 147 150 151 152 153 154 157 158 161 162 163 164 165 168 169 172 173 174 175 176 179 180 183 184 185 186 187 190 191 194 195 196 197 198 201 202 205 206 207 208 209 212 213 216 217 218 219 220 223 224 227 228 229 230 231 234 235 238 239 240 241 242 245 246 249 250 251 252 253 256 257 260 261 262 263 264 267 268 271 272 273 274 275]);
model.component('comp1').material('mat3').propertyGroup.create('Enu', [native2unicode(hex2dec({'67' '68'}), 'unicode')  native2unicode(hex2dec({'6c' '0f'}), 'unicode')  native2unicode(hex2dec({'6a' '21'}), 'unicode')  native2unicode(hex2dec({'91' 'cf'}), 'unicode')  native2unicode(hex2dec({'54' '8c'}), 'unicode')  native2unicode(hex2dec({'6c' 'ca'}), 'unicode')  native2unicode(hex2dec({'67' '7e'}), 'unicode')  native2unicode(hex2dec({'6b' 'd4'}), 'unicode') ]);

model.component('comp1').cpl.create('intop1', 'Integration');
model.component('comp1').cpl('intop1').selection.geom('geom1', 0);
model.component('comp1').cpl('intop1').selection.set([514]);

model.component('comp1').coordSystem.create('pml1', 'PML');
model.component('comp1').coordSystem.create('pml2', 'PML');
model.component('comp1').coordSystem('pml1').selection.set([1 2 5 6 12 13 16 17 23 24 27 28 34 35 38 39 45 50 56 61 67 72 78 83 89 94 100 105 111 116 122 127 133 138 144 149 155 160 166 171 177 182 188 193 199 204 210 215 221 226 232 233 236 237 243 244 247 248 254 255 258 259 265 266 269 270]);
model.component('comp1').coordSystem('pml2').selection.set([3 4 14 15 25 26 36 37 234 235 245 246 256 257 267 268]);

model.component('comp1').physics.create('solid', 'SolidMechanics', 'geom1');
model.component('comp1').physics('solid').selection.set([3 4 7 8 9 10 11 14 15 18 19 20 21 22 25 26 29 30 31 32 33 36 37 40 41 42 43 44 47 48 51 52 53 54 55 58 59 62 63 64 65 66 69 70 73 74 75 76 77 80 81 84 85 86 87 88 91 92 95 96 97 98 99 102 103 106 107 108 109 110 113 114 117 118 119 120 121 124 125 128 129 130 131 132 135 136 139 140 141 142 143 146 147 150 151 152 153 154 157 158 161 162 163 164 165 168 169 172 173 174 175 176 179 180 183 184 185 186 187 190 191 194 195 196 197 198 201 202 205 206 207 208 209 212 213 216 217 218 219 220 223 224 227 228 229 230 231 234 235 238 239 240 241 242 245 246 249 250 251 252 253 256 257 260 261 262 263 264 267 268 271 272 273 274 275]);
model.component('comp1').physics('solid').create('pc1', 'PeriodicCondition', 2);
model.component('comp1').physics('solid').feature('pc1').selection.set([8 12 23 24 64 68 79 80 120 124 135 136 176 180 191 192 232 236 247 248 288 292 303 304 344 348 359 360 400 404 415 416 456 460 471 472 512 516 527 528 568 572 583 584 624 628 639 640 680 684 695 696 736 740 751 752 792 796 807 808 848 852 863 864 904 908 919 920 960 964 975 976 1016 1020 1031 1032 1072 1076 1087 1088 1128 1132 1143 1144 1184 1188 1199 1200 1240 1244 1255 1256 1296 1300 1311 1312 1352 1356 1367 1368]);
model.component('comp1').physics('solid').create('pc2', 'PeriodicCondition', 2);
model.component('comp1').physics('solid').feature('pc2').selection.set([7 11 1403 1404]);
model.component('comp1').physics.create('acpr', 'PressureAcoustics', 'geom1');
model.component('comp1').physics('acpr').selection.set([1 2 5 6 12 13 16 17 23 24 27 28 34 35 38 39 45 46 49 50 56 57 60 61 67 68 71 72 78 79 82 83 89 90 93 94 100 101 104 105 111 112 115 116 122 123 126 127 133 134 137 138 144 145 148 149 155 156 159 160 166 167 170 171 177 178 181 182 188 189 192 193 199 200 203 204 210 211 214 215 221 222 225 226 232 233 236 237 243 244 247 248 254 255 258 259 265 266 269 270]);
model.component('comp1').physics('acpr').create('bpf1', 'BackgroundPressureField', 3);
model.component('comp1').physics('acpr').feature('bpf1').selection.set([2 13 24 35 46 57 68 79 90 101 112 123 134 145 156 167 178 189 200 211 222 233 244 255 266]);
model.component('comp1').physics('acpr').create('pc1', 'PeriodicCondition', 2);
model.component('comp1').physics('acpr').feature('pc1').selection.set([1 4 14 17 1401 1402 1405 1406]);
model.component('comp1').physics('acpr').create('pc2', 'PeriodicCondition', 2);
model.component('comp1').physics('acpr').feature('pc2').selection.set([2 5 15 18 21 22 25 26 58 61 71 74 77 78 81 82 114 117 127 130 133 134 137 138 170 173 183 186 189 190 193 194 226 229 239 242 245 246 249 250 282 285 295 298 301 302 305 306 338 341 351 354 357 358 361 362 394 397 407 410 413 414 417 418 450 453 463 466 469 470 473 474 506 509 519 522 525 526 529 530 562 565 575 578 581 582 585 586 618 621 631 634 637 638 641 642 674 677 687 690 693 694 697 698 730 733 743 746 749 750 753 754 786 789 799 802 805 806 809 810 842 845 855 858 861 862 865 866 898 901 911 914 917 918 921 922 954 957 967 970 973 974 977 978 1010 1013 1023 1026 1029 1030 1033 1034 1066 1069 1079 1082 1085 1086 1089 1090 1122 1125 1135 1138 1141 1142 1145 1146 1178 1181 1191 1194 1197 1198 1201 1202 1234 1237 1247 1250 1253 1254 1257 1258 1290 1293 1303 1306 1309 1310 1313 1314 1346 1349 1359 1362 1365 1366 1369 1370]);

model.component('comp1').multiphysics.create('asb1', 'AcousticStructureBoundary', 2);
model.component('comp1').multiphysics('asb1').selection.set([9 16 65 72 121 128 177 184 233 240 289 296 345 352 401 408 457 464 513 520 569 576 625 632 681 688 737 744 793 800 849 856 905 912 961 968 1017 1024 1073 1080 1129 1136 1185 1192 1241 1248 1297 1304 1353 1360]);

model.component('comp1').mesh('mesh1').create('size1', 'Size');
model.component('comp1').mesh('mesh1').create('size2', 'Size');
model.component('comp1').mesh('mesh1').create('se1', 'SizeExpression');
model.component('comp1').mesh('mesh1').create('id1', 'IdenticalMesh');
model.component('comp1').mesh('mesh1').create('id2', 'IdenticalMesh');
model.component('comp1').mesh('mesh1').create('id3', 'IdenticalMesh');
model.component('comp1').mesh('mesh1').create('id4', 'IdenticalMesh');
model.component('comp1').mesh('mesh1').create('dis1', 'Distribution');
model.component('comp1').mesh('mesh1').create('ftet1', 'FreeTet');
model.component('comp1').mesh('mesh1').create('map1', 'Map');
model.component('comp1').mesh('mesh1').create('copy1', 'Copy');
model.component('comp1').mesh('mesh1').create('map2', 'Map');
model.component('comp1').mesh('mesh1').create('copy2', 'Copy');
model.component('comp1').mesh('mesh1').create('swe1', 'Sweep');
model.component('comp1').mesh('mesh1').feature('size1').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('size1').selection.set([2 5 13 16 24 27 35 38 46 49 57 60 68 71 79 82 90 93 101 104 112 115 123 126 134 137 145 148 156 159 167 170 178 181 189 192 200 203 211 214 222 225 233 236 244 247 255 258 266 269]);
model.component('comp1').mesh('mesh1').feature('size2').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('size2').selection.set([3 4 7 8 9 10 11 14 15 18 19 20 21 22 25 26 29 30 31 32 33 36 37 40 41 42 43 44 47 48 51 52 53 54 55 58 59 62 63 64 65 66 69 70 73 74 75 76 77 80 81 84 85 86 87 88 91 92 95 96 97 98 99 102 103 106 107 108 109 110 113 114 117 118 119 120 121 124 125 128 129 130 131 132 135 136 139 140 141 142 143 146 147 150 151 152 153 154 157 158 161 162 163 164 165 168 169 172 173 174 175 176 179 180 183 184 185 186 187 190 191 194 195 196 197 198 201 202 205 206 207 208 209 212 213 216 217 218 219 220 223 224 227 228 229 230 231 234 235 238 239 240 241 242 245 246 249 250 251 252 253 256 257 260 261 262 263 264 267 268 271 272 273 274 275]);
model.component('comp1').mesh('mesh1').feature('se1').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('se1').selection.set([2 5 13 16 24 27 35 38 46 49 57 60 68 71 79 82 90 93 101 104 112 115 123 126 134 137 145 148 156 159 167 170 178 181 189 192 200 203 211 214 222 225 233 236 244 247 255 258 266 269]);
model.component('comp1').mesh('mesh1').feature('dis1').selection.geom('geom1', 1);
model.component('comp1').mesh('mesh1').feature('dis1').selection.set([1 18 23 34 97 114 119 130 193 210 215 226 289 306 311 322 385 402 407 418 481 498 503 514 577 594 599 610 673 690 695 706 769 786 791 802 865 882 887 898 961 978 983 994 1057 1074 1079 1090 1153 1170 1175 1186 1249 1266 1271 1282 1345 1362 1367 1378 1441 1458 1463 1474 1537 1554 1559 1570 1633 1650 1655 1666 1729 1746 1751 1762 1825 1842 1847 1858 1921 1938 1943 1954 2017 2034 2039 2050 2113 2130 2135 2146 2209 2226 2231 2242 2305 2322 2327 2338 2401 2412 2415 2420]);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([2 3 4 5 7 8 9 10 11 13 14 15 16 18 19 20 21 22 24 25 26 27 29 30 31 32 33 35 36 37 38 40 41 42 43 44 46 47 48 49 51 52 53 54 55 57 58 59 60 62 63 64 65 66 68 69 70 71 73 74 75 76 77 79 80 81 82 84 85 86 87 88 90 91 92 93 95 96 97 98 99 101 102 103 104 106 107 108 109 110 112 113 114 115 117 118 119 120 121 123 124 125 126 128 129 130 131 132 134 135 136 137 139 140 141 142 143 145 146 147 148 150 151 152 153 154 156 157 158 159 161 162 163 164 165 167 168 169 170 172 173 174 175 176 178 179 180 181 183 184 185 186 187 189 190 191 192 194 195 196 197 198 200 201 202 203 205 206 207 208 209 211 212 213 214 216 217 218 219 220 222 223 224 225 227 228 229 230 231 233 234 235 236 238 239 240 241 242 244 245 246 247 249 250 251 252 253 255 256 257 258 260 261 262 263 264 266 267 268 269 271 272 273 274 275]);
% 为了防止弹簧处计算错误，每个弹簧的网格要求不小于边长的1/4
for i = 1:N_cell
    spring_mesh_size_name = ['size',num2str(i)];
    spring_geom3_number = [11*i-2 11*i-1 11*i];
    spring_mesh_size_max = ['wspring',num2str(i),'/4'];
    model.component('comp1').mesh('mesh1').feature('ftet1').create(spring_mesh_size_name, 'Size');
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).selection.set(spring_geom3_number);
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).set('custom', 'on');
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).set('hmax', spring_mesh_size_max);
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).set('hmaxactive', true);
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).set('hmin', 0.0171);
    model.component('comp1').mesh('mesh1').feature('ftet1').feature(spring_mesh_size_name).set('hminactive', false);
end
model.component('comp1').mesh('mesh1').feature('map1').selection.set([2 18 58 74 114 130 170 186 226 242 282 298 338 354 394 410 450 466 506 522 562 578 618 634 674 690 730 746 786 802 842 858 898 914 954 970 1010 1026 1066 1082 1122 1138 1178 1194 1234 1250 1290 1306 1346 1362]);
model.component('comp1').mesh('mesh1').feature('map2').selection.set([1 17]);
model.component('comp1').mesh('mesh1').feature('swe1').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('swe1').selection.set([1 6 12 17 23 28 34 39 45 50 56 61 67 72 78 83 89 94 100 105 111 116 122 127 133 138 144 149 155 160 166 171 177 182 188 193 199 204 210 215 221 226 232 237 243 248 254 259 265 270]);
model.component('comp1').mesh('mesh1').feature('swe1').create('dis1', 'Distribution');

model.result.table('tbl1').comments([native2unicode(hex2dec({'51' '68'}), 'unicode')  native2unicode(hex2dec({'5c' '40'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode') ' 2']);

model.component('comp1').variable('var2').label([native2unicode(hex2dec({'53' 'd8'}), 'unicode')  native2unicode(hex2dec({'91' 'cf'}), 'unicode') ' 1']);

model.component('comp1').material('mat1').active(false);
model.component('comp1').material('mat1').label('Aluminum');
model.component('comp1').material('mat1').set('family', 'aluminum');
model.component('comp1').material('mat1').propertyGroup('def').label('Basic');
model.component('comp1').material('mat1').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', '900[J/(kg*K)]');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', {'238[W/(m*K)]' '0' '0' '0' '238[W/(m*K)]' '0' '0' '0' '238[W/(m*K)]'});
model.component('comp1').material('mat1').propertyGroup('def').set('electricconductivity', {'3.774e7[S/m]' '0' '0' '0' '3.774e7[S/m]' '0' '0' '0' '3.774e7[S/m]'});
model.component('comp1').material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('comp1').material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'23e-6[1/K]' '0' '0' '0' '23e-6[1/K]' '0' '0' '0' '23e-6[1/K]'});
model.component('comp1').material('mat1').propertyGroup('def').set('density', '2700[kg/m^3]');
model.component('comp1').material('mat1').propertyGroup('Enu').label('Young''s modulus and Poisson''s ratio');
model.component('comp1').material('mat1').propertyGroup('Enu').set('E', '70[GPa]');
model.component('comp1').material('mat1').propertyGroup('Enu').set('nu', '0.33');
model.component('comp1').material('mat1').propertyGroup('Murnaghan').set('l', '-250[GPa]');
model.component('comp1').material('mat1').propertyGroup('Murnaghan').set('m', '-330[GPa]');
model.component('comp1').material('mat1').propertyGroup('Murnaghan').set('n', '-350[GPa]');
model.component('comp1').material('mat2').label('Water, liquid');
model.component('comp1').material('mat2').set('family', 'water');
model.component('comp1').material('mat2').propertyGroup('def').label('Basic');
model.component('comp1').material('mat2').propertyGroup('def').func('eta').label('Piecewise');
model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('arg', 'T');
model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('pieces', {'273.15' '413.15' '1.3799566804-0.021224019151*T^1+1.3604562827E-4*T^2-4.6454090319E-7*T^3+8.9042735735E-10*T^4-9.0790692686E-13*T^5+3.8457331488E-16*T^6'; '413.15' '553.75' '0.00401235783-2.10746715E-5*T^1+3.85772275E-8*T^2-2.39730284E-11*T^3'});
model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('argunit', 'K');
model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('fununit', 'Pa*s');
model.component('comp1').material('mat2').propertyGroup('def').func('Cp').label('Piecewise 2');
model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('arg', 'T');
model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('pieces', {'273.15' '553.75' '12010.1471-80.4072879*T^1+0.309866854*T^2-5.38186884E-4*T^3+3.62536437E-7*T^4'});
model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('argunit', 'K');
model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('fununit', 'J/(kg*K)');
model.component('comp1').material('mat2').propertyGroup('def').func('rho').label('Piecewise 3');
model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('arg', 'T');
model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('smooth', 'contd1');
model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('pieces', {'273.15' '293.15' '0.000063092789034*T^3-0.060367639882855*T^2+18.9229382407066*T-950.704055329848'; '293.15' '373.15' '0.000010335053319*T^3-0.013395065634452*T^2+4.969288832655160*T+432.257114008512'});
model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('argunit', 'K');
model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('fununit', 'kg/m^3');
model.component('comp1').material('mat2').propertyGroup('def').func('k').label('Piecewise 4');
model.component('comp1').material('mat2').propertyGroup('def').func('k').set('arg', 'T');
model.component('comp1').material('mat2').propertyGroup('def').func('k').set('pieces', {'273.15' '553.75' '-0.869083936+0.00894880345*T^1-1.58366345E-5*T^2+7.97543259E-9*T^3'});
model.component('comp1').material('mat2').propertyGroup('def').func('k').set('argunit', 'K');
model.component('comp1').material('mat2').propertyGroup('def').func('k').set('fununit', 'W/(m*K)');
model.component('comp1').material('mat2').propertyGroup('def').func('cs').label('Interpolation');
model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('table', {'273' '1403';  ...
'278' '1427';  ...
'283' '1447';  ...
'293' '1481';  ...
'303' '1507';  ...
'313' '1526';  ...
'323' '1541';  ...
'333' '1552';  ...
'343' '1555';  ...
'353' '1555';  ...
'363' '1550';  ...
'373' '1543'});
model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('interp', 'piecewisecubic');
model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('fununit', {'m/s'});
model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('argunit', {'K'});
model.component('comp1').material('mat2').propertyGroup('def').func('an1').label('Analytic 1');
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('funcname', 'alpha_p');
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('expr', '-1/rho(T)*d(rho(T),T)');
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('args', {'T'});
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('fununit', '1/K');
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('argunit', {'K'});
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat2').propertyGroup('def').func('an1').set('plotargs', {'T' '273.15' '373.15'});
model.component('comp1').material('mat2').propertyGroup('def').func('an2').label('Analytic 2');
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('funcname', 'gamma_w');
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('expr', '1+(T/Cp(T))*(alpha_p(T)*cs(T))^2');
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('args', {'T'});
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('fununit', '1');
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('argunit', {'K'});
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat2').propertyGroup('def').func('an2').set('plotargs', {'T' '273.15' '373.15'});
model.component('comp1').material('mat2').propertyGroup('def').func('an3').label('Analytic 3');
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('funcname', 'muB');
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('expr', '2.79*eta(T)');
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('args', {'T'});
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('fununit', 'Pa*s');
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('argunit', {'K'});
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat2').propertyGroup('def').func('an3').set('plotargs', {'T' '273.15' '553.75'});
model.component('comp1').material('mat2').propertyGroup('def').set('thermalexpansioncoefficient', '');
model.component('comp1').material('mat2').propertyGroup('def').set('bulkviscosity', '');
model.component('comp1').material('mat2').propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(T)' '0' '0' '0' 'alpha_p(T)' '0' '0' '0' 'alpha_p(T)'});
model.component('comp1').material('mat2').propertyGroup('def').set('bulkviscosity', 'muB(T)');
model.component('comp1').material('mat2').propertyGroup('def').set('dynamicviscosity', 'eta(T)');
model.component('comp1').material('mat2').propertyGroup('def').set('ratioofspecificheat', 'gamma_w(T)');
model.component('comp1').material('mat2').propertyGroup('def').set('electricconductivity', {'5.5e-6[S/m]' '0' '0' '0' '5.5e-6[S/m]' '0' '0' '0' '5.5e-6[S/m]'});
model.component('comp1').material('mat2').propertyGroup('def').set('heatcapacity', 'Cp(T)');
model.component('comp1').material('mat2').propertyGroup('def').set('density', '1000');
model.component('comp1').material('mat2').propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
model.component('comp1').material('mat2').propertyGroup('def').set('soundspeed', '1500');
model.component('comp1').material('mat2').propertyGroup('def').addInput('temperature');
model.component('comp1').material('mat3').label('Fe');
model.component('comp1').material('mat3').propertyGroup('def').set('density', 'rho_Fe');
model.component('comp1').material('mat3').propertyGroup('Enu').set('E', 'E_Fe');
model.component('comp1').material('mat3').propertyGroup('Enu').set('nu', 'nu_Fe');

model.component('comp1').coordSystem('pml1').label('PML fluid');
model.component('comp1').coordSystem('pml1').set('wavelengthSource', 'acpr');
model.component('comp1').coordSystem('pml2').label('PML plate');
model.component('comp1').coordSystem('pml2').set('wavelengthSource', 'solid');

model.component('comp1').physics('solid').feature('pc1').set('PeriodicType', 'Floquet');
model.component('comp1').physics('solid').feature('pc2').set('PeriodicType', 'Floquet');
model.component('comp1').physics('acpr').feature('bpf1').set('p', 'p_beam');
model.component('comp1').physics('acpr').feature('bpf1').set('dir', [0; 0; 1]);
model.component('comp1').physics('acpr').feature('bpf1').set('PressureFieldType', 'UserDefined');
model.component('comp1').physics('acpr').feature('bpf1').set('pamp', 'p0');
model.component('comp1').physics('acpr').feature('bpf1').set('c_mat', 'from_mat');
model.component('comp1').physics('acpr').feature('bpf1').set('c', 1500);
model.component('comp1').physics('acpr').feature('pc1').set('PeriodicType', 'Floquet');
model.component('comp1').physics('acpr').feature('pc1').set('kFloquet', {'k0x'; 'k0y'; 'k0z'});
model.component('comp1').physics('acpr').feature('pc2').set('PeriodicType', 'Floquet');
model.component('comp1').physics('acpr').feature('pc2').set('kFloquet', {'k0x'; 'k0y'; 'k0z'});

model.component('comp1').mesh('mesh1').feature('size').set('hauto', 3);
model.component('comp1').mesh('mesh1').feature('size1').set('custom', 'on');
model.component('comp1').mesh('mesh1').feature('size1').set('hmax', 'lambda/10');
model.component('comp1').mesh('mesh1').feature('size1').set('hmaxactive', true);
model.component('comp1').mesh('mesh1').feature('size1').set('hmin', '9.5000E-6');
model.component('comp1').mesh('mesh1').feature('size1').set('hminactive', true);
model.component('comp1').mesh('mesh1').feature('size2').set('custom', 'on');
model.component('comp1').mesh('mesh1').feature('size2').set('hmax', 'lambdaL/6');
model.component('comp1').mesh('mesh1').feature('size2').set('hmaxactive', true);

model.sol.create('sol1');

model.study.create('std1');
model.study('std1').create('freq', 'Frequency');

model.component('comp1').mesh('mesh1').feature('se1').set('evaltype', 'initialexpression');
model.component('comp1').mesh('mesh1').feature('se1').set('sizeexpr', 'subst(real(acpr.c_c),acpr.freq,freqmax)/freqmax/5');
model.component('comp1').mesh('mesh1').feature('se1').set('studystep', 'std1/freq');
model.component('comp1').mesh('mesh1').feature('id1').selection('group1').set([7 11]);
model.component('comp1').mesh('mesh1').feature('id1').selection('group2').set([1403 1404]);
model.component('comp1').mesh('mesh1').feature('id2').selection('group1').set([8 12 64 68 120 124 176 180 232 236 288 292 344 348 400 404 456 460 512 516 568 572 624 628 680 684 736 740 792 796 848 852 904 908 960 964 1016 1020 1072 1076 1128 1132 1184 1188 1240 1244 1296 1300 1352 1356]);
model.component('comp1').mesh('mesh1').feature('id2').selection('group2').set([23 24 79 80 135 136 191 192 247 248 303 304 359 360 415 416 471 472 527 528 583 584 639 640 695 696 751 752 807 808 863 864 919 920 975 976 1031 1032 1087 1088 1143 1144 1199 1200 1255 1256 1311 1312 1367 1368]);
model.component('comp1').mesh('mesh1').feature('id3').selection('group1').set([2 5 15 18 58 61 71 74 114 117 127 130 170 173 183 186 226 229 239 242 282 285 295 298 338 341 351 354 394 397 407 410 450 453 463 466 506 509 519 522 562 565 575 578 618 621 631 634 674 677 687 690 730 733 743 746 786 789 799 802 842 845 855 858 898 901 911 914 954 957 967 970 1010 1013 1023 1026 1066 1069 1079 1082 1122 1125 1135 1138 1178 1181 1191 1194 1234 1237 1247 1250 1290 1293 1303 1306 1346 1349 1359 1362]);
model.component('comp1').mesh('mesh1').feature('id3').selection('group2').set([21 22 25 26 77 78 81 82 133 134 137 138 189 190 193 194 245 246 249 250 301 302 305 306 357 358 361 362 413 414 417 418 469 470 473 474 525 526 529 530 581 582 585 586 637 638 641 642 693 694 697 698 749 750 753 754 805 806 809 810 861 862 865 866 917 918 921 922 973 974 977 978 1029 1030 1033 1034 1085 1086 1089 1090 1141 1142 1145 1146 1197 1198 1201 1202 1253 1254 1257 1258 1309 1310 1313 1314 1365 1366 1369 1370]);
model.component('comp1').mesh('mesh1').feature('id4').selection('group1').set([1 4 14 17]);
model.component('comp1').mesh('mesh1').feature('id4').selection('group2').set([1401 1402 1405 1406]);
model.component('comp1').mesh('mesh1').feature('dis1').set('type', 'predefined');
model.component('comp1').mesh('mesh1').feature('dis1').set('elemcount', 8);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('custom', 'on');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hmax', 'wspring1/4');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hmaxactive', true);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hmin', 0.0171);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hminactive', false);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('custom', 'on');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hmax', 'wspring2/4');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hmaxactive', true);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hmin', 0.0171);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hminactive', false);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size3').set('custom', 'on');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size3').set('hmax', 'wspring3/4');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size3').set('hmaxactive', true);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size3').set('hmin', 0.0171);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size3').set('hminactive', false);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size4').set('custom', 'on');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size4').set('hmax', 'wspring4/4');
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size4').set('hmaxactive', true);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size4').set('hmin', 0.0171);
% model.component('comp1').mesh('mesh1').feature('ftet1').feature('size4').set('hminactive', false);
model.component('comp1').mesh('mesh1').feature('map1').set('adjustedgdistr', true);
model.component('comp1').mesh('mesh1').feature('copy1').set('dimension', 2);
model.component('comp1').mesh('mesh1').feature('copy1').selection('source').set([2 18 58 74 114 130 170 186 226 242 282 298 338 354 394 410 450 466 506 522 562 578 618 634 674 690 730 746 786 802 842 858 898 914 954 970 1010 1026 1066 1082 1122 1138 1178 1194 1234 1250 1290 1306 1346 1362]);
model.component('comp1').mesh('mesh1').feature('copy1').selection('destination').set([21 26 77 82 133 138 189 194 245 250 301 306 357 362 413 418 469 474 525 530 581 586 637 642 693 698 749 754 805 810 861 866 917 922 973 978 1029 1034 1085 1090 1141 1146 1197 1202 1253 1258 1309 1314 1365 1370]);
model.component('comp1').mesh('mesh1').feature('map2').set('adjustedgdistr', true);
model.component('comp1').mesh('mesh1').feature('copy2').set('dimension', 2);
model.component('comp1').mesh('mesh1').feature('copy2').selection('source').set([1 17]);
model.component('comp1').mesh('mesh1').feature('copy2').selection('destination').set([1401 1406]);
model.component('comp1').mesh('mesh1').feature('swe1').feature('dis1').set('numelem', 8);

model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('p1', 'Parametric');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').create('i2', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').create('mg2', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('hybridization', 'multi');
model.sol('sol1').feature('s1').feature('i1').feature('mg2').set('hybridization', 'multi');
model.sol('sol1').feature('s1').feature('i2').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i2').create('dp1', 'DirectPreconditioner');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').set('hybridization', 'multi');
model.sol('sol1').feature('s1').feature('i2').feature('dp1').set('hybridization', 'multi');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.numerical.create('gev1', 'EvalGlobal');
model.result.numerical.create('gev2', 'EvalGlobal');
model.result.create('pg1', 'PlotGroup3D');
model.result.create('pg2', 'PlotGroup3D');
model.result.create('pg3', 'PlotGroup3D');
model.result.create('pg5', 'PlotGroup3D');
model.result.create('pg6', 'PlotGroup3D');
model.result('pg1').create('vol1', 'Volume');
model.result('pg1').feature('vol1').set('expr', 'u');
model.result('pg1').feature('vol1').create('def', 'Deform');
model.result('pg2').selection.geom('geom1', 3);
model.result('pg2').selection.set([5 16 27 38 49 60 71 82 93 104 115 126 137 148 159 170 181 192 203 214 225 236 247 258 269]);
model.result('pg2').create('surf1', 'Surface');
model.result('pg2').feature('surf1').set('expr', 'acpr.p_s');
model.result('pg3').create('surf1', 'Surface');
model.result('pg3').feature('surf1').set('expr', 'acpr.Lp_t');
model.result('pg5').create('vol1', 'Volume');
model.result('pg5').feature('vol1').set('expr', 'w');
model.result('pg5').feature('vol1').create('def', 'Deform');
model.result('pg6').selection.geom('geom1', 3);
model.result('pg6').selection.set([4 5 6 8 11 15 16 17 19 22 26 27 28 30 33 37 38 39 41 44 48 49 50 52 55 59 60 61 63 66 70 71 72 74 77 81 82 83 85 88 92 93 94 96 99 103 104 105 107 110 114 115 116 118 121 125 126 127 129 132 136 137 138 140 143 147 148 149 151 154 158 159 160 162 165 169 170 171 173 176 180 181 182 184 187 191 192 193 195 198 202 203 204 206 209 213 214 215 217 220 224 225 226 228 231 235 236 237 239 242 246 247 248 250 253 257 258 259 261 264 268 269 270 272 275]);
model.result('pg6').create('slc1', 'Slice');
model.result('pg6').feature('slc1').set('expr', 'acpr.p_t');

model.study('std1').feature('freq').set('plist', 'f0');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('st1').label([native2unicode(hex2dec({'7f' '16'}), 'unicode')  native2unicode(hex2dec({'8b' 'd1'}), 'unicode')  native2unicode(hex2dec({'65' 'b9'}), 'unicode')  native2unicode(hex2dec({'7a' '0b'}), 'unicode') ': ' native2unicode(hex2dec({'98' '91'}), 'unicode')  native2unicode(hex2dec({'57' 'df'}), 'unicode') ]);
model.sol('sol1').feature('v1').label([native2unicode(hex2dec({'56' 'e0'}), 'unicode')  native2unicode(hex2dec({'53' 'd8'}), 'unicode')  native2unicode(hex2dec({'91' 'cf'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('v1').set('clistctrl', {'p1'});
model.sol('sol1').feature('v1').set('cname', {'freq'});
model.sol('sol1').feature('v1').set('clist', {'f0'});
model.sol('sol1').feature('s1').label([native2unicode(hex2dec({'7a' '33'}), 'unicode')  native2unicode(hex2dec({'60' '01'}), 'unicode')  native2unicode(hex2dec({'6c' '42'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').set('probesel', 'none');
model.sol('sol1').feature('s1').feature('dDef').label([native2unicode(hex2dec({'76' 'f4'}), 'unicode')  native2unicode(hex2dec({'63' 'a5'}), 'unicode') ' 2']);
model.sol('sol1').feature('s1').feature('aDef').label([native2unicode(hex2dec({'9a' 'd8'}), 'unicode')  native2unicode(hex2dec({'7e' 'a7'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('aDef').set('cachepattern', true);
model.sol('sol1').feature('s1').feature('aDef').set('complexfun', true);
model.sol('sol1').feature('s1').feature('p1').label([native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'65' '70'}), 'unicode')  native2unicode(hex2dec({'53' '16'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});
model.sol('sol1').feature('s1').feature('p1').set('plistarr', {'f0'});
model.sol('sol1').feature('s1').feature('p1').set('punit', {'Hz'});
model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');
model.sol('sol1').feature('s1').feature('fc1').label([native2unicode(hex2dec({'51' '68'}), 'unicode')  native2unicode(hex2dec({'80' '26'}), 'unicode')  native2unicode(hex2dec({'54' '08'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('s1').feature('d1').label(['Suggested Direct Solver (asb1) (' native2unicode(hex2dec({'5d' 'f2'}), 'unicode')  native2unicode(hex2dec({'54' '08'}), 'unicode')  native2unicode(hex2dec({'5e' '76'}), 'unicode') ')']);
model.sol('sol1').feature('s1').feature('i1').label('Suggested Iterative Solver (GMRES with GMG) (asb1)');
model.sol('sol1').feature('s1').feature('i1').feature('ilDef').label([native2unicode(hex2dec({'4e' '0d'}), 'unicode')  native2unicode(hex2dec({'5b' '8c'}), 'unicode')  native2unicode(hex2dec({'51' '68'}), 'unicode') ' LU ' native2unicode(hex2dec({'52' '06'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').label([native2unicode(hex2dec({'59' '1a'}), 'unicode')  native2unicode(hex2dec({'91' 'cd'}), 'unicode')  native2unicode(hex2dec({'7f' '51'}), 'unicode')  native2unicode(hex2dec({'68' '3c'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('hybridvar', {'comp1_p'});
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').label([native2unicode(hex2dec({'98' '84'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').label([native2unicode(hex2dec({'54' '0e'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').label([native2unicode(hex2dec({'7c' '97'}), 'unicode')  native2unicode(hex2dec({'53' '16'}), 'unicode')  native2unicode(hex2dec({'6c' '42'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('dDef').label([native2unicode(hex2dec({'76' 'f4'}), 'unicode')  native2unicode(hex2dec({'63' 'a5'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg2').label([native2unicode(hex2dec({'59' '1a'}), 'unicode')  native2unicode(hex2dec({'91' 'cd'}), 'unicode')  native2unicode(hex2dec({'7f' '51'}), 'unicode')  native2unicode(hex2dec({'68' '3c'}), 'unicode') ' 2.1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg2').set('hybridvar', {'comp1_u'});
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('pr').label([native2unicode(hex2dec({'98' '84'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('pr').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('po').label([native2unicode(hex2dec({'54' '0e'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('po').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('cs').label([native2unicode(hex2dec({'7c' '97'}), 'unicode')  native2unicode(hex2dec({'53' '16'}), 'unicode')  native2unicode(hex2dec({'6c' '42'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i1').feature('mg2').feature('cs').feature('dDef').label([native2unicode(hex2dec({'76' 'f4'}), 'unicode')  native2unicode(hex2dec({'63' 'a5'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').label('Suggested Iterative Solver (GMRES with GMG and Direct Precond.) (asb1)');
model.sol('sol1').feature('s1').feature('i2').feature('ilDef').label([native2unicode(hex2dec({'4e' '0d'}), 'unicode')  native2unicode(hex2dec({'5b' '8c'}), 'unicode')  native2unicode(hex2dec({'51' '68'}), 'unicode') ' LU ' native2unicode(hex2dec({'52' '06'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').label([native2unicode(hex2dec({'59' '1a'}), 'unicode')  native2unicode(hex2dec({'91' 'cd'}), 'unicode')  native2unicode(hex2dec({'7f' '51'}), 'unicode')  native2unicode(hex2dec({'68' '3c'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').set('hybridvar', {'comp1_p'});
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('pr').label([native2unicode(hex2dec({'98' '84'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('pr').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('po').label([native2unicode(hex2dec({'54' '0e'}), 'unicode')  native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'6e' 'd1'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('po').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('cs').label([native2unicode(hex2dec({'7c' '97'}), 'unicode')  native2unicode(hex2dec({'53' '16'}), 'unicode')  native2unicode(hex2dec({'6c' '42'}), 'unicode')  native2unicode(hex2dec({'89' 'e3'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').feature('mg1').feature('cs').feature('dDef').label([native2unicode(hex2dec({'76' 'f4'}), 'unicode')  native2unicode(hex2dec({'63' 'a5'}), 'unicode') ' 1']);
model.sol('sol1').feature('s1').feature('i2').feature('dp1').label([native2unicode(hex2dec({'76' 'f4'}), 'unicode')  native2unicode(hex2dec({'63' 'a5'}), 'unicode')  native2unicode(hex2dec({'98' '84'}), 'unicode')  native2unicode(hex2dec({'67' '61'}), 'unicode')  native2unicode(hex2dec({'4e' 'f6'}), 'unicode')  native2unicode(hex2dec({'56' '68'}), 'unicode') ' 1.1']);
model.sol('sol1').feature('s1').feature('i2').feature('dp1').set('mumpsblr', true);
model.sol('sol1').feature('s1').feature('i2').feature('dp1').set('hybridvar', {'comp1_u'});
% model.sol('sol1').runAll;

model.result.numerical('gev1').set('expr', {'Keff' 'Meff' 'Zr' 'ceff'});
model.result.numerical('gev1').set('unit', {'' '' '' ''});
model.result.numerical('gev1').set('descr', {'' '' '' ''});
model.result.numerical('gev1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result.numerical('gev2').set('table', 'tbl1');
model.result.numerical('gev2').set('expr', {'tau'});
model.result.numerical('gev2').set('unit', {''});
model.result.numerical('gev2').set('descr', {''});
model.result.numerical('gev2').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result.numerical('gev2').setResult;
model.result('pg1').label([native2unicode(hex2dec({'5e' '94'}), 'unicode')  native2unicode(hex2dec({'52' '9b'}), 'unicode') ' (solid)']);
model.result('pg1').set('frametype', 'spatial');
model.result('pg1').feature('vol1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result('pg1').feature('vol1').set('colortable', 'Prism');
model.result('pg1').feature('vol1').set('resolution', 'custom');
model.result('pg1').feature('vol1').set('refine', 2);
model.result('pg1').feature('vol1').set('threshold', 'manual');
model.result('pg1').feature('vol1').set('thresholdvalue', 0.2);
model.result('pg1').feature('vol1').set('resolution', 'custom');
model.result('pg1').feature('vol1').set('refine', 2);
model.result('pg1').feature('vol1').feature('def').set('scale', 2.966574780495984E8);
model.result('pg1').feature('vol1').feature('def').set('scaleactive', false);
model.result('pg2').label([native2unicode(hex2dec({'58' 'f0'}), 'unicode')  native2unicode(hex2dec({'53' '8b'}), 'unicode') ' (acpr)']);
model.result('pg2').set('edges', false);
model.result('pg2').set('showlegendsunit', true);
model.result('pg2').feature('surf1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result('pg2').feature('surf1').set('colorscalemode', 'linearsymmetric');
model.result('pg2').feature('surf1').set('resolution', 'normal');
model.result('pg3').label([native2unicode(hex2dec({'58' 'f0'}), 'unicode')  native2unicode(hex2dec({'53' '8b'}), 'unicode')  native2unicode(hex2dec({'7e' 'a7'}), 'unicode') ' (acpr)']);
model.result('pg3').set('showlegendsunit', true);
model.result('pg3').feature('surf1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result('pg3').feature('surf1').set('resolution', 'normal');
model.result('pg5').label([native2unicode(hex2dec({'4f' '4d'}), 'unicode')  native2unicode(hex2dec({'79' 'fb'}), 'unicode') ' (solid)']);
model.result('pg5').set('frametype', 'spatial');
model.result('pg5').feature('vol1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result('pg5').feature('vol1').set('colortable', 'SpectrumLight');
model.result('pg5').feature('vol1').set('resolution', 'custom');
model.result('pg5').feature('vol1').set('refine', 2);
model.result('pg5').feature('vol1').set('threshold', 'manual');
model.result('pg5').feature('vol1').set('thresholdvalue', 0.2);
model.result('pg5').feature('vol1').set('resolution', 'custom');
model.result('pg5').feature('vol1').set('refine', 2);
model.result('pg5').feature('vol1').feature('def').set('scale', 2.966574780495984E8);
model.result('pg5').feature('vol1').feature('def').set('scaleactive', false);
model.result('pg6').label([native2unicode(hex2dec({'58' 'f0'}), 'unicode')  native2unicode(hex2dec({'53' '8b'}), 'unicode') ' (acpr) y=0' native2unicode(hex2dec({'5e' '73'}), 'unicode')  native2unicode(hex2dec({'97' '62'}), 'unicode') ]);
model.result('pg6').set('edges', false);
model.result('pg6').set('showlegendsunit', true);
model.result('pg6').feature('slc1').set('const', {'solid.refpntx' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'x ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpnty' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'y ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]; 'solid.refpntz' '0' [native2unicode(hex2dec({'52' '9b'}), 'unicode')  native2unicode(hex2dec({'77' 'e9'}), 'unicode')  native2unicode(hex2dec({'8b' 'a1'}), 'unicode')  native2unicode(hex2dec({'7b' '97'}), 'unicode')  native2unicode(hex2dec({'53' 'c2'}), 'unicode')  native2unicode(hex2dec({'80' '03'}), 'unicode')  native2unicode(hex2dec({'70' 'b9'}), 'unicode')  native2unicode(hex2dec({'ff' '0c'}), 'unicode') 'z ' native2unicode(hex2dec({'57' '50'}), 'unicode')  native2unicode(hex2dec({'68' '07'}), 'unicode') ]});
model.result('pg6').feature('slc1').set('planetype', 'general');
model.result('pg6').feature('slc1').set('genmethod', 'pointnormal');
model.result('pg6').feature('slc1').set('genpnvec', [0 1 0]);
model.result('pg6').feature('slc1').set('rangecoloractive', true);
model.result('pg6').feature('slc1').set('rangecolormin', -12);
model.result('pg6').feature('slc1').set('rangecolormax', 15);
model.result('pg6').feature('slc1').set('resolution', 'normal');

out = model;
