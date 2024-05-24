clear;
clc,close all;
% ori_path='../data_ori_test/';
% rec_base_path='data_rec_test/';
% h5_train='h5_test/';
% txt_path='../data_ori_test/testFile.txt';

ply_path = 'loot_vox10_1200.ply';
ori = pcread(ply_path);
ori_color=ori.Color;
ori_color_yuv=rgb2yuv(ori_color);
ori_loc=ori.Location;
pointNumber=length(ori_loc);
x = linspace(0, 0, pointNumber);
y = linspace(0, 0, pointNumber);
u = linspace(0, 0, pointNumber);
v = linspace(0, 0, pointNumber);

for i = 1:pointNumber
   x(i) = i;
   y(i) = ori_color_yuv(i, 1);
   u(i) = ori_color_yuv(i, 2);
   v(i) = ori_color_yuv(i, 3);
end

plot(x, v,'-r');
axis([0,pointNumber,0,255])  %确定x轴与y轴框图大小
set(gca,'FontName','Times New Roman','FontSize',24,'FontWeight', 'bold')
xlabel('Point Index','FontSize',30, 'FontWeight', 'bold', 'FontName', 'times new roman')  %x轴坐标描述
ylabel('Value','FontSize',30, 'FontWeight', 'bold', 'FontName', 'times new roman') %y轴坐标描述

title('Cr component','FontSize',34, 'FontWeight', 'bold', 'FontName', 'times new roman')
print(gcf,['Vcomponent.png'],'-dpng','-r300');
