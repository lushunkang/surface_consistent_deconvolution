# surface_consistent_deconvolution
surface consistent deconvolution
这里使用的模型是一个长10000的模型，其中每隔100米放炮，检波点每隔10米一个，所以一共有1001个
检波点，101个炮点，每炮所有的检波点都会接收到数据。

首先需要在scd文件中求取各个地表一致性反褶积影响因素算子，
其中要自己设置几个参数：
trace_num=x*2-1，每一道有x数据，这里x*2-1，是为了后面做傅里叶变换而变长的。
stability_factor：一个平衡参数，经验值，看情况填写,stability_factor>=0;
num:炮的起点位置，这里是未来路读取数据方便，我的数据里一共是101炮每炮的数据存放在一个bin文件里
，文件名为（shot_0_rp.bin，shot_100_rp.bin，shot_200_rp.bin...）通过for读取所有的数据。
ns=炮数
nr=检波器个数
ne=中心点个数
nh=炮检距数目个数
最后将算出的每个影响因素的矩阵保存到bin文件里

processingDataTime是做时间域做地表一致性反褶积
processingData是做频率域做地表一致性反褶积


processingDataTime的效果比processingData的好

在processingDataTime当中，
trace_num1=每道数据个数=scd处理中的trace_num中的x；
其它参数和scd中一样
最后得到的结果保存在bin文件中，
最后会掉用wigb这个画图程序；


