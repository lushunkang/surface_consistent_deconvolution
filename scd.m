% 读取数据信息
clc;
clear;
format long;


%每道有多少个数据
trace_num = 752*2-1;
stability_factor = 20;

% 影响因子a

% 炮的起点
num=0;
%用于存放地震数据，每道，这里是101炮，每炮1001道，每道752个数据
dataArray = zeros(752,1001,101);
i=1;

%震源参数
ns=101;
s_list = zeros(trace_num,ns);
s_list_new=zeros(trace_num,ns);

%检波器参数
nr = 1001;
r_list = zeros(trace_num,nr);
r_list_new = zeros(trace_num,nr);

% 中心点参数
ne=nr*2-1;
e_list = zeros(trace_num,ne);
e_list_new = zeros(trace_num,ne);

% 炮检距参数
% nh = nr;
% h_list = zeros(trace_num,nh);
% h_list_new = zeros(trace_num,nh);
nh = nr*2-1;
h_list = zeros(trace_num,nh);
h_list_new = zeros(trace_num,nh);


%炮点和检波器转换距离
ns_nr = (nr-1)/(ns-1);

while num<=10000;
    filename=['data5/shot_',num2str(num),'_rp.bin'];
    fid = fopen(filename,'r');
    [data,count]=fread(fid,[752,1001],'float32');
    dataArray(:,:,i)=data;
%     if(num==5000)
%       fid2 = fopen('daraTest/shot_real2_x5000_topo_rp.bin','r');
%       [data2,count2]=fread(fid2,[752,1001],'float32');
%       dataArray(:,1:50,i)=data2(:,1:50);
%       dataArray(:,1001-50+1:1001,i)=data2(:,1001-50+1:1001);
%       fclose(fid2);
%     end
    i=i+1;
    num=num+10000/(ns-1);
    fclose(fid);
end
dataArray_fft =  zeros(trace_num,nr,ns);

% 将地震数据转换到频率域上
for i= 1:ns;
    for j = 1:nr;
        dataArray_fft_data = fft(dataArray(:,j,i),trace_num);
        dataArray_fft_data = abs(dataArray_fft_data);
        dataArray_fft(:,j,i)=dataArray_fft_data;
    end
end

% 将频率域地震数据求对数
dataArray_fft = log(dataArray_fft);


%迭代次数
iteration_num_data = 50;
iteration_num = 1;
iteration_bool = true;
e_data_last = 0;
%查看误差变化
e_data_list = zeros(0,iteration_num_data);
while iteration_bool && iteration_num<=iteration_num_data;
    iteration_num
    %********************************************************************
    %震源迭代
    %循环每个震源
    for i = 1:ns;
        % 将炮位置变到检波器上
        ns_num = (i-1)*ns_nr+1;
        ns_data = zeros(trace_num,1);
        %循环每个检波器点
        for j = 1:nr;
%               ns_data = ns_data + dataArray_fft(:,j,i)-r_list(:,j)-h_list(:,abs(ns_num-j)+1)-e_list(:,(ns_num+j)-1);
            ns_data = ns_data + dataArray_fft(:,j,i)-r_list(:,j)-e_list(:,(ns_num+j)-1)-h_list(:,ns_num-j+nr);
        end
        ns_data = ns_data/(nr+stability_factor);
        s_list(:,i)=ns_data;
    end
    %********************************************************************

    %********************************************************************
    % 检波器迭代
    % 循环每个检波器
    for j =1:nr;
        nr_num = zeros(trace_num,1);
        %循环每个炮点
        for i = 1:ns;
            ns_num = (i-1)*ns_nr+1;
%             nr_num = nr_num + dataArray_fft(:,j,i)-s_list(:,i)-h_list(:,abs(ns_num-j)+1)-e_list(:,(ns_num+j)-1);
            nr_num = nr_num + dataArray_fft(:,j,i)-s_list(:,i)-e_list(:,(ns_num+j)-1)-h_list(:,ns_num-j+nr);
        end
        nr_num = nr_num/(ns+stability_factor);
        r_list(:,j)=nr_num;
    end
    %********************************************************************

    %********************************************************************
    %中性点迭代
    %循环所有中心点
    for k = 1:ne;
        ne_data=zeros(trace_num,1);
        %中心点位置
        ne_location = k+1;
        % 循环每个炮点寻找对应的检波器点
        ne_num =0 ;
        for i = 1:ns;
            %找到炮中心点和检波器位置；
            ns_num = (i-1)*ns_nr+1;
            j = ne_location-ns_num;
            if j>=1 && j<=nr;
%                 ne_data = ne_data + dataArray_fft(:,j,i)-h_list(:,abs(ns_num-j)+1)-s_list(:,i)-r_list(:,j);
                ne_data = ne_data + dataArray_fft(:,j,i)-h_list(:,ns_num-j+nr)-s_list(:,i)-r_list(:,j);
                ne_num =ne_num+1;
            end
        end
        if ne_num>0;
            e_list(:,k) = ne_data/(ne_num+stability_factor);
        end
    end

    %********************************************************************

    %********************************************************************
    %炮检距迭代
    % 循环所有检距
    for l = 1:nh;
        nh_data=zeros(trace_num,1);
        %         nh_location = l-1;
        nh_location = l-nr;
        nh_num = 0;
        for i = 1:ns;
            ns_num = (i-1)*ns_nr+1;
            j1 = ns_num-nh_location;
            j2 = ns_num+nh_location;
            if(j1>=1 && j1<=801)
                nh_data=nh_data+dataArray_fft(:,j1,i)-s_list(:,i)-r_list(:,j1)-e_list(:,(ns_num+j1)-1);
                nh_num = nh_num+1;
            end
            if(j2>=1 && j2<=801 && j1~=j2)
                nh_data=nh_data+dataArray_fft(:,j2,i)-s_list(:,i)-r_list(:,j2)-e_list(:,(ns_num+j2)-1);
                nh_num =nh_num+1;
            end

            j=ns_num-nh_location;
            if(j>=1&&j<=nr)
                nh_data=nh_data+dataArray_fft(:,j,i)-s_list(:,i)-r_list(:,j)-e_list(:,(ns_num+j)-1);
                nh_num =nh_num+1;
            end
        end
        h_list(:,l) = nh_data/(nh_num+stability_factor);
    end

    %********************************************************************
    %     s_list = s_list_new;
    %     r_list = r_list_new;
    %     e_list = e_list_new;
    %     h_list = h_list_new;
    e= 0;
    for i  =1:ns;
        for j = 1:nr;
            i_num = (i-1)*ns_nr+1;
%             e = e+(dataArray_fft(:,j,i)-s_list(:,i)-r_list(:,j)-e_list(:,(i_num+j)-1)-h_list(:,abs(i_num-j)+1)).^2;
              e = e+(dataArray_fft(1,j,i)-s_list(1,i)-r_list(1,j)-e_list(1,(i_num+j)-1)-h_list(1,i_num-j+nr))^2;
        end
    end
    e_data = e
    %     if abs(e_data)<=1 || e_data_last ==e_data;
    %         iteration_bool = false;
    %     end
    e_data_list(iteration_num)=e_data;
    e_data_last = e_data;
    iteration_num=iteration_num+1;

end

%将每个分量求e的次方
s_list = exp(s_list);
fid_s_list = fopen('data5/s_list_f.bin','wb');
fwrite(fid_s_list,s_list,"double");
fclose(fid_s_list);

r_list = exp(r_list);
fid_r_list = fopen('data5/r_list_f.bin','wb');
fwrite(fid_r_list,r_list,"double");
fclose(fid_r_list);

a=e_list;
e_list = exp(e_list);
fid_e_list = fopen('data5/e_list_f.bin','wb');
fwrite(fid_e_list,e_list,"double");
fclose(fid_e_list);

h_list = exp(h_list);
fid_h_list = fopen('data5/h_list_f.bin','wb');
fwrite(fid_h_list,h_list,"double");
fclose(fid_h_list);

%画出误差图
figure(1)
e_data_list_x=[1:length(e_data_list)];
plot(e_data_list_x,e_data_list);
title("误差变化图");
