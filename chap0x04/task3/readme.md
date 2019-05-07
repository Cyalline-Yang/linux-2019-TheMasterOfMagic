# 任务要求
- 用bash编写一个文本批处理脚本，对以下附件分别进行批量处理完成相应的数据统计任务
	- [Web服务器访问日志](http://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z)
		- 统计访问来源主机TOP 100和分别对应出现的总次数
		- 统计访问来源主机TOP 100 IP和分别对应出现的总次数
		- 统计最频繁被访问的URL TOP 100
		- 统计不同响应状态码的出现次数和对应百分比
		- 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
		- 给定URL输出TOP 100访问来源主机

# 实施过程
- 根据题意, 处理脚本不需要编写成`shell tool`, 只要能得出统计结果即可
- 任务本身并不难. 但有个问题是, 本来考虑到目标文件较大, 我在处理文件时尽量避免使用`sed`, `awk`等指令, 尽量使用原生`bash`的内容来做字符串替换或数据统计等工作. 结果事实证明这样反而很慢, **在travis上甚至[因为超时而被判定失败](https://travis-ci.org/CUCCS/linux-2019-TheMasterOfMagic/builds/529581446#L569)**, 不得已只能参考其他同学的写法使用`awk`来重写(事实证明术业有专攻, `awk`真的很快).

# 统计结果
- 当不指定url时: [travis](https://travis-ci.org/CUCCS/linux-2019-TheMasterOfMagic/builds/529588975#L567)
- 当指定url时: [travis](https://travis-ci.org/CUCCS/linux-2019-TheMasterOfMagic/builds/529588975#L909)
