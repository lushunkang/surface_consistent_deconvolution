% 读取数据信息
clc;
clear;

%每道有多少个数据
trace_num1=752;
trace_num = 752*2-1;

% 炮的起点
num= 0;
ns = 101;
nr = 1001;
%炮点和检波器转换距离
ns_nr = (nr-1)/(ns-1);
dataArray = zeros(trace_num1,nr,ns);
i=1;
while num<=10000;
    filename=['data5/shot_',num2str(num),'_rp.bin'];
    fid = fopen(filename,'r');
    [data,count]=fread(fid,[trace_num1,nr],'float32');
    dataArray(:,:,i)=data;
%     if(num==5000)
%       fid2 = fopen('daraTest/shot_real2_x5000_topo_rp.bin','r');
%       [data2,count2]=fread(fid2,[752,1001],'float32');
%       dataArray(:,1:50,i)=data2(:,1:50);
%       dataArray(:,1001-50+1:1001,i)=data2(:,1001-50+1:1001);
%       fclose(fid2);
% 
%       fid_s_list = fopen('daraTest/a_out_5_1.bin','wb');
%       fwrite(fid_s_list,dataArray(:,:,i),"float32");
%       fclose(fid_s_list);
%     end
    i=i+1;
    num=num+10000/(ns-1);
    fclose(fid);
end
% 读取震源影响
fid_s_list = fopen('data5/s_list_f.bin','r');
[s_list,count]=fread(fid_s_list,[trace_num,ns],'double');
fclose(fid_s_list);
% 读取炮检距影响
fid_h_list = fopen('data5/h_list_f.bin','r');
[h_list,count]=fread(fid_h_list,[trace_num,nr*2-1],'double');
fclose(fid_h_list);
% 读取中心点影响
fid_e_list = fopen('data5/e_list_f.bin','r');
[e_list,count]=fread(fid_e_list,[trace_num,nr*2-1],'double');
fclose(fid_e_list);
% 读取检波器影响
fid_r_list = fopen('data5/r_list_f.bin','r');
[r_list,count]=fread(fid_r_list,[trace_num,nr],'double');
fclose(fid_r_list);

% 抽取第21炮做运算
seismic_data_num = 51;
seismic_data_num_data = (seismic_data_num-1)*ns_nr+1;
seismic_data = dataArray(:,:,seismic_data_num);
% map_data = zeros(1024,801);
% 每一道做反褶积
fund_max_data=zeros(1,nr);
back_max_data=zeros(1,nr);
for i = 1:nr;
    % 求取褶积算子
    or_data_fft_or = seismic_data(:,i);
    or_data_fft_or_len = zeros(1,length(or_data_fft_or)*2-1);
    or_data_fft_or_len(1:length(or_data_fft_or)) = or_data_fft_or;
    %设计褶积算子
    %将每个褶积算子转换到时间域
    %炮点
    s_list_fft = s_list(:,seismic_data_num);
    s_dec = ifft(s_list_fft);
    s_dec = s_dec(1:trace_num1);
    s_dec = 1./s_dec;
    %跑间距
    h_list_fft = h_list(:,seismic_data_num_data-i+nr);
    h_dec = ifft(h_list_fft);
%     h_dec = h_dec(1:trace_num1);
    % 检波器
    r_list_fft = r_list(:,i);
    r_dec = ifft(r_list_fft);
%     r_dec = r_dec(1:trace_num1);

    % 中心点
    e_list_fft = e_list(:,(seismic_data_num_data+i)-1);
    e_dec = ifft(e_list_fft);
%     e_dec = e_dec(1:trace_num1);
    
%     [or_data_fft,a] = deconv(or_data_fft_or_len,r_dec);
    or_data_fft = conv(or_data_fft_or_len,1.\r_dec);

    or_data_fft = or_data_fft(1:trace_num);
    or_data_fft = conv(or_data_fft_or_len,1.\h_dec);

%     or_data_fft = or_data_fft(1:trace_num);
%     or_data_fft = conv(or_data_fft_or_len,1.\s_dec);

%     or_data_fft_or_len(1:length(or_data_fft_or))= or_data_fft;
%     [or_data_fft,a] = deconv(or_data_fft_or_len,h_dec);
% 
%     or_data_fft_or_len(1:length(or_data_fft_or))= or_data_fft;
%     [or_data_fft,a] = deconv(or_data_fft_or_len,s_dec);
% 
%     or_data_fft_or_len(1:length(or_data_fft_or))= or_data_fft;
%     [or_data_fft,a] = deconv(or_data_fft_or_len,e_dec);

    or_data_fft = or_data_fft;
    map_data(:,i)=or_data_fft(1:trace_num1);
    map_data2(:,i)=map_data(1:trace_num1,i);
    fund_max_data(i)=max(seismic_data(:,i));
    back_max_data(i)=max(map_data2(:,i));
end
fid_s_list = fopen('data5/a_out_5_4.bin','wb');
fwrite(fid_s_list,map_data2,"float32");
fclose(fid_s_list);
dt=0.004;
%绘制图像
original_data = dataArray(:,:,seismic_data_num);
[m,n]=size(original_data);
t=0:dt:(m-1)*dt;
for i=1:n
    often(i)=2*(i-1);
end
figure(1);
wigb(original_data,1,often,t);
%改变后的图像;
[m,n]=size(map_data2);
t=0:dt:(m-1)*dt;
for i=1:n
    often2(i)=2*(i-1);
end
figure(2);
wigb(map_data2,1,often2,t);

% 获取最后一道数据画图
original_data_last= original_data(:,501);
data_last = map_data2(:,501);
t=0:dt:(length(original_data_last)-1)*dt;
figure(3)
subplot(5,1,1)
plot(t,original_data_last)
title("读入数据的波形")
hold on;
plot(t,data_last)
title("改变后数据的波形")
% 获取最后一道数据画图
original_data_last= original_data(:,651);
data_last = map_data2(:,651);
t=0:dt:(length(original_data_last)-1)*dt;
subplot(5,1,2)
plot(t,original_data_last)
title("读入数据的波形")
hold on;
plot(t,data_last)
title("改变后数据的波形")
% 获取最后一道数据画图
original_data_last= original_data(:,1001);
data_last = map_data2(:,1001);
t=0:dt:(length(original_data_last)-1)*dt;
subplot(5,1,3)
plot(t,original_data_last)
title("读入数据的波形")
hold on;
plot(t,data_last)
title("改变后数据的波形")

original_data_last_ftt = abs(fft(original_data_last));
data_last_fft = abs(fft(data_last));

fs = 1/dt;
f_x = 0:fs/(length(data_last_fft)-1):fs;

subplot(5,1,4)
plot(f_x(1:end/2),original_data_last_ftt(1:end/2))
title("读入数据的波形fft")
hold on;
plot(f_x(1:end/2),data_last_fft(1:end/2))
title("改变后数据的波形fft")

%最大值画图

subplot(5,1,5)
plot((1:length(fund_max_data)),fund_max_data)
title("读入数据的波形最大")
hold on;
plot((1:length(back_max_data)),back_max_data)
title("改变后数据的波形最大")







