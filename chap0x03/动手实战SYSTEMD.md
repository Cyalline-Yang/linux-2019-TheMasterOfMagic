# 动手实战SYSTEMD
![](images/systemd_structure.png)

# 实验目的
- 学习理解`systemd`管理机制并动手实践相关命令

# 实验环境
```bash
kaizhangzhong@ubuntu:~$ uname -a
Linux ubuntu 4.13.0-36-generic #40~16.04.1-Ubuntu SMP Fri Feb 16 23:25:58 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
```

# 实验过程
[![asciicast](https://asciinema.org/a/MbtFoXq6YHyWnPXktUmTmH7MO.svg)](https://asciinema.org/a/MbtFoXq6YHyWnPXktUmTmH7MO)
	

# 实验结果
- 见上

# 自查清单
- 如何添加一个用户并使其具备sudo执行程序的权限？
	- 执行`sudo adduser <用户名>`以添加用户
	- 执行`sudo adduser <用户名> sudo`以将其加入`sudo`用户组, 进而使其得到`sudo`权限
- 如何将一个用户添加到一个用户组？
	- `sudo adduser <用户名> <组名>`
- 如何查看当前系统的分区表和文件系统详细信息？
	- `sudo sfdisk -l`
- 如何实现开机自动挂载Virtualbox的共享目录分区？
	- 首先在VB界面设置共享目录, 假如目录名为`vb_sf`
	- 在`Ubuntu`里选择一个用于挂载的路径, 比如`/mnt/vb_sf`
	- 在`Ubuntu`中以`sudo`权限在`/etc/fstab`文件末尾添加一行:`vb_sf /mnt/vb_sf vboxsf defaults 0 0`
- 基于LVM（逻辑分卷管理）的分区如何实现动态扩容和缩减容量？
	- 首先需要安装`lvm2`软件包: `sudo apt install lvm2`
	- 安装好后切换至`root`用户, 否则需要在每条指令前加`sudo`
	- 查看逻辑卷信息: `lvdisplay`
	- 扩容: `lvextend --size +<大小>m <逻辑卷>`
	- 缩容: `lvreduce --size -<大小>m <逻辑卷>`
- 如何通过systemd设置实现在网络连通时运行一个指定脚本，在网络断开时运行另一个脚本？
	- (未能验证)可能存在这样一个服务, 当网络连通时启动, 当网络断开时停止? 如果有, 那么在其配置文件的`[Service]`区块中相应添加`ExecStartPost`字段和`ExecStopPost`即可.
- 如何通过systemd设置实现一个脚本在任何情况下被杀死之后会立即重新启动？实现杀不死？
	- 编写对应的`.service`文件, 将`[Service]`区块的`Restart`字段设置为`always`即可