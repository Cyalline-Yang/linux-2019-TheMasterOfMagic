# 任务要求
- 用bash编写一个文本批处理脚本，对以下附件分别进行批量处理完成相应的数据统计任务
	- [2014世界杯运动员数据](http://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv)
		- 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
		- 统计不同场上位置的球员数量、百分比
		- 名字最长的球员是谁？名字最短的球员是谁？
		- 年龄最大的球员是谁？年龄最小的球员是谁？

# 实施过程
- 根据题意, 处理脚本不需要编写成`shell tool`, 只要能得出统计结果即可
- 任务本身并不难, 只需逐行读取目标文件, 在条件符合时将相应的变量`+=1`即可

# 统计结果
- 见[travis](https://travis-ci.org/CUCCS/linux-2019-TheMasterOfMagic/builds/529588975#L549)
