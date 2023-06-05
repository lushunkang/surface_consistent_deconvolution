% 读取数据信息
clc;
clear;
% 炮的起点
num=-2000;
ns = 401;
nr = 801;
%炮点和检波器转换距离
ns_nr = (nr-1)/(ns-1);
dataArray = zeros(1024,nr,ns);
i=1; 
while num<=2000;
    filename=['data2/shot_',num2str(num),'_rp.bin'];
    fid = fopen(filename,'r');
    [data,count]=fread(fid,[1024,nr],'float32');
    dataArray(:,:,i)=data;
    i=i+1;
    num=num+4000/(ns-1);
    fclose(fid);
end
dataArray_fft =  zeros(1024,nr,ns);

% 将地震数据转换到频率域上
for i= 1:ns;
    for j = 1:nr;
        dataArray_fft_data = fft(dataArray(:,j,i));
        dataArray_fft(:,j,i)=dataArray_fft_data;
    end
end
% 读取震源影响
fid_s_list = fopen('data2/s_list_f.bin','r');
[s_list,count]=fread(fid_s_list,[1024,ns],'double');
fclose(fid_s_list);
% 读取炮检距影响
fid_h_list = fopen('data2/h_list_f.bin','r');
[h_list,count]=fread(fid_h_list,[1024,nr*2-1],'double');
fclose(fid_h_list);
% 读取中心点影响
fid_e_list = fopen('data2/e_list_f.bin','r');
[e_list,count]=fread(fid_e_list,[1024,nr*2-1],'double');
fclose(fid_e_list);
% 读取检波器影响
fid_r_list = fopen('data2/r_list_f.bin','r');
[r_list,count]=fread(fid_r_list,[1024,nr],'double');
fclose(fid_r_list);

% 抽取第21炮做运算
seismic_data_num = 201;
seismic_data_num_data = (seismic_data_num-1)*ns_nr+1;
seismic_data = dataArray_fft(:,:,seismic_data_num);
% map_data = zeros(1024,801);
% 每一道做反褶积
fund_max_data=zeros(1,801);
back_max_data=zeros(1,801);
for i = 1:801;
    % 求取褶积算子
    or_data_fft_or = dataArray_fft(:,i,seismic_data_num);
%     fft_data = r_list(:,i);
%     fft_data_ifft = ifft(fft_data);
%     fft_data_ifft = 1./(fft_data_ifft);
%     or_data_fft_or=conv(or_data_fft_or,fft_data_ifft);
%     or_data_fft = or_data_fft_or(length(fft_data_ifft)-1:2*length(fft_data_ifft)-1);
    % 检波器
    or_data_fft = or_data_fft_or./r_list(:,i);
    % 炮点
%     or_data_fft = or_data_fft./s_list(:,seismic_data_num);
    %     中心点
%         or_data_fft = or_data_fft./e_list(:,(seismic_data_num_data+i)-1);
    %炮检距
    %方法1
%     or_data_fft = or_data_fft./h_list(:,abs(seismic_data_num_data-i)+1);
    %方法2 ns_num-j+nr
    or_data_fft = or_data_fft./h_list(:,seismic_data_num_data-i+nr);
%     if i <=127 ||i>=801-127;
%         map_data(:,i)=ifft(or_data_fft_or);
%     else
%         map_data(:,i)=ifft(or_data_fft);
%     end

 map_data(:,i)=ifft(or_data_fft);
 fund_max_data(i)=max(dataArray(:,i,seismic_data_num));
 back_max_data(i)=max(map_data(:,i));
end
fid_s_list = fopen('data2/a_out_2_4.bin','wb');
fwrite(fid_s_list,map_data,"float32");
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
[m,n]=size(map_data);
t=0:dt:(m-1)*dt;
for i=1:n
    often2(i)=2*(i-1);
end
figure(2);
wigb(map_data,1,often2,t);

% 获取最后一道数据画图
original_data_last= original_data(:,750);
data_last = map_data(:,750);
t=0:dt:(length(original_data_last)-1)*dt;
figure(3)
subplot(3,1,1)
plot(t,original_data_last)
title("读入数据的波形")
hold on;
plot(t,data_last)
title("改变后数据的波形")

original_data_last_ftt = abs(fft(original_data_last));
data_last_fft = abs(fft(data_last));

fs = 1/dt;
f_x = 0:fs/(length(data_last_fft)-1):fs;

subplot(3,1,2)
plot(f_x(1:end/2),original_data_last_ftt(1:end/2))
title("读入数据的波形fft")
hold on;
plot(f_x(1:end/2),data_last_fft(1:end/2))
title("改变后数据的波形fft")

%最大值画图

subplot(3,1,3)
plot((1:length(fund_max_data)),fund_max_data)
title("读入数据的波形最大")
hold on;
plot((1:length(back_max_data)),back_max_data)
title("改变后数据的波形最大")







